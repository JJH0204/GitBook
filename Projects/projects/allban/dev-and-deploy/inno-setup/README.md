---
description: 복잡한 의존성(Npcap, Tailscale, Python Assets)을 포함한 단일 설치 파일 제작.
---

# 인스톨러 구축 및 배포 자동화 (Inno Setup)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-012-REF |
| 유형 | REF (요구사항·설정 항목 표) + 문제·해결 표 |
| 목적 | 올반 서버 설치 프로그램의 요구사항, Inno Setup 설정 항목, 만났던 문제와 해결을 찾아 쓴다 |
| 적용 환경 | Windows, Inno Setup, 설치 대상: Dart(Flutter) 서버 + 임베디드 파이썬 |
| 확인 상태 | 미검증 (원본 기록을 정리한 것이며 설치 프로그램을 빌드하거나 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 NSSM으로 서비스를 등록하던 시점의 기록이다. 이후 NSSM을 제외했다([NSSM 서비스 관리 전환 (NSSM)](neem.exe.md), PRJ-ALB-013-DO). 설치 경로, 서비스 계정, 레지스트리 값은 `<값 생략>`으로 둔다.
{% endhint %}

## 1. 요구사항

| 번호 | 요구사항 | 내용 |
|---|---|---|
| 1 | 목적 | 주방 현장의 다양한 PC에서 사용자 개입 없이 서버와 패킷 스니퍼가 바로 가동되게 패키징한다 |
| 2 | 도구 | Inno Setup(인스톨러 제작), NSSM(Windows 서비스 등록) |
| 3 | 자동 실행 | Windows 시작 시 백그라운드 서비스로 자동 실행한다 |
| 4 | 필수 런타임 | Npcap, Tailscale, VC++ Redist를 자동 확인하고 안내한다 |
| 5 | 무결성 | 임베디드 파이썬과 에셋을 그대로 유지한다 |

## 2. 설치 구조와 설정 항목

설치 후 폴더 구조다. `{app}`은 Inno Setup의 설치 폴더 상수이며, 실제 경로는 `<값 생략>`이다.

| 경로 | 내용 |
|---|---|
| `{app}\AllbenServer.exe` | 빌드된 Flutter 서버 |
| `{app}\python_runtime\` | 임베디드 파이썬 런타임 |
| `{app}\python_assets\` | 스니핑 스크립트와 에셋 |

설정 항목이다.

| 구역·이벤트 | 설정 | 목적 |
|---|---|---|
| `[Setup]` | `PrivilegesRequired=admin` | 설치 시작 시점부터 관리자 권한을 확보해 서비스 등록 실패를 막는다 |
| `[Code]` `InitializeSetup` | 레지스트리 키 `SOFTWARE\Npcap` 등의 존재 여부 확인 | 필수 인프라(Npcap 등)가 없으면 공식 다운로드 페이지로 안내한다 |
| `[Run]` | `nssm set AllbenServer AppDirectory "{app}"` | 서비스 작업 디렉터리를 설치 폴더로 지정한다 |
| `[Run]` (NSSM 로그) | `AppStdout`, `AppStderr` 파라미터 | 표준 출력과 오류를 지정한 로그 파일로 남긴다 |
| `[UninstallRun]` | `stop` 후 `remove` + `confirm` 플래그 | 서비스를 멈춘 뒤 사용자 개입 없이 삭제한다 |

{% hint style="info" %}
NOTE: 원본은 스크립트 전문을 싣지 않았다. 위 표는 원본이 언급한 항목만 옮긴 것이다. `AppId`, 파일 복사(`[Files]`), 레지스트리 쓰기(`[Registry]`)의 실제 값은 원본에 없다. Tailscale과 VC++ Redist를 어떻게 확인했는지도 원본에 없다(Npcap 키만 언급). 확인이 필요하다.
{% endhint %}

## 3. 문제와 해결

| 번호 | 문제 | 원인 | 해결 |
|---|---|---|---|
| 1 | 서버(`AllbenServer.exe`)가 자기 폴더를 인식하지 못해 하위 `python_assets`를 찾지 못한다 | 서비스로 실행하면 작업 디렉터리가 `C:\Windows\System32`로 고정되는 Windows 서비스의 특성 | `[Run]`에서 NSSM `AppDirectory`를 `{app}`으로 지정한다 |
| 2 | 업데이트 설치 때 기존 서비스가 멈추지 않거나, 삭제 후에도 서비스 목록에 남아 재설치를 막는다 | 서비스 중지 없이 삭제를 시도한다 | `[UninstallRun]`에서 `remove` 전에 `stop`을 먼저 실행하고 `confirm` 플래그를 붙인다 |
| 3 | 서비스 실행 중 파이썬 로그가 남지 않는다 | NSSM 서비스에는 콘솔 창이 없어 표준 출력이 사라진다 | NSSM `AppStdout`, `AppStderr`로 로그 파일 경로를 지정한다 |
| 4 | 관리자 권한이 부족해 서비스 등록에 실패한다 | 일반 권한으로 설치가 시작된다 | `PrivilegesRequired=admin`을 명시한다 |

## 4. 설계 원칙

1. 서비스 안정화: NSSM에서 `AppDirectory`를 빠뜨리면 모든 상대 경로 로직이 깨진다.
2. 의존성 가시성: 무엇이 부족해서 실행되지 않는지 사용자가 알 수 있게 사전 확인 로직을 넣는다.
3. 클린 언인스톨: 서비스 등록만큼 서비스의 완전한 제거가 중요하다.

{% hint style="warning" %}
CAUTION: 설치 프로그램이 관리자 권한으로 서비스를 등록하고 레지스트리를 읽는다. 출처가 불분명한 바이너리를 같은 방식으로 포함하지 않는다. 이 판단은 NSSM 제외 결정과 같은 맥락이다.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| Inno Setup | Windows 설치 프로그램 제작 도구 |
| NSSM | Non-Sucking Service Manager, 일반 실행 파일을 Windows 서비스로 등록하는 도구 |
| `{app}` | Inno Setup이 설치 폴더로 치환하는 상수 |
| `[Run]`, `[UninstallRun]` | 설치 후, 제거 시 실행할 명령을 적는 구역 |
| Npcap | Windows용 패킷 캡처 드라이버 |
| VC++ Redist | Visual C++ 재배포 가능 패키지 |
