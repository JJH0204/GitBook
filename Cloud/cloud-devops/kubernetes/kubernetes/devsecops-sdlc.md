# 보안 중심 SDLC와 SAST/DAST

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-006-DO |
| 유형 | D&O (개념) |
| 목적 | 소프트웨어 개발 생명주기(SDLC)의 단계마다 필요한 보안 활동과 정적·동적 분석(SAST/DAST)의 차이를 설명한다 |
| 확인 상태 | 미검증 (원본 `eks.md`에 섞여 있던 메모를 분리해 정리했고 공개된 일반 지식으로 보충했다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 [AWS EKS 구축 및 운영](eks.md)(CLD-K8T-005-MP)에 섞여 있던 개념 설명을 분리한 것이다. CI/CD 파이프라인 도구 목록은 [DevSecOps 파이프라인 개요](../../ci-cd-devsecops/devsecops-overview.md)(CLD-CIC-001-DO)에 있다. 원본의 일부 항목은 빈 칸이어서 일반적인 내용으로 채우고 표시했다.
{% endhint %}

## 1. 목적

DevSecOps는 개발(Dev), 보안(Sec), 운영(Ops)을 합친 방식이다. 보안을 마지막에 점검하지 않고 계획부터 운영까지 모든 단계에 넣는다. 이 문서는 단계별 보안 활동과 SAST, DAST의 차이를 정리한다.

## 2. 구성 요소

### 2.1 보안 중심 SDLC 단계

| 번호 | 단계 | 보안 활동 | 비고 |
|---|---|---|---|
| 1 | 기획 | 보안 요구 사항을 정하고 예상 가능한 보안 위협을 모델링한다 | |
| 2 | 구현 | 구현 단계의 보안 위협을 점검한다. 정적 분석(SAST)을 수행한다 | 원본 라벨은 "SAST, DAST" |
| 3 | 테스트 | 빌드된 애플리케이션을 실행해 동적 분석(DAST)을 수행한다 | 원본은 비어 있었다. 일반 지식으로 채웠다 |
| 4 | 배포 | 접근 제어를 적용하고 침투 테스트를 수행한다 | |
| 5 | 운영 | 로깅, 웹 방화벽(WAF), 보안 패치를 적용한다 | |
| 6 | 모니터링 | 보안 정보·이벤트 관리(SIEM)와 취약점 모니터링 도구로 공격을 탐지한다 | |

### 2.2 단계별 목표

| 번호 | 단계 | 목표 |
|---|---|---|
| 1 | 기획 | 초기 계획 단계에서 보안을 고려한다 |
| 2 | 구현 | 코드가 안전하게 작성되고 저장되도록 보안 검증을 수행한다 |
| 3 | 빌드·테스트 | 빌드된 애플리케이션의 보안을 검증한다 |
| 4 | 배포 | 애플리케이션을 안전하게 배포한다 |
| 5 | 운영 | 운영 중인 애플리케이션의 보안을 유지한다 |
| 6 | 모니터링 | 지속적으로 보안 상태를 감시하고 개선 사항을 수집한다 |

### 2.3 SAST와 DAST

| 번호 | 구분 | 정의 | 시점 |
|---|---|---|---|
| 1 | SAST | Static Application Security Testing. 코드를 실행하기 전에 정적 분석으로 코드 안의 보안 취약점을 찾는다 | 구현, 빌드 |
| 2 | DAST | Dynamic Application Security Testing. 프로그램을 실행해 동적 분석으로 보안 취약점을 찾는다 | 테스트, 운영 전 |

### 2.4 분석 방식

| 번호 | 방식 | 장점 | 한계 |
|---|---|---|---|
| 1 | 직접 분석(수동) | 개발자의 의도를 파악해 코드를 점검할 수 있다 | 대량의 코드를 점검하기에 적절하지 않다 |
| 2 | 자동 분석(도구) | 객관적인 분석 결과를 얻는다 | 이미 알려진 취약점에만 대응할 수 있다 |

{% hint style="info" %}
NOTE: 원본의 마지막 항목 "소프트웨어 개발보안 검사원(진단원)"은 설명 없이 이름만 있었다. 소프트웨어 개발 보안 점검을 수행하는 직무나 자격으로 보이나 정확한 명칭과 내용은 확인 필요다.
{% endhint %}

## 3. 동작 원리

1. 개발자가 소스를 수정하고 저장소에 커밋한다.
2. CI 서버가 빌드와 단위 테스트를 수행한다.
3. SAST 도구가 소스를 정적 분석해 취약점을 보고한다.
4. 테스트 환경에 배포하고 DAST 도구가 실행 중인 애플리케이션을 점검한다.
5. 통과하면 운영에 배포하고 모니터링과 로깅으로 상태를 관찰한다.
6. 발견된 문제는 다음 소스 수정으로 되돌아간다.

## 4. 약어·용어

| 용어 | 풀이 |
|---|---|
| SDLC | Software Development Life Cycle, 소프트웨어 개발 생명주기 |
| SAST | Static Application Security Testing |
| DAST | Dynamic Application Security Testing |
| WAF | Web Application Firewall, 웹 방화벽 |
| SIEM | Security Information and Event Management |
| CI/CD | Continuous Integration / Continuous Delivery(또는 Deployment) |

{% hint style="warning" %}
CAUTION: 원본은 CI를 "Continous Intergrity"로 적었다. CI는 Continuous Integration(지속적 통합)이다. 정정했다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [devsecops-overview.md](../../ci-cd-devsecops/devsecops-overview.md) | CLD-CIC-001-DO | DevSecOps 파이프라인 개요 |
| [eks.md](eks.md) | CLD-K8T-005-MP | AWS EKS 구축 및 운영 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] SAST와 DAST가 각각 잡기 쉬운 취약점과 놓치기 쉬운 취약점을 하나씩 적는다.
- [ ] 보안 점검을 개발 마지막이 아닌 모든 단계에 넣는 이유를 내 말로 설명한다.
- [ ] 내가 만든 프로젝트에 위 6단계를 적용한다면 가장 먼저 넣을 활동을 적는다.
