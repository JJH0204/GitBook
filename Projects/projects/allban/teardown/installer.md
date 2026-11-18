# Allban 인스톨러와 배포

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-103-REF |
| 유형 | REF (스크립트 구성 표) + 빌드 순서 해설 |
| 목적 | `bat/`와 `innoSetup/`의 스크립트가 관리 프로그램과 스니퍼를 어떻게 패키징하는지 단계별로 정리한다 |
| 확인 상태 | 미검증 (스크립트를 읽고 쓴 것이며 빌드·설치를 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | PRJ-ALB-100-DO | Allban 해체 분석 |
| [queue-sync.md](queue-sync.md) | PRJ-ALB-101-DO | Allban 큐 동기화와 프로세스 관리 |
| [인스톨러 구축 및 배포 자동화 (Inno Setup)](../dev-and-deploy/inno-setup/README.md) | PRJ-ALB-012-REF | 요구사항과 NSSM 시점의 기록 |
| [임베디드 파이썬 환경 구축 (Python)](../dev-and-deploy/embeddable-python.md) | PRJ-ALB-010-DO | 임베디드 파이썬 구성 회고 |

{% hint style="info" %}
NOTE: 이 페이지는 `.iss`와 `.bat`의 실제 내용을 기준으로 한다. 레포 안에 임베디드 파이썬 폴더, 의존 설치 파일(`dependencies/`), 빌드 산출물(`.exe`)이 있으나 읽지 않았다.
{% endhint %}

## 이 영역이 하는 일

설치 파일을 두 종류 만든다.

| 설치 파일 | 스크립트 | 내용 |
|---|---|---|
| 관리 프로그램 설치기(v2.0) | `innoSetup/setup_script.iss` | Flutter 릴리스 폴더 전체(파이썬 에셋 포함) + VC++ 재배포 패키지 |
| 스니퍼 단독 설치기(v1.0) | `innoSetup/scapy_sniffer_setup.iss` | 임베디드 파이썬 + `scapy_main.py` + 실행 배치 |

## 구성 요소

| 파일 | 역할 |
|---|---|
| `bat/deploy_windows.bat` | 5단계 배포 자동화: 빌드, 폴더 정리, 파이썬 복사, 스크립트 복사, 인스톨러 컴파일 |
| `bat/run_scapy_sniffer.bat` | 관리자 권한 확인 후 `..\python_runtime\python.exe ..\python_packetSnip\scapy_main.py` 실행 |
| `bat/deploy_py.bat` | 빈 파일(0바이트) |
| `innoSetup/setup_script.iss` | 관리 프로그램 설치기 |
| `innoSetup/scapy_sniffer_setup.iss` | 스니퍼 단독 설치기 |

## 데이터 흐름

```
 deploy_windows.bat
   [1/5] admin_console 에서 flutter build windows --release
   [2/5] build\windows\x64\runner\Release\python_assets 를 비우고 새로 만든다
   [3/5] python_runtime\  ->  python_assets\python\   (xcopy)   python.exe 존재 확인, 없으면 중단
   [4/5] python_packetSnip\main.py, requirements.txt -> python_assets\
   [5/5] ISCC.exe innoSetup\setup_script.iss  ->  Allben_Setup_v2.0.exe

 설치 폴더(설치 후)
   <앱 폴더>\(Flutter 릴리스 산출물)
   <앱 폴더>\python_assets\python\python.exe   <-- 서버의 _pythonPath 가 1순위로 찾는 위치
   <앱 폴더>\python_assets\main.py             <-- 서버의 _scriptPath 가 1순위로 찾는 위치
```

서버 코드가 찾는 경로([큐 동기화](queue-sync.md))와 배치 파일이 만드는 경로가 서로 맞는다는 점이 핵심이다.

## `setup_script.iss` 해설

| 구역 | 내용 |
|---|---|
| `[Setup]` | 앱 이름·버전 2.0, 설치 폴더는 Program Files 아래, 출력 파일명 `Allben_Setup_v2.0`, `lzma` 압축, `PrivilegesRequired=admin`, 한국어·영어 지원 |
| `[Files]` | Flutter 릴리스 폴더 전체를 설치 폴더로(하위 폴더 포함). `dependencies\VC_redist.x64.exe`는 임시 폴더로 풀고 설치 후 삭제 |
| `[Icons]` | 시작 메뉴·제거·(선택) 바탕화면 아이콘. 실행 파일 이름은 `AllbenKitchenAdmin.exe` |
| `[Run]` | `VC_redist.x64.exe /quiet /install`을 끝날 때까지 기다린다 |
| `[Code]` `InitializeSetup` | 레지스트리로 Npcap, Wireshark(TShark), Tailscale 설치 여부를 확인하고, 없으면 공식 다운로드 페이지를 열지 묻는다 |

`InitializeSetup`의 구조는 "없으면 안내하고 설치를 중단한다(`Result := False`)"이다. 세 개의 확인이 순서대로 걸려 있고, 앞 검사에서 실패하면 뒤 검사는 건너뛴다.

## `scapy_sniffer_setup.iss` 해설

| 구역 | 내용 |
|---|---|
| `[Setup]` | 상수(`#define`)로 이름·버전·게시자를 정의, 출력 파일명 `AllbenScapySniffer_Setup`, 관리자 권한 필수 |
| `[Files]` | `python_runtime\`, `scapy_main.py`, `run_scapy_sniffer.bat`을 각각 설치 폴더의 하위로 복사 |
| `[Icons]` | 시작 메뉴·바탕화면 바로가기가 배치 파일을 가리킨다 |
| `[Run]` | 설치 후 배치 파일을 바로 실행하는 선택 항목(조용한 설치에서는 건너뜀) |

## 따라 만들기

`확인 상태: 미검증`

| 단계 | 할 일 | 기대 결과 |
|---|---|---|
| 1 | Flutter 데스크톱 앱을 `flutter build windows --release`로 빌드한다 | `build\windows\x64\runner\Release`에 실행 파일이 생긴다 |
| 2 | 그 폴더 아래에 `python_assets\python\`을 만들고 임베디드 파이썬 사본을 복사한다 | `python.exe`가 그 위치에 있다 |
| 3 | 스니퍼 스크립트를 `python_assets\`에 복사한다 | 서버 코드가 찾는 경로와 같아진다 |
| 4 | 필요한 파이썬 패키지(`pyshark`, `requests`, 또는 `scapy`)가 임베디드 파이썬에 들어 있게 한다 | 파이썬에서 `import`가 성공한다 |
| 5 | `.iss`의 `[Files]`에 릴리스 폴더를 `recursesubdirs`로 넣고 `PrivilegesRequired=admin`을 지정한다 | 컴파일하면 설치 파일이 나온다 |
| 6 | `[Code]`에서 Npcap 등의 레지스트리 키를 확인해 없으면 안내한다 | 필수 도구가 없는 PC에서 설치가 안내와 함께 멈춘다 |
| 7 | `ISCC.exe`를 배치 파일에서 호출하고 `ERRORLEVEL`로 실패를 감지한다 | 한 번의 실행으로 설치 파일이 만들어진다 |
| 8 | 깨끗한 PC에서 설치하고 서버를 켜서 스니퍼 로그가 대시보드에 나오는지 본다 | 서버를 끄면 `tshark.exe`가 남지 않는다 |

## 알려진 한계·주의

| 번호 | 내용 |
|---|---|
| 1 | `InitializeSetup`의 Tailscale 검사 주석은 "선택 사항(권장)"인데 코드는 `Result := False`로 설치를 중단한다. 주석과 동작이 어긋난다 |
| 2 | 설치기는 Wireshark(TShark)를 필수로 확인하는데, 스니퍼 단독 설치기가 쓰는 `scapy_main.py`는 TShark를 쓰지 않는다. 관리 프로그램 설치기가 쓰는 `main.py`(pyshark)만 TShark가 필요하다 |
| 3 | `deploy_windows.bat`은 `main.py`(pyshark)를 복사하는데 `requirements.txt`에는 `scapy`만 있다. 임베디드 파이썬에 `pyshark`가 들어 있는지는 배치가 확인하지 않는다 |
| 4 | `deploy_windows.bat`의 Inno Setup 경로는 기본 설치 위치로 고정돼 있다 |
| 5 | 이 스냅샷의 `.iss`에는 NSSM 서비스 등록이 없다. 서버가 스니퍼를 직접 실행한다. 기존 회고의 NSSM 서술과 시점이 다르다 |
| 6 | 설치 실행 파일 이름은 `AllbenKitchenAdmin.exe`로 지정돼 있다. 빌드 산출물의 실제 이름이 같은지는 읽지 않았다(확인 필요) |
| 7 | 스니퍼 단독 실행 배치는 `openfiles`로 관리자 권한을 확인한다. 서버가 자식으로 실행하면 서버 프로세스의 권한을 이어받는다. 필요한 권한 수준은 확인이 필요하다 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |
