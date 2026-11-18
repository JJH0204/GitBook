# Windows Python 환경 설정 (pyenv)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-003-MP |
| 목적 | Windows에 pyenv-win을 설치하고 Python 버전을 고른 뒤 venv 가상환경을 만든다 |
| 적용 대상 | Windows 10/11, PowerShell 5 이상, 인터넷 연결, Git 설치됨 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 절차를 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 구역 A(pyenv 설치), B(Python 설치), C(가상환경 생성), D(전체 흐름 예)로 나뉜다. 구역은 순서대로 수행한다. 이미 pyenv가 있으면 구역 B부터 수행한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [pyenv-win 설치 안내 (GitHub)](https://github.com/pyenv-win/pyenv-win/blob/master/README.md#installation) | 외부 | pyenv-win 공식 README |
| [Python 공식 문서: venv](https://docs.python.org/ko/3/library/venv.html) | 외부 | venv 모듈 설명 |
| [pyenv-virtualenv (GitHub)](https://github.com/pyenv/pyenv-virtualenv) | 외부 | macOS/Linux용 가상환경 플러그인 |
| [macOS Python 환경 설정](pythonidesetupformac.md) | DEV-ENV-001-MP | macOS용 절차 |
| [Poetry 설치와 사용](poetryinstallation.md) | DEV-ENV-005-MP | 가상환경 대신 Poetry를 쓰는 방법 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | PowerShell | Windows 기본 제공 | 구역 A는 관리자 권한으로 실행한다 |
| 2 | CMD 또는 PowerShell | 일반 권한 | 구역 B~D에서 사용 |
| 3 | Git | 설치됨 | pyenv-win은 Git 설치를 권장한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 5-A-02의 설치 스크립트는 인터넷에서 내려받아 실행한다. 명령의 주소가 `raw.githubusercontent.com/pyenv-win/pyenv-win/`로 시작하는지 확인한 뒤 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 시스템 환경 변수의 기존 `PATH` 값을 지우지 않는다. 항목을 추가만 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 사용자 이름을 확인한다: PowerShell에서 `$env:USERNAME` | 계정 이름이 출력된다. 이 문서의 `<사용자ID>`에 이 값을 쓴다 |
| 2 | pyenv가 이미 설치됐는지 확인한다: `pyenv --version` | 설치됐다면 버전이 출력된다. 이 경우 구역 A를 건너뛴다 |

## 5. 절차

### A. pyenv-win 설치

1. (5-A-01) 시작 메뉴에서 `PowerShell`을 검색해 우클릭하고 `관리자 권한으로 실행`을 선택한다. → 결과: 제목에 `관리자`가 붙은 PowerShell 창이 열린다.

{% hint style="warning" %}
CAUTION: 아래 5-A-02에서 `UnauthorizedAccess` 오류가 나면 PowerShell이 스크립트 실행을 막은 것이다. 그때만 5-A-02a를 수행한다. 실행 정책을 바꾸면 이 PC의 모든 사용자에게 서명되지 않은 로컬 스크립트 실행이 허용된다.
{% endhint %}

2. (5-A-02) 설치 스크립트를 내려받아 실행한다. → 결과: 오류 없이 끝나고 pyenv-win이 설치됐다는 메시지가 나온다.

{% code title="PowerShell (관리자)" %}
```powershell
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```
{% endcode %}

3. (5-A-02a) 실행 정책 오류가 났을 때만 다음 명령을 실행하고 5-A-02를 다시 수행한다: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine` → 결과: 실행 정책 변경 확인을 묻고, `Y`를 입력하면 끝난다.
4. (5-A-03) PowerShell 창을 닫고 새로 연다. → 결과: 새 창이 열린다.
5. (5-A-04) 설치를 확인한다: `pyenv --version` → 결과: `pyenv 3.x.y` 형식으로 출력된다.

{% hint style="info" %}
NOTE: 원본 페이지의 5-A-04 명령 블록은 비어 있었다. `pyenv --version`은 이 문서에서 보충했다.
{% endhint %}

6. (5-A-05) 5-A-04가 `인식되지 않습니다` 오류를 내면 환경 변수를 수동으로 설정한다. 시작 메뉴에서 `시스템 환경 변수 편집`을 검색해 열고 하단의 `환경 변수`를 선택한다.
7. (5-A-06) `사용자 변수` 또는 `시스템 변수`에서 `새로 만들기`로 다음 두 변수를 추가한다. 이미 있으면 건드리지 않는다.

| 변수 이름 | 변수 값 |
|---|---|
| `PYENV` | `C:\Users\<사용자ID>\.pyenv\pyenv-win\` |
| `PYENV_HOME` | `C:\Users\<사용자ID>\.pyenv\pyenv-win\` |

8. (5-A-07) `Path` 변수를 선택하고 `편집`을 눌러 다음 두 줄을 추가한다. → 결과: `Path` 목록에 두 줄이 보인다.

{% code title="Path에 추가" %}
```
%USERPROFILE%\.pyenv\pyenv-win\bin
%USERPROFILE%\.pyenv\pyenv-win\shims
```
{% endcode %}

9. (5-A-08) 새 PowerShell 창을 열고 `pyenv --version`을 실행한다. → 결과: 버전이 출력된다.

{% hint style="info" %}
NOTE: 원본은 `PYENV` 값을 `...\pyenv-win\bin`으로 적었으나 pyenv-win 공식 안내는 `...\pyenv-win\`(끝에 `bin` 없음)이다. 이 문서는 공식 안내 쪽으로 정정했다. 공식 설치 스크립트는 이 변수와 `Path`를 자동으로 설정하므로 5-A-05~5-A-08은 5-A-04가 실패할 때만 수행한다. 실제 동작은 확인하지 않았다.
{% endhint %}

### B. Python 설치

1. (5-B-01) 일반 권한의 CMD 또는 PowerShell을 연다. → 결과: 프롬프트가 나타난다.
2. (5-B-02) 설치 가능한 버전 목록을 확인한다: `pyenv install -l` → 결과: 버전 목록이 출력된다. 처음 한 번은 실행해 보기를 권장한다.
3. (5-B-03) 원하는 버전을 설치한다: `pyenv install <버전>` (예: `pyenv install 3.9.9`) → 결과: 설치가 끝났다는 메시지가 나온다.
4. (5-B-04) 전역 기본 버전을 지정한다: `pyenv global <버전>` → 결과: 오류 없이 끝난다.
5. (5-B-05) 지정한 버전을 확인한다: `pyenv version` → 결과: 지정한 버전과 설정 위치가 출력된다.
6. (5-B-06) Python 실행 파일 경로를 확인한다: `python -c "import sys; print(sys.executable)"` → 결과: `C:\Users\<사용자ID>\.pyenv\pyenv-win\versions\<버전>\python.exe`가 출력된다.

{% hint style="info" %}
NOTE: 5-B-06에서 pyenv 경로가 아니라 `...\WindowsApps\python.exe`가 나오면 Microsoft Store의 Python 바로가기가 먼저 잡힌 것이다. `설정 > 앱 > 고급 앱 설정 > 앱 실행 별칭`에서 `python.exe`, `python3.exe`를 끈다. 이 항목은 이번 개정에서 보충했으며 확인하지 않았다.
{% endhint %}

### C. 가상환경 생성 (venv)

{% hint style="info" %}
NOTE: macOS에서는 pyenv와 `pyenv-virtualenv`로 가상환경을 관리한다. Windows는 `pyenv-virtualenv` 지원이 제한적이므로 Python 내장 `venv` 모듈을 쓴다.
{% endhint %}

1. (5-C-01) 프로젝트 디렉터리로 이동한다: `cd <프로젝트 경로>` → 결과: 프롬프트의 경로가 바뀐다.
2. (5-C-02) 가상환경을 만든다: `python -m venv .venv` → 결과: `.venv` 폴더가 생긴다. 이름은 관례적으로 `.venv`를 쓴다.
3. (5-C-03) (선택) 가상환경 폴더를 Git에서 제외한다. `.gitignore` 파일에 `.venv/` 줄을 추가한다. 버전 관리에 포함하려면 이 단계를 건너뛴다.
4. (5-C-04) (선택) 이 프로젝트에서 쓸 Python 버전을 지정한다: `pyenv local <버전>` → 결과: 프로젝트 디렉터리에 `.python-version` 파일이 생긴다. 해당 버전이 구역 B에서 설치돼 있어야 한다. 이 단계는 5-C-02보다 먼저 수행해야 `.venv`가 그 버전으로 만들어진다.
5. (5-C-05) 가상환경을 활성화한다. → 결과: 프롬프트 앞에 `(.venv)`가 붙는다.

{% code title="CMD" %}
```bat
.venv\Scripts\activate.bat
```
{% endcode %}

{% code title="PowerShell" %}
```powershell
.venv\Scripts\Activate.ps1
```
{% endcode %}

{% hint style="warning" %}
CAUTION: PowerShell에서 `Activate.ps1`이 실행 정책 오류로 막히면 현재 사용자 범위로만 허용한다: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`. 번거로우면 CMD에서 `activate.bat`을 쓴다. 이 안내는 이번 개정에서 보충했으며 확인하지 않았다.
{% endhint %}

6. (5-C-06) 활성화를 확인한다: `where python` → 결과: 첫 줄이 `<프로젝트 경로>\.venv\Scripts\python.exe`다.

{% hint style="info" %}
NOTE: PowerShell에서 `pyenv local`이 동작하지 않으면 `cmd /c pyenv local <버전>`으로 실행한다.
{% endhint %}

### D. 전체 흐름 예

다음은 구역 C를 한 번에 수행한 CMD 예다. 경로와 버전은 예시다.

{% code title="CMD" %}
```bat
> cd <프로젝트 경로>
> cmd /c pyenv local 3.9.9
> python -m venv .venv
> .venv\Scripts\activate.bat
(.venv) > where python
<프로젝트 경로>\.venv\Scripts\python.exe
C:\Users\<사용자ID>\.pyenv\pyenv-win\shims\python
C:\Users\<사용자ID>\.pyenv\pyenv-win\shims\python.bat
C:\Users\<사용자ID>\AppData\Local\Microsoft\WindowsApps\python.exe
(.venv) > deactivate
>
```
{% endcode %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `pyenv --version` | 버전이 출력된다 | `pyenv 3.x.y` 형식 |
| 2 | `pyenv versions` | 설치한 버전이 나온다 | 5-B-03의 버전이 목록에 있다 |
| 3 | 활성화 후 `where python` | 가상환경 경로가 첫 줄이다 | 첫 줄이 `.venv\Scripts\python.exe`로 끝난다 |
| 4 | 활성화 후 `python --version` | 지정한 버전이 출력된다 | 5-C-04에서 지정한 버전과 같다 |

## 7. 복구

1. (7-01) 가상환경을 끈다: `deactivate` → 결과: 프롬프트의 `(.venv)`가 사라진다.
2. (7-02) 가상환경을 지운다: `.venv` 폴더를 삭제한다. 프로젝트 소스는 지워지지 않는다.
3. (7-03) 프로젝트 Python 버전 지정을 해제한다: `.python-version` 파일을 삭제한다.
4. (7-04) 설치한 Python 버전을 지운다: `pyenv uninstall <버전>`
5. (7-05) pyenv-win을 완전히 제거하려면 `C:\Users\<사용자ID>\.pyenv` 폴더를 삭제하고, 5-A-06~5-A-07에서 추가한 환경 변수와 `Path` 항목을 지운다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `pythonsettingwin.md`를 AMM 형식으로 재작성. 깨진 코드 블록 복원, 외부 링크를 참조로 이동, 사용자 이름·경로를 `<사용자ID>`로 일반화, `PYENV` 값 정정, 실행 정책·PowerShell 활성화·Store 별칭 안내 보충, 자동완성 블로그 링크 삭제 |
