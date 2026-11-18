# [생성형 AI] 쿠버네티스 매니페스트 기본 — 파드·디플로이먼트·서비스

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-008-REF |
| 유형 | REF (표) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 파드, 디플로이먼트, 서비스 YAML의 필수 필드와 예를 찾는다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 클러스터에 적용해 확인하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 공통 구조

| 필드 | 설명 |
|---|---|
| `apiVersion` | API 그룹과 버전. 파드·서비스는 `v1`, 디플로이먼트는 `apps/v1` |
| `kind` | 개체 종류 |
| `metadata.name` | 이름. 네임스페이스 안에서 유일해야 한다 |
| `metadata.labels` | 개체를 고르는 데 쓰는 키-값 |
| `spec` | 원하는 상태 |

## 2. 디플로이먼트

| 필드 | 설명 |
|---|---|
| `spec.replicas` | 유지할 파드 수 |
| `spec.selector.matchLabels` | 관리할 파드를 고르는 레이블. `template.metadata.labels`와 일치해야 한다 |
| `spec.template` | 만들 파드의 틀 |
| `containers[].image` | 이미지. `latest` 대신 버전 태그를 쓴다 |
| `containers[].resources` | `requests`(스케줄링 기준)와 `limits`(상한) |
| `readinessProbe`, `livenessProbe` | 트래픽 수신 준비 검사, 생존 검사 |

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:stable
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              memory: 128Mi
          readinessProbe:
            httpGet:
              path: /
              port: 80
```

## 3. 서비스

| 필드 | 설명 |
|---|---|
| `spec.selector` | 트래픽을 보낼 파드의 레이블 |
| `spec.ports[].port` | 서비스가 받는 포트 |
| `spec.ports[].targetPort` | 파드의 포트 |
| `spec.type` | `ClusterIP`(기본, 클러스터 내부), `NodePort`(노드 포트 30000-32767 기본 범위), `LoadBalancer`(클라우드 로드 밸런서) |

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 80
```

## 4. 파드

파드를 직접 만들 수도 있다. 파드가 죽으면 다시 만들어지지 않으므로 보통은 디플로이먼트로 만든다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
    - name: shell
      image: busybox:1.36
      command: ["sleep", "3600"]
```

## 5. 적용과 확인

1. 파일을 적용한다: `kubectl apply -f <파일>` → 결과: `created` 또는 `configured`가 출력된다.
2. 상태를 본다: `kubectl get deploy,svc,pods` → 결과: 파드가 `Running`이고 `READY`가 `1/1`이다.
3. 로컬에서 접속한다: `kubectl port-forward svc/web 8080:80` 후 `curl http://127.0.0.1:8080/` → 결과: 응답이 온다.

{% hint style="warning" %}
CAUTION: 서비스의 `selector`가 파드 레이블과 다르면 서비스에 연결된 파드가 없다. `kubectl get endpoints web`의 값이 비면 레이블을 확인한다.
{% endhint %}

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [쿠버네티스 핵심 이론](kubernetestheory.md) | CLD-K8T-001-DO | 워크로드 개체 |
| [kubectl 명령 정리](kubectl-reference.md) | CLD-K8T-007-REF | 명령 |
| [Dockerfile 이미지 쿠버네티스 배포 명령](../../docker/dockerfile-k8s-deploy.md) | CLD-DKR-014-REF | 명령형 배포 |
