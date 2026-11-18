# 3. 밖으로 여는 법 — NodePort 와 Ingress

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md) · 절차는 [NodePort 공개 실습](lesson-3-lab.md), 대본은 [STEP 3](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-003-DO |
| 유형 | D&O (개념) |
| 목적 | 문을 여는 세 단계(ClusterIP, NodePort, Ingress), kind의 포트 매핑, NodePort의 번호 네 개, Ingress가 푸는 문제, 11일차와 14일차 최소 개방이 쿠버네티스에서 나타나는 방식을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 문을 여는 세 단계를 구분한다: `port-forward`, NodePort, Ingress.
- kind 클러스터에 포트 구멍을 뚫어 다시 만든다.
- NodePort로 밖에서 접속한다.
- Ingress가 무엇을 푸는지 안다(12일차 프록시 회수).
- 11일차와 14일차 최소 개방이 쿠버네티스에서 어떻게 나타나는지 말한다.

## 1. 목적

15일차부터 지금까지 쓴 것은 `kubectl port-forward`였다.

```bash
kubectl port-forward deployment/mysite 8080:80
```

이것은 터미널을 켜 둔 동안만 열리는 통로이다. 끄면 닫힌다. 옆자리는 보지 못한다. 14일차에 `-p 127.0.0.1:8080:80`으로 묶어 뒀던 그 상태이다. 이 문서는 제대로 여는 방법을 설명한다.

## 2. 구성 요소

### 문을 여는 세 단계

```
 ① ClusterIP      클러스터 안에서만            기본값. 15일차에 쓴 것
       │          (+ port-forward로 잠깐 들여다보기)
       ▼
 ② NodePort       노드의 포트를 연다           오늘 실습
       │          밖에서 노드 주소:포트로 들어온다
       ▼
 ③ Ingress        이름으로 나눠 보내는 한 문    오늘 개념, 시연
                  하나의 80번으로 여러 서비스
```

| | 누가 볼 수 있나 | 14일차로 치면 |
|---|---|---|
| ClusterIP | 클러스터 안만 | `-p`를 쓰지 않은 컨테이너 |
| ClusterIP + port-forward | 나만, 켜 둔 동안 | `-p 127.0.0.1:8080:80` |
| NodePort | 밖에서 | `-p 8080:80` |
| Ingress | 밖에서, 이름으로 | 앞에 세운 리버스 프록시 |

11일차 최소 개방이 그대로 올라왔다. 쿠버네티스는 아무것도 하지 않으면 열리지 않는다. 열고 싶으면 명시해야 한다.

### kind는 포트를 미리 뚫어 둬야 한다

15일차와 달라지는 부분이다. 노드가 Docker 컨테이너이므로, 그 컨테이너에 `-p`가 없으면 밖에서 들어올 수 없다.

```bash
docker ps        # 15일차에 만든 노드에는 포트 매핑이 없다
```

14일차에 배운 그대로이다. 컨테이너는 `-p` 없이는 열리지 않는다. 노드도 컨테이너이다. 그래서 클러스터를 설정 파일로 다시 만든다.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080      # 노드 안쪽 (NodePort 번호)
    hostPort: 8080            # 내 WSL 쪽
```

클러스터도 파일로 적어 다시 만든다. 15일차 4번 절의 선언형이 클러스터 자체에도 적용된 것이다. 절차는 [클러스터 재생성 실습](lesson-0-lab.md)에 있다.

{% hint style="warning" %}
CAUTION: 클러스터를 지우면 안의 것이 전부 사라진다. 이미지도 다시 넣고 매니페스트도 다시 `apply`한다. 그래서 대본은 STEP 0에서 이 설정으로 클러스터를 만든다. 수업 중에 지우고 다시 만들 시간이 없다.
{% endhint %}

### NodePort로 연다

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysite
spec:
  type: NodePort             # 기본값 ClusterIP에서 바꾼다
  selector:
    app: mysite
  ports:
  - port: 80                 # Service가 받는 번호
    targetPort: 80           # Pod가 듣는 번호
    nodePort: 30080          # 노드에 열 번호 (kind-config와 맞춘다)
```

```bash
kubectl apply -f k8s/service.yaml
kubectl get svc mysite
curl http://localhost:8080          # port-forward 없이 열린다
```

터미널을 점유하지 않는다. `port-forward`를 껐는데도 열려 있다. 이것이 진짜로 연 것이다.

| 번호 | 누가 쓰나 |
|---|---|
| `port: 80` | 클러스터 안에서 `http://mysite`로 부를 때 |
| `targetPort: 80` | Pod 안의 nginx가 듣는 번호 |
| `nodePort: 30080` | 노드 바깥에서 들어올 때 |
| `hostPort: 8080`(kind-config) | 내 WSL에서 들어올 때 |

14일차 `-p 8080:80`이 네 칸으로 늘어난 것이다.

{% hint style="warning" %}
CAUTION: NodePort는 30000~32767 범위에서만 고를 수 있다. 80번을 직접 쓸 수 없다. 그래서 실무에서 NodePort를 그대로 쓰지 않는다. 포트 번호가 지저분하고, 서비스가 늘어나면 번호를 외울 수 없다. 그 답이 Ingress이다.
{% endhint %}

### Ingress: 이름으로 나눠 보내는 한 문 (개념, 시연)

서비스가 셋이 되면 다음처럼 된다.

```
  포트폴리오   →  :30080
  게시판       →  :30081
  관리자       →  :30082     번호를 외워야 한다. 문이 세 개다
```

문을 세 개 열었다. 11일차에 문이 많을수록 공격 표면이 넓어진다고 했다. Ingress는 문 하나(80/443)를 두고, 주소의 이름이나 경로를 보고 안에서 나눠 보낸다.

```
                     ┌──────────────────────────┐
  밖 ── :80 ──▶      │  Ingress                 │
                     │  /          → 포트폴리오 │
                     │  /board     → 게시판     │
                     │  admin.***  → 관리자     │
                     └──────────────────────────┘
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mysite
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mysite
            port:
              number: 80
```

12일차 7번(프록시)이 여기서 회수된다. 그때는 `squid`(포워드 프록시)를 다뤘고, 방향을 뒤집은 것이 리버스 프록시이다. Ingress는 쿠버네티스가 리버스 프록시를 다루는 방식이다. 14일차 3번 절에서 미뤄 둔 "그럼 제대로 공개하려면?"의 답이 이것이다.

{% hint style="info" %}
NOTE: Ingress는 규칙일 뿐이다. 실제로 트래픽을 받아 나눠 주는 컨트롤러가 클러스터에 따로 있어야 동작한다. 설치 방법은 쿠버네티스 배포판마다 다르다. 오늘은 개념과 강사 시연까지 한다. 학생 실습은 NodePort로 완결한다. 컨트롤러 설치가 또 하나의 병목이 되면 마지막 날을 끝내지 못한다.
{% endhint %}

## 3. 동작 원리

### 열기 전에: 11일차와 14일차 점검

```bash
kubectl get svc                  # 지금 밖에 열린 문이 몇 개인가
sudo ss -tulnp | grep 8080       # 호스트 쪽에서도 확인
```

| 11일차에 배운 것 | 쿠버네티스에서 |
|---|---|
| 공격 표면 = `LISTEN` 한 줄 한 줄 | `type: NodePort`인 Service 하나하나 |
| 기본 거부 | 기본이 `ClusterIP`. 열려 있지 않다 |
| 최소 개방 | 꼭 필요한 것만 NodePort와 Ingress |
| DB는 밖에 열지 않는다 | DB Service는 ClusterIP로 둔다 |

14일차 Compose의 결말인 `ports`가 없는 db가 쿠버네티스에서는 `type`을 바꾸지 않는 것으로 나타난다. 생각이 완전히 같다.

{% hint style="danger" %}
WARNING: 14일차의 "Docker가 ufw를 우회한다"는 그대로 유효하다. kind 노드는 컨테이너이므로 `ufw`로 막았다고 안심하면 안 된다.
{% endhint %}

### 요청이 들어오는 길

1. 내 WSL의 `localhost:8080`으로 요청이 들어온다(`hostPort`).
2. Docker가 그것을 kind 노드 컨테이너의 30080으로 보낸다(`containerPort`).
3. 노드의 30080(`nodePort`)이 Service `mysite`로 이어진다.
4. Service가 `selector`의 라벨 `app: mysite`가 붙은 Pod의 80번(`targetPort`)으로 보낸다.

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| ClusterIP | 클러스터 안에서만 닿는 Service 타입. 기본값 |
| NodePort | 모든 노드의 한 포트(30000~32767)를 여는 Service 타입 |
| Ingress | 하나의 입구에서 이름과 경로로 여러 Service에 나눠 보내는 규칙 |
| Ingress 컨트롤러 | Ingress 규칙을 실제로 실행하는 프로그램. 따로 설치해야 한다 |
| `extraPortMappings` | kind 노드 컨테이너의 포트를 호스트에 연결하는 설정 |
| 리버스 프록시 | 서버 앞에서 요청을 대신 받아 안쪽으로 나눠 보내는 프록시 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 문을 여는 세 단계 | 2절의 세 단계 그림. 오늘 가장 헷갈리는 절이므로 먼저 칠판에 그린다. 판서로 그린다 |
| 2 | 포트 번호 네 개 | `port`, `targetPort`, `nodePort`, `hostPort`의 표. 판서로 그린다 |

## 강의 메모

- 세 단계 그림을 칠판에 먼저 그리고 시작한다. 오늘 가장 헷갈리는 절이다.
- kind 재생성은 STEP 0에서 끝내 둔다. 수업 중에 클러스터를 지우고 다시 만들면 15분이 날아간다. 대본은 처음부터 `--config ~/kind-config.yaml`로 만든다.
- 번호 네 개(`port`, `targetPort`, `nodePort`, `hostPort`)가 폭격이다. 표를 칠판에 그려 두고 하나씩 가리킨다. "14일차 `-p 8080:80`이 네 칸으로 늘어난 것"이라고 말한다.
- 3절의 표가 과정 전체의 회수 지점이다. 11일차 공격 표면, 14일차 `-p`, 오늘 Service 타입이 이어진다.
- Ingress는 욕심내지 않는다. 컨트롤러 설치까지 가면 마지막 날을 끝내지 못한다. 개념과 시연으로 끊는다.
- 이론 20분, 실습 25분으로 45분이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 서비스가 다섯 개가 되면 NodePort는 무엇이 불편한가?
- [ ] DB를 밖에서 보게 하려면 어떻게 해야 하는가? 그리고 왜 하면 안 되는가?
- [ ] `kind-config.yaml` 없이 만든 클러스터에서 NodePort를 쓰면 왜 열리지 않는지 내 말로 설명해 보자.
