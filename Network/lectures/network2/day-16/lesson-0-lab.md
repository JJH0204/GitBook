# 클러스터 재생성 실습

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-008-MP |
| 목적 | 환경을 점검하고, 14일차 이미지가 없으면 저장소에서 다시 굽고, 호스트 8080을 노드 30080에 연결하는 설정 파일로 kind 클러스터를 다시 만든다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x, kind, kubectl |
| 소요 시간 | 약 15분(두 번째 생성이라 클러스터 생성은 1~2분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-16-001-DO | 내 이미지를 클러스터로 |
| [lesson-3.md](lesson-3.md) | LEC-N2-16-003-DO | 밖으로 여는 법 |
| [commands.md](commands.md) | LEC-N2-16-007-REF | 16일차 실습 명령어 |
| [15일차 README](../day-15/README.md) | | 15일차 클러스터 생성 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 한 개 |
| 2 | Docker Engine | 29.x | |
| 3 | kind, kubectl | 15일차에 설치한 것 | |
| 4 | 13일차 저장소 | GitHub의 `myweb` | 5-B에서 이미지를 다시 구울 때만 필요하다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 5-C-02의 `kind delete cluster`는 클러스터와 그 안의 모든 Pod, 노드에 넣은 이미지를 지운다. 되돌릴 수 없다. 실행 전 3초 멈추고 클러스터 이름이 `student`인지 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 15일차 클러스터에는 포트 매핑이 없다. 클러스터를 지우고 설정 파일로 다시 만들어야 NodePort로 밖에서 접속된다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | WSL 터미널이 열려 있다 | 프롬프트가 나타난다 |
| 2 | 15일차 클러스터가 있는지 확인한다 | `kind get clusters`가 `student`를 출력하거나 아무것도 출력하지 않는다 |

## 5. 절차

### A. 점검

1. (5-A-01) cgroup 버전을 확인한다: `stat -fc %T /sys/fs/cgroup` → 결과: `cgroup2fs`.
2. (5-A-02) 초기화 프로세스를 확인한다: `ps -p 1 -o comm=` → 결과: `systemd`.
3. (5-A-03) Docker 버전을 확인한다: `docker info --format '{{.ServerVersion}}'` → 결과: `29.x`.
4. (5-A-04) 남은 클러스터를 확인한다: `kind get clusters`
5. (5-A-05) 14일차 이미지를 확인한다: `docker images | grep mysite` → 결과: `mysite   1.0`이 보인다. 보이면 5-B를 건너뛴다.

### B. 14일차 이미지가 없을 때: 저장소에서 다시 굽는다

1. (5-B-01) 저장소를 받는다: `cd ~ && git clone https://github.com/<내 아이디>/myweb.git 2>/dev/null; cd ~/myweb` → 결과: `~/myweb` 폴더로 이동한다.
2. (5-B-02) 이미지를 굽는다: `docker build -t mysite:1.0 .` → 결과: 빌드가 오류 없이 끝난다.
3. (5-B-03) 이미지를 확인한다: `docker images | grep mysite` → 결과: `mysite   1.0`이 보인다.

{% hint style="info" %}
NOTE: 저장소만 있으면 어느 PC에서든 같은 이미지가 나온다. 14일차에 증명하려던 그것이다.
{% endhint %}

### C. 클러스터를 설정 파일로 다시 만든다

1. (5-C-01) 설정 파일을 만든다. → 결과: `~/kind-config.yaml`이 생긴다.

```bash
cat > ~/kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080      # 노드 안쪽 (NodePort 번호)
    hostPort: 8080            # 내 WSL 쪽
EOF
```

2. (5-C-02) 기존 클러스터를 지운다: `kind delete cluster --name student` → 결과: `Deleted clusters: ["student"]`. 클러스터가 없었다면 지울 것이 없다는 메시지가 나온다.
3. (5-C-03) 설정 파일로 클러스터를 만든다: `kind create cluster --name student --config ~/kind-config.yaml` → 결과: `Set kubectl context to "kind-student"`로 끝난다.
4. (5-C-04) 포트 매핑을 확인한다: `docker ps` → 결과: `0.0.0.0:8080->30080/tcp`가 보인다.
5. (5-C-05) 노드를 확인한다: `kubectl get nodes` → 결과: `student-control-plane   Ready`.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker ps` | `0.0.0.0:8080->30080/tcp` | 포트 매핑이 보인다 |
| 2 | `kubectl get nodes` | `Ready` | STATUS가 `Ready`이다 |
| 3 | `docker images \| grep mysite` | `mysite 1.0` | 한 줄 이상 보인다 |

## 7. 복구

1. (7-01) 클러스터를 지운다: `kind delete cluster --name student` → 결과: `Deleted clusters: ["student"]`. 집에서 다시 해보려면 지우지 않고 남겨 둔다.
2. (7-02) 설정 파일을 지운다: `rm ~/kind-config.yaml`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `commands.md` STEP 0과 `lesson-1.md` 복구 경로, `lesson-3.md` 2절의 클러스터 재생성 항목을 AMM 형식으로 재작성. 복구 절을 추가했다 |
