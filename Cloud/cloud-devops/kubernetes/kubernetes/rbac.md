# [생성형 AI] 쿠버네티스 RBAC — 역할 기반 접근 제어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-013-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 사용자와 파드가 API로 할 수 있는 일을 제한하는 RBAC를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 쿠버네티스 공식 문서의 알려진 동작을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

쿠버네티스 API는 파드 조회, 시크릿 읽기, 노드 삭제 같은 모든 작업의 입구다. RBAC(Role-Based Access Control)는 "누가 어떤 자원에 어떤 동작을 할 수 있는가"를 규칙으로 정한다. 최소 권한 원칙에 따라 필요한 권한만 준다.

## 2. 구성 요소

| 번호 | 개체 | 범위 | 역할 |
|---|---|---|---|
| 1 | `Role` | 네임스페이스 | 한 네임스페이스 안의 권한 규칙 묶음 |
| 2 | `ClusterRole` | 클러스터 | 클러스터 전체(노드 등)나 모든 네임스페이스에 적용할 권한 규칙 묶음 |
| 3 | `RoleBinding` | 네임스페이스 | Role 또는 ClusterRole을 주체에게 연결한다. 그 네임스페이스에서만 유효하다 |
| 4 | `ClusterRoleBinding` | 클러스터 | ClusterRole을 주체에게 클러스터 전체로 연결한다 |
| 5 | `ServiceAccount` | 네임스페이스 | 파드가 API를 호출할 때 쓰는 계정 |

주체(subject)는 사용자(User), 그룹(Group), ServiceAccount 중 하나다.

### 2.1 규칙의 필드

| 필드 | 설명 | 예 |
|---|---|---|
| `apiGroups` | API 그룹. 핵심 그룹은 빈 문자열 `""` | `["", "apps"]` |
| `resources` | 자원 종류 | `["pods", "deployments"]` |
| `verbs` | 허용할 동작 | `get`, `list`, `watch`, `create`, `update`, `patch`, `delete` |

## 3. 동작 원리

1. 요청이 API 서버에 들어오면 먼저 인증(누구인가)을 거친다.
2. 인가 단계에서 RBAC가 주체에 연결된 모든 규칙을 확인한다.
3. 허용 규칙이 하나라도 있으면 통과한다. RBAC에는 거부(deny) 규칙이 없다. 허용만 더해진다.
4. 규칙이 없으면 거부된다(기본 거부).

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: <네임스페이스>
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: <네임스페이스>
  name: read-pods
subjects:
  - kind: ServiceAccount
    name: <서비스어카운트명>
    namespace: <네임스페이스>
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl auth can-i list pods -n <네임스페이스> --as system:serviceaccount:<네임스페이스>:<서비스어카운트명>
kubectl get role,rolebinding -n <네임스페이스>
```

{% hint style="danger" %}
WARNING: `cluster-admin` ClusterRole은 모든 자원에 모든 동작을 허용한다. 일반 사용자나 앱의 ServiceAccount에 연결하지 않는다. 침해되면 클러스터 전체를 잃는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `secrets`에 `get`, `list`, `watch`를 주면 그 네임스페이스의 모든 시크릿 값을 읽을 수 있다. 필요한 경우에만 주고, 가능하면 특정 이름으로 제한한다(`resourceNames`).
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| RBAC | Role-Based Access Control. 역할 기반 접근 제어 |
| 주체(Subject) | 권한을 받는 사용자, 그룹, ServiceAccount |
| `roleRef` | 바인딩이 가리키는 Role. 만든 뒤에는 바꿀 수 없다 |
| 최소 권한 | 업무에 필요한 최소한의 권한만 주는 원칙 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [AWS 아키텍처 다이어그램](../../aws/aws.md) | CLD-AWS-001-DO | AWS의 RBAC(IAM) 개념 |
| [컨피그맵과 시크릿](configmap-secret.md) | CLD-K8T-009-DO | 시크릿 접근 |
| [kubectl 명령 정리](kubectl-reference.md) | CLD-K8T-007-REF | `kubectl auth can-i` |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `Role`과 `ClusterRole`, `RoleBinding`과 `ClusterRoleBinding`의 차이를 내 말로 정리해 보자.
- [ ] 로그만 읽는 모니터링 앱에 줄 권한을 정한다면 어떤 `verbs`와 `resources`가 필요한가?
