# 6. 오늘의 문제 🎯

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md)
> 💡 **진행 방법**: 각자 먼저 풀게 한 뒤 → `정답 및 해설` 콜아웃을 펼쳐 함께 확인한다.
> 📌 **마지막 날이다.** Q8 은 16일 전체를 꿰는 문제다.

---

## Q1. 클러스터는 이미지를 어디서 찾나 ⭐ — [1_내_이미지를_클러스터로](lesson-1.md)

You built `mysite:1.0` on your WSL. Why can't the cluster find it?
(내 WSL 에서 이미지를 구웠는데 클러스터가 못 찾는다. 왜인가?)

- A. 이미지가 손상돼서
- B. **노드(컨테이너) 안의 이미지 목록은 내 Docker 와 별개라서**
- C. 태그가 없어서
- D. 클러스터가 꺼져 있어서

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 15일차에 봤듯 **노드는 컨테이너 한 개**다. 그 안은 내 WSL 의 Docker 와 **다른 공간**이다
- 넣는 방법은 둘 — **레지스트리에 올리거나**(`docker push`), **노드에 직접 넣거나**(`kind load`)
- 수업에서는 계정이 필요 없는 **`kind load`** 로 갔다
- 📌 못 찾으면 STATUS 가 **`ErrImagePull`** 로 뜬다
{% endhint %}

---

## Q2. 🚨 kind load 가 실패했다 — [1_내_이미지를_클러스터로](lesson-1.md)

`kind load docker-image mysite:1.0` fails with `ctr: content digest ... not found`. What is the cause and the workaround?
(`kind load docker-image` 가 저 오류로 실패한다. 원인과 대안은?)

- A. 이미지를 다시 빌드한다
- B. 클러스터를 다시 만든다
- C. **Docker 29 의 이미지 저장 방식이 바뀌어서 → `docker image save` + `kind load image-archive`**
- D. `sudo` 를 붙인다

{% hint style="success" %}
**정답 및 해설**

**정답: C**
- **Docker Engine 29 부터 새로 설치하면 이미지 저장소가 바뀌었다**(containerd 이미지 저장소가 기본). 14일차에 깐 것이 바로 그 버전이다
- 대안 — 파일로 떠서 넣는다
  ```bash
  docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0
  kind load image-archive /tmp/mysite.tar --name student
  ```
- 💡 **떠서(save) → 넣는다(load).** 12일차 `scp` 로 파일을 옮기던 감각 그대로다
- ⭐ **교과서 한 줄이 안 될 때 두 줄로 돌아갈 수 있는 것**이 오늘 배운 일이다
{% endhint %}

---

## Q3. ErrImagePull 과 태그 ⭐ — [1_내_이미지를_클러스터로](lesson-1.md)

You loaded the image into the node, but the Pod still shows `ErrImagePull`. The image tag is `mysite:latest`. Why?
(노드에 넣었는데도 `ErrImagePull` 이다. 태그가 `latest` 다. 왜인가?)

- A. `latest` 는 예약어라서
- B. **태그가 `latest` 면 기본 정책이 `Always` 라, 로컬에 있어도 밖에서 받으려 한다**
- C. 노드가 하나라서
- D. Service 를 안 만들어서

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **고정 태그(`1.0`)** → 기본 `imagePullPolicy` 는 **`IfNotPresent`** → 노드에 있으면 **그걸 쓴다** ○
- **`latest` 또는 태그 없음** → **`Always`** → **매번 레지스트리를 찾는다** → 없으니 실패 ×
- 못 박으려면 매니페스트에 **`imagePullPolicy: IfNotPresent`**
- ⭐ 14일차에 **"태그를 올려 쓰라"**(`1.0` → `1.1`)고 한 이유가 여기서 증명된다. 되돌릴 자리도 태그가 만든다
{% endhint %}

---

## Q4. Secret 🚨 ⭐⭐ — [2_설정과_비밀](lesson-2.md) · 13일차

A Kubernetes Secret stores `DB_PASSWORD` as `ZXhhbXBsZS1wYXNzd29yZA==`. Is the password protected?
(Secret 에 비밀번호가 저렇게 들어 있다. 안전한가?)

- A. 안전하다 — 암호화돼 있다
- B. **안전하지 않다 — base64 는 암호가 아니라 표현 방식이다**
- C. 안전하다 — 클러스터 안에만 있으니까
- D. 재부팅하면 안전해진다

{% hint style="success" %}
**정답 및 해설**

**정답: B 🚨**
- `echo 'ZXhhbXBsZS1wYXNzd29yZA==' | base64 -d` **한 줄이면 풀린다**
- **Secret 이라는 이름에 속으면 안 된다.** '숨긴 것'이 아니라 **'다르게 적은 것'** 이다
- 🚨 **Secret 매니페스트를 파일로 만들어 커밋하면** 13일차 `.env` 사고와 **똑같다**. 지워도 이력에 남는다
- 그래서 **명령으로 만들거나**(`kubectl create secret`), **값 파일을 `.gitignore`** 에 둔다
- 실무에서는 외부 비밀 저장소를 붙인다 — **"그런 자리가 있다"** 까지
{% endhint %}

---

## Q5. 문을 여는 세 단계 ⭐⭐ — [3_밖으로_여는_법](lesson-3.md) · 14일차

Which Service type makes an app reachable from outside the cluster in our kind setup?
(우리 kind 환경에서 밖에서 접속되게 하는 Service 타입은?)

- A. ClusterIP
- B. **NodePort**
- C. 아무거나 된다
- D. Service 없이도 된다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **ClusterIP**(기본) = 클러스터 안만. `port-forward` 는 **켜 둔 동안만** 열리는 들여다보기용 통로
- **NodePort** = 노드에 포트를 연다. 🚨 단, **kind 는 클러스터를 만들 때 `extraPortMappings` 로 구멍을 뚫어 둬야** 한다
  - 노드도 **컨테이너**이므로 **`-p` 가 없으면 안 열린다** — 14일차 그대로다
- **Ingress** = 문 하나로 **이름·경로를 보고 나눠 보낸다**. 12일차 프록시의 방향을 뒤집은 것
- ⭐ 14일차 대응 — `-p` 없음 → `127.0.0.1:` → `-p 8080:80` → 리버스 프록시
{% endhint %}

---

## Q6. DB 는 어떻게 두나 ⭐ — [3_밖으로_여는_법](lesson-3.md) · 11 · 14일차

How should the database Service be exposed?
(DB 의 Service 는 어떻게 두어야 하나?)

- A. NodePort 로 열어 둔다
- B. **ClusterIP 그대로 둔다 (밖에 열지 않는다)**
- C. Ingress 에 붙인다
- D. port-forward 를 켜 둔다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- 웹만 DB 에 닿으면 되므로 **밖에 열 이유가 없다**
- ⭐ 14일차 Compose 의 결말 — **`ports` 가 없는 db** — 가 쿠버네티스에서는 **`type` 을 안 바꾸는 것**으로 나타난다
- 11일차 **공격 표면**: 밖에 열린 Service 하나하나가 문이다. **기본이 ClusterIP** 라는 건 **기본 거부**와 같은 생각
- 🚨 14일차 **"Docker 가 ufw 를 우회한다"** 는 여기서도 유효하다. kind 노드는 컨테이너다
{% endhint %}

---

## Q7. 끊김 없이 바꾸기 ⭐ — [4_고치고_되돌리기](lesson-4.md)

During `kubectl set image`, in what order do Pods change?
(롤링 업데이트에서 Pod 는 어떤 순서로 바뀌나?)

- A. 옛 Pod 를 지우고 새 Pod 를 만든다
- B. **새 Pod 가 Running 이 된 뒤 옛 Pod 가 내려간다**
- C. 동시에 바뀐다
- D. 노드를 재부팅한다

{% hint style="success" %}
**정답 및 해설**

**정답: B**
- **새 것이 준비된 다음에 옛 것을 내린다.** 그래서 **끊기지 않는다**
- 💡 **교대 근무** — 다음 사람이 자리에 앉은 뒤에 앞사람이 퇴근한다. 카운터가 비는 순간이 없다
- 13일차 `git pull` 과 14일차 `rm -f` 후 `run` 은 **잠깐 끊겼다**. 그 차이가 오늘의 값이다
- 되돌리기는 **`kubectl rollout undo`** — 되돌리는 동안에도 안 끊긴다
- ⚠️ `mysite:1.0` 이미지를 지웠으면 **못 돌아간다.** `latest` 하나로 덮어쓰면 안 되는 이유다
{% endhint %}

---

## Q8. 16일을 한 줄로 ⭐⭐ — [5_16일_되짚기](lesson-5.md)

Which sentence runs through 11, 12, 14, and 16일차 alike?
(11 · 12 · 14 · 16일차를 관통하는 문장은?)

- A. 컨테이너가 가볍다
- B. **열지 않은 것은 닫혀 있다 — 필요한 것만 연다**
- C. 리눅스가 좋다
- D. 백업이 중요하다

{% hint style="success" %}
**정답 및 해설**

**정답: B — 과정 전체의 뼈대다**
- 11일차 **ACL 의 암묵적 deny** · 12일차 **`ufw` ⑤ 개방** · 14일차 **`-p` 를 아낀다** · 16일차 **기본이 ClusterIP**
- 도구는 넷 다 다르지만 **생각은 하나**다
- 🚨 그리고 **예외도 배웠다** — 14일차 Docker 의 `ufw` 우회. **규칙을 아는 것과, 규칙이 안 통하는 자리를 아는 것은 다르다**
- 📌 나머지 넷 — **여섯 단계** · **되돌릴 수 있게** · **기억 말고 적어 두기** · **한 포트에 한 프로그램**
{% endhint %}

---

## 📝 강의 메모

- ⭐⭐ **Q2 · Q3 는 오늘 실제로 막히는 지점**이다. 실습 중에 만난 에러를 그대로 문제로 낸 것이니 **그때 한 번 더 짚어** 둔다
- ⭐⭐ **Q4(base64)** 는 손으로 풀어 본 뒤에 푼다. 안 해봤으면 문제가 안 산다
- ⭐ **Q8 은 마지막 문제다.** 답을 맞히는 것보다 **학생이 네 날을 스스로 꿰는 것**이 목적이다. 시간을 넉넉히
- ⏱ 20분. 시간이 모자라면 **Q1 · Q5 는 눈으로** 읽고 **Q3 · Q4 · Q8** 에 집중한다
- 📌 끝맺음 — **"16일 동안 도구는 계속 바뀌었습니다. 생각은 다섯 개뿐이었습니다."**
