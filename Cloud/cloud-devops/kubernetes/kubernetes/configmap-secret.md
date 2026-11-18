# [생성형 AI] 컨피그맵과 시크릿

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-009-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 설정과 비밀값을 이미지 밖에서 파드에 전달하는 ConfigMap과 Secret을 설명한다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

설정값과 비밀번호를 이미지에 넣으면 환경마다 이미지를 다시 만들어야 하고 비밀이 노출된다. 쿠버네티스는 이를 별도 개체로 분리해 파드에 전달한다.

## 2. 구성 요소

| 번호 | 개체 | 용도 | 저장 형태 |
|---|---|---|---|
| 1 | ConfigMap | 일반 설정(환경 변수, 설정 파일) | 평문 |
| 2 | Secret | 비밀번호, 토큰, 키 | base64 인코딩 |

파드가 값을 받는 방식은 두 가지다.

| 방식 | 설명 | 값 변경 시 |
|---|---|---|
| 환경 변수 | `env.valueFrom` 또는 `envFrom`으로 주입 | 파드를 다시 만들어야 반영된다 |
| 볼륨 마운트 | 파일로 마운트 | 한참 뒤 자동 갱신된다. `subPath`로 마운트한 파일은 갱신되지 않는다 |

## 3. 동작 원리

```bash
kubectl create configmap app-config --from-literal=LOG_LEVEL=info
kubectl create secret generic db-secret --from-literal=password='<비밀번호>'
```

```yaml
# 파드 spec.containers[] 안
env:
  - name: LOG_LEVEL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: LOG_LEVEL
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

{% hint style="danger" %}
WARNING: Secret의 base64는 암호화가 아니라 인코딩이다. `base64 -d`로 누구나 풀 수 있다. 기본 설정에서는 etcd에도 암호화 없이 저장된다. Secret을 읽을 수 있는 권한(RBAC)을 제한하고, 필요하면 etcd 저장 시 암호화를 켠다. Secret YAML을 저장소에 올리지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `--from-literal`로 입력한 비밀번호는 셸 기록(history)에 남는다. 파일에서 읽는 `--from-file`을 쓰거나 기록이 남지 않게 입력한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ConfigMap | 설정 데이터를 담는 개체 |
| Secret | 비밀 데이터를 담는 개체 |
| RBAC | 역할 기반 접근 제어 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [쿠버네티스 매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | 파드 YAML |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | `CreateContainerConfigError` |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Secret은 왜 암호화된 것이 아닌가?
- [ ] 환경 변수 주입과 볼륨 마운트 중 설정을 자주 바꾸는 앱에는 무엇이 맞는가?
