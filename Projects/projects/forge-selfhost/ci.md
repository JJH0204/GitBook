# forge CI 해체 분석: 가드레일·Unity 빌드·설치 마법사

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-FRG-104-DO |
| 유형 | D&O (해체 분석, 따라 만들기 절차 포함) |
| 목적 | 저장소 가드레일 검사, 태그로 시작하는 Windows 빌드, 설치 마법사 생성, 배포 알림의 구조를 보이고 따라 만들 수 있게 한다 |
| 확인 상태 | 미검증 (워크플로와 스크립트를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 참조

| 참조 문서 | 내용 |
|---|---|
| [무인 운영 해체 분석](operations.md) | 러너 감독과 헬스체크 |
| [설치·실행 런처 해체 분석](launcher.md) | 릴리스를 받아 설치하는 클라이언트 |
| [도입 과정](process.md) | CI를 도입한 배경 |

{% hint style="danger" %}
WARNING: 원본 `ci/build.yml`에는 알림 웹훅 주소가 값 그대로 들어 있고, 서버 도메인과 조직·저장소 이름도 들어 있다. 이 문서는 그 값을 옮기지 않았다. 따라 만들 때는 웹훅을 저장소 비밀(Secrets)로 두고, 이미 노출된 웹훅은 서비스에서 삭제 후 재발급해야 한다. 값을 바꾸는 것만으로는 히스토리에 남은 이전 값이 무효화되지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 서버 주소, 조직·저장소 이름, 게임 이름과 실행 파일 이름, 게시자 이름, 설치 프로그램 식별자(GUID), 경로의 사용자·드라이브 배치는 일반화하거나 뺐다.
{% endhint %}

## 이 영역이 하는 일

CI는 워크플로 두 개와 보조 파일로 이루어진다.

| 워크플로 | 트리거 | 러너 | 하는 일 |
|---|---|---|---|
| Guardrails | 모든 push, pull request | Linux 컨테이너 러너 | 되돌리기 어려운 사고(LFS 누락, `.meta` 누락, GUID 중복 등)를 막는다 |
| Build Windows | `v*`, `debug-*` 태그, 수동 실행 | Windows 네이티브 러너(host 모드) | Unity 빌드, 산출물 보관, 설치 파일 생성, 릴리스 업로드, 선택적 Steam 업로드, 알림 |

## 구성 요소

| 파일 | 배치 위치(저장소 기준) | 역할 |
|---|---|---|
| `ci/guardrails.yml` | `.gitea/workflows/guardrails.yml` | 가드레일 워크플로 |
| `ci/guardrails.sh` | `.gitea/scripts/guardrails.sh` | LFS, 대용량 파일, `.meta` 누락 검사 |
| `ci/project-rules.sh` | `.gitea/scripts/project-rules.sh` | GUID 중복, 산출물 디렉터리, 파일명, 대소문자 중복, 씬 동시 수정 검사 |
| `ci/build.yml` | `.gitea/workflows/build.yml` | 빌드와 배포 워크플로 |
| `ci/CIBuild.cs` | `Assets/Editor/CIBuild.cs` | Unity 배치 모드 빌드 진입점 |
| `ci/installer.iss` | `.gitea/installer.iss` | Inno Setup 설치 마법사 정의 |
| `scripts/make-installer-local.ps1` | 서버 쪽 | 설치 정의만 고쳤을 때 Unity 산출물로 설치 파일만 다시 만든다 |
| `scripts/verify-cibuild-compile.ps1`, `verify-installer.ps1` | 서버 쪽 | 빌드 작업 폴더를 건드리지 않고 별도 사본에서 컴파일·설치 정의를 검증한다 |

## 데이터 흐름

```
 push / PR ---------> [Guardrails]
                        체크아웃(LFS 객체는 받지 않음, 전체 히스토리) -> 기준 커밋 결정
                        -> guardrails.sh -> Unity CLI projects verify -> project-rules.sh
                        (앞 단계가 실패해도 다음 단계를 실행해 한 번에 모든 문제를 보인다)

 태그 v* / debug-* --> [Build Windows] (Windows 러너, 고정 경로 작업 폴더)
   동기화(강제 체크아웃, HEAD 대조) -> 모드·버전 결정 -> Unity CLI 준비
   -> Unity 빌드(CIBuild.BuildWindows64) -> 산출물 보관(최근 5개만 유지)
   -> 설치 파일 생성(Inno Setup) -> 릴리스 업로드(태그일 때만, debug는 사전 릴리스)
   -> Steam 비공개 브랜치 업로드(변수가 있을 때만) -> 성공 표시 -> 알림(항상, 실패해도 빌드 결과에 영향 없음)
```

## 핵심 코드 해설

### 1. 변경분만 검사하는 가드레일 (`ci/guardrails.sh`)

기존 히스토리에는 이미 들어간 위반이 있다(원본 예: 6.9MB PDF). 전체를 차단 기준으로 삼으면 잘못 없는 사람의 push가 막힌다. 그래서 push면 직전 커밋, PR이면 대상 브랜치의 기준 커밋과 비교한 변경 파일만 본다.

| 검사 | 분류 | 내용 |
|---|---|---|
| LFS 규칙이 걸린 파일이 포인터가 아님 | 차단 | 실제 바이너리가 커밋됨 |
| LFS 규칙 없는 바이너리가 10MB 초과 | 차단 | 환경변수 `MAX_BYTES`로 조정 |
| 대용량 텍스트 에셋(씬·프리팹 YAML) | 경고 | git 델타 압축이 되고 머지도 되므로 차단하지 않음. LFS로 옮기면 델타가 사라진다 |
| `Assets/` 아래 파일의 `.meta` 누락 | 차단 | 다른 사람의 참조가 깨진다 |
| 대상 없는 `.meta` | 경고 | git이 빈 폴더를 저장하지 않아 오탐이 잦다 |

핵심 구현 두 가지가 기록으로 남아 있다.

```bash
git() { command git -c core.quotePath=false "$@"; }
git cat-file -p "${HEAD_REF}:$1" | head -c 60 | grep -q 'version https://git-lfs'
```

- 작업 트리가 아니라 커밋된 blob(`git cat-file`)을 읽는다. 작업 트리를 읽으면 로컬에서 방금 커밋한 정상 LFS 파일이 위반으로 잡혔다(작업 트리에 원본이 남아 있어서).
- `core.quotePath=false`로 비ASCII 경로를 그대로 받는다. 기본값이면 경로가 따옴표와 8진수로 출력되어 blob을 못 찾고 검사가 조용히 건너뛰어진다.

### 2. 프로젝트 규칙 검사 (`ci/project-rules.sh`)

| 번호 | 검사 | 범위 |
|---|---|---|
| 1 | `.meta` GUID 중복 | 전체(GUID는 저장소 전체에서 유일해야 하므로) |
| 2 | 산출물 디렉터리 커밋(`Library`, `Temp`, `Build` 등) | 변경분 |
| 3 | Windows에서 체크아웃 불가능한 파일명 문자 | 변경분 |
| 4 | 대소문자만 다른 경로 | 전체 |
| 5 | Unity가 무시하는 파일명(`.`으로 시작, `~`로 끝남) | `Assets/` 변경분 |
| 6 | PR이 대상 브랜치와 같은 씬·프리팹을 동시에 수정 | 경고만 |

{% hint style="warning" %}
CAUTION: `project-rules.sh`는 `grep -P`를 쓰므로 Perl 정규식을 지원하는 `grep`이 필요하다. 러너 이미지에 따라 다를 수 있다(원본에서 확인하지 않음, 확인 필요).
{% endhint %}

### 3. 두 검사의 역할 분담 (`ci/guardrails.yml`)

Unity CLI의 `projects verify`는 겹치지 않는 세 항목만 켠다(충돌 마커, manifest 파싱, 에디터 버전 드리프트). `.meta` 누락과 GUID 중복은 위 두 스크립트가 변경분 기준으로 보므로, 전체 스캔인 CLI 검사를 켜면 설계가 깨진다. 각 단계에 `if: always()`를 붙여 앞 단계가 실패해도 다음을 실행한다. 한쪽 때문에 다른 쪽 문제를 못 보면 고치고 push하고 또 다른 실패를 만나는 일을 반복하게 된다.

{% hint style="info" %}
NOTE: 에디터 버전 기대값이 `guardrails.yml`의 `--expect-editor`와 `build.yml`의 에디터 경로 두 곳에 박혀 있다. 에디터를 올릴 때 한쪽만 바꾸면 가드레일에서 걸리도록 의도한 것이다.
{% endhint %}

### 4. 고정 경로 작업 폴더와 강제 동기화 (`ci/build.yml`, 첫 단계)

러너의 작업 디렉터리는 잡마다 바뀌어 Unity `Library/`(수 GB)를 매번 새로 만든다. 고정 경로를 쓰면 `Library`, 패키지 해석 결과, LFS 객체가 남는다(원본 기록: 13분에서 1.4분). 대신 이 폴더는 작업 공간이 아니라 빌드 입력이므로 강제로 서버 상태에 맞춘다.

```powershell
function Git-Run { & git @args; if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed" } }
Remove-Item .git\index.lock -Force -ErrorAction SilentlyContinue
Git-Run @auth fetch --quiet --prune --prune-tags --force --tags origin
Git-Run checkout -q -f --detach "${{ github.sha }}"
Git-Run reset -q --hard
Git-Run clean -xfdq -e Library -e Logs
```

- PowerShell은 네이티브 명령이 실패해도 예외를 던지지 않는다. 래퍼 함수로 종료 코드를 검사한다(이걸 놓쳐 옛 커밋으로 빌드한 적이 있다).
- 인증은 `.git/config`에 남기지 않고 명령마다 `-c http.extraheader`로만 전달한다. URL에 토큰을 박으면 설정에 남아 로그로 샌다.
- 체크아웃 후 `HEAD`가 목표 커밋과 같은지 직접 대조한다.
- Unity는 빌드마다 일부 에셋 파일을 수정하므로, 일반 체크아웃은 두 번째 빌드부터 거부된다. `checkout -f`와 `reset --hard`가 필요하다.

### 5. 태그 규칙과 모드 결정 (`ci/build.yml`, 모드 결정 단계)

| 태그 | 모드 | 버전 | 릴리스 |
|---|---|---|---|
| `v<버전>` | release | `v` 뒤 | 정식 |
| `debug-<버전>` | debug | `debug-` 뒤 | 사전 릴리스, 설치 항목이 정식판과 분리됨 |
| 수동 실행 | 입력값(기본 debug) | 입력값, 없으면 프로젝트 설정 + `-dev` | 올리지 않음 |

모드와 버전은 이 단계에서 한 번만 정하고 이후 단계는 환경변수(`BUILD_MODE`, `BUILD_VERSION`)만 읽는다. 같은 규칙을 여러 단계에 복사하면 한쪽만 고치는 실수가 난다.

### 6. Unity 빌드 진입점 (`ci/CIBuild.cs`)

워크플로가 `-ciOutputDir`, `-ciVersion`, `-ciDevelopment` 인자를 넘기고, `CIBuild.BuildWindows64`가 읽는다. 핵심 규칙은 다음과 같다.

| 상황 | 종료 코드 |
|---|---|
| 예외 발생 | 1 |
| Build Settings에 활성 씬이 없음 | 2 |
| 빌드 타깃 전환 실패 | 3 |
| 성공 보고인데 실행 파일이 없음 | 4 |
| Addressables 콘텐츠 빌드 실패 | 5 |
| 빌드 실패 | 1 |

```csharp
AddressableAssetSettings.BuildPlayerContent(out AddressablesPlayerBuildResult result);
...
var report = BuildPipeline.BuildPlayer(options);
...
EditorApplication.Exit(0);
```

- `-quit`를 넘기지 않고 `EditorApplication.Exit`를 직접 호출해 프로세스 종료 코드가 빌드 결과를 그대로 반영한다.
- `BuildPipeline.BuildPlayer`는 Addressables 콘텐츠를 만들지 않는다. 먼저 `BuildPlayerContent`를 호출하지 않으면 빌드는 성공하는데 에셋이 빠지고 런타임에서야 드러난다.
- 스크립팅 백엔드를 CI에서만 강제하지 않는다. CI 빌드가 로컬 에디터 테스트와 달라지는 것을 막으려는 결정이다.
- 개발 빌드는 `Development`와 `AllowDebugging` 옵션만 켜고 IL2CPP 컴파일러 설정은 건드리지 않는다. 성능 피드백이 의미를 잃지 않게 하려는 결정이다.
- 로그는 ASCII만 쓴다. 비ASCII는 CI 로그에서 깨진다.

### 7. 빌드 호출과 산출물 (`ci/build.yml`)

Unity CLI로 `unity build`를 호출하면서 에디터 경로, 로그 파일, 출처 기록(provenance) 경로, 타임아웃(10800초), 사용자 인자를 지정한다. 출처 기록은 산출물 폴더 안에 쓰므로 뒤의 복사 단계가 함께 가져간다. 필드를 골라 읽지 않고 파일 전체를 로그에 남긴다(스키마가 바뀌면 조용히 빈 값이 찍히기 때문).

보관 단계는 `robocopy`를 쓴다. 종료 코드는 일반 규약과 달라 0은 복사할 것 없음, 1은 성공, 8 이상이 실패다. 8 이상일 때만 실패로 보고 `$global:LASTEXITCODE = 0`으로 되돌린다. 처음에 이를 실패로 전파해 빌드 성공인데 잡이 실패하는 일이 있었다. 산출물은 최근 5개만 남긴다(빌드마다 2GB 넘게 쌓임).

### 8. 설치 마법사 (`ci/installer.iss`)

`ISCC`에 `/DMyVersion`, `/DMySourceDir`, `/DMyOutputDir`와 디버그일 때 `/DMyDebug`를 넘긴다.

| 설계 | 이유 |
|---|---|
| 관리자 권한을 요구하지 않음(`PrivilegesRequired=lowest`) | 팀원이 UAC 없이 설치 |
| 설치 경로를 시스템 드라이브의 `Games\<이름>` 고정 경로로 | `{autopf}`는 낮은 권한에서 사용자 AppData 아래로 풀리고, 그 아래 실행 파일은 백신·정책이 차단해 게임이 뜨지 않았다(원본 기록 Phase 7-7) |
| 앱 식별자는 고정 GUID | 버전이 올라가도 같은 항목을 갱신한다. 바꾸면 이전 버전이 제거되지 않고 중복 설치된다 |
| 디버그 빌드는 앱 식별자·이름·파일 이름·설치 폴더를 분리 | 한 PC에 정식판과 디버그판을 함께 두고 비교할 수 있다 |
| `VersionInfoVersion`용 숫자 전용 버전을 하이픈 앞에서 잘라 별도 생성 | `0.1.0-dev` 같은 문자열은 컴파일이 거부된다 |
| 디버그용 폴더(IL2CPP C++ 소스, 디버그 정보)를 `Excludes`로 제외 | 원본 기록으로 빌드 5.8GB 중 약 4GB였다. 크래시 분석용 사본은 산출물 보관 폴더에 남는다 |
| `#pragma message`로 이름·설치 경로·식별자를 컴파일 시 출력 | 어느 모드·경로로 나갔는지 산출물만 보고는 알 수 없는 문제를 막는다 |
| `PrivilegesRequiredOverridesAllowed=commandline` | 선택창을 띄우지 않고, 관리자가 필요하면 `/ALLUSERS`로 설치 |

{% hint style="warning" %}
CAUTION: `installer.iss`에는 `[InstallDelete]` 절이 두 번 나온다(이전 이름의 실행 파일·데이터 폴더 삭제용과 디버그 폴더 삭제용). Inno Setup이 같은 이름의 절을 여러 번 쓰는 것을 허용하는지는 원본에서 컴파일로 확인한 기록이 있다고 보이나(`verify-installer.ps1`) 이 환경에서는 확인하지 못했다(확인 필요).
{% endhint %}

### 9. 릴리스, Steam 업로드, 알림 (`ci/build.yml`)

- 릴리스는 태그일 때만 만든다. 같은 태그의 릴리스가 있으면 재사용하고, 같은 이름의 첨부가 있으면 삭제 후 다시 올린다(서버가 동명 첨부를 중복 허용하기 때문). 삭제 경로에는 릴리스 번호가 포함되어야 한다. 큰 파일은 `curl.exe`로 스트리밍 업로드한다(`Invoke-RestMethod`는 메모리에 올린다).
- Steam 업로드는 저장소 변수에 업로드 계정이 있을 때만 돈다. 태그가 `debug-*`면 debug 브랜치, `v*`면 internal 브랜치로 올리고, 공개(default) 브랜치에는 자동으로 올리지 않는다. 비밀번호는 어디에도 두지 않고 러너 PC에서 한 번 직접 로그인해 인증을 통과시키는 전제다. 브랜치 반영은 별도 변수가 `1`일 때만 한다.
- 알림 단계는 `if: always()`이고 항상 `exit 0`으로 끝난다. 알림 실패가 빌드를 실패로 만들면 안 된다. 성공 여부는 마지막에 쓰는 `BUILD_OK` 표시로 판단하고 `job.status`에 의존하지 않는다. 본문은 작은따옴표 문자열 배열로 만든다(here-string은 YAML 블록 스칼라가 들여쓰기가 얕은 줄에서 블록을 끝내 워크플로가 잘린 채 파싱될 수 있다).

## 따라 만들기

확인 상태: 미검증. 기대 결과는 원본 기록에 근거한 설명이다.

1. 가드레일 워크플로를 만든다. 전체 히스토리(`fetch-depth: 0`)를 받고 LFS 객체는 받지 않는다. 기준 커밋을 push면 직전 커밋, PR이면 대상 기준 커밋으로 정한다. 기대 결과: 로그에 기준과 대상 커밋이 찍힌다.
2. `guardrails.sh`를 쓴다. 변경 파일 목록, LFS 포인터 판정, 크기 판정, `.meta` 검사를 커밋된 blob 기준으로 구현한다. 기대 결과: LFS 규칙이 걸린 확장자를 포인터 없이 커밋하면 차단된다.
3. `project-rules.sh`를 쓴다. 전체를 봐야 하는 검사(GUID, 대소문자)와 변경분만 보는 검사를 나눈다. 기대 결과: `.meta` 사본을 만들어 GUID를 겹치게 하면 차단된다.
4. 각 검사 단계에 `if: always()`를 붙인다. 기대 결과: 한 번의 실행에서 모든 종류의 위반이 보인다.
5. `CIBuild.cs`를 `Assets/Editor/`에 둔다. 활성 씬 확인, Addressables 콘텐츠 빌드, 빌드, 종료 코드 규약을 구현한다. 기대 결과: 씬을 모두 끄면 종료 코드 2로 끝난다.
6. Windows 러너를 host 모드로 등록하고 [무인 운영](operations.md)의 감독 스크립트로 띄운다. 빌드 워크플로의 `runs-on`을 그 라벨로 맞춘다. 기대 결과: 태그를 밀면 잡이 러너에서 시작된다.
7. 빌드 워크플로를 쓴다. 고정 경로 동기화(강제 체크아웃과 HEAD 대조), 모드 결정, 빌드, 산출물 보관 순서로 구현한다. 기대 결과: 두 번째 빌드가 `Library` 캐시로 첫 빌드보다 훨씬 빠르다(원본 기록: 27분에서 8분).
8. `installer.iss`를 쓴다. 변수 세 개와 디버그 분기, 고정 앱 식별자, 고정 설치 경로, 제외 패턴을 넣는다. 먼저 로컬에서 `verify-installer.ps1` 같은 별도 검증으로 문법을 확인한다. 기대 결과: 설치 파일이 UAC 없이 설치되고 게임이 실행된다.
9. 릴리스 업로드와 알림을 붙인다. 웹훅은 저장소 비밀로 둔다. 기대 결과: 태그 빌드 후 릴리스에 설치 파일이 한 개만 보이고, 실패한 빌드도 알림이 온다.

## 알려진 한계·주의

- 원본 `build.yml`에는 웹훅이 값 그대로 있다(위 WARNING). 서버가 VPN 안에서만 열린다는 전제 위의 선택이라고 주석에 적혀 있으나, 공개 저장소에 올리면 안 된다.
- `ci/build.yml`의 알림 단계가 서버 주소와 게임 설치 경로를 본문에 넣는다. 일반화해서 옮겨야 한다.
- 가드레일이 에디터 버전을 두 곳에서 따로 갖는다(한쪽만 바꾸면 걸리도록 의도).
- 설치 경로 문제는 한 PC에서 확인한 결과다. 팀원 PC의 백신·정책이 다르면 다시 나타날 수 있어 실행 실패 보고가 오면 설치 경로부터 확인한다(원본 기록).
- 이미 AppData 경로에 설치한 사람은 제거 후 새 설치 파일을 실행해야 한다. 앱 식별자를 바꾸지 않았으므로 이전 설치 경로를 기억해 덮어쓴다.
- 빌드 시간이 길어(원본 기록: 디버그 약 33분) 4코어 머신에서는 main push마다 빌드하지 않고 태그에서만 돈다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성. 워크플로·스크립트·설치 정의를 읽고 정리함(실행하지 않음) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 가드레일이 전체 히스토리가 아니라 변경분만 검사하게 한 이유를 설명해 보라.
- [ ] 빌드 성공과 잡 성공이 어긋났던 사례(종료 코드, 콘텐츠 누락 등) 중 하나를 골라 어떻게 알아냈는지 적어 보라.
- [ ] 설치 경로를 고정 경로로 바꾼 결정의 장단점을 내 말로 적어 보라.
