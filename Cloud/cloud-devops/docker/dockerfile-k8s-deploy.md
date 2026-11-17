# Dockerfile 이미지 쿠버네티스 배포 명령

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-014-REF |
| 유형 | REF (명령 표) |
| 목적 | 도커로 빌드한 이미지를 쿠버네티스 클러스터에 배포·갱신·삭제할 때 쓰는 `kubectl` 명령을 찾는다 |
| 확인 상태 | 미검증 (원본 `dockerfile.md`의 명령 메모를 정리한 것이며 실행해 확인하지 않았다. 원본의 명령 일부를 정정했다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 명령은 쿠버네티스 클러스터와 `kubectl`이 준비돼 있어야 쓸 수 있다. 클러스터가 로컬 이미지를 볼 수 없으면(예: Kind) 이미지를 클러스터에 불러오거나 레지스트리에 올려야 한다. [Kind 클러스터 도커 이미지 배포](../kubernetes/kubernetes/kubernetes-on-dockerimage.md)를 참조한다.
{% endhint %}

## 1. 명령 표

| 목적 | 명령 | 설명 |
|---|---|---|
| 배포 생성 | `kubectl create deployment my-web-app --image=my-web-app:latest` | 이미지로 Deployment를 만든다 |
| 서비스 노출 | `kubectl expose deployment my-web-app --type=LoadBalancer --port=80 --target-port=80` | Deployment를 서비스로 노출한다 |
| 서비스 확인 | `kubectl get services` | 서비스 목록과 접속 주소를 출력한다 |
| 버전 갱신 | `kubectl set image deployment/my-web-app my-web-app=my-web-app:second` | 컨테이너 이미지를 다른 태그로 바꾼다 |
| 갱신 진행 확인 | `kubectl rollout status deployment/my-web-app` | 배포 갱신이 끝났는지 출력한다 |
| 배포 삭제 | `kubectl delete deployment my-web-app` | Deployment를 삭제한다 |

{% hint style="danger" %}
WARNING: `kubectl delete deployment`는 Deployment와 그 Pod를 삭제해 서비스가 중단된다. 삭제 전에 `kubectl get deployments`로 대상 이름을 확인한다.
{% endhint %}

{% hint style="info" %}
NOTE: `--type=LoadBalancer`는 서비스를 클러스터 밖에 노출한다. 클라우드나 별도 로드 밸런서가 없는 환경에서는 외부 주소가 `<pending>`으로 남을 수 있다.
{% endhint %}

## 2. 원본에서 정정한 명령

| 원본 | 정정 | 이유 |
|---|---|---|
| `kubectl expose --type=LoadBalancer --port:80 --target:80` | `kubectl expose deployment my-web-app --type=LoadBalancer --port=80 --target-port=80` | 대상 리소스 지정이 없었고, 옵션은 `=`로 값을 주며 `--target`은 `--target-port`다 |
| `kubectl set image deployment/my-web-app my-web-app=my-web-app:v2` | `...=my-web-app:second` | 실습(CLD-DKR-011-MP)에서 만든 태그는 `second`이며 `v2`가 아니다 |
| `kubectl service my-web-app`: service start | `kubectl get service my-web-app` | `kubectl service`는 명령이 아니다. 서비스 상태를 보는 명령으로 바꿨다 |
| `kubectl delete deployment/my-web-app`: delete image | 설명을 "배포 삭제"로 변경 | 이 명령은 이미지가 아니라 Deployment를 삭제한다 |

## 3. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Dockerfile 실습: Nginx 웹 페이지 이미지](dockerfile-practice-nginx.md) | CLD-DKR-011-MP | 배포할 이미지를 만든다 |
| [Kind 클러스터 도커 이미지 배포](../kubernetes/kubernetes/kubernetes-on-dockerimage.md) | - | 로컬 클러스터 배포 |
| [kubectl 공식 문서](https://kubernetes.io/docs/reference/kubectl/) | - | 외부 문서 |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `dockerfile.md`의 `kubectl` 메모를 REF로 분리. 잘못된 옵션과 존재하지 않는 명령을 정정하고 삭제 WARNING을 추가했다 |
