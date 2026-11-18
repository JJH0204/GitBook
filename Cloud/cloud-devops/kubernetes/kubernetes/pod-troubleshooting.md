# [생성형 AI] 파드 장애 진단

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-010-TS |
| 유형 | TS (문제 해결) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 파드가 `Running`이 되지 않거나 서비스에 연결되지 않을 때 원인을 좁힌다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 증상과 가능 원인

| 번호 | 증상(STATUS) | 가능 원인 | 확인 |
|---|---|---|---|
| 1 | `Pending` | 노드에 자원이 부족하다. 노드 선택 조건·taint 불일치. 볼륨 클레임이 연결되지 않았다 | `kubectl describe pod`의 `Events` (`FailedScheduling`) |
| 2 | `ImagePullBackOff`, `ErrImagePull` | 이미지 이름·태그 오류, 비공개 저장소 인증 없음, 레지스트리 접속 불가 | `Events`의 이미지 이름과 오류 문구 |
| 3 | `CrashLoopBackOff` | 컨테이너가 시작 후 반복 종료한다. 앱 오류, 설정 누락, 잘못된 명령 | `kubectl logs <파드> --previous` |
| 4 | `CreateContainerConfigError` | 참조한 ConfigMap·Secret이 없다 | `Events` |
| 5 | `OOMKilled` (마지막 종료 사유), 종료 코드 137 | 메모리 `limits` 초과 | `kubectl describe pod`의 `Last State` |
| 6 | `Running`이지만 `READY 0/1` | readiness probe가 실패한다 | `describe`의 probe 설정과 `Events` |
| 7 | 서비스로 접속되지 않는다 | 서비스 `selector`와 파드 레이블 불일치, `targetPort` 오류 | `kubectl get endpoints <서비스>` |
| 8 | 노드가 `NotReady` | CNI 플러그인 미설치, kubelet 중지, 노드 자원 부족 | `kubectl describe node <노드>` |

## 2. 격리 절차

1. (2-01) 파드 상태를 본다: `kubectl get pods -o wide` → 결과: `STATUS`와 배치된 노드가 보인다.
2. (2-02) 이벤트를 확인한다: `kubectl describe pod <파드>` → 결과: 아래쪽 `Events`에 원인 문구가 있다.
3. (2-03) 로그를 확인한다: `kubectl logs <파드>`. 재시작을 반복하면 `--previous`를 붙인다 → 결과: 앱의 오류 메시지가 보인다.
4. (2-04) 서비스 연결을 확인한다: `kubectl get endpoints <서비스>` → 결과: 파드 IP가 한 개 이상 나온다. 비어 있으면 레이블을 `kubectl get pods --show-labels`로 대조한다.
5. (2-05) 노드를 확인한다: `kubectl get nodes` → 결과: 모든 노드가 `Ready`다.
6. (2-06) 파드 안에서 확인한다: `kubectl exec -it <파드> -- sh` → 결과: 셸이 열려 환경 변수와 파일을 확인할 수 있다.

## 3. 시정 조치

| 원인 | 조치 |
|---|---|
| 자원 부족 | `requests`를 줄이거나 노드를 늘린다 |
| 이미지 오류 | 이미지 이름·태그를 고치고 `kubectl apply`를 다시 실행한다. 비공개 저장소는 `imagePullSecrets`를 설정한다 |
| 앱 오류·설정 누락 | 로그의 원인을 고치고, 없는 ConfigMap·Secret을 만든다([컨피그맵과 시크릿](configmap-secret.md), CLD-K8T-009-DO) |
| OOM | `limits.memory`를 올리거나 앱 메모리 사용을 줄인다 |
| readiness 실패 | probe의 경로·포트·지연(`initialDelaySeconds`)을 앱에 맞춘다 |
| 레이블 불일치 | 서비스 `selector` 또는 파드 레이블을 맞춘다 |
| 노드 `NotReady` | CNI 설치 여부와 노드의 kubelet 상태를 확인한다. 설치 절차는 [쿠버네티스 노드 설치 및 설정](kube_setup.md)(CLD-K8T-002-MP)를 따른다 |

{% hint style="warning" %}
CAUTION: `kubectl delete pod`는 디플로이먼트가 관리하는 파드면 새 파드를 만들지만, 원인이 그대로면 같은 증상이 반복된다. 삭제 전에 로그와 `describe` 출력을 저장한다.
{% endhint %}

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kubectl 명령 정리](kubectl-reference.md) | CLD-K8T-007-REF | 명령 옵션 |
| [쿠버네티스 매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | probe·resources |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `describe`와 `logs`는 각각 어떤 정보를 주는가?
- [ ] 직접 겪은 파드 장애가 있다면 원인과 해결을 적는다.
