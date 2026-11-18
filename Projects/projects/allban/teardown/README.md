# Allban 해체 분석

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-100-DO |
| 유형 | D&O (소스 해체 분석 시리즈 안내) |
| 목적 | Allban(AllbenKitchenManager)의 소스 구조 지도를 보이고, 영역별 해체 페이지의 읽는 순서를 안내한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 빌드·실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

Allban은 PC방 주방용 주문 표시 시스템(KDS)이다. Windows 관리 프로그램(Flutter, 내부 HTTP·WebSocket 서버)이 메뉴와 주문을 들고, Android 태블릿 앱이 주문을 받아 조리 타이머와 레시피를 보여 준다. 주문은 기존 PC방 관리 프로그램의 DB 통신을 패킷으로 관찰해 얻는 구조이며, 이를 위해 Python 스니퍼를 관리 프로그램의 자식 프로세스로 띄운다. 이 시리즈는 그 소스를 "따라 만들 수 있게" 구성 요소 → 데이터 흐름 → 구현 순서로 해체한다.

{% hint style="info" %}
NOTE: 소스는 공개 레포 [JJH0204/AllbenKitchenManager](https://github.com/JJH0204/AllbenKitchenManager)다. 기획·UI/UX·설계 회고는 이미 [올반 프로젝트 (Allban)](../README.md)에 있으므로 이 시리즈는 겹치지 않게 소스 구조만 다룬다.
{% endhint %}

{% hint style="warning" %}
WARNING: 모든 동작 설명은 소스를 읽고 판단한 것이며 실행해 확인하지 않았다(미검증). 접속 주소, 계정, 대상 시스템의 테이블·컬럼 이름은 문서에 적지 않았다(`<값 생략>`). 패킷 분석은 구조와 방어 관점으로만 설명한다.
{% endhint %}

## 구조 지도

| 디렉터리 | 역할 | 해설 페이지 |
|---|---|---|
| `admin_console/` | Windows 관리 프로그램(Flutter). 메뉴·주문 관리, `shelf` 기반 HTTP·WebSocket 서버, 스니퍼 프로세스 실행·종료 | [큐 동기화](queue-sync.md), [KDS 통신 규약](kds-protocol.md) |
| `android_app/` | 주방 태블릿 앱(Flutter). WebSocket으로 주문 수신, 조리 타이머, 레시피, 초성 검색 | [KDS 통신 규약](kds-protocol.md) |
| `python_packetSnip/` | 패킷 스니퍼. `main.py`(pyshark, 서버 전송용)와 `scapy_main.py`(Scapy, 자체 MySQL 디코더) | [패킷 분석](packet-sniffer.md), [큐 동기화](queue-sync.md) |
| `bat/` | `deploy_windows.bat`(빌드 → 에셋 복사 → 인스톨러), `run_scapy_sniffer.bat`(스니퍼 단독 실행). `deploy_py.bat`은 빈 파일 | [인스톨러와 배포](installer.md) |
| `innoSetup/` | `setup_script.iss`(관리 프로그램), `scapy_sniffer_setup.iss`(스니퍼 단독) | [인스톨러와 배포](installer.md) |
| `python_runtime/` | 임베디드 파이썬 사본 (분석에서 제외) | |

| 항목 | 내용 | 출처 |
|---|---|---|
| 언어·프레임워크 | Dart/Flutter(두 앱), Python(스니퍼), Inno Setup 스크립트, 배치 파일 | 소스 |
| 서버 | `shelf`, `shelf_static`, `shelf_web_socket`. 모든 인터페이스에 바인드, 기본 포트 8080 | `admin_console/lib/services/server_service.dart`, `storage_service.dart` |
| 상태 관리 | 양쪽 모두 `provider`(`ChangeNotifier`) | `pubspec.yaml` |
| 코드 규모 | UI 위젯을 뺀 `lib/`: 관리 프로그램 약 1,200줄(서버 서비스 445), 태블릿 약 1,000줄(`kitchen_provider.dart` 590), 스니퍼 `main.py` 170줄·`scapy_main.py` 402줄 | `wc -l` |
| 저장 | 관리: 앱 지원 폴더의 `menus.json`·`images/`, 설정은 `shared_preferences`. 태블릿: 서버 주소·마지막 데이터 캐시 | `storage_service.dart` 두 개 |

## 전체 구조 그림

```
 [기존 PC방 관리 프로그램] <--MySQL(루프백)--> [DB]
            |                         ^
            |  (같은 루프백 트래픽을 읽기만 한다)
            v
 [python_packetSnip]  Npcap 루프백 어댑터 캡처
   main.py: pyshark(tshark) -> 주문 추정 -> queue.Queue -> 워커 스레드
            |  HTTP POST /api/external_order
            v
 [admin_console] Dart 서버 (shelf, 0.0.0.0:8080)
   - HTTP: /api/kitchen_data, /api/external_order, /images/*
   - WS  : /ws  (ACK, PING/PONG, 주문 생성·삭제, 메뉴 동기화)
   - 스니퍼를 Process.start 로 띄우고 종료 때 taskkill /T /F
            |  WebSocket JSON
            v
 [android_app] 태블릿: 주문 카드, 조리 타이머, 레시피, 캐시
```

핵심 설계는 세 가지다.

1. **수집과 전송을 큐로 분리**: 스니퍼 엔진은 전송 지연과 상관없이 계속 패킷을 읽는다.
2. **서버가 스니퍼의 부모**: 관리 프로그램을 켜면 스니퍼가 자동으로 뜨고, 끄면 프로세스 트리째 사라진다.
3. **태블릿은 오프라인 캐시**: 마지막으로 받은 데이터를 파일에 저장해 서버가 없어도 화면을 띄운다.

{% hint style="warning" %}
WARNING: 이 스냅샷에서는 스니퍼에서 서버로 간 주문이 태블릿까지 이어지지 않는다. 서버의 `/api/external_order` 핸들러는 본문을 파싱해 로그만 남기고 주문을 만들지 않는다. 자세한 내용은 [큐 동기화](queue-sync.md)의 한계 절에 있다.
{% endhint %}

## 읽는 순서

1. [패킷 분석](packet-sniffer.md): 주문 정보가 어디서 어떻게 나오는지 본다.
2. [큐 동기화](queue-sync.md): 수집한 데이터를 전송하는 큐 구조와 서버의 자식 프로세스 관리를 본다.
3. [KDS 통신 규약](kds-protocol.md): 서버와 태블릿이 주고받는 메시지와 데이터 모양을 본다.
4. [인스톨러와 배포](installer.md): 빌드부터 설치 파일까지의 순서를 본다.

## 페이지 목록

| 페이지 | Task ID | 유형 | 내용 |
|---|---|---|---|
| [queue-sync.md](queue-sync.md) | PRJ-ALB-101-DO | D&O | 스니퍼 큐, 전송 워커, 서버 수신, 프로세스 생명주기 |
| [packet-sniffer.md](packet-sniffer.md) | PRJ-ALB-102-DO | D&O | 두 스니퍼의 MySQL 바이너리 프로토콜 해석 구조 |
| [installer.md](installer.md) | PRJ-ALB-103-REF | REF | 배포 배치 파일과 Inno Setup 스크립트 두 개 |
| [kds-protocol.md](kds-protocol.md) | PRJ-ALB-104-REF | REF | HTTP·WebSocket 메시지 표, 주문·메뉴 모델 |

## 확인 필요

- 기존 회고 문서는 NSSM 서비스 등록을 전제로 쓴 부분이 있으나, 이 스냅샷의 `.iss`에는 NSSM 설정이 없고 서버가 스니퍼를 직접 실행한다. 최종 채택 구조는 확인이 필요하다.
- 레포의 `python_packetSnip/log/raw_packet_log.txt`는 실제 캡처로 보이는 로그다. 대상 시스템의 쿼리가 들어 있어 이 시리즈에서는 인용하지 않았다. 공개 레포에 두어도 되는지 확인이 필요하다.
- 레포에 단위 테스트는 없다(Flutter 기본 테스트 파일 제외).

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 주문 정보를 DB 트래픽에서 얻기로 한 이유와 다른 선택지를 내 말로 적어 보자.
- [ ] 관리 프로그램이 서버, 스니퍼의 부모, 설정 UI를 한꺼번에 맡은 구조의 장단점을 적어 보자.
- [ ] 이 소스를 처음부터 다시 만든다면 가장 먼저 바꿀 부분을 적어 보자.
