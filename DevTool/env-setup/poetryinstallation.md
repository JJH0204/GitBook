# Poetry 설치와 사용

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-005-MP |
| 목적 | Poetry를 설치하고 새 프로젝트에서 의존성을 추가·설치·실행한다 |
| 적용 대상 | macOS, Linux 또는 Windows (PowerShell), Python 3.9 이상 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 명령과 공식 설치 안내를 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 기존 `poetry.md`의 "설치 및 기본 사용법" 부분을 별도 절차 문서로 분리한 것이다. 개념은 DEV-ENV-004-DO를 따른다. `poetry shell`은 Poetry 2.0부터 기본 기능이 아니므로 이 문서는 `poetry run`을 쓴다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Poetry 패키지 관리자](poetry.md) | DEV-ENV-004-DO | 개념과 pip + venv 비교 |
| [macOS Python 환경 설정](pythonidesetupformac.md) | DEV-ENV-001-MP | macOS Python 준비 |
| [Windows Python 환경 설정 (pyenv)](pythonsettingwin.md) | DEV-ENV-003-MP | Windows Python 준비 |
| [macOS 환경 변수 설정](macosenvvariablesetup.md) | DEV-ENV-002-MP | `PATH` 추가 방법 |
| [Poetry 공식 문서](https://python-poetry.org/docs/) | 외부 | 설치와 명령 안내 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Python | 3.9 이상 | `python3 --version`으로 확인한다 |
| 2 | 터미널 | macOS/Linux 셸 또는 Windows PowerShell | |
| 3 | 인터넷 연결 | | 설치 스크립트와 패키지를 내려받는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 5-A-01은 인터넷의 스크립트를 내려받아 바로 실행한다. 주소가 `https://install.python-poetry.org`인지 확인한 뒤 실행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Python이 설치돼 있는지 확인한다: `python3 --version` (Windows: `python --version`) | `Python 3.9` 이상이 출력된다 |
| 2 | 이미 Poetry가 있는지 확인한다: `poetry --version` | 없으면 `command not found`가 나온다. 있으면 구역 A를 건너뛴다 |

## 5. 절차

### A. Poetry 설치

1. (5-A-01) 공식 설치 스크립트를 실행한다. → 결과: 설치가 끝나고 설치 경로 안내가 출력된다.

{% code title="macOS / Linux" %}
```bash
curl -sSL https://install.python-poetry.org | python3 -
```
{% endcode %}

{% code title="Windows (PowerShell)" %}
```powershell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
```
{% endcode %}

2. (5-A-02) `poetry` 명령이 있는 디렉터리를 `PATH`에 추가한다. macOS/Linux는 `~/.local/bin`이다. 편집 방법은 DEV-ENV-002-MP의 구역 D를 따른다.

{% code title="~/.zshrc" %}
```bash
export PATH="$HOME/.local/bin:$PATH"
```
{% endcode %}

3. (5-A-03) Windows는 `%APPDATA%\Python\Scripts`를 사용자 `Path`에 추가한다. 5-A-01의 출력에 실제 경로가 안내되므로 그 경로를 쓴다.
4. (5-A-04) 새 터미널을 연다. → 결과: 프롬프트가 나타난다.
5. (5-A-05) 설치를 확인한다: `poetry --version` → 결과: `Poetry (version 2.x.y)` 형식으로 출력된다.

{% hint style="info" %}
NOTE: `pipx`가 있으면 `pipx install poetry`로도 설치할 수 있다. 원본에는 공식 설치 스크립트 명령만 있었다. 설치 경로와 Windows 명령은 공식 안내를 기준으로 보충했으며 확인하지 않았다.
{% endhint %}

### B. 프로젝트 시작

1. (5-B-01) 새 프로젝트 디렉터리를 만들고 이동한다: `mkdir <프로젝트 이름> && cd <프로젝트 이름>` → 결과: 프롬프트의 경로가 바뀐다.
2. (5-B-02) 프로젝트를 초기화한다: `poetry init` → 결과: 이름, 버전, 설명, Python 버전, 의존성을 묻는 질문이 이어진다.
3. (5-B-03) 질문에 답한다. 기본값은 `Enter`를 누른다. → 결과: 마지막에 `Do you confirm generation?`이 나오면 `yes`를 입력한다.
4. (5-B-04) 생성된 파일을 확인한다: `ls pyproject.toml` (Windows: `dir pyproject.toml`) → 결과: 파일 이름이 출력된다.

### C. 패키지 추가와 실행

1. (5-C-01) 패키지를 추가한다: `poetry add requests` → 결과: 가상환경이 만들어지고 `requests`가 설치되며 `pyproject.toml`과 `poetry.lock`이 갱신된다.
2. (5-C-02) 가상환경 안에서 Python 명령을 실행한다: `poetry run python -c "import requests; print(requests.__version__)"` → 결과: `requests` 버전이 출력된다.
3. (5-C-03) 스크립트를 실행한다: `poetry run python <스크립트 파일>.py` → 결과: 스크립트가 가상환경의 Python으로 실행된다.
4. (5-C-04) 가상환경 정보를 확인한다: `poetry env info` → 결과: Python 버전과 가상환경 경로가 출력된다.

{% hint style="info" %}
NOTE: Poetry 2.0 이후 쉘을 가상환경에 넣으려면 `poetry env activate`가 출력하는 명령을 실행하거나 `poetry-plugin-shell` 플러그인을 설치해 `poetry shell`을 쓴다. Poetry 1.x에서는 `poetry shell`이 기본 명령이다. 이 구분은 공식 변경 내용을 기준으로 했으며 직접 확인하지 않았다.
{% endhint %}

### D. 다른 환경에서 의존성 설치

1. (5-D-01) 저장소를 복제한다: `git clone <저장소 주소>` → 결과: 프로젝트 폴더가 생긴다.
2. (5-D-02) 프로젝트 폴더로 이동한다: `cd <프로젝트 폴더>` → 결과: `pyproject.toml`이 있는 위치다.
3. (5-D-03) 의존성을 설치한다: `poetry install` → 결과: `poetry.lock`에 적힌 버전 그대로 가상환경에 설치된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `poetry --version` | 버전이 출력된다 | `Poetry (version ...)` 형식 |
| 2 | `ls pyproject.toml poetry.lock` | 두 파일이 있다 | 두 파일 이름이 모두 출력된다 |
| 3 | `poetry run python -c "import requests"` | 오류 없이 끝난다 | `ModuleNotFoundError`가 없다 |
| 4 | `poetry show` | 설치된 패키지 목록이 나온다 | `requests`가 목록에 있다 |

## 7. 복구

1. (7-01) 패키지를 제거한다: `poetry remove requests` → 결과: `pyproject.toml`에서 항목이 사라진다.
2. (7-02) 프로젝트의 가상환경을 제거한다: `poetry env remove --all` → 결과: 가상환경이 삭제된다.
3. (7-03) Poetry를 제거한다: macOS/Linux는 `curl -sSL https://install.python-poetry.org | python3 - --uninstall` → 결과: Poetry가 삭제된다.
4. (7-04) 5-A-02에서 추가한 `PATH` 줄을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `poetry.md`의 설치·사용 부분을 분리해 신규 작성. `poetry shell`을 `poetry run` 중심으로 정정하고 Windows 설치, `PATH`, 복구 절을 보충 |
