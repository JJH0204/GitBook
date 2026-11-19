# [생성형 AI] 인그레스 (Ingress)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-011-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 한 개의 진입점으로 여러 서비스에 HTTP(S) 요청을 나누는 Ingress를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 쿠버네티스 공식 문서의 알려진 동작을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

서비스마다 `LoadBalancer`나 `NodePort`를 열면 진입점이 늘어나고 비용도 는다. Ingress는 호스트 이름과 URL 경로를 기준으로 요청을 서비스에 나누는 규칙이다. 한 개의 진입점에서 여러 서비스를 받는다.

## 2. 구성 요소

| 번호 | 요소 | 역할 |
|---|---|---|
| 1 | Ingress 개체 | 라우팅 규칙을 적은 API 개체(`networking.k8s.io/v1`). 규칙만 정의하고 트래픽을 직접 처리하지 않는다 |
| 2 | 인그레스 컨트롤러 | 규칙을 읽어 실제로 트래픽을 전달하는 프로그램. 클러스터에 따로 설치해야 한다 |
| 3 | `IngressClass` | 어떤 컨트롤러가 이 Ingress를 처리할지 가리킨다 |
| 4 | 서비스(Service) | Ingress가 요청을 넘기는 대상 |
| 5 | TLS 시크릿 | HTTPS용 인증서와 개인 키를 담은 Secret |

컨트롤러 없이 Ingress 개체만 만들면 아무 일도 일어나지 않는다.

## 3. 동작 원리

1. 외부 요청이 인그레스 컨트롤러의 주소(보통 `LoadBalancer` 또는 `NodePort`)로 들어온다.
2. 컨트롤러는 요청의 `Host` 헤더와 URL 경로를 Ingress 규칙과 비교한다.
3. 일치한 규칙의 백엔드 서비스로 요청을 전달한다.
4. 서비스가 요청을 파드 중 하나로 보낸다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
spec:
  ingressClassName: <인그레스클래스명>
  tls:
    - hosts: [<도메인>]
      secretName: <TLS시크릿명>
  rules:
    - host: <도메인>
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
```

| 필드 | 설명 |
|---|---|
| `pathType: Prefix` | 경로를 `/` 단위 접두사로 비교한다 |
| `pathType: Exact` | 경로가 정확히 같을 때만 일치한다 |
| `pathType: ImplementationSpecific` | 일치 방식을 컨트롤러에 맡긴다 |

```bash
kubectl get ingress
kubectl describe ingress web
kubectl get ingressclass
```

{% hint style="warning" %}
CAUTION: 컨트롤러마다 지원하는 어노테이션과 동작이 다르다. 쓰려는 컨트롤러의 문서를 확인한다. Ingress API는 기능이 고정되어 있고, 후속 API로 Gateway API가 있다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 인그레스 컨트롤러 | Ingress 규칙을 실제로 구현하는 프록시 프로그램 |
| 호스트 기반 라우팅 | 도메인 이름으로 대상 서비스를 고른다 |
| 경로 기반 라우팅 | URL 경로로 대상 서비스를 고른다 |
| TLS 종료 | 컨트롤러에서 HTTPS를 풀어 내부는 HTTP로 전달한다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [쿠버네티스 핵심 이론](kubernetestheory.md) | CLD-K8T-001-DO | 서비스 개념 |
| [매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | 서비스 YAML |
| [컨피그맵과 시크릿](configmap-secret.md) | CLD-K8T-009-DO | TLS 시크릿 |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | 백엔드 파드 점검 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Ingress 개체와 인그레스 컨트롤러의 역할은 어떻게 다른가?
- [ ] 서비스마다 `LoadBalancer`를 쓰는 방식과 비교해 Ingress의 장점은 무엇인가?
