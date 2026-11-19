# [생성형 AI] 리소스 요청·제한과 오토스케일링 (HPA)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-015-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 파드의 CPU·메모리 요청과 제한, 부하에 따라 파드 수를 조절하는 HPA를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 쿠버네티스 공식 문서의 알려진 동작을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

파드가 쓸 자원을 정하지 않으면 한 파드가 노드 자원을 독점하거나, 스케줄러가 배치를 잘못 정할 수 있다. 자원의 요청(requests)과 제한(limits)으로 이를 막고, HPA(Horizontal Pod Autoscaler)로 부하에 맞게 파드 수를 자동으로 늘리고 줄인다.

## 2. 구성 요소

### 2.1 요청과 제한

| 항목 | 의미 | 초과했을 때 |
|---|---|---|
| `requests` | 스케줄러가 노드를 고를 때 보장해야 하는 양 | 노드에 남은 양이 부족하면 파드가 배치되지 않고 `Pending`이 된다 |
| `limits` | 컨테이너가 쓸 수 있는 최대량 | CPU는 속도가 제한(throttling)되고, 메모리는 컨테이너가 `OOMKilled`로 종료된다 |

| 단위 | 설명 |
|---|---|
| `500m` | CPU 0.5코어 (m은 밀리코어, 1000m = 1코어) |
| `256Mi` | 메모리 256 메비바이트 |

```yaml
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

### 2.2 QoS 등급

| 등급 | 조건 | 자원이 부족할 때 |
|---|---|---|
| `Guaranteed` | 모든 컨테이너에서 requests와 limits가 같게 지정됨 | 가장 늦게 쫓겨난다 |
| `Burstable` | requests가 지정되었으나 Guaranteed 조건이 아님 | 중간 |
| `BestEffort` | requests와 limits가 모두 없음 | 가장 먼저 쫓겨난다 |

### 2.3 HPA

| 요소 | 설명 |
|---|---|
| `scaleTargetRef` | 조절할 대상(예: 디플로이먼트) |
| `minReplicas`, `maxReplicas` | 파드 수의 하한과 상한 |
| `metrics` | 판단 기준 (CPU·메모리 사용률 등) |
| metrics-server | 파드의 사용량을 모아 API로 제공하는 구성 요소. HPA의 CPU·메모리 기준에 필요하다 |

## 3. 동작 원리

1. metrics-server가 파드의 현재 사용량을 수집한다.
2. HPA가 일정 주기로 현재 값과 목표 값을 비교한다.
3. 원하는 파드 수를 `ceil[현재 파드 수 × (현재 값 ÷ 목표 값)]`로 계산한다. 결과는 `minReplicas`와 `maxReplicas` 사이로 맞춘다.
4. 대상 디플로이먼트의 `replicas`를 바꾼다.

사용률(utilization)은 파드의 `requests` 대비 비율이다. `requests`를 지정하지 않으면 HPA가 CPU·메모리 사용률을 계산하지 못한다.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

```bash
kubectl top pod
kubectl get hpa
kubectl describe hpa web
```

{% hint style="warning" %}
CAUTION: HPA를 쓰는 디플로이먼트의 `replicas`를 매니페스트에 고정해 두고 다시 적용하면 HPA가 정한 값을 덮어쓸 수 있다. HPA와 `replicas`를 함께 관리하는 방식을 정한다.
{% endhint %}

{% hint style="info" %}
NOTE: HPA는 파드 수를 조절한다. 노드 수를 늘리려면 별도의 클러스터 오토스케일러가 필요하다. 이 쪽은 다루지 않는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| HPA | Horizontal Pod Autoscaler. 파드 수를 수평으로 조절 |
| Throttling | CPU limit에 도달해 실행 속도가 제한되는 현상 |
| `OOMKilled` | 메모리 제한 초과로 종료된 컨테이너 상태 |
| metrics-server | 자원 사용량 수집 구성 요소 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | 디플로이먼트 YAML |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | `Pending`, `OOMKilled` |
| [컨테이너 로그와 리소스 제한](../../docker/docker-logs-resources.md) | CLD-DKR-025-REF | 도커의 자원 제한 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `requests`와 `limits`의 차이를 파드 배치와 실행 두 관점으로 설명해 보자.
- [ ] HPA의 CPU 사용률 기준이 `requests` 없이 동작하지 않는 이유는 무엇인가?
