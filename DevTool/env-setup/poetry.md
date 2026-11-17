# Poetry 패키지 관리자

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-004-DO |
| 유형 | D&O (개념·원리) |
| 목적 | Poetry의 역할, 구성 요소, 동작 순서를 설명하고 pip + venv와 비교한다 |
| 확인 상태 | 미검증 (원본 페이지와 공식 문서 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 개념 설명이다. 설치와 사용 절차는 DEV-ENV-005-MP를 따른다.
{% endhint %}

## 1. 목적

**Poetry**는 Python 프로젝트의 **의존성 관리(dependency management)**와 **패키지 관리(package management)**를 한 도구로 처리한다. `pip`과 `venv`를 따로 쓰던 작업을 하나로 합쳐, 프로젝트별 개발 환경을 일관되게 유지한다.

## 2. 구성 요소

| 번호 | 이름 | 위치 | 역할 |
|---|---|---|---|
| 1 | `poetry` 명령 | 시스템 `PATH` | 의존성 추가·설치·실행·배포를 처리한다 |
| 2 | `pyproject.toml` | 프로젝트 최상위 디렉터리 | 프로젝트 정보와 의존성을 선언한다 (PEP 518 표준 형식) |
| 3 | `poetry.lock` | 프로젝트 최상위 디렉터리 | 해결된 정확한 패키지 버전을 고정한다. 팀원이 같은 버전을 설치하게 한다 |
| 4 | 가상환경 | Poetry 기본 저장 위치 | 프로젝트별 독립 Python 환경이다. Poetry가 자동으로 만들고 연결한다 |
| 5 | PyPI | 원격 저장소 | 패키지를 내려받고 배포하는 Python Package Index다 |

## 3. 동작 원리

```
poetry add <패키지> > pyproject.toml 갱신 > 의존성 해결 > poetry.lock 기록 > 가상환경에 설치
```

1. `poetry add`가 `pyproject.toml`에 의존성을 기록한다.
2. Poetry가 패키지 간 충돌이 없는 버전 조합을 찾는다(자동 의존성 해결).
3. 결과를 `poetry.lock`에 기록한다.
4. 프로젝트 전용 가상환경에 패키지를 설치한다.
5. 다른 사람이 저장소를 받아 `poetry install`을 실행하면 `poetry.lock`의 버전 그대로 설치된다.

### 주요 기능

* **의존성 관리**: 필요한 패키지를 `pyproject.toml`에 선언하고 설치·갱신한다.
* **가상환경 관리**: 별도 `virtualenv` 설정 없이 프로젝트마다 독립 환경을 만든다.
* **패키지 배포**: 작성한 코드를 PyPI에 배포할 수 있다.
* **명령어 통합**: 설치, 제거, 갱신, 의존성 확인을 `poetry` 하나로 처리한다.

### 장점

* 프로젝트별로 의존성이 분리돼 다른 프로젝트와 충돌하지 않는다.
* `pyproject.toml`과 `poetry.lock`을 저장소에 올려 팀이 같은 환경을 쓴다.
* `requirements.txt`보다 직관적인 선언 형식(PEP 518)을 쓴다.

### Poetry와 pip + venv 비교

| 기능 | Poetry | pip + venv |
|---|---|---|
| 의존성 관리 | 자동 의존성 해결 및 갱신 | 수동으로 해결해야 한다 |
| 가상환경 관리 | 자동 생성 및 연결 | 수동으로 만들어야 한다 |
| 패키지 버전 고정 | `poetry.lock` 파일 | `requirements.txt` 사용 |
| 배포·빌드 지원 | PyPI 배포 내장 | 추가 도구가 필요하다 |

팀 협업이나 큰 프로젝트에서 의존성을 일관되게 관리해야 할 때 Poetry를 도입할 만하다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| PyPI | Python Package Index. Python 패키지 공개 저장소 |
| PEP 518 | `pyproject.toml`로 빌드 요구사항을 선언하는 Python 표준 문서 |
| 의존성(dependency) | 프로젝트가 동작하는 데 필요한 외부 패키지 |
| 가상환경(virtual environment) | 프로젝트별로 분리된 Python 실행 환경 |
| lock 파일 | 해결된 패키지 버전을 고정해 둔 파일 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `pyproject.toml`과 `poetry.lock`은 각각 어떤 역할을 하고, 왜 둘 다 저장소에 올릴까?
- [ ] pip + venv로 작업하다 겪었던 불편함은 무엇이고, Poetry가 그것을 어떻게 줄여 줄까?
- [ ] 내 프로젝트에 Poetry를 쓰겠다면 어떤 이유 때문인가?
