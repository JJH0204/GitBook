# [생성형 AI] 영구 볼륨과 클레임 (PV·PVC)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-012-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 파드가 사라져도 데이터를 보존하는 PV, PVC, StorageClass를 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 쿠버네티스 공식 문서의 알려진 동작을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

컨테이너의 파일 시스템은 파드가 삭제되면 함께 사라진다. 데이터베이스처럼 데이터를 남겨야 하는 앱은 파드 수명과 분리된 저장소가 필요하다. 쿠버네티스는 저장소 자체(PV)와 저장소 사용 요청(PVC)을 나눠서 다룬다.

## 2. 구성 요소

| 번호 | 요소 | 역할 |
|---|---|---|
| 1 | PersistentVolume(PV) | 클러스터의 저장소 한 덩어리. 관리자가 만들거나 StorageClass가 자동으로 만든다 |
| 2 | PersistentVolumeClaim(PVC) | 사용자가 "용량과 접근 방식"을 적어 저장소를 요청하는 개체. 네임스페이스에 속한다 |
| 3 | StorageClass | 저장소 종류와 자동 생성(동적 프로비저닝) 방식을 정의한다 |
| 4 | 파드의 `volumes` | PVC 이름을 지정해 파드에 저장소를 붙인다 |

PV는 네임스페이스에 속하지 않는 클러스터 단위 개체다.

### 2.1 접근 모드(accessModes)

| 모드 | 뜻 |
|---|---|
| `ReadWriteOnce` | 노드 하나가 읽기·쓰기로 붙인다 |
| `ReadOnlyMany` | 여러 노드가 읽기 전용으로 붙인다 |
| `ReadWriteMany` | 여러 노드가 읽기·쓰기로 붙인다 |
| `ReadWriteOncePod` | 파드 하나만 읽기·쓰기로 붙인다 |

스토리지 종류에 따라 지원하는 모드가 다르다.

### 2.2 회수 정책(reclaimPolicy)

| 정책 | PVC를 지웠을 때 |
|---|---|
| `Retain` | PV와 데이터를 남긴다. 수동으로 정리한다 |
| `Delete` | PV와 뒤의 실제 저장소를 함께 삭제한다 |

동적 프로비저닝으로 만든 PV의 기본 회수 정책은 StorageClass에서 정한 값이며, 지정하지 않으면 `Delete`다.

## 3. 동작 원리

1. 사용자가 PVC를 만든다 (요청 용량, 접근 모드, StorageClass).
2. 조건에 맞는 PV가 있으면 PVC와 PV가 묶인다(`Bound`). 없고 StorageClass가 동적 프로비저닝을 지원하면 PV를 새로 만든다.
3. 파드가 PVC 이름을 참조하면 해당 저장소가 컨테이너 경로에 붙는다.
4. 파드를 지우고 다시 만들어도 같은 PVC를 쓰면 데이터가 남는다.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data
spec:
  accessModes: [ReadWriteOnce]
  storageClassName: <스토리지클래스명>
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
    - name: app
      image: <이미지>
      volumeMounts:
        - name: data
          mountPath: /var/lib/app
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data
```

```bash
kubectl get pv,pvc
kubectl get storageclass
kubectl describe pvc data
```

{% hint style="danger" %}
WARNING: `reclaimPolicy: Delete`인 PV는 PVC를 삭제하면 실제 데이터도 사라진다. 중요한 데이터는 PVC를 지우기 전에 백업하고 정책을 `Retain`으로 정한다.
{% endhint %}

{% hint style="info" %}
NOTE: PVC가 `Pending`에서 멈추면 `kubectl describe pvc <이름>`의 `Events`를 본다. 흔한 원인은 맞는 StorageClass가 없거나 조건에 맞는 PV가 없는 경우다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| PV | PersistentVolume |
| PVC | PersistentVolumeClaim |
| 동적 프로비저닝 | PVC가 만들어질 때 PV를 자동으로 만드는 방식 |
| `Bound` | PVC와 PV가 연결된 상태 |
| `emptyDir` | 파드가 사는 동안만 있는 임시 볼륨. 파드를 삭제하면 사라진다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 볼륨과 데이터 보존](../../docker/docker-volume.md) | CLD-DKR-020-DO | 도커의 볼륨 |
| [매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | YAML 구조 |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | `Pending` 원인 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] PV와 PVC를 나눈 이유를 개발자와 관리자의 역할로 설명해 보자.
- [ ] 데이터베이스 파드를 지웠다 다시 만들 때 데이터를 지키려면 무엇을 확인해야 하는가?
