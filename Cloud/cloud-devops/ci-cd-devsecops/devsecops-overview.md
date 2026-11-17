# DevSecOps 파이프라인 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-CIC-001-DO |
| 유형 | D&O (개념) |
| 목적 | DevSecOps 실습 파이프라인의 구성 요소와 흐름을 설명한다 |
| 확인 상태 | 미검증 (원본 `jenkins.md`의 다이어그램 라벨을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 `jenkins.md`에 섞여 있던 개념 설명을 분리한 것이다. 설정 절차는 [Jenkins CI/CD 파이프라인](jenkins.md)(CLD-CIC-002-MP)에 있다.
{% endhint %}

## 1. 목적

DevSecOps는 개발(Dev), 보안(Sec), 운영(Ops)을 파이프라인으로 묶어 코드 변경마다 빌드와 보안 점검을 자동으로 수행하는 방식이다. 이 문서는 실습에 쓰는 도구와 그 관계를 정리한다.

## 2. 구성 요소

| 번호 | 구성 요소 | 역할 | 비고 |
|---|---|---|---|
| 1 | 개발자 IDE | 코드를 작성한다 | |
| 2 | GitHub | 소스 저장소다. 커밋과 푸시를 받는다 | 점검 대상으로 취약한 웹 앱 WebGoat를 포크해 쓴다 |
| 3 | Jenkins | CI/CD 서버다. 변경 사항을 감지해 파이프라인을 실행한다 | 도커 이미지로 실행할 수 있다 |
| 4 | SonarQube | 정적 분석(SAST) 도구다 | 인증 설정이 필요하다 |
| 5 | Maven, Gradle | 빌드 도구다 | Jenkins에 설치하거나 프로젝트의 래퍼(`mvnw`)를 쓴다 |
| 6 | Docker | 도구를 컨테이너로 실행한다 | |
| 7 | Grafana, Prometheus, ELK 스택 | 모니터링과 로그 분석 도구다 | 원본은 이름만 적었다 |

## 3. 동작 원리

1. 개발자가 소스를 GitHub에 커밋하고 푸시한다.
2. Jenkins가 변경 사항을 감지한다.
3. Jenkins 파이프라인이 소스를 가져오고(Checkout) 빌드한다.
4. 빌드 후 SonarQube 작업을 호출해 SAST를 수행한다.
5. 배포 단계는 원본에서 구현하지 않았다.
6. 모니터링 도구가 실행 상태와 로그를 수집한다.

파이프라인(pipeline)은 개발, 빌드, 테스트, 배포 과정을 자동화하고 관리하는 일련의 단계다.

{% hint style="info" %}
NOTE: SonarQube는 생성형 AI처럼 동작하지 않는다. 규칙(Rule) 기반으로 패턴을 검사한다. 규칙은 직접 작성하거나 외부 규칙을 가져와 적용할 수 있다.
{% endhint %}

## 4. 약어·용어

| 약어 | 풀이 |
|---|---|
| CI | Continuous Integration, 지속적 통합 |
| CD | Continuous Delivery/Deployment, 지속적 제공/배포 |
| SAST | Static Application Security Testing, 정적 애플리케이션 보안 테스트 |
| SCM | Source Control Management |
| WebGoat | 보안 학습용으로 만든 의도적 취약 웹 애플리케이션 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] CI와 CD의 차이를 내 말로 설명한다.
- [ ] SAST가 잡을 수 있는 문제와 잡지 못하는 문제를 하나씩 적는다.
- [ ] 직접 파이프라인을 써 본 경험이 있다면 어느 단계에서 막혔는가?
