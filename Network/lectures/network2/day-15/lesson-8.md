# 8. 오늘의 문제 🎯

> 상위: [15일차 · 쿠버네티스 입문](README.md)
> 💡 **진행 방법**: 각자 먼저 풀게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.
> ⚖️ **Q9 는 🅰️ A안, Q10 은 🅱️ B안 전용**이다. 간 쪽만 푼다.

---

## Q1. 명령형과 선언형 ⭐⭐ — [1_왜_쿠버네티스인가](lesson-1.md)

What is the key difference between `docker run` and a Kubernetes manifest?
(`docker run` 과 쿠버네티스 매니페스트의 결정적 차이는?)

- A. 쿠버네티스가 더 빠르다
- B. **`docker run` 은 "해라", 매니페스트는 "이런 상태여야 한다"**
- C. `docker run` 은 이미지를 못 쓴다
- D. 매니페스트는 컨테이너를 안 쓴다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **명령형**은 시킨 일이 끝나면 그걸로 끝이다. **선언형**은 그 상태가 깨지면 **누군가 계속 되돌린다**
- 에어컨 비유 — "3분 틀어라"(명령형) vs **"24도를 유지해라"**(선언형)
- 증거는 5번 절이다. Pod 를 지워도 **개수가 모자라서** 새로 생긴다
- D 는 틀렸다. 쿠버네티스도 **결국 컨테이너를 돌린다**. 14일차가 사라지는 게 아니라 **위에 한 층**이 얹힌 것
{% endhint %}

---

## Q2. kind 가 만든 노드 ⭐ — [2_클러스터_세우기](lesson-2.md)

After `kind create cluster`, what do you see in `docker ps`?
(`kind create cluster` 뒤 `docker ps` 에는 무엇이 보이나?)

- A. 아무것도 안 보인다
- B. nginx 컨테이너
- C. **클러스터의 노드가 컨테이너로 보인다**
- D. kubectl 프로세스

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **kind** = **K**ubernetes **IN** **D**ocker. 노드를 **Docker 컨테이너로** 만든다
- `kindest/node` 이미지의 컨테이너가 `<클러스터이름>-control-plane` 이라는 이름으로 떠 있다
- ⭐ 그래서 오늘 배운 것은 **14일차 위에 올라간 한 층**이다. 완전히 새로운 세계가 아니다
- 📌 그 컨테이너를 `docker stop` 하면 **클러스터가 멈춘다**
{% endhint %}

---

## Q3. 세 단어 — [3_첫_배포](lesson-3.md)

Which object gives a stable name and address to a group of Pods?
(Pod 묶음에 이름과 고정 주소를 주는 것은?)

- A. Pod
- B. Deployment
- C. **Service**
- D. Node

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **Pod** = 가장 작은 단위 · **Deployment** = 몇 개를 유지할지 · **Service** = 이름과 고정 주소
- 식당 비유 — Pod=직원, Deployment=근무 규정, **Service=손님이 부르는 "여기요"**
- ⭐ Pod 이름과 IP 는 **매번 바뀐다.** 그래서 Service 가 필요하다
- 14일차 Compose 에서 **서비스 이름으로 통하던 그것**과 같은 자리다
{% endhint %}

---

## Q4. ClusterIP — [3_첫_배포](lesson-3.md) · 11일차

You created a Service of type `ClusterIP`. Can a classmate reach it from their PC?
(`ClusterIP` Service 를 만들었다. 옆자리에서 접속할 수 있나?)

- A. 된다
- B. **안 된다 — 클러스터 안에서만 쓰는 주소다**
- C. 포트를 80으로 하면 된다
- D. `kubectl` 을 깔면 된다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- `ClusterIP` 는 **클러스터 안에서만** 통하는 주소다
- ⭐ 14일차에 **`-p` 를 안 쓴 DB** 와 같은 상태다. 11일차 **최소 개방**이 쿠버네티스에서는 **기본값**이다
- 내 브라우저로 잠깐 보려면 **`kubectl port-forward`** — 켜 둔 동안만 열리는 **들여다보기용 통로**다
- 제대로 밖에 여는 법은 **16일차**에서 다룬다
{% endhint %}

---

## Q5. 라벨 짝 맞추기 ⭐ — [4_선언형_YAML](lesson-4.md)

In a Deployment manifest, what must match?
(Deployment 매니페스트에서 반드시 같아야 하는 것은?)

- A. `metadata.name` 과 컨테이너 이름
- B. **`spec.selector.matchLabels` 와 `spec.template.metadata.labels`**
- C. `apiVersion` 과 `kind`
- D. `port` 와 `targetPort`

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- Deployment 가 **"내가 관리할 Pod"** 를 찾는 방법이 **라벨**이기 때문이다
- 다르면 만든 Pod 를 자기 것으로 못 알아보고 **계속 새로 만든다**
- 💡 근무 규정에 "파란 조끼가 내 직원"이라 적고 **새 직원에게 파란 조끼**를 입히는 것
- D 는 **같을 필요가 없다** — `port` 는 Service 가 받는 번호, `targetPort` 는 Pod 가 듣는 번호다
{% endhint %}

---

## Q6. apply 를 두 번 ⭐ — [4_선언형_YAML](lesson-4.md)

You run `kubectl apply -f deployment.yaml` twice in a row. What happens the second time?
(같은 파일을 두 번 연속 `apply` 하면 두 번째는?)

- A. 에러가 난다 (이름 충돌)
- B. Deployment 가 2개가 된다
- C. **`unchanged` — 아무 일도 하지 않는다**
- D. Pod 가 2배가 된다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **선언형이기 때문이다.** "만들어라"가 아니라 **"이 상태여야 한다"** 이므로, 이미 그 상태면 할 일이 없다
- 14일차 `docker run` 을 두 번 치면 **이름 충돌**이 났다. `apply` 는 그렇지 않다
- 그래서 **고칠 때도 같은 파일을 고쳐서 다시 `apply`** 한다
- 📌 `--dry-run=client` 를 먼저 치는 습관 — 12일차 `nginx -t`, 14일차 `docker compose config` 와 같은 자리
{% endhint %}

---

## Q7. Pod 를 지우면 ⭐⭐ — [5_자가치유와_스케일](lesson-5.md)

You run `kubectl delete pod web-5d8f9c7b4-x7k2p`. What happens?
(Pod 를 지웠다. 어떻게 되나?)

- A. 영영 사라진다
- B. 같은 이름으로 되살아난다
- C. **다른 이름의 새 Pod 가 생긴다**
- D. Deployment 도 함께 사라진다

{% hint style="success" %}
**정답 및 해설**

**정답: C 🚨 이름을 보는 것이 핵심이다**
- 쿠버네티스는 **지운 것을 되살리지 않는다.** "1개여야 하는데 0개네" 를 보고 **새로 하나 만든다**
- 그래서 **이름이 다르다**. 되살아난 게 아니라는 증거다
- 진짜로 없애려면 **Deployment 를 지운다** → `kubectl delete deployment web`
- ⭐ 한 줄 — **"쿠버네티스는 되살리지 않는다. 세어 보고 모자라면 만든다."**
{% endhint %}

---

## Q8. scale 과 파일 ⭐ — [5_자가치유와_스케일](lesson-5.md) · 13일차

You ran `kubectl scale deployment web --replicas=3`. Then someone runs `kubectl apply -f deployment.yaml` (the file says `replicas: 1`). How many Pods?
(`scale` 로 3개로 늘린 뒤, 누가 `replicas: 1` 인 파일을 `apply` 하면?)

- A. 3개 그대로
- B. **1개로 돌아간다**
- C. 4개가 된다
- D. 에러가 난다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **파일에 적힌 것이 "원하는 상태"** 다. `scale` 로 바꾼 것은 **파일에 남지 않는다**
- ⭐ 13일차 **"서버에서 직접 파일을 고치지 않는다"** 와 **완전히 같은 교훈**이다
- **고치는 곳은 파일 하나.** 그래야 다음 사람이 `apply` 해도 같은 결과가 나온다
- `scale` 은 **급할 때 임시로** 쓰고, 끝나면 파일에 반영한다
{% endhint %}

---

## Q9. 🅰️ kubectl 과 API — [6_API로_들여다보기](lesson-6.md) · 10일차

What does `kubectl get pods` actually do under the hood?
(`kubectl get pods` 는 속으로 무엇을 하고 있나?)

- A. 노드에 SSH 로 접속한다
- B. **API 서버에 HTTP `GET` 요청을 보낸다**
- C. Docker 소켓을 직접 읽는다
- D. 파일을 읽는다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- `kubectl get pods -v=6` 을 치면 **`GET https://.../api/v1/namespaces/default/pods ... 200 OK`** 가 그대로 보인다
- 10일차 **클라이언트–서버** 그림 그대로다. `kubectl` 이 클라이언트, **API 서버**가 서버
- `kubectl proxy` 로 통로를 열면 **`curl` 로 같은 답**을 받을 수 있다 → `jq` 로 잘라 읽는다
- ⭐ 주소가 **"무엇을"**, 메서드가 **"어떻게"** 다. `get`→`GET`, `delete`→`DELETE`
- 🚨 `kubectl proxy` 는 **인증 없이 열린 통로**다. 실습이 끝나면 반드시 `Ctrl+C`
{% endhint %}

---

## Q10. 🅱️ 접속이 안 된다 — [7_더_들어가기](lesson-7.md) · 12일차

Pods are `Running` but the Service returns nothing, and `kubectl get endpoints web` is empty. What is wrong?
(Pod 는 `Running` 인데 Service 로 접속이 안 되고 `endpoints` 가 비어 있다. 무엇이 문제인가?)

- A. 이미지가 잘못됐다
- B. 포트가 막혔다
- C. **라벨이 안 맞아서 Service 가 Pod 를 못 찾고 있다**
- D. 노드가 죽었다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- Service 는 **라벨로** 보낼 Pod 를 고른다. `spec.selector` 와 Pod 의 라벨이 다르면 **보낼 곳이 없다**
- **`endpoints` 가 비어 있다 = 라벨 문제**. 14일차에 `ss` 로 "듣고 있나"를 보던 자리와 같다
- 좁혀 가는 순서 — ① `get pods` ② `describe`(Events) ③ `logs` ④ `get svc,endpoints`
- ⭐ **`describe` 의 맨 아래 Events** 가 "안 되면 여기부터" 다. 12일차 `journalctl` 과 같은 자리
{% endhint %}

---

## 📝 강의 메모

- ⭐⭐ **Q1 · Q7 은 무슨 일이 있어도 다룬다.** 둘이 한 쌍이다 — Q1 이 주장, Q7 이 증거
- **Q2** 는 "쿠버네티스는 딴 세상"이라는 공포를 푸는 문제다. 짧게 짚고 넘어간다
- **Q5 · Q6** 은 매니페스트를 직접 쓴 반에서만 효과가 있다. 4번 절을 읽기만 했다면 **Q5 는 눈으로**
- **Q8** 은 13일차와 꿰는 문제다. "고치는 곳은 하나" 가 세 번째 반복이다
- ⏱ 20분. 시간이 모자라면 **Q3 · Q4 는 눈으로** 읽고 **Q1 · Q7 · Q8** 에 집중한다
- 📌 끝맺음 한 줄 — **"오늘 우리는 컨테이너를 띄운 게 아니라, 띄워진 상태를 적어 뒀습니다."**
