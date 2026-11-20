# [생성형 AI] GitHub Actions 워크플로 기본

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-CIC-004-REF |
| 유형 | REF (표) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | GitHub Actions 워크플로 파일의 구조와 자주 쓰는 키를 찾는다 |
| 확인 상태 | 미검증 (일반 지식과 GitHub 공식 문서의 알려진 동작을 정리한 것이며 GitHub에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 개요

GitHub Actions는 저장소의 이벤트(푸시, 풀 리퀘스트 등)에 반응해 빌드·테스트·배포를 실행하는 CI/CD 기능이다. 워크플로는 저장소의 `.github/workflows/<이름>.yml` 파일로 정의한다.

## 2. 구조

| 번호 | 키 | 설명 |
|---|---|---|
| 1 | `name` | 워크플로 이름 |
| 2 | `on` | 실행 조건(이벤트) |
| 3 | `permissions` | 작업이 쓸 `GITHUB_TOKEN` 권한 |
| 4 | `jobs.<id>` | 작업. 기본적으로 서로 병렬로 실행된다 |
| 5 | `jobs.<id>.runs-on` | 실행할 러너(가상 머신) 종류. 예: `ubuntu-latest` |
| 6 | `jobs.<id>.needs` | 먼저 끝나야 하는 작업. 순서를 만든다 |
| 7 | `jobs.<id>.steps` | 작업 안의 단계. 위에서 아래로 순서대로 실행된다 |
| 8 | `steps[].uses` | 미리 만들어진 액션을 쓴다 |
| 9 | `steps[].run` | 셸 명령을 실행한다 |
| 10 | `steps[].with` / `env` | 액션 입력값 / 환경 변수 |

## 3. 이벤트(`on`)

| 이벤트 | 설명 |
|---|---|
| `push` | 브랜치나 태그에 푸시할 때. `branches`로 대상을 좁힌다 |
| `pull_request` | 풀 리퀘스트가 열리거나 갱신될 때 |
| `workflow_dispatch` | 사용자가 화면에서 수동으로 실행할 때 |
| `schedule` | 정해진 시각마다. `cron` 표기를 쓴다 (UTC 기준) |

## 4. 예: 테스트 워크플로

```yaml
name: ci
on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npm test
```

| 단계 | 동작 |
|---|---|
| `actions/checkout` | 저장소 코드를 러너로 내려받는다 |
| `actions/setup-node` | 지정한 Node.js 버전을 설치한다 |
| `npm ci` | 잠금 파일 기준으로 의존성을 설치한다 |
| `npm test` | 테스트를 실행한다. 실패하면(종료 코드 0이 아님) 작업이 실패한다 |

## 5. 자주 쓰는 기능

| 기능 | 형식 | 설명 |
|---|---|---|
| 시크릿 | `${{ secrets.<이름> }}` | 저장소 설정에 저장한 비밀 값을 꺼낸다. 로그에서 마스킹된다 |
| 매트릭스 | `strategy.matrix` | 버전·OS 조합마다 같은 작업을 병렬로 실행한다 |
| 캐시 | `actions/cache` 또는 `setup-*`의 `cache` 입력 | 의존성을 재사용해 시간을 줄인다 |
| 조건 | `if: github.ref == 'refs/heads/main'` | 조건이 참일 때만 단계나 작업을 실행한다 |
| 아티팩트 | `actions/upload-artifact` | 빌드 결과물을 저장한다 |

## 6. 보안 점검

{% hint style="danger" %}
WARNING: 시크릿을 `echo`로 출력하거나 코드·워크플로 파일에 직접 적지 않는다. 이미 노출된 값은 즉시 폐기하고 새로 발급한다.
{% endhint %}

| 번호 | 항목 | 이유 |
|---|---|---|
| 1 | `permissions`를 `contents: read`처럼 최소로 둔다 | 토큰이 탈취돼도 피해를 줄인다 |
| 2 | 외부 액션은 신뢰할 수 있는 것만 쓰고, 가능하면 커밋 해시로 고정한다 | 태그가 나중에 다른 코드를 가리키는 공급망 공격을 막는다 |
| 3 | 포크에서 온 풀 리퀘스트에 시크릿을 노출하지 않는다 | 기본적으로 포크 PR에는 시크릿이 전달되지 않는다. `pull_request_target`은 시크릿 접근이 가능하므로 신뢰할 수 없는 코드를 실행하지 않는다 |
| 4 | 이슈 제목·브랜치 이름 같은 외부 입력을 `run`에 직접 끼워 넣지 않는다 | 명령 주입을 막는다. 환경 변수로 받아 쓴다 |

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [CI/CD 기본 개념](cicd-basics.md) | CLD-CIC-003-DO | CI/CD 개념 |
| [DevSecOps 파이프라인 개요](devsecops-overview.md) | CLD-CIC-001-DO | 보안 점검 단계 |
| [Jenkins CI/CD 파이프라인](jenkins.md) | CLD-CIC-002-MP | 다른 CI 도구 |
