# Kubernetes on dockerImage

여기서는 Kind 클러스터의 특정 노드에서 Docker Hub 이미지 krjaeh0/aurora:latest 를 실행하는 방법을 단계별로 정리했어.

{% stepper %}
{% step %}
### 1. Kind 클러스터에서 Docker 실행 지원 확인

Kind 노드들은 기본적으로 컨테이너 환경에서 실행되므로, 클러스터 내부에서 추가 Docker 컨테이너를 실행하려면 다음을 확인해야 해.

#### 컨트롤 플레인에서 노드 확인

Kind 클러스터에서 노드 목록 확인:

```bash
kubectl get nodes
```

출력 예시:

```
NAME                     STATUS   ROLES           AGE   VERSION
kind-control-plane       Ready    control-plane   10m   v1.27.3
kind-worker              Ready    <none>          10m   v1.27.3
kind-worker2             Ready    <none>          10m   v1.27.3
```
{% endstep %}

{% step %}
### 2. krjaeh0/aurora:latest 이미지 실행 준비

#### 이미지를 노드에 가져오기

Kind 노드 내에서 Docker 이미지를 사용할 수 있도록 이미지를 노드로 가져와야 해.

* 이미지 로드 (kind는 클러스터 내부 노드에 직접 이미지를 로드할 수 있는 명령을 제공함):

```bash
kind load docker-image krjaeh0/aurora:latest --name <클러스터이름>
```

위 명령에서 `<클러스터이름>`은 클러스터 생성 시 사용한 이름이야. 기본적으로 `kind`라는 이름일 가능성이 높아:

```bash
kind load docker-image krjaeh0/aurora:latest --name kind
```

* 이미지 확인: 이미지가 정상적으로 로드되었는지 확인하려면:

```bash
kubectl describe nodes
```
{% endstep %}

{% step %}
### 3. Deployment 생성 및 특정 노드에 할당

이제 krjaeh0/aurora:latest 이미지를 실행하기 위해 Deployment를 생성하고, 특정 노드에 할당할 수 있어.

#### Deployment YAML 파일 작성

`aurora-deployment.yaml`처럼 Deployment 파일을 작성해:

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
        image: krjaeh0/aurora:latest
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/hostname: kind-worker  # 특정 노드에 배포
```

여기서 `nodeSelector`는 Pod가 특정 노드(예: `kind-worker`)에 배포되도록 지정하는 설정이야.

#### Deployment 적용

작성한 YAML 파일을 클러스터에 적용해:

```bash
kubectl apply -f aurora-deployment.yaml
```
{% endstep %}

{% step %}
### 4. Pod 배포 확인

배포된 Pod가 올바르게 동작하는지 확인하려면:

```bash
kubectl get pods -o wide
```

출력 예시:

```
NAME                                READY   STATUS    RESTARTS   AGE   NODE
aurora-deployment-xxxxxx-yyyy       1/1     Running   0          2m    kind-worker
```

여기서 `NODE` 열에서 Pod가 `kind-worker` 노드에 실행 중인 것을 확인할 수 있어.
{% endstep %}

{% step %}
### 5. 서비스 노출

외부에서 Pod에 접근하려면 Service를 설정해야 해.

#### Service YAML 작성

`aurora-service.yaml` 파일 작성:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: aurora-service
spec:
  type: LoadBalancer
  selector:
    app: aurora
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

#### Service 적용

```bash
kubectl apply -f aurora-service.yaml
```

#### Service 확인

```bash
kubectl get svc aurora-service
```

출력 예시:

```
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
aurora-service   NodePort    10.96.123.456    <none>        80:30000/TCP   2m
```

위 출력에서 `30000`은 클러스터 외부에서 접속할 수 있는 노드 포트야. 브라우저에서 `http://<노드 IP>:30000`으로 접근하면 krjaeh0/aurora:latest가 실행 중인 애플리케이션에 접속할 수 있어.

#### Port Forwarding(선택)

Kind 클러스터와 로컬 머신 간 연결 문제를 우회하기 위해 `kubectl port-forward`를 사용해볼 수 있어.

* Pod 이름 확인:

```bash
kubectl get pods
```

예: `aurora-deployment-5c54fc85d7-29zms`

* 포트 포워딩 실행 (Pod의 포트를 로컬 머신의 포트로 포워딩):

```bash
kubectl port-forward pod/aurora-deployment-5c54fc85d7-29zms 30291:80
```

* 로컬에서 접근: 이제 `http://localhost:30291`로 접근하면 Pod의 서비스에 연결될 거야.
{% endstep %}
{% endstepper %}
