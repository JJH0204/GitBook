# [생성형 AI] kubectl 명령 정리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-007-REF |
| 유형 | REF (표) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 자주 쓰는 `kubectl` 명령과 옵션을 찾는다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 클러스터에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 공통 옵션

| 옵션 | 설명 |
|---|---|
| `-n <네임스페이스>` | 네임스페이스를 지정한다. 생략하면 현재 컨텍스트의 기본값이다 |
| `-A` | 모든 네임스페이스 |
| `-o wide` | 노드, IP 등 추가 열을 출력한다 |
| `-o yaml` / `-o json` | 개체 전체를 출력한다 |
| `-l <키>=<값>` | 레이블로 고른다 |
| `-w` | 변화를 계속 지켜본다 |

## 2. 조회

| 명령 | 설명 |
|---|---|
| `kubectl get nodes` | 노드 목록과 상태 |
| `kubectl get pods -A` | 모든 네임스페이스의 파드 |
| `kubectl get deploy,svc` | 디플로이먼트와 서비스를 함께 본다 |
| `kubectl describe pod <파드>` | 상세 정보와 이벤트(`Events`) |
| `kubectl get events --sort-by=.metadata.creationTimestamp` | 이벤트를 시간순으로 본다 |
| `kubectl explain pod.spec.containers` | 필드 설명을 본다 |
| `kubectl top pod` | CPU·메모리 사용량. metrics-server가 있어야 한다 |

## 3. 변경

| 명령 | 설명 |
|---|---|
| `kubectl apply -f <파일 또는 폴더>` | 매니페스트를 적용한다(없으면 만들고 있으면 갱신) |
| `kubectl delete -f <파일>` | 매니페스트의 개체를 삭제한다 |
| `kubectl delete pod <파드>` | 파드를 삭제한다. 디플로이먼트가 새 파드를 만든다 |
| `kubectl scale deploy <이름> --replicas=<N>` | 복제 수를 바꾼다 |
| `kubectl set image deploy/<이름> <컨테이너>=<이미지:태그>` | 이미지를 바꾼다(롤링 업데이트) |
| `kubectl create deployment <이름> --image=<이미지> --dry-run=client -o yaml` | 실제 생성 없이 YAML 초안을 만든다 |

## 4. 디버깅

| 명령 | 설명 |
|---|---|
| `kubectl logs <파드>` | 로그 |
| `kubectl logs <파드> -f` | 로그를 계속 따라간다 |
| `kubectl logs <파드> --previous` | 재시작 전 컨테이너의 로그 |
| `kubectl logs <파드> -c <컨테이너>` | 컨테이너가 여럿일 때 지정 |
| `kubectl exec -it <파드> -- sh` | 파드 안에서 셸을 연다 |
| `kubectl port-forward <파드 또는 svc/이름> <로컬포트>:<포트>` | 로컬 포트를 파드·서비스로 전달한다 |

## 5. 롤아웃과 노드

| 명령 | 설명 |
|---|---|
| `kubectl rollout status deploy/<이름>` | 배포 진행을 본다 |
| `kubectl rollout history deploy/<이름>` | 개정 이력 |
| `kubectl rollout undo deploy/<이름>` | 직전 개정으로 되돌린다 |
| `kubectl cordon <노드>` | 노드에 새 파드가 배치되지 않게 한다 |
| `kubectl drain <노드> --ignore-daemonsets` | 노드의 파드를 다른 노드로 옮긴다 |
| `kubectl uncordon <노드>` | 배치를 다시 허용한다 |

## 6. 컨텍스트

| 명령 | 설명 |
|---|---|
| `kubectl config get-contexts` | 접속 가능한 클러스터(컨텍스트) 목록 |
| `kubectl config current-context` | 현재 컨텍스트 |
| `kubectl config use-context <이름>` | 컨텍스트를 바꾼다 |

{% hint style="danger" %}
WARNING: 변경 명령은 현재 컨텍스트의 클러스터에 적용된다. 운영 클러스터와 연습 클러스터를 같이 쓰면 `kubectl config current-context`로 대상을 확인한 뒤 실행한다. `drain`과 `delete`는 서비스를 중단시킬 수 있다.
{% endhint %}

## 7. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [쿠버네티스 핵심 이론](kubernetestheory.md) | CLD-K8T-001-DO | 개체 개념 |
| [쿠버네티스 매니페스트 기본](manifest-basics.md) | CLD-K8T-008-REF | YAML 작성 |
| [파드 장애 진단](pod-troubleshooting.md) | CLD-K8T-010-TS | 진단 순서 |
