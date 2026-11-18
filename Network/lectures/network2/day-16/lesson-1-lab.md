# 내 이미지 올리기 실습

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-009-MP |
| 목적 | 14일차에 구운 `mysite:1.0` 이미지를 파일로 떠서 kind 클러스터에 넣고, `latest` 태그로 `ErrImagePull`을 일부러 내 본 뒤, 매니페스트로 Pod를 `Running`으로 만든다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x, kind 클러스터 `student`(포트 매핑 설정 포함) |
| 소요 시간 | 약 35분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 클러스터에서 실행해 확인하지 않았다. 원본 리허설에서 `docker image save` 단계만 확인되었다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-16-001-DO | 내 이미지를 클러스터로 |
| [lesson-0-lab.md](lesson-0-lab.md) | LEC-N2-16-008-MP | 클러스터 재생성 실습 |
| [commands.md](commands.md) | LEC-N2-16-007-REF | 16일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 한 개 |
| 2 | Docker Engine | 29.x | `mysite:1.0` 이미지가 있어야 한다 |
| 3 | kind 클러스터 | 이름 `student` | 클러스터 재생성 실습을 마친 상태 |
| 4 | 브라우저 | Windows | 5-D에서 사용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Pod 이름은 사람마다 다르다. `kubectl get pods`로 확인한 이름을 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클러스터가 떠 있다 | `kubectl get nodes`가 `Ready`를 출력한다 |
| 2 | 이미지가 있다 | `docker images \| grep mysite`가 `1.0`을 출력한다 |
| 3 | 매니페스트 폴더가 있다 | `ls ~/myweb/k8s`가 오류 없이 끝난다. 없으면 5-C-01에서 만든다 |

## 5. 절차

### A. 이미지를 파일로 떠서 노드에 넣는다

1. (5-A-01) 이미지를 파일로 뜬다: `docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0` → 결과: `/tmp/mysite.tar`가 생긴다(약 28MB).
2. (5-A-02) 노드에 넣는다: `kind load image-archive /tmp/mysite.tar --name student` → 결과: 오류 없이 끝난다.
3. (5-A-03) 노드 안의 이미지 목록을 확인한다: `docker exec student-control-plane crictl images | grep mysite` → 결과: `mysite`와 태그 `1.0`이 보인다.

{% hint style="info" %}
NOTE: 짧은 길인 `kind load docker-image mysite:1.0 --name student`도 있다. 될 때도 있지만 Docker 29에서 `ctr: content digest ... not found`로 실패할 수 있다. 이 문서는 처음부터 위 두 줄로 간다.
{% endhint %}

### B. 일부러 틀려 본다: `ErrImagePull`

1. (5-B-01) `latest` 태그로 Deployment를 만든다: `kubectl create deployment bad --image=mysite:latest`
2. (5-B-02) Pod 상태를 본다: `kubectl get pods` → 결과: `bad-...` Pod의 STATUS가 `ErrImagePull` 또는 `ImagePullBackOff`이다.
3. (5-B-03) 원인을 본다: `kubectl describe pod -l app=bad | tail -8` → 결과: `Failed to pull image "mysite:latest"` 계열의 경고가 보인다.
4. (5-B-04) Deployment를 지운다: `kubectl delete deployment bad` → 결과: `deployment.apps "bad" deleted`.

{% hint style="info" %}
NOTE: `latest`는 기본 정책이 `Always`이므로 밖에서 받으려 한다. 이 실험에서는 노드에 `mysite:latest`가 없으므로 어느 정책이어도 실패한다. 정책의 차이는 매니페스트에 `imagePullPolicy`를 적어 확인한다.
{% endhint %}

### C. 매니페스트로 띄운다

1. (5-C-01) 폴더를 만들고 이동한다: `mkdir -p ~/myweb/k8s && cd ~/myweb/k8s`
2. (5-C-02) `nano deployment.yaml`로 파일을 연다.
3. (5-C-03) 아래 내용을 입력하고 저장한다(`Ctrl+O`, Enter, `Ctrl+X`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysite
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysite
  template:
    metadata:
      labels:
        app: mysite
    spec:
      containers:
      - name: mysite
        image: mysite:1.0
        imagePullPolicy: IfNotPresent     # 노드에 있으면 그것을 쓴다
        ports:
        - containerPort: 80
```

4. (5-C-04) 문법을 검사한다: `kubectl apply -f deployment.yaml --dry-run=client` → 결과: `deployment.apps/mysite created (dry run)`.
5. (5-C-05) 적용한다: `kubectl apply -f deployment.yaml` → 결과: `deployment.apps/mysite created`.
6. (5-C-06) Pod를 확인한다: `kubectl get pods` → 결과: `mysite-...`의 STATUS가 `Running`이다.

### D. 브라우저로 확인한다

{% hint style="warning" %}
CAUTION: 클러스터 재생성 실습에서 호스트 8080 포트를 노드 컨테이너에 연결했다. `kubectl port-forward`로 같은 8080을 쓰면 포트 충돌이 날 수 있다. 이 문서는 8081을 쓴다.
{% endhint %}

1. (5-D-01) 포트를 전달한다: `kubectl port-forward deployment/mysite 8081:80` → 결과: `Forwarding from 127.0.0.1:8081 -> 80`이 나오고 터미널이 점유된다.
2. (5-D-02) Windows 브라우저에서 `http://localhost:8081`을 연다. → 결과: 13일차에 만든 내 포트폴리오가 보인다.
3. (5-D-03) `Ctrl+C`로 전달을 끝낸다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker exec student-control-plane crictl images \| grep mysite` | `mysite 1.0` | 한 줄 이상 보인다 |
| 2 | `kubectl get pods` | `mysite-...` | STATUS가 `Running`이다 |
| 3 | 5-B-02의 STATUS | `ErrImagePull` 또는 `ImagePullBackOff` | 오류 상태가 보였다 |
| 4 | 브라우저 | 내 포트폴리오 | 기본 nginx 화면이 아니다 |

## 7. 복구

1. (7-01) Deployment를 지운다: `kubectl delete deployment mysite` → 결과: `deployment.apps "mysite" deleted`. 이후 실습이 이 Deployment를 쓰므로 모든 실습을 마친 뒤에만 실행한다.
2. (7-02) tar 파일을 지운다: `rm /tmp/mysite.tar`
3. (7-03) 이미지를 노드에서 빼려면 클러스터를 다시 만든다: [클러스터 재생성 실습](lesson-0-lab.md)

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-1.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. `deployment.yaml` 전문과 복구 절을 추가했다. 포트 전달 번호를 8081로 바꿨다 |
