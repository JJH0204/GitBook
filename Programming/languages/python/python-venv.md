# [생성형 AI] Python 가상환경 (venv)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-010-MP |
| 유형 | MP (절차) |
| 목적 | 프로젝트별로 패키지를 분리하는 가상환경을 만들고 사용하는 순서를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 일부 검증. Linux, Python 3.14에서 `python3 -m venv <폴더>`로 폴더 생성, `pyvenv.cfg` 내용, 폴더 안 `python`의 `sys.prefix`가 가상환경 경로를 가리킴을 확인했다. 이 환경에는 `ensurepip`가 없어 `pip` 설치·`activate` 실행·Windows 명령은 검증하지 못했다(미검증) |
| 개정 | R1 (2026-11-19) |

## 참조

* [Python 개발 환경 및 문법](python.md)
* [Python 개요 (Overview)](pythonoverview.md)

## 필요 장비

| 항목 | 기준 |
|---|---|
| Python | 3.3 이상(표준 라이브러리 `venv` 포함) |
| 디스크 | 가상환경 폴더 1개(보통 수 MB~수십 MB, 설치한 패키지에 따라 증가) |

## 개념

가상환경은 프로젝트 전용 Python 실행 파일 링크와 `site-packages` 폴더를 가진 폴더다. 프로젝트마다 패키지와 버전을 독립시켜 한 프로젝트의 설치가 다른 프로젝트를 깨뜨리지 않게 한다. 시스템 Python에 직접 패키지를 설치하면 운영체제 도구와 충돌할 수 있다.

## 안전

{% hint style="warning" %}
CAUTION: 가상환경 폴더는 복사하거나 이동하면 내부 경로가 어긋나 동작하지 않는다. 폴더를 옮기지 말고 새로 만든다. 소스 저장소에는 올리지 않는다(`.gitignore`에 추가).
{% endhint %}

## 절차

### SUBTASK 1. 가상환경 만들기

1. 프로젝트 폴더에서 다음을 실행한다.

```bash
python3 -m venv .venv
```

2. `.venv/pyvenv.cfg`가 생겼는지 확인한다. `home` 항목이 기반 Python 경로를 가리킨다.

일부 Linux 배포판(Debian, Ubuntu)은 `venv` 모듈이 별도 패키지(`python3-venv`)이며, 없으면 `ensurepip is not available` 오류가 난다. 이때는 배포판 패키지 관리자로 해당 패키지를 설치한 뒤 `.venv`를 지우고 다시 만든다.

### SUBTASK 2. 활성화

| 환경 | 명령 |
|---|---|
| Linux, macOS (bash, zsh) | `source .venv/bin/activate` |
| Windows (PowerShell) | `.venv\Scripts\Activate.ps1` |
| Windows (cmd) | `.venv\Scripts\activate.bat` |

활성화하면 프롬프트 앞에 `(.venv)`가 붙고 `python`이 가상환경의 Python을 가리킨다. 활성화 없이 `.venv/bin/python`을 직접 실행해도 같은 효과다.

### SUBTASK 3. 확인

```bash
python -c "import sys; print(sys.prefix != sys.base_prefix)"
```

가상환경 안이면 `True`를 출력한다(이 확인은 실행 검증함).

### SUBTASK 4. 패키지 설치와 목록 저장

```bash
python -m pip install <패키지명>
python -m pip freeze > requirements.txt
```

다른 환경에서는 새 가상환경을 만든 뒤 `python -m pip install -r requirements.txt`로 같은 패키지를 설치한다.

### SUBTASK 5. 비활성화와 삭제

* 비활성화: `deactivate`
* 삭제: 가상환경 폴더(`.venv`)를 지운다. 소스 코드와 `requirements.txt`는 영향이 없다.

## 기능 확인

| 확인 | 기대 결과 |
|---|---|
| `python -c "import sys; print(sys.prefix)"` | 출력이 `.venv` 폴더 경로 |
| `python -m pip list` | 기본 패키지(`pip`) 정도만 표시 |
| 활성화 해제 후 같은 명령 | 시스템 Python 경로 |

## 복구

| 증상 | 조치 |
|---|---|
| `ensurepip is not available` | 배포판의 `python3-venv` 패키지를 설치하고 `.venv`를 지운 뒤 다시 만든다 |
| 폴더를 옮긴 뒤 오류 | `.venv`를 지우고 새로 만들어 `requirements.txt`로 재설치한다 |
| PowerShell에서 스크립트 실행 차단 | 실행 정책 때문이다. 정책 변경 방법은 PowerShell 문서에서 확인한다(미검증) |

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
