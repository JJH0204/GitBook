# 쿠버네티스 대시보드 배포

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-003-MP |
| 목적 | 쿠버네티스 웹 대시보드(Kubernetes Dashboard) v2.7.0을 배포하고, 서비스 계정 토큰으로 로그인해 클러스터를 웹 화면에서 확인한다 |
| 적용 대상 | 동작 중인 쿠버네티스 클러스터(예: CLD-K8T-002-MP로 만든 클러스터), `kubectl` 관리자 권한 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본의 명령을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 매니페스트 버전 `v2.7.0`은 원본을 따른다. 대시보드 프로젝트의 최신 버전과 유지 상태는 공식 저장소에서 확인한다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kube_setup.md](kube_setup.md) | CLD-K8T-002-MP | 쿠버네티스 노드 설치 및 설정 |
| [kubernetestheory.md](kubernetestheory.md) | CLD-K8T-001-DO | 쿠버네티스 핵심 이론 (Kubernetes) |

외부 참조:

* Kubernetes Dashboard 저장소: https://github.com/kubernetes/dashboard

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 쿠버네티스 클러스터 | 노드 `Ready` | `kubectl get nodes`로 확인 |
| 2 | `kubectl` | 클러스터 버전과 마이너 버전 1 이내 | 클러스터 관리자 권한 설정 필요 |
| 3 | 인터넷 연결 | `raw.githubusercontent.com` 접근 | 매니페스트 내려받기 |
| 4 | 웹 브라우저 | 최신 버전 | 대시보드 접속용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 5-B의 `admin-user`는 `cluster-admin` 권한을 가진다. 이 계정의 토큰은 클러스터 전체를 조작할 수 있는 권한이다. 토큰을 문서, 채팅, 화면 공유, 저장소에 노출하지 않는다. 노출됐다면 7-02로 계정을 삭제하고 5-B로 다시 만든다.
{% endhint %}

{% hint style="danger" %}
WARNING: 대시보드를 NodePort로 노출하면(5-C) 노드가 접근 가능한 네트워크의 누구나 로그인 화면에 접속할 수 있다. 인터넷에 열린 노드에서는 NodePort 노출을 하지 않는다. `kubectl proxy`는 `--address`나 `--accept-hosts` 옵션으로 외부에 열지 않는다. 기본값(로컬호스트 전용)을 유지한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 대시보드 인증서는 자체 서명이므로 브라우저가 보안 경고를 표시한다. 접속 주소가 본인의 노드인지 확인한 뒤에만 경고를 넘긴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클러스터가 정상이다 | `kubectl get nodes`가 모든 노드를 `Ready`로 출력한다 |
| 2 | 현재 컨텍스트가 대상 클러스터다 | `kubectl config current-context` 출력이 대상 클러스터 이름이다 |

## 5. 절차

### A. 대시보드 배포

1. (5-A-01) 대시보드를 배포한다: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml` → 결과: 네임스페이스 `kubernetes-dashboard`와 관련 리소스가 `created`로 출력된다.
2. (5-A-02) 파드 상태를 확인한다: `kubectl get pods -n kubernetes-dashboard` → 결과: `kubernetes-dashboard`, `dashboard-metrics-scraper` 파드가 `Running`이다.

### B. 관리자 계정 생성

1. (5-B-01) 서비스 계정과 권한 바인딩을 만든다. → 결과: `serviceaccount/admin-user created`, `clusterrolebinding.rbac.authorization.k8s.io/admin-user created`가 출력된다.

```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

### C. 접속 경로 선택

접속 경로는 둘 중 하나를 고른다. 로컬에서만 쓰면 C-1을 권장한다.

**C-1. kubectl proxy (권장, 로컬 전용)**

1. (5-C1-01) 프록시를 실행한다: `kubectl proxy` → 결과: `Starting to serve on 127.0.0.1:8001`이 출력된다. 이 터미널은 접속하는 동안 열어 둔다.
2. (5-C1-02) 같은 PC의 브라우저에서 `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`를 연다. → 결과: 대시보드 로그인 화면이 나타난다.

**C-2. NodePort**

{% hint style="danger" %}
WARNING: 이 방식은 3절의 위험이 있다. 폐쇄된 실습망에서만 수행한다.
{% endhint %}

1. (5-C2-01) 서비스 타입을 NodePort로 바꾼다: `kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'` → 결과: `service/kubernetes-dashboard patched`가 출력된다.
2. (5-C2-02) 노드포트를 확인한다: `kubectl get svc -n kubernetes-dashboard` → 결과: `kubernetes-dashboard`의 PORT(S) 열이 `443:<노드포트>/TCP` 형식이다.
3. (5-C2-03) 브라우저에서 `https://<노드 IP 주소>:<노드포트>`를 연다. → 결과: 보안 경고 뒤에 대시보드 로그인 화면이 나타난다.

### D. 접근 토큰 생성

1. (5-D-01) 토큰을 생성한다: `kubectl -n kubernetes-dashboard create token admin-user` → 결과: 긴 문자열이 출력된다. 기본 유효 시간은 1시간이다.
2. (5-D-02) 토큰을 로그인 화면의 `Token` 입력란에 붙여 넣고 `Sign in`을 누른다. → 결과: 대시보드 개요 화면이 나타난다.

{% hint style="danger" %}
WARNING: 원본에는 생성된 토큰 전문이 예시로 적혀 있었다. 토큰은 인증 자격 증명이므로 삭제했다. 이 문서에도 토큰 값을 적지 않는다. 화면에 출력된 토큰은 입력 후 터미널 기록에서 지운다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get pods -n kubernetes-dashboard` | 파드 2개 | 모두 `Running` |
| 2 | 브라우저로 접속해 토큰으로 로그인 | 개요 화면 | `Workloads` 항목에 파드 목록이 보인다 |

## 7. 복구

{% hint style="warning" %}
CAUTION: 아래 삭제 명령은 대시보드와 관리자 계정을 제거한다. 다른 사용자가 같은 대시보드를 쓰고 있지 않은지 확인한다.
{% endhint %}

1. (7-01) NodePort를 썼다면 원래 타입으로 되돌린다: `kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p '{"spec": {"type": "ClusterIP"}}'` → 결과: `patched`가 출력된다.
2. (7-02) 관리자 계정과 바인딩을 삭제한다: `kubectl delete clusterrolebinding admin-user` 그리고 `kubectl -n kubernetes-dashboard delete serviceaccount admin-user` → 결과: 두 리소스가 `deleted`로 출력된다.
3. (7-03) 대시보드를 삭제한다: `kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml` → 결과: 네임스페이스와 리소스가 `deleted`로 출력된다.
4. (7-04) `kubectl proxy`를 실행했다면 해당 터미널에서 `Ctrl+C`로 종료한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 원본에 있던 토큰 예시와 노드 IP, NodePort 번호를 삭제했다. `kubectl proxy` 접속 경로, 안전 사항, 기능 확인, 복구 절차를 추가했다 |
