# [생성형 AI] Python 가상환경(venv) 만들기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-ENV-006-MP |
| 목적 | 프로젝트마다 독립된 Python 환경을 만들고 활성화·비활성화한다 |
| 적용 대상 | Python 3.3 이상(표준 라이브러리 `venv`), Windows·macOS·Linux |
| 소요 시간 | 약 5분 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 일부 검증 (Python 3.14.4, Linux, 2026-11-19에서 환경 생성, `activate`, `deactivate`를 `--without-pip`로 실행해 확인했다. 이 환경에는 pip와 `ensurepip`가 없어 `pip install` 단계와 Windows·macOS 명령은 미검증이다) |
| 개정 | R1 (2026-11-19) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [pythonsettingwin.md](pythonsettingwin.md) | DEV-ENV-003-MP | Windows Python 환경 설정 (pyenv) |
| [poetry.md](poetry.md) | DEV-ENV-004-DO | Poetry 패키지 관리자 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | Python | 3.3 이상 | `python3 --version` |
| 2 | `venv` 모듈 | 표준 라이브러리 | Debian·Ubuntu에서는 `python3-venv` 패키지가 필요할 수 있다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: `.venv` 폴더는 내용을 다시 만들 수 있는 산출물이다. Git에 올리지 않는다. `.gitignore`에 `.venv/`를 넣는다(DEV-GIT-011-MP).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 프로젝트 폴더로 이동한다 | `pwd`가 프로젝트 폴더를 가리킨다 |
| 2 | Python이 설치돼 있다 | `python3 --version`에 버전이 출력된다 |

## 5. 절차

**A. 만들기**

1. (SUBTASK 5-A-01) `python3 -m venv .venv` 실행 → 결과: `.venv` 폴더가 생긴다. Windows는 `python -m venv .venv`를 쓴다(미검증).
2. (SUBTASK 5-A-02) 내용을 본다: `ls .venv` → 결과: `bin`, `include`, `lib`, `pyvenv.cfg`가 있다. `pyvenv.cfg`에는 기반 Python의 경로와 버전이 적혀 있다.

{% hint style="warning" %}
CAUTION: Debian·Ubuntu에서 `The virtual environment was not created successfully because ensurepip is not available.`가 출력되면 `python3-venv` 패키지가 없는 것이다. 이 환경에서 이 메시지를 확인했다. 패키지를 설치하거나 `--without-pip`로 pip 없는 환경을 만든다.
{% endhint %}

**B. 활성화**

1. (SUBTASK 5-B-01) Linux·macOS: `source .venv/bin/activate` 실행 → 결과: `VIRTUAL_ENV`가 `.venv` 경로로 설정된다. 프롬프트 앞에 `(.venv)`가 붙는다.
2. (SUBTASK 5-B-02) Windows PowerShell: `.venv\Scripts\Activate.ps1`, 명령 프롬프트: `.venv\Scripts\activate.bat` (미검증)
3. (SUBTASK 5-B-03) `python -c "import sys; print(sys.prefix != sys.base_prefix)"` 실행 → 결과: `True`. 가상환경 안이라는 뜻이다.
4. (SUBTASK 5-B-04) 패키지를 설치한다: `python -m pip install <패키지>` → 결과: 패키지가 `.venv` 안에만 설치된다 (미검증).

**C. 비활성화**

1. (SUBTASK 5-C-01) `deactivate` 실행 → 결과: `VIRTUAL_ENV`가 없어지고 프롬프트의 `(.venv)`가 사라진다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 활성화 후 `echo $VIRTUAL_ENV` | `.venv`의 경로 | 경로가 출력됨 |
| 2 | 활성화 후 `sys.prefix != sys.base_prefix` | `True` | `True` |
| 3 | 비활성화 후 `echo ${VIRTUAL_ENV:-unset}` | `unset` | `unset` |

## 7. 복구

1. (7-01) 환경을 지운다: 비활성화한 뒤 `rm -rf .venv` → 결과: 폴더가 사라진다. 소스 코드에는 영향이 없다. 필요하면 5-A부터 다시 만든다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 신규 작성 (생성형 AI 초안) |
