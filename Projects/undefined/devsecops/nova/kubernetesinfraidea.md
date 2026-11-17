# 쿠버네티스 인프라 구상 (K8s)

로컬 클러스터 구축: 각 노드를 도커 컨테이너로 실행하고 관리하기 쉽게 제공\
테스트 및 개발 용이: 자체 테스트를 위해 설계되었지만, 로컬 개발이나 CI 환경에서 유용하게 사용가능\
멀티 노드 지원: 단일 노드 뿐 아니라 멀티 노드 클러스터 구성도 지원\
kubeadm 기반 설정: 쿠버네티스 클러스터 노드 구성을 위해 공식 도구인 kubeadm을 사용하여 실제 배포 환경과 유사한 설정을 제공

docker 설치

클러스터 생성

kind 설치

클러스터 확인

클러스터 삭제

go install sigs.k8s.io/kind@v0.26.0

## 기본 클러스터 생성

다음 명령으로 기본 클러스터를 생성합니다:

{% stepper %}
{% step %}
### 기본 클러스터 생성

```bash
kind create cluster
```
{% endstep %}

{% step %}
### 멀티 노드 클러스터 생성

kind-config.yaml

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

클러스터 생성 명령:

```bash
kind create cluster --config=kind-config.yaml 
```

클러스터 상태 확인:

```bash
kubectl get nodes
kubectl get pods -A
```

클러스터 삭제:

```bash
kind delete cluster
```
{% endstep %}
{% endstepper %}

***
