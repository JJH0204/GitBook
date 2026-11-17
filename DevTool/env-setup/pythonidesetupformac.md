# macOS Python 환경 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-001-MP |
| 목적 | macOS에 설치된 Python의 버전과 경로를 확인하고, pyenv로 Python 버전을 관리할 수 있게 한다 |
| 적용 대상 | macOS (Apple Silicon 또는 Intel), zsh, Homebrew 설치됨 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리하고 pyenv 절차를 보충한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 구역 A~B는 원본 페이지의 내용이다. 구역 C(pyenv 설치)는 원본에 없어 이번 개정에서 보충했다. 원본의 빈 코드 블록은 바로 아래에 같은 명령이 이미 적혀 있어 삭제했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [macOS 환경 변수 설정](macosenvvariablesetup.md) | DEV-ENV-002-MP | `~/.zshrc` 수정, `PATH` 확인 |
| [Windows Python 환경 설정 (pyenv)](pythonsettingwin.md) | DEV-ENV-003-MP | Windows용 절차 |
| [Poetry 설치와 사용](poetryinstallation.md) | DEV-ENV-005-MP | 프로젝트 의존성 관리 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | macOS 터미널 | zsh | |
| 2 | Homebrew | 최신 | 구역 C에서 사용. `brew --version`으로 확인한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: macOS에는 시스템이 쓰는 Python이 있다(`/usr/bin/python3`). 이 Python에 `pip install`로 패키지를 덮어쓰거나 파일을 지우지 않는다. 패키지는 가상환경 또는 pyenv로 설치한 Python에 설치한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | 사용 중인 셸을 확인한다: `echo $SHELL` | `/bin/zsh`가 출력된다 |

## 5. 절차

### A. Python 버전과 경로 확인

1. (5-A-01) 두 명령의 버전을 확인한다: `python3 --version` 과 `python --version` → 결과: 각각 `Python 3.x.y` 형식으로 출력된다.
2. (5-A-02) 두 결과를 비교한다. → 결과: 버전이 다르면 서로 다른 Python이 설치된 것이다.

{% code title="출력 예" %}
```
% python --version
Python 3.9.6

% python3 --version
Python 3.11.7
```
{% endcode %}

{% hint style="info" %}
NOTE: macOS에는 보통 `python3` 명령만 있다. `python` 명령은 별칭(alias)이 걸려 있거나 아예 없을 수 있다. `command not found: python`이 나오면 `python3`를 쓴다.
{% endhint %}

3. (5-A-03) 실행 파일 경로를 확인한다: `which python` 과 `which python3` → 결과: 각 명령이 가리키는 경로가 출력된다.

{% code title="출력 예" %}
```
% which python
python: aliased to /usr/bin/python3

% which python3
/opt/anaconda3/bin/python3
```
{% endcode %}

{% hint style="info" %}
NOTE: 위 예에서 `python3`는 Anaconda 설치에 포함된 것이다. 경로가 `/opt/anaconda3/`로 시작하면 Anaconda, `/usr/bin/`이면 macOS 기본, `/opt/homebrew/`이면 Homebrew가 설치한 Python이다.
{% endhint %}

### B. 라이브러리 설치 (pip)

1. (5-B-01) 현재 `python3`에 연결된 pip로 패키지를 설치한다: `python3 -m pip install requests` → 결과: `Successfully installed requests-...` 가 출력된다.

{% hint style="warning" %}
CAUTION: `pip`와 `pip3`는 어느 Python에 연결됐는지 알기 어렵다. `python3 -m pip` 형식은 지금 쓰는 Python의 pip를 실행하므로 안전하다. 다음 세 명령은 서로 다른 Python에 설치될 수 있다.
{% endhint %}

{% code title="참고: 같은 결과를 보장하지 않는 형식" %}
```bash
pip install requests
pip3 install requests
python -m pip install requests
```
{% endcode %}

### C. pyenv 설치 (보충 내용)

1. (5-C-01) pyenv를 설치한다: `brew install pyenv` → 결과: 설치가 오류 없이 끝난다.
2. (5-C-02) `~/.zshrc` 맨 아래에 다음 세 줄을 추가한다. 편집 방법은 DEV-ENV-002-MP의 구역 D를 따른다.

{% code title="~/.zshrc" %}
```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```
{% endcode %}

3. (5-C-03) 새 터미널 창을 연다. → 결과: 프롬프트가 나타난다.
4. (5-C-04) 설치를 확인한다: `pyenv --version` → 결과: `pyenv 2.x.y` 형식으로 출력된다.
5. (5-C-05) 설치 가능한 버전을 확인한다: `pyenv install -l` → 결과: 버전 목록이 출력된다.
6. (5-C-06) 원하는 버전을 설치한다: `pyenv install <버전>` (예: `pyenv install 3.12.7`) → 결과: 설치가 끝난다. 수 분이 걸린다.
7. (5-C-07) 전역 버전을 지정한다: `pyenv global <버전>` → 결과: 오류 없이 끝난다.
8. (5-C-08) 적용을 확인한다: `python --version` → 결과: 지정한 버전이 출력된다.

{% hint style="info" %}
NOTE: pyenv 설치 안내는 원본에 없었다. Homebrew 방식과 `~/.zshrc` 세 줄은 pyenv 공식 안내를 기준으로 썼으며 이 문서에서 실행해 확인하지 않았다. Anaconda가 설치돼 있으면 `PATH` 순서에 따라 Anaconda의 Python이 먼저 잡힐 수 있다. 5-C-08에서 다른 버전이 나오면 `which python`으로 경로를 확인한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `python3 --version` | 버전이 출력된다 | `Python 3.x.y` 형식 |
| 2 | `which python3` | 경로가 출력된다 | 의도한 Python의 경로 (pyenv 사용 시 `~/.pyenv/shims/python3`) |
| 3 | `python3 -m pip --version` | pip 버전과 경로가 출력된다 | 경로가 2번의 Python과 같은 환경 |
| 4 | `pyenv versions` | 설치한 버전 목록이 나온다 | 5-C-06에서 설치한 버전이 있고 `*`가 붙어 있다 |

## 7. 복구

1. (7-01) pyenv 설정을 되돌린다: `~/.zshrc`에서 5-C-02의 세 줄을 지운다.
2. (7-02) 설치한 Python 버전을 지운다: `pyenv uninstall <버전>`
3. (7-03) pyenv를 제거한다: `brew uninstall pyenv`
4. (7-04) 새 터미널 창을 연다. → 결과: `pyenv --version`이 `command not found`를 출력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `pythonidesetupformac.md`를 AMM 형식으로 재작성. 빈 코드 블록 삭제, `python3` 중심 안내, pyenv 설치(구역 C)와 복구 절 보충 |
