# [생성형 AI] 멀티 스테이지 빌드와 이미지 경량화

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-024-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 빌드 도구를 최종 이미지에서 빼서 이미지를 작게 만드는 멀티 스테이지 빌드를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 도커 공식 문서의 알려진 동작을 정리한 것이며 이 환경에서 빌드하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

컴파일러, 패키지 관리자, 소스 코드는 빌드할 때만 필요하다. 한 이미지에 모두 담으면 이미지가 커지고 공격 면(attack surface)도 넓어진다. 멀티 스테이지 빌드는 한 Dockerfile 안에 `FROM`을 여러 번 써서 빌드 단계와 실행 단계를 나눈다. 최종 이미지에는 마지막 단계의 내용만 남는다.

## 2. 구성 요소

| 번호 | 요소 | 설명 |
|---|---|---|
| 1 | `FROM <이미지> AS <이름>` | 단계(stage)를 시작하고 이름을 붙인다 |
| 2 | `COPY --from=<이름> <원본> <대상>` | 앞 단계의 파일만 현재 단계로 복사한다 |
| 3 | 빌드 단계 | 컴파일러와 의존성 설치 도구가 있는 이미지를 쓴다 |
| 4 | 실행 단계 | 실행에 필요한 최소 이미지(예: `alpine`, `distroless`)를 쓴다 |
| 5 | `--target <이름>` | `docker build`가 지정한 단계까지만 빌드한다 |

## 3. 동작 원리

1. 빌드 단계에서 소스를 복사하고 컴파일한다.
2. 실행 단계는 새 `FROM`으로 시작하며 앞 단계의 파일 시스템을 물려받지 않는다.
3. `COPY --from`으로 결과물(실행 파일 등)만 가져온다.
4. 최종 이미지는 마지막 단계의 레이어만 포함한다. 앞 단계의 레이어는 빌드 캐시에 남지만 이미지에는 들어가지 않는다.

```dockerfile
FROM golang:<버전> AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -o /out/app .

FROM alpine:<버전>
COPY --from=build /out/app /usr/local/bin/app
USER 10001
ENTRYPOINT ["/usr/local/bin/app"]
```

```bash
docker build -t myapp:1.0 .
docker build --target build -t myapp:build .
docker image ls myapp
docker history myapp:1.0
```

## 4. 경량화 기법

| 번호 | 기법 | 효과 |
|---|---|---|
| 1 | 작은 기본 이미지 선택 (`alpine`, `slim`, `distroless`) | 이미지 크기와 포함된 패키지 수 감소 |
| 2 | `.dockerignore`에 `.git`, 빌드 산출물, 로컬 설정 파일을 적는다 | 빌드 컨텍스트가 줄고 비밀 파일이 이미지에 들어가는 일을 막는다 |
| 3 | 의존성 파일을 먼저 `COPY`하고 설치한 뒤 소스를 `COPY`한다 | 소스만 바뀐 재빌드에서 설치 레이어의 캐시를 재사용한다 |
| 4 | 같은 `RUN`에서 설치와 캐시 정리를 함께 한다 | 지운 파일이 앞 레이어에 남아 크기가 줄지 않는 문제를 피한다 |
| 5 | 비루트 사용자(`USER`)로 실행한다 | 침해 시 피해 범위 감소 |

{% hint style="warning" %}
CAUTION: `alpine`은 glibc 대신 musl을 쓴다. 동적 링크된 실행 파일은 실행 단계에서 동작하지 않을 수 있다. 실행 파일을 정적으로 빌드하거나 같은 libc의 기본 이미지를 쓴다.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| 스테이지(Stage) | Dockerfile에서 `FROM` 하나가 만드는 빌드 단계 |
| 빌드 컨텍스트 | `docker build`가 도커 엔진에 보내는 디렉터리 |
| distroless | 셸과 패키지 관리자 없이 실행 환경만 담은 이미지 계열 |
| 레이어 | 이미지를 이루는 읽기 전용 변경 묶음 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 이미지 개념](docker_image.md) | CLD-DKR-003-DO | 레이어 구조 |
| [Dockerfile 작성법 및 실습](dockerfile.md) | CLD-DKR-010-REF | 지시어 표 |
| [Dockerfile·이미지 보안 점검표](docker-security-checklist.md) | CLD-DKR-022-INS | 비루트 실행, 비밀 값 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 멀티 스테이지 빌드로 이미지가 작아지는 이유를 레이어 개념으로 설명해 보자.
- [ ] 내가 만든 이미지에서 빌드 단계에만 필요한 것은 무엇이었는가?
