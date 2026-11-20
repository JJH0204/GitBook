# [생성형 AI] 네트워크 정책 (NetworkPolicy)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-016-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 파드 사이 통신을 제한하는 NetworkPolicy를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 쿠버네티스 공식 문서의 알려진 동작을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

기본 상태의 쿠버네티스는 모든 파드가 다른 모든 파드와 통신할 수 있다. 침해된 파드 하나가 클러스터의 데이터베이스까지 접근할 수 있다는 뜻이다. NetworkPolicy는 파드 단위로 들어오는(ingress) 통신과 나가는(egress) 통신을 허용 목록으로 제한한다.

## 2. 구성 요소

| 번호 | 필드 | 설명 |
|---|---|---|
| 1 | `podSelector` | 정책을 적용할 파드를 레이블로 고른다. `{}`는 네임스페이스의 모든 파드다 |
| 2 | `policyTypes` | `Ingress`, `Egress` 중 정책이 다룰 방향 |
| 3 | `ingress.from` | 들어오는 통신을 허용할 출발지 (`podSelector`, `namespaceSelector`, `ipBlock`) |
| 4 | `egress.to` | 나가는 통신을 허용할 목적지 |
| 5 | `ports` | 허용할 프로토콜과 포트 |
| 6 | CNI 플러그인 | 정책을 실제로 집행하는 네트워크 플러그인 |

{% hint style="danger" %}
WARNING: NetworkPolicy 개체를 만들어도 정책을 지원하지 않는 CNI에서는 집행되지 않는다. 오류도 나오지 않는다. 쓰는 CNI(예: Calico, Cilium)가 정책을 지원하는지 먼저 확인한다.
{% endhint %}

## 3. 동작 원리

1. 어떤 파드도 정책에 선택되지 않았으면 그 파드의 통신은 모두 허용된다.
2. 파드가 한 방향(예: Ingress)을 다루는 정책에 하나라도 선택되면, 그 방향은 정책이 허용한 통신만 통과한다. 나머지는 거부된다.
3. 정책이 여러 개이면 허용 규칙이 합쳐진다(합집합). 거부 규칙은 없다.
4. 허용 규칙에서 `from`/`to` 안의 항목은 OR, 한 항목 안의 `podSelector`와 `namespaceSelector`를 함께 쓰면 AND로 계산된다.

```yaml
# 네임스페이스의 모든 파드: 들어오는 통신 전부 거부
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes: [Ingress]
---
# db 파드는 app=web 파드에서 오는 3306 포트만 허용
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-to-db
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: web
      ports:
        - protocol: TCP
          port: 3306
```

```bash
kubectl get networkpolicy
kubectl describe networkpolicy allow-web-to-db
```

{% hint style="warning" %}
CAUTION: `Egress`를 막으면 DNS 조회(보통 포트 53, UDP와 TCP)도 막힌다. 서비스 이름으로 접속이 실패하면 DNS 허용 규칙을 추가한다.
{% endhint %}

## 4. 적용 순서(권장)

1. 먼저 네임스페이스에 기본 거부 정책을 둔다.
2. 필요한 통신만 허용 정책으로 추가한다.
3. 정책을 추가한 뒤 서비스 간 통신이 되는지 확인한다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| CNI | Container Network Interface. 파드 네트워크를 구성하는 플러그인 규격 |
| ingress / egress | 파드로 들어오는 / 파드에서 나가는 통신 |
| 기본 거부(default deny) | 허용하지 않은 통신을 모두 막는 구성 |
| `ipBlock` | CIDR 범위로 출발지·목적지를 지정하는 항목 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [쿠버네티스 핵심 이론](kubernetestheory.md) | CLD-K8T-001-DO | 파드·서비스 개념 |
| [인그레스](ingress.md) | CLD-K8T-011-DO | 외부 진입점 |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | 통신 불가 점검 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 정책이 없을 때와 정책이 하나라도 선택했을 때, 파드 통신 기본값은 어떻게 다른가?
- [ ] 웹, API, 데이터베이스 3계층에서 허용해야 할 통신 방향을 그려 보자.
