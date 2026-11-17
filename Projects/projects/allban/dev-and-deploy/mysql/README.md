---
description: PC방 관리 프로그램(레거시 시스템)의 로컬 루프백 트래픽에서 실시간 주문 데이터를 추출하는 것.
---

# 네트워크 패킷 분석 및 MySQL 디코딩

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-007-DO |
| 유형 | D&O (분석 회고) |
| 목적 | MySQL 바이너리 프로토콜 패킷에서 주문 데이터(좌석 번호, 결제 총액)를 추출한 방식을 설명한다 |
| 적용 환경 | Windows 10/11, MariaDB 10.0.16, Npcap Loopback Adapter |
| 확인 상태 | 미검증 (원본 분석 기록을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="warning" %}
CAUTION: 이 문서는 기존 PC방 관리 프로그램(레거시 시스템)의 DB 트래픽을 가로채 실시간 주문 알림을 만든 기록이다. 대상 프로그램의 이용 약관과 계약상 허용 여부는 원본에 없다. 같은 방식을 쓰기 전에 확인한다. DB 접속 계정, 비밀번호, 호스트 값은 이 문서에 적지 않았다(`<값 생략>`).
{% endhint %}

## 1. 목적과 초기 문제

- 목적: 레거시 시스템의 DB 트래픽을 가로채 실시간 주문 알림 시스템을 구현한다.
- 초기 문제: Wireshark에서는 패킷이 보이지만 파이썬(Pyshark/Scapy) 스크립트에서는 주문 데이터(좌석 번호, 상품명 등)가 텍스트로 나오지 않아 추출에 실패했다.

## 2. 장애 요인

| 번호 | 요인 | 내용 |
|---|---|---|
| 1 | 바이너리 프로토콜 | 대상 시스템은 일반 `COM_QUERY(0x03)`가 아니라 Prepared Statement를 쓴다. 값이 `COM_STMT_EXECUTE(0x17, Type 23)` 명령으로 전달되며 사람이 읽을 수 없는 바이너리로 인코딩된다 |
| 2 | TCP 세그먼트 파편화 | 주문 데이터가 길면 하나의 MySQL 패킷이 여러 TCP 세그먼트로 쪼개진다. 재조합(Reassembly) 없이는 MySQL 레이어의 필드(`stmt_id`, parameters)에 접근할 수 없다 |

## 3. 구성 요소와 설정

| 구성 요소 | 설정·역할 |
|---|---|
| Statement ID 캐시 | `COM_STMT_PREPARE(22)` 패킷에서 쿼리에 `tb_order` 등이 포함되면 해당 `stmt_id`를 메모리(`dict`)에 저장한다 |
| 실행 패킷 매칭 | `COM_STMT_EXECUTE(23)` 패킷의 ID가 저장된 ID와 같으면 주문 데이터로 판단한다 |
| Tshark 재조합 설정 | `tcp.desegment_tcp_streams`: TRUE (쪼개진 TCP 스트림 재조합) |
| | `mysql.desegment_buffers`: TRUE (MySQL 버퍼 재조합) |
| | `decode_as`: 포트 3306을 MySQL 프로토콜로 강제 해석 |
| 파라미터 인덱스 | PDML 분석 결과에 따른 바이너리 필드 위치. Index 9: 좌석 번호, Index 7: 결제 총액. `mysql.value.all_fields` 또는 `mysql.string.all_fields`를 리스트로 만들어 해당 위치 값을 추출한다 |

{% hint style="info" %}
NOTE: 원본은 "PREPARE 패킷의 `stmt_id`를 저장한다"고 적었다. MySQL 프로토콜에서 `stmt_id`는 서버가 PREPARE에 응답할 때 부여한다. 요청 패킷이 아니라 응답 패킷에서 얻는지는 원본으로 판단할 수 없어 확인이 필요하다.
{% endhint %}

## 4. 동작 원리

1. 루프백 어댑터를 찾는다. 방법은 [루프백 어댑터 자동 탐색 구현 (Npcap)](get_tshark_interfaces.md)(PRJ-ALB-008-REF)에 있다.
2. Tshark 재조합 설정으로 파편화된 패킷을 합친다.
3. `COM_STMT_PREPARE`에서 `tb_order` 쿼리의 `stmt_id`를 저장한다.
4. `COM_STMT_EXECUTE`에서 저장한 ID와 같은 패킷을 주문으로 판단한다.
5. 바이너리 파라미터에서 좌석 번호와 결제 총액을 인덱스로 꺼낸다.
6. 꺼낸 데이터를 큐에 넣어 서버로 보낸다. 구조는 [큐 기반 비동기 데이터 동기화 (Queue)](../queue.md)(PRJ-ALB-005-DO)에 있다.

## 5. 시행착오

| 증상 | 원인 | 해결 |
|---|---|---|
| 인터페이스 경로 탐색 실패 | Windows에서 Npcap 루프백 어댑터 이름이 시스템마다 다르다(`\Device\NPF_Loopback` 등) | `get_tshark_interfaces()`로 런타임에 "loopback"이 들어간 GUID를 자동 검색한다 |
| [실시간 로그 출력 지연](realtime-output-delay.md) (PRJ-ALB-009-TS) | 파이썬 표준 출력 버퍼링과 Dart `Process.start`의 스트림 간섭 | 파이썬 실행 옵션에 `-u`를 추가하고 Dart에서 `LineSplitter`로 줄 단위 로그를 복원한다 |

## 6. 결과와 근거

- MySQL Internals 명세를 따랐다. Binary Protocol의 `Null Bitmap` 이후 데이터 배치 규칙을 적용해 데이터 무결성을 확보했다.
- 패킷 수집과 서버 전송을 분리하려고 `queue.Queue`와 `threading`을 도입했다(유니티 서버급의 비동기 소켓 처리 흐름이라는 것이 원본의 설명이다).

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| Prepared Statement | 쿼리 틀을 먼저 서버에 등록하고 값만 바꿔 실행하는 방식 |
| `COM_STMT_PREPARE` (22) | 쿼리 틀 등록 명령 |
| `COM_STMT_EXECUTE` (23) | 등록한 쿼리를 값과 함께 실행하는 명령 |
| `COM_QUERY` (3) | 일반 텍스트 쿼리 명령 |
| PDML | Packet Details Markup Language, Wireshark의 패킷 상세 XML 출력 |
| Null Bitmap | 파라미터별 NULL 여부를 나타내는 비트 배열 |
| Npcap | Windows용 패킷 캡처 드라이버 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Wireshark에서는 보이는데 스크립트에서는 보이지 않았던 이유를 내 말로 설명하면?
- [ ] 이 방식의 법적·약관상 위험을 어떻게 판단했는가?
- [ ] 패킷 분석 중 가장 오래 막혔던 단계는 어디였는가?
