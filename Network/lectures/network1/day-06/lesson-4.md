# 4. 오늘의 CCNA

> 상위: [6일차 · 라우팅 프로토콜 심화 — 재분배](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-06-004-INS |
| 유형 | INS (점검) |
| 목적 | 6일차 내용을 CCNA 실전형 문제 5개로 점검한다 |
| 확인 상태 | 미검증 (원본 문제와 정답을 정리한 것이며 실제 시험 기출과 대조하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 점검 방법

- 문제를 먼저 각자 풀게 한 뒤 정답과 해설을 함께 확인한다.
- CCNA 실제 시험은 영어라서 핵심 용어는 영문을 함께 표기했다.
- 6일차는 통역사(경계 라우터) 한 대가 주인공이다. 답을 고르기 전에 "이것은 어느 라우터에서 하는 이야기인가?"부터 묻는다.
- 합격 기준: 5문항 중 4문항 이상 정답이다.

## 그림 목록

그림 파일은 없다. 발표 드로잉 10장은 문제 프레임과 정답·해설 프레임이 쌍으로 이어진다. 문제 프레임에서 멈추고 풀게 한 뒤 다음 프레임(정답)으로 넘어간다.

| 프레임 | 내용 | 프레임 | 내용 |
|---|---|---|---|
| 01 | Q1 왜 통신이 안 되나 | 02 | Q1 정답·해설 |
| 03 | Q2 명령을 어디서 치나 | 04 | Q2 정답·해설 |
| 05 | Q3 seed metric 누락 | 06 | Q3 정답·해설 |
| 07 | Q4 `O E2` 읽기 | 08 | Q4 정답·해설 |
| 09 | Q5 재분배의 위험 | 10 | Q5 정답·해설 |

---

## Q1. 왜 통신이 안 되나

관련 문서: [1. 재분배란 무엇인가](lesson-1.md)

R2 runs **both RIP and OSPF**. R1 runs RIP only; R3 runs OSPF only.
All links are up and R2's routing table shows **every** network.
Still, a PC behind R1 cannot reach a PC behind R3. Why?
(R2는 모든 경로를 아는데도 끝단끼리 통신이 안 된다. 왜?)

- A. R2의 인터페이스가 down 상태여서
- B. 한 장비 안에 있어도 RIP 프로세스와 OSPF 프로세스는 서로 경로를 넘기지 않기 때문
- C. AD가 충돌해서 R2가 경로를 버렸기 때문
- D. RIP과 OSPF는 같은 라우터에서 동시에 돌 수 없기 때문

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- 프로토콜은 자기 언어권하고만 정보를 나눈다. 같은 장비 안이어도 마찬가지다.
- R2는 왼쪽 소식도 알고 오른쪽 소식도 알지만 옮겨 주지 않는다. 혼자만 안다.
- 그래서 R1은 30.0을, R3은 10.0을 끝내 모른다. 경로가 없으므로 버린다.
- D가 오답인 이유: 동시에 돌 수 있다. 오히려 그래야 재분배가 가능하다.
- 통역사가 가만히 있는 상태이며, "통역해 주세요"라고 시켜야 한다. 그것이 재분배다.
- 되짚기: 재분배 전 확인 단계에서 세 라우터 테이블을 나란히 비교한 표
{% endhint %}

---

## Q2. 명령을 어디서 치나

관련 문서: [2. 재분배의 원리와 주의점](lesson-2.md)

You want **RIP-learned routes to appear in OSPF**.
Under which process do you configure the `redistribute` command?
(RIP 경로를 OSPF에 넣고 싶다. 어느 프로세스 안에서 설정하나?)

- A. `router rip` 안에서 `redistribute ospf 1`
- B. `router ospf 1` 안에서 `redistribute rip subnets metric 20`
- C. 전역 설정 모드에서 `redistribute rip into ospf`
- D. 인터페이스 설정 모드에서

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- 공식: "받는 집에 들어가서, 어디서 가져올지 말한다"
- 넣고 싶은 곳은 OSPF이므로 `router ospf 1`로 들어간다.
- 가져올 곳은 RIP이므로 `redistribute rip`을 친다.
- A가 오답인 이유: 정반대 방향(OSPF 경로를 RIP에 넣기)이다.
- 방향은 각각 설정한다. 끝단끼리 ping이 되려면 두 줄이 다 필요하다(라우팅은 왕복, 4일차부터 계속 나온 원칙).
{% endhint %}

---

## Q3. 재분배했는데 왜 안 올까

관련 문서: [2. 재분배의 원리와 주의점](lesson-2.md)

An engineer configures `redistribute ospf 1` under `router rip`.
After waiting several minutes, the RIP routers still receive **nothing**.
What is the most likely cause?
(몇 분을 기다려도 RIP 쪽에 아무 경로도 오지 않는다. 가장 유력한 원인은?)

- A. OSPF의 area 번호가 틀렸다
- B. seed metric을 지정하지 않아 무한대(∞)로 취급되어 광고되지 않는다
- C. RIP의 `version 2`를 안 했다
- D. 재분배는 원래 몇 시간이 걸린다

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- RIP과 EIGRP는 seed metric 기본값이 무한대(∞)다. 즉 도달 불가다.
- 무한대인 경로는 광고 자체를 하지 않는다. 상대는 아무 소식도 받지 못한다.
- 해결: `redistribute ospf 1 metric 3` 또는 `default-metric 3`
- 비대칭에 주의한다. OSPF는 기본값 20이 있어서 안 줘도 동작한다. "OSPF 쪽은 되던데요?"가 여기서 나온다.

| 받는 쪽 | 기본 seed metric | 지정 |
|---|---|---|
| RIP, EIGRP | 무한대(∞) | 필수 |
| OSPF | 20 | 선택 |

- 되짚기: 실습에서 일부러 메트릭 없이 쳐서 실패를 본 장면
{% endhint %}

---

## Q4. 이 표시는 무슨 뜻인가

관련 문서: [1. 재분배란 무엇인가](lesson-1.md)

A router's table shows:
`O E2  192.168.10.0/24 [110/20] via 192.168.50.1`
What does **E2** tell you?
(`O E2`의 `E2`가 뜻하는 것은?)

- A. OSPF Area 2에서 온 경로
- B. OSPF 밖에서 재분배돼 들어온 외부 경로이며, 코스트가 seed metric 그대로 고정된다
- C. 두 번째로 좋은 경로(백업)
- D. EIGRP로 배운 경로

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- E는 External이다. OSPF 세상 밖에서 재분배돼 들어온 손님이라는 표식이다.
- 2는 Type 2다. 코스트가 seed metric 그대로이며 어느 라우터에서 봐도 항상 20이다.
- E1이면 seed metric에 여기까지 오는 내부 코스트를 더한 값이므로 위치마다 다르다.
- 기본값은 E2다.
- A가 오답인 이유: Area 간 경로는 `O IA`(Inter-Area)로 따로 표시된다.
- D가 오답인 이유: EIGRP 외부 경로는 `D EX`다.
- 경계 라우터가 여러 곳일 때 가까운 쪽을 고르려면 E1이 유리하다.
{% endhint %}

---

## Q5. 재분배가 왜 위험한가

관련 문서: [2. 재분배의 원리와 주의점](lesson-2.md)

Two boundary routers perform **mutual redistribution** between RIP and OSPF.
What is the primary risk?
(경계 라우터 두 곳에서 상호 재분배를 했다. 가장 큰 위험은?)

- A. CPU 사용률이 100%가 된다
- B. 경로가 한 도메인으로 나갔다가 다른 지점으로 되돌아와 라우팅 루프가 생길 수 있다
- C. 라우터가 재부팅된다
- D. IP 주소가 중복된다

{% hint style="info" %}
NOTE: 정답 및 해설

정답: B

- 경계가 한 곳이면 나간 경로가 돌아올 길이 없어 안전하다.
- 경계가 두 곳 이상이면 R2로 나간 경로가 R4를 통해 되돌아온다.
- 되돌아온 경로가 AD가 낮아 보이면 라우터가 그것을 믿는다. 그러면 경로가 빙빙 돈다.
- 함께 오는 문제: 차선 경로(seed metric이 원래 거리를 지워 먼 길을 고름)
- 실무 3원칙: ① 재분배 지점 최소화 ② route-map으로 필터 ③ `distance`로 AD 조정(②③은 CCNP 수준이며 이름만 알아 두면 충분하다)
- 되짚기: 실습에서 R1이 30.0과 50.0을 똑같이 `[120/3]`으로 본 화면이 거리 정보가 사라진 증거다.
{% endhint %}

---

## 합격 기준

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Q1~Q5를 푼다 | 정답과 일치한다 | 5문항 중 4문항 이상 |
| 2 | 오답 문항의 해설을 읽고 다시 푼다 | 해설의 근거로 답이 나온다 | 오답 문항 모두 재풀이 성공 |

## 강의 메모

- Q1(왜 필요), Q2(어디서), Q3(왜 실패), Q4(표시 읽기), Q5(위험) 순서가 오늘 흐름 그대로다.
- Q3이 오늘의 최중요 문제다. 실습에서 직접 실패를 겪었으므로 정답률이 높다. 자신감을 주고 RIP/EIGRP와 OSPF의 비대칭을 한 번 더 각인시킨다.
- Q2는 "받는 집에 들어가서" 구호를 학생이 소리 내어 말하게 한다.
- Q4는 실제 출력 한 줄을 화면에 띄우고 손가락으로 짚어 가며 읽힌다.
- Q5는 그림(경계 라우터 2곳)을 칠판에 그려야 이해가 빠르다.
- 4~6일차 라우팅 3부작이 오늘로 끝난다. 마무리에 되짚는다.
  1. 4일차: 손으로 길을 넣는다(정적)
  2. 5일차: 라우터끼리 알아서 채운다(동적)
  3. 6일차: 말이 다른 구역을 잇는다(재분배)
- 다음 예고: "라우터는 끝났다. 이제 꽂기만 했던 스위치를 제대로 다뤄 보자" → [7일차](../day-07/README.md)

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 강의 노트를 AMM 형식(INS)으로 재작성. 정답 해설의 알림 종류를 success에서 info로 변경 |
