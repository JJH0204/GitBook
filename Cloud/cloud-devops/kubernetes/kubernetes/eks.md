# AWS EKS 구축 및 운영

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-005-MP |
| 목적 | `eksctl`로 AWS EKS 클러스터와 관리형 노드 그룹을 만들고, `kubectl`로 접속해 테스트 배포를 한 뒤, 과금을 막기 위해 모든 리소스를 정리한다 |
| 적용 대상 | AWS 계정(IAM 사용자 또는 역할로 EKS·EC2·CloudFormation·IAM 권한 보유), Linux 또는 macOS 또는 Windows 터미널, `aws` CLI v2, `eksctl`, `kubectl` |
| 소요 시간 | 생성 약 20분, 정리 약 15분 |
| 확인 상태 | 미검증 (원본에는 EKS 구축 절차가 없었다. 공개된 `eksctl` 사용법으로 새로 작성했으며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 페이지는 EKS 절차 없이 EKS 워크숍 링크와 DevSecOps(CI/CD 파이프라인, 보안 SDLC, SAST/DAST) 메모만 담고 있었다. 파이프라인 개념은 [DevSecOps 파이프라인 개요](../../ci-cd-devsecops/devsecops-overview.md)(CLD-CIC-001-DO)에, 보안 SDLC와 SAST/DAST는 [보안 중심 SDLC와 SAST/DAST](devsecops-sdlc.md)(CLD-K8T-006-DO)에 있다. 이 문서의 절차는 원본에 없던 내용이다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [aws_services.md](../../aws/aws_services.md) | CLD-AWS-002-DO | AWS 주요 서비스 정리 |
| [aws_ec2.md](../../aws/aws_ec2.md) | CLD-AWS-003-MP | AWS EC2 가이드 (EC2) |
| [kubernetestheory.md](kubernetestheory.md) | CLD-K8T-001-DO | 쿠버네티스 핵심 이론 (Kubernetes) |
| [devsecops-overview.md](../../ci-cd-devsecops/devsecops-overview.md) | CLD-CIC-001-DO | DevSecOps 파이프라인 개요 |
| [devsecops-sdlc.md](devsecops-sdlc.md) | CLD-K8T-006-DO | 보안 중심 SDLC와 SAST/DAST |

외부 참조:

* EKS 워크숍: https://www.eksworkshop.com/
* eksctl 공식 문서: https://eksctl.io/
* EKS 요금: https://aws.amazon.com/eks/pricing/

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | AWS 계정 | EKS, EC2, VPC, CloudFormation, IAM 생성 권한 | 학습용 계정 권장 |
| 2 | AWS CLI | v2 | `aws --version`으로 확인 |
| 3 | eksctl | 최신 안정 버전 | `eksctl version`으로 확인 |
| 4 | kubectl | 클러스터 버전과 마이너 버전 1 이내 | |
| 5 | 결제 알림 | AWS Budgets 또는 결제 알림 설정 | 5절 시작 전에 설정 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: EKS는 유료다. 클러스터가 존재하는 동안 컨트롤 플레인 요금이 시간 단위로 부과되고, 워커 노드(EC2), NAT 게이트웨이, 로드 밸런서, EBS 볼륨의 요금이 별도로 부과된다. 사용하지 않을 때도 삭제하지 않으면 계속 부과된다. 요금 단가는 시점과 리전에 따라 달라지므로 EKS 요금 페이지에서 확인한다. 실습이 끝나면 즉시 7절의 정리를 수행한다.
{% endhint %}

{% hint style="danger" %}
WARNING: AWS 액세스 키와 비밀 키, 계정 ID를 문서, 저장소, 채팅에 적지 않는다. 이 문서는 계정 ID를 `<계정 ID>`로 표기한다. 루트 계정 대신 IAM 사용자 또는 역할로 작업한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `eksctl create cluster`는 VPC, 서브넷, NAT 게이트웨이, IAM 역할, 노드 그룹을 CloudFormation 스택으로 한꺼번에 만든다. 기존 VPC를 지정하지 않으면 새 VPC가 생긴다. 계정의 VPC 한도를 먼저 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | AWS CLI가 인증돼 있다 | `aws sts get-caller-identity`가 `Account`, `Arn`을 출력한다 |
| 2 | 작업 리전을 정했다 | 이 문서는 `<리전>`으로 표기한다. 모든 명령에 같은 리전을 쓴다 |
| 3 | `eksctl`이 설치돼 있다 | `eksctl version`이 버전을 출력한다 |
| 4 | 결제 알림이 설정돼 있다 | AWS 결제 콘솔에서 Budgets 항목을 확인한다 |

## 5. 절차

### A. 클러스터와 노드 그룹 생성

1. (5-A-01) 클러스터를 만든다: `eksctl create cluster --name <클러스터 이름> --region <리전> --nodegroup-name <노드 그룹 이름> --node-type t3.medium --nodes 2` → 결과: 약 15~20분 뒤 `EKS cluster "<클러스터 이름>" in "<리전>" region is ready`가 출력된다. `eksctl`이 kubeconfig를 자동으로 갱신한다.
2. (5-A-02) 생성 진행 중에는 터미널을 닫지 않는다. → 결과: 출력이 멈춰 보여도 CloudFormation 스택 생성이 진행 중이다.

{% hint style="info" %}
NOTE: 노드 타입 `t3.medium`과 노드 수 2는 학습용 최소 구성 예시다. 실제 요구에 맞게 바꾼다. 이 값의 적합성은 확인 필요다.
{% endhint %}

### B. kubectl 연결

1. (5-B-01) kubeconfig를 갱신한다: `aws eks update-kubeconfig --region <리전> --name <클러스터 이름>` → 결과: `Added new context arn:aws:eks:...`가 출력된다.
2. (5-B-02) 현재 컨텍스트를 확인한다: `kubectl config current-context` → 결과: EKS 클러스터의 컨텍스트가 출력된다. 다른 클러스터면 `kubectl config use-context <컨텍스트 이름>`을 실행한다.
3. (5-B-03) 노드를 확인한다: `kubectl get nodes` → 결과: 노드 2개가 `Ready`다.

### C. 테스트 배포

1. (5-C-01) nginx Deployment를 만든다: `kubectl create deployment nginx --image=nginx --replicas=2` → 결과: `deployment.apps/nginx created`
2. (5-C-02) 파드를 확인한다: `kubectl get pods -o wide` → 결과: 파드 2개가 `Running`이다.
3. (5-C-03) 로컬에서 접속을 확인한다: `kubectl port-forward deployment/nginx 8080:80` 실행 후 다른 터미널에서 `curl http://localhost:8080` → 결과: `Welcome to nginx!`가 포함된 HTML이 출력된다. 확인 뒤 `Ctrl+C`로 포트 포워딩을 종료한다.

{% hint style="warning" %}
CAUTION: `--type LoadBalancer`로 서비스를 만들면 AWS 로드 밸런서가 생성되고 별도 요금이 부과된다. 이 문서의 테스트는 로드 밸런서를 만들지 않는다. 만들었다면 7-02에서 반드시 먼저 삭제한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `eksctl get cluster --region <리전>` | 클러스터 목록 | `<클러스터 이름>`이 보인다 |
| 2 | `kubectl get nodes` | 노드 2개 | 모두 `Ready` |
| 3 | `kubectl get pods -o wide` | nginx 파드 | 모두 `Running` |

## 7. 복구

{% hint style="danger" %}
WARNING: `eksctl delete cluster`는 클러스터, 노드 그룹, `eksctl`이 만든 VPC를 삭제한다. 그 안의 모든 워크로드와 데이터가 사라지며 되돌릴 수 없다. 클러스터 이름과 리전을 확인한 뒤 실행한다.
{% endhint %}

1. (7-01) 테스트 Deployment를 삭제한다: `kubectl delete deployment nginx` → 결과: `deployment.apps "nginx" deleted`
2. (7-02) 로드 밸런서 타입 서비스가 있으면 먼저 삭제한다: `kubectl get svc -A`로 TYPE이 `LoadBalancer`인 서비스를 찾아 `kubectl delete svc <서비스 이름> -n <네임스페이스>`를 실행한다. → 결과: `TYPE LoadBalancer` 서비스가 목록에 없다. 이 단계를 건너뛰면 로드 밸런서가 남아 VPC 삭제가 실패하고 요금이 계속 부과될 수 있다.
3. (7-03) 클러스터를 삭제한다: `eksctl delete cluster --name <클러스터 이름> --region <리전>` → 결과: 약 10~15분 뒤 `all cluster resources were deleted`가 출력된다.
4. (7-04) AWS 콘솔에서 남은 리소스를 확인한다. 같은 리전에서 CloudFormation 스택(`eksctl-<클러스터 이름>-*`), EC2 인스턴스, 로드 밸런서, 사용하지 않는 EBS 볼륨, NAT 게이트웨이, 탄력적 IP를 본다. → 결과: 해당 리소스가 모두 없다.
5. (7-05) 로컬 kubeconfig에서 컨텍스트를 정리한다: `kubectl config delete-context <컨텍스트 이름>` → 결과: `deleted context`가 출력된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 원본의 DevSecOps 메모는 CLD-CIC-001-DO와 CLD-K8T-006-DO로 분리했다. EKS 구축·접속·정리 절차를 새로 작성했다(원본에 없던 내용) |
