# poetry

## Poetry 개요

**Poetry**는 Python 프로젝트의 \*\*의존성 관리(dependency management)\*\*와 \*\*패키지 관리(package management)\*\*를 쉽게 해주는 도구입니다. 기존의 `pip`과 `virtualenv` 또는 `venv`를 통합한 현대적인 대안으로, Python 개발 환경을 더 깔끔하고 체계적으로 관리할 수 있게 도와줍니다.

{% stepper %}
{% step %}
### 의존성 관리

* 프로젝트에서 필요한 Python 패키지 및 라이브러리를 `pyproject.toml` 파일에 정의하고, 해당 패키지를 설치 및 관리합니다.
* **자동 의존성 해결**: 패키지 간 충돌이 없도록 적합한 버전을 찾아 설치합니다.
{% endstep %}

{% step %}
### 가상 환경 관리

* 프로젝트별 독립적인 Python 가상 환경을 자동으로 생성하고 연결합니다.
* 별도의 `virtualenv` 설정 없이도 간단히 사용 가능합니다.
{% endstep %}

{% step %}
### 패키지 배포 지원

* Poetry를 통해 작성한 코드를 Python 패키지로 만들어 PyPI(Python Package Index)에 배포할 수 있습니다.
{% endstep %}

{% step %}
### 직관적인 명령어

* 패키지 설치, 제거, 업데이트 등의 작업을 간단한 명령어로 처리할 수 있습니다.
{% endstep %}
{% endstepper %}

***

## Poetry 사용의 장점

{% stepper %}
{% step %}
### 프로젝트 단위로 의존성 관리

* 프로젝트의 의존성을 명확히 관리해 다른 프로젝트와 충돌을 방지합니다.
* `pyproject.toml` 파일에 의존성을 기록하여 공유할 수 있습니다.
{% endstep %}

{% step %}
### 동시 가상 환경 관리

* Python 버전과 패키지를 가상 환경 안에서 자동으로 설정합니다.
{% endstep %}

{% step %}
### 빠르고 편리한 명령어

* 패키지 설치, 제거, 의존성 확인 등을 하나의 도구로 처리할 수 있습니다.
{% endstep %}

{% step %}
### PEP 518 지원

* `pyproject.toml` 표준을 사용해 Python 패키지의 의존성을 선언합니다.
* 기존의 `requirements.txt`보다 더 직관적인 설정을 제공합니다.
{% endstep %}
{% endstepper %}

***

## 설치 및 기본 사용법

### 설치

Poetry는 아래 명령어로 설치할 수 있습니다:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

설치 후 환경 변수 설정을 확인한 다음 명령어를 사용할 수 있습니다.

### 프로젝트 초기화

새로운 Python 프로젝트를 시작하려면:

```bash
poetry init
```

질문에 답하며 프로젝트의 이름, 버전, 의존성 등을 설정하면 `pyproject.toml` 파일이 생성됩니다.

### 패키지 설치

Poetry로 의존성을 설치하려면:

```bash
poetry add <패키지명>
```

예: `poetry add requests`는 `requests` 패키지를 설치하고 `pyproject.toml`에 기록합니다.

### 가상 환경 실행

Poetry가 관리하는 가상 환경을 활성화하려면:

```bash
poetry shell
```

### 의존성 설치

다른 팀원이 프로젝트를 복제한 후 필요한 패키지를 설치하려면:

```bash
poetry install
```

***

## Poetry와 기존 도구 비교

| 기능         |               Poetry |            pip + venv |
| ---------- | -------------------: | --------------------: |
| 의존성 관리     |     자동 의존성 해결 및 업데이트 |            수동으로 해결 필요 |
| 가상 환경 관리   |           자동 생성 및 연결 |            수동으로 생성 필요 |
| 패키지 버전 고정  | `poetry.lock` 파일로 관리 | `requirements.txt` 사용 |
| 배포 및 빌드 지원 |        PyPI 배포 내장 지원 |              추가 도구 필요 |

Poetry는 특히 팀 협업이나 대규모 프로젝트에서 의존성을 효과적으로 관리해야 할 때 큰 이점을 제공합니다. 팀원과 통일된 개발 환경을 유지하거나 패키지 관리를 간소화하려고 한다면 도입을 고려해볼 만합니다. 😊
