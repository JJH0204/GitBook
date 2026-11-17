# VS Code 터미널 실행 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-VSC-001-MP |
| 목적 | Code Runner 확장이 코드를 터미널에서 실행하도록 `Run In Terminal` 설정을 켠다 |
| 적용 대상 | VS Code, Code Runner 확장 설치됨, macOS 기준 |
| 소요 시간 | 약 2분 |
| 확인 상태 | 미검증 (원본 페이지의 메뉴 경로를 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 설정은 VS Code 기본 기능이 아니라 Code Runner 확장의 설정(`code-runner.runInTerminal`)이다. 원본 페이지에는 확장 이름이 없었고 설정 이름 `Code-runner: Run In Terminal`로만 알 수 있었다. 설정을 끄면 Code Runner는 실행 결과를 출력(Output) 패널에 표시한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [vscodecppdevelopment.md](vscodecppdevelopment.md) | DEV-VSC-002-REF | VS Code C 및 C++ 개발 환경 설정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | VS Code | 최신 버전 | |
| 2 | Code Runner 확장 | 확장 탭에서 `Code Runner` 검색 | 설정 이름에 `Code-runner`가 보여야 한다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 설정은 사용자(User) 설정에 저장돼 모든 프로젝트에 적용된다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Code Runner 확장이 설치돼 있는지 확인한다 | 확장 탭의 설치됨 목록에 `Code Runner`가 있다 |

## 5. 절차

### A. 설정 켜기

1. (5-A-01) 설정을 연다: 메뉴바에서 `Code > Preferences > Settings`를 선택한다. → 결과: 설정 화면이 열린다.
2. (5-A-02) 검색창에 `run in terminal`을 입력한다. → 결과: `Code-runner: Run In Terminal` 항목이 보인다.
3. (5-A-03) `Code-runner: Run In Terminal`의 체크 상자를 선택한다. → 결과: 체크 표시가 나타난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 소스 파일에서 Code Runner 실행 버튼을 누른다 | 하단 터미널 패널에서 프로그램이 실행된다 | 출력 패널이 아니라 터미널에 결과가 나온다 |

## 7. 복구

1. (7-01) 5-A-03의 체크 상자를 해제한다. → 결과: 실행 결과가 출력 패널에 표시된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 설정이 Code Runner 확장의 것임을 명시하고 AMM 형식으로 재작성 |
