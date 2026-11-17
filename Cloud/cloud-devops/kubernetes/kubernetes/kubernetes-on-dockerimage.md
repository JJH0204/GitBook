# Kind 클러스터 도커 이미지 배포

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-004-MP |
| 목적 | Docker Hub의 이미지를 Kind 클러스터 노드에 로드하고, 특정 Worker Node에 Deployment로 배포한 뒤 Service와 포트 포워딩으로 접속한다 |
| 적용 대상 | CLD-K8S-001-MP로 만든 Kind 클러스터(이름 `kind`, 노드 `kind-control-plane`, `kind-worker`, `kind-worker2`), Docker, `kubectl`, `kind` |
| 소요 시간 | 약 15분 (이미지 내려받기 시간 제외) |
| 확인 상태 | 미검증 (원본의 명령과 매니페스트를 정리하고 오류를 정정한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 이미지를 `<도커 허브 사용자명>/aurora:latest`로 표기한다. 원본의 이미지 이름은 Docker Hub의 특정 사용자 저장소였다. 본인의 이미지 이름으로 바꿔 쓴다. 컨테이너가 80번 포트에서 HTTP 서비스를 제공한다고 가정한다(원본의 `containerPort: 80`).
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kubernetes_in_windows.md](../kubernetes_in_windows.md) | CLD-K8S-001-MP | Windows 환경 Kind 쿠버네티스 설치 |
| [kubernetestheory.md](kubernetestheory.md) | CLD-K8T-001-DO | 쿠버네티스 핵심 이론 (Kubernetes) |

외부 참조:

* Kind 이미지 로드 공식 문서: https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Kind 클러스터 | Worker Node 1개 이상 | CLD-K8S-001-MP로 생성 |
| 2 | Docker | 동작 중 | `docker version`으로 확인 |
| 3 | `kubectl`, `kind` | 설치됨 | |
| 4 | Docker Hub 이미지 | `<도커 허브 사용자명>/aurora:latest` | 공개 이미지 또는 로그인된 계정 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 태그가 `latest`인 이미지는 쿠버네티스의 기본 `imagePullPolicy`가 `Always`다. 로드한 이미지를 쓰지 않고 Docker Hub에서 다시 받으려 한다. 5-C의 매니페스트에 `imagePullPolicy: IfNotPresent`를 지정한다. 이 정정은 원본에 없던 내용이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Kind 클러스터가 있다 | `kind get clusters`가 `kind`를 출력한다 |
| 2 | 컨텍스트가 Kind 클러스터다 | `kubectl config current-context`가 `kind-kind`다 |

## 5. 절차

### A. 클러스터 노드 확인

1. (5-A-01) 노드 목록을 확인한다: `kubectl get nodes` → 결과: 노드가 모두 `Ready`다.

```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   10m   v1.27.3
kind-worker          Ready    <none>          10m   v1.27.3
kind-worker2         Ready    <none>          10m   v1.27.3
```

### B. 이미지 준비와 노드로 로드

Kind 노드는 도커 컨테이너다. 호스트 Docker에 있는 이미지는 노드 안에서 바로 보이지 않는다. `kind load`로 노드에 복사한다.

1. (5-B-01) 이미지를 호스트로 내려받는다: `docker pull <도커 허브 사용자명>/aurora:latest` → 결과: `Status: Downloaded newer image` 또는 `Image is up to date`가 출력된다. 원본은 이 단계를 적지 않았다. `kind load`는 호스트에 이미 있는 이미지만 복사한다.
2. (5-B-02) 이미지를 모든 노드에 로드한다: `kind load docker-image <도커 허브 사용자명>/aurora:latest --name kind` → 결과: 노드별로 `Image: ... loading` 형식의 로그가 출력된다. 클러스터 이름이 `kind`가 아니면 `--name <클러스터 이름>`으로 바꾼다.
3. (5-B-03) 노드 안의 이미지를 확인한다: `docker exec kind-worker crictl images` → 결과: 목록에 `<도커 허브 사용자명>/aurora`가 있다.

### C. Deployment 배포

1. (5-C-01) `aurora-deployment.yaml` 파일을 만들고 아래 내용을 저장한다. → 결과: 파일이 저장된다. `nodeSelector`는 파드를 `kind-worker`에 배치한다.

{% code title="aurora-deployment.yaml" %}
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aurora-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aurora
  template:
    metadata:
      labels:
        app: aurora
    spec:
      containers:
      - name: aurora-container
        image: <도커 허브 사용자명>/aurora:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/hostname: kind-worker
```
{% endcode %}

2. (5-C-02) 매니페스트를 적용한다: `kubectl apply -f aurora-deployment.yaml` → 결과: `deployment.apps/aurora-deployment created`가 출력된다.

### D. 파드 배치 확인

1. (5-D-01) 파드를 확인한다: `kubectl get pods -o wide` → 결과: `STATUS`가 `Running`이고 `NODE`가 `kind-worker`다.

```
NAME                            READY   STATUS    RESTARTS   AGE   NODE
aurora-deployment-xxxxxx-yyyy   1/1     Running   0          2m    kind-worker
```

### E. Service 노출

{% hint style="info" %}
NOTE: 원본은 Service 타입을 `LoadBalancer`로 적고 출력 예시는 `NodePort`로 적어 서로 달랐다. Kind에는 기본 로드 밸런서가 없어 `LoadBalancer`의 EXTERNAL-IP가 `<pending>`으로 남는다. 이 문서는 `NodePort`로 통일했다.
{% endhint %}

1. (5-E-01) `aurora-service.yaml` 파일을 만들고 아래 내용을 저장한다. → 결과: 파일이 저장된다.

{% code title="aurora-service.yaml" %}
```yaml
apiVersion: v1
kind: Service
metadata:
  name: aurora-service
spec:
  type: NodePort
  selector:
    app: aurora
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```
{% endcode %}

2. (5-E-02) 서비스를 적용한다: `kubectl apply -f aurora-service.yaml` → 결과: `service/aurora-service created`가 출력된다.
3. (5-E-03) 서비스를 확인한다: `kubectl get svc aurora-service` → 결과: TYPE이 `NodePort`이고 PORT(S) 열이 `80:<노드포트>/TCP` 형식이다.

```
NAME             TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
aurora-service   NodePort   <CLUSTER-IP>   <none>        80:<노드포트>/TCP   2m
```

{% hint style="info" %}
NOTE: Kind 노드 IP는 도커 내부 네트워크 주소다. Docker Desktop(Windows, macOS) 환경에서는 호스트 브라우저에서 `<노드 IP 주소>:<노드포트>`로 접속되지 않을 수 있다. 이때는 구역 F의 포트 포워딩을 쓴다.
{% endhint %}

### F. 포트 포워딩으로 접속

1. (5-F-01) 파드 이름을 확인한다: `kubectl get pods` → 결과: `aurora-deployment-<해시>-<접미사>` 형식의 이름이 보인다.
2. (5-F-02) 로컬 포트를 파드의 80번 포트로 연결한다: `kubectl port-forward pod/<파드 이름> 30291:80` → 결과: `Forwarding from 127.0.0.1:30291 -> 80`이 출력된다. 이 터미널은 접속하는 동안 열어 둔다.
3. (5-F-03) 같은 PC의 브라우저에서 `http://localhost:30291`을 연다. → 결과: 애플리케이션 화면이 나타난다.

서비스로 연결하려면 `kubectl port-forward svc/aurora-service 30291:80`을 쓴다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get pods -o wide` | 파드 1개 | `Running`, NODE가 `kind-worker` |
| 2 | `kubectl get svc aurora-service` | 서비스 | TYPE이 `NodePort` |
| 3 | `curl http://localhost:30291` (포트 포워딩 중) | HTTP 응답 | 응답 본문이 출력된다 |

## 7. 복구

1. (7-01) 포트 포워딩 터미널을 `Ctrl+C`로 종료한다.
2. (7-02) Service를 삭제한다: `kubectl delete -f aurora-service.yaml` → 결과: `service "aurora-service" deleted`
3. (7-03) Deployment를 삭제한다: `kubectl delete -f aurora-deployment.yaml` → 결과: `deployment.apps "aurora-deployment" deleted`
4. (7-04) 노드에 로드한 이미지는 클러스터를 삭제하면 함께 사라진다. 클러스터 삭제는 CLD-K8S-001-MP의 7절을 따른다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 대화체를 평서체로 고쳤다. `docker pull` 단계와 `imagePullPolicy: IfNotPresent`를 추가했고, Service 타입을 `NodePort`로 통일했다. 이미지 이름과 잘못된 ClusterIP 예시를 자리 표시자로 바꿨다 |
