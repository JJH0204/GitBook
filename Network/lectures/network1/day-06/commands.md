# 0. 6일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [6일차 · 라우팅 프로토콜 심화 — 재분배](README.md) · 설명은 [3. 재분배 실습](lesson-3.md)

## 문서 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-06-005-REF |
| 유형 | REF (명령어 대본, 표) |
| 목적 | 6일차 실습의 명령을 수업 흐름 순서대로 모아, 실습 중 화면에 띄우거나 인쇄해 따라 치게 한다 |
| 확인 상태 | 미검증 (원본 명령 대본을 정리한 것이며 Packet Tracer에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

위에서 아래로 그대로 따라 치면 오늘 실습이 끝난다.

## 읽는 법 (4·5일차와 같은 약속)

- 블록 하나는 한 장비에서 끊지 않고 이어 치는 한 덩어리다.
- 블록 머리의 `PC0`, `R2` 등은 어느 장비의 어느 창인지를 뜻하고, 블록 끝의 "다음:"은 다음 행선지다.
- `#` 뒤의 글은 설명이다. 안 쳐도 된다.
- 오늘도 기다리는 실습이다. RIP 쪽은 최대 30초, OSPF 쪽은 몇 초가 걸린다.
- 오늘의 실습은 하나다. 5일차 파일을 고쳐 쓰지 않고 새 파일에 그림을 처음부터 다시 만든다. 그림과 주소는 5일차와 같다.

## 오늘의 그림

5일차와 같은 그림이며 언어만 둘로 나눈다.

```
      ◀────── RIP 구역 ──────▶   ◀───── OSPF 구역 ─────▶
[PC0]──[SW1]──[R1]══════[R2]══════[R3]──[SW2]──[PC2]
 .10.1        20.0/24    ▲   50.0/24        .30.1
                         │
                    양쪽 언어를 다 하는 라우터
                    = 통역사 = 오늘의 주인공
```

| 장비 | 도는 프로토콜 | 아는 네트워크 |
|---|---|---|
| R1 | RIP만 | 10.0, 20.0 |
| R2 | RIP + OSPF 둘 다 | 전부(통역사 = ASBR) |
| R3 | OSPF만 | 50.0, 30.0 |

오늘의 질문: R2는 다 아는데 R1과 R3은 왜 서로를 모르는가?

| 장비 | G0/0 | G0/1 |
|---|---|---|
| R1 | `192.168.10.254` (PC0 쪽) | `192.168.20.1` |
| R2 | `192.168.50.1` | `192.168.20.2` |
| R3 | `192.168.30.254` (PC2 쪽) | `192.168.50.2` |

- PC0: `192.168.10.1`, 게이트웨이 `192.168.10.254`
- PC2: `192.168.30.1`, 게이트웨이 `192.168.30.254`

---

## 준비: 그림 만들기 (5일차와 같다)

### 0-1 마우스로 (명령 아님)

1. 라우터 3대, 스위치 2대, PC 2대를 배치하고 케이블을 연결한다.
2. 라우터끼리는 크로스오버, 나머지는 다이렉트로 연결한다. 링크 점이 초록이 될 때까지 기다린다.
3. `PC0`, `PC2`에 IP, 마스크, 게이트웨이를 입력한다.

### 0-2 R1, R2, R3 CLI: 인터페이스 켜기

```bash
# ── R1 ──
enable
configure terminal
no ip domain-lookup
hostname R1
interface g0/0
 ip address 192.168.10.254 255.255.255.0
 no shutdown
 exit
interface g0/1
 ip address 192.168.20.1 255.255.255.0
 no shutdown
end
show ip interface brief
```

```bash
# ── R2 ──
enable
configure terminal
no ip domain-lookup
hostname R2
interface g0/1
 ip address 192.168.20.2 255.255.255.0
 no shutdown
 exit
interface g0/0
 ip address 192.168.50.1 255.255.255.0
 no shutdown
end
show ip interface brief
```

```bash
# ── R3 ──
enable
configure terminal
no ip domain-lookup
hostname R3
interface g0/1
 ip address 192.168.50.2 255.255.255.0
 no shutdown
 exit
interface g0/0
 ip address 192.168.30.254 255.255.255.0
 no shutdown
end
show ip interface brief
```

체크: 세 라우터 모두 `up/up` 2개, 각자 `C` 경로 2개다.

---

## STEP 1. 한 회사를 두 구역으로 쪼갠다 (25분)

상황극: A사(R1 쪽, 옛날 장비라 RIP)와 B사(R3 쪽, OSPF)가 합병했다. 가운데 R2만 두 언어를 다 할 줄 안다.

### 1-1 R1 CLI: 왼쪽 구역은 RIP

```bash
configure terminal
router rip
 version 2
 no auto-summary
 network 192.168.10.0
 network 192.168.20.0
end
show ip protocols              # rip 만 도는가
show ip route                  # C 와 L 만 — 아직 아무것도 못 배웠다
```

다음: R3 CLI로 간다(오른쪽 구역부터 마저 만든다).

### 1-2 R3 CLI: 오른쪽 구역은 OSPF

```bash
configure terminal
router ospf 1
 network 192.168.50.0 0.0.0.255 area 0
 network 192.168.30.0 0.0.0.255 area 0
end
show ip protocols              # ospf 만
show ip route                  # C 와 L 만 (10.0 · 20.0 을 모른다)
```

다음: R2 CLI로 간다. 오늘의 주인공이다.

### 1-3 R2 CLI: 왼쪽은 RIP, 오른쪽은 OSPF (한 대에서 둘 다)

```bash
configure terminal
router rip                                  # 왼쪽 구간만 RIP 으로
 version 2
 no auto-summary
 network 192.168.20.0
 exit
router ospf 1                               # 오른쪽 구간만 OSPF 로
 network 192.168.50.0 0.0.0.255 area 0
end
show ip protocols              # rip 과 ospf 가 둘 다 나온다 = 통역사 자격
show ip route                  # 30초 대기 · R 192.168.10.0 · O 192.168.30.0 둘 다 보인다
```

이 화면이 오늘의 핵심 장면이다. R2만 `R`과 `O`를 동시에 갖고 있다.

체크: R1은 `rip`만, R2는 `rip`과 `ospf`, R3은 `ospf`만 나온다.

---

## STEP 2. 왜 안 되는지 먼저 확인한다 (10분)

케이블은 다 붙어 있고 라우터도 다 살아 있다. 그런데 안 된다. 왜인가?

### 2-1 PC0: 실패 확인

```bash
ping 192.168.30.1              # 실패한다
```

### 2-2 R1 CLI: 내가 아는 것 (모른다)

```bash
show ip route                  # 30.0 · 50.0 이 없다 → 보낼 곳을 모른다
```

### 2-3 R2 CLI: 나는 다 안다

```bash
show ip route                  # R 10.0 · C 20.0 · C 50.0 · O 30.0 — 전부 있다
```

질문: "가운데 R2는 다 아는데 왜 통신이 안 되는가?" → R2가 혼자만 알고 있기 때문이다. 왼쪽 말을 오른쪽에 옮겨 주지 않는다. 프로토콜은 자기 언어끼리만 정보를 나눈다. → [1. 재분배란 무엇인가](lesson-1.md)

체크: R1과 R3은 반쪽만 안다. R2만 전부 안다. PC0에서 PC2로 ping이 실패한다.

---

## STEP 3. 통역을 걸어 준다 (30분, 오늘의 핵심)

모든 명령은 R2 한 대에서만 친다. R1과 R3은 끝까지 손대지 않는다.

### 3-1 R2 CLI: ① OSPF 쪽으로 RIP 소식 넘기기

```bash
configure terminal
router ospf 1
 redistribute rip subnets metric 20     # RIP 이 아는 것을 OSPF 언어로 옮긴다
end
show ip route                           # R2 자신은 변화 없다 (원래 다 알았으니까)
```

- `redistribute rip`: 어디서 가져올지 지정한다.
- `subnets`: 서브넷까지 전부 넘긴다(습관적으로 항상 붙인다).
- `metric 20`: OSPF 언어로 매긴 값(코스트)이며 seed metric이다.

다음: R3로 가서 효과를 확인한다(넘겨받는 쪽에서 봐야 보인다).

### 3-2 R3 CLI: 밖에서 온 경로가 보인다

```bash
show ip route                  # 몇 초 · O E2 항목이 새로 생겼다
show ip route ospf
```

```
O E2 192.168.10.0/24 [110/20] via 192.168.50.1, 00:00:09, GigabitEthernet0/1
──┬─                  ──┬─
  E = External          재분배할 때 준 seed metric 20 이 그대로
  "밖에서 재분배돼 들어온 경로"
```

질문: "`O` 뒤에 붙은 `E`가 무엇인가?" → External. 이 구역 밖에서 온 경로라는 표식이다.

다음: 반대 방향으로 간다. R2로 돌아간다.

### 3-3 R2 CLI: ② RIP 쪽으로 넘기기 (일부러 틀리게 먼저)

```bash
configure terminal
router rip
 redistribute ospf 1            # 메트릭을 일부러 안 준다
end
```

30초 기다린다. 그동안 R1 화면을 띄워 둔다. 다음: R1에서 `show ip route`를 입력하면 아무것도 생기지 않는다.

### 3-4 R1 CLI: 안 생기는 것을 확인 (기다려도 안 생긴다)

```bash
show ip route                  # 30초 더 기다려도 30.0 · 50.0 이 없다
```

질문: "명령은 분명히 쳤는데 왜 안 오는가?" → RIP은 홉 수로 말한다. 몇 홉인지 안 알려 줬다. 무한대(∞)로 취급해 광고하지 않는다. 이것이 seed metric을 반드시 줘야 하는 이유다. → [2. 재분배의 원리와 주의점](lesson-2.md)

다음: 다시 R2로 간다.

### 3-5 R2 CLI: ③ seed metric을 준다 (한 단어 차이)

```bash
configure terminal
router rip
 redistribute ospf 1 metric 3   # "RIP 언어로 3홉짜리" 라고 알려준다
end
```

30초 기다린다. 다음: R1으로 간다.

### 3-6 R1 CLI: 이번에는 생긴다

```bash
show ip route                   # 30초 대기 · R 192.168.30.0 · R 192.168.50.0
show ip route rip
```

```
R    192.168.30.0/24 [120/3] via 192.168.20.2   ← 우리가 준 3홉이 그대로 들어왔다
R    192.168.50.0/24 [120/3] via 192.168.20.2
```

질문: "이 3은 실제 거리인가?" → 아니다. 우리가 정해 준 값이다. 실제 거리를 잃어버리는 것이 재분배의 대표적인 부작용(차선 경로)이다.

다음: PC0에서 최종 확인한다.

### 3-7 PC0: 끝에서 끝까지 성공

```bash
ping 192.168.30.1
tracert 192.168.30.1            # R1 → R2 → R3 을 거쳐 간다
```

저장: 세 라우터 모두 `copy running-config startup-config`를 입력하고, 파일은 `Ctrl + S`로 저장한다.

체크:

- [ ] R3 테이블에 `O E2` 2개(10.0, 20.0)
- [ ] R1 테이블에 `R` 2개(30.0, 50.0), 메트릭 `[120/3]`
- [ ] PC0에서 PC2로 ping 성공
- [ ] R1과 R3에는 재분배 설정을 하지 않았다(통역은 R2 한 대에서만)

---

## STEP 4. E1과 E2는 무엇이 다른가 (15분, 여유 있으면)

`O E2`의 2는 무슨 뜻인가. 숫자 하나를 바꿔서 직접 비교한다.

### 4-1 R2 CLI: E1로 바꿔 본다

```bash
configure terminal
router ospf 1
 redistribute rip subnets metric 20 metric-type 1
end
```

몇 초 기다린다. 다음: R3로 간다.

### 4-2 R3 CLI: 표시와 숫자가 둘 다 바뀐다

```bash
show ip route ospf
```

| 구분 | 표시 | 코스트 |
|---|---|---|
| 바꾸기 전(기본) | `O E2` | `[110/20]`. 어디서 보든 항상 20 |
| 바꾼 뒤 | `O E1` | `[110/21…]`. 20 + 여기까지 오는 내부 비용 |

E2는 준 값 그대로, E1은 준 값에 오는 길 비용을 더한 값이다. 여러 통역사(경계 라우터)가 있을 때 가까운 통역사를 고르려면 E1이 유리하다. 기본값은 E2다.

### 4-3 R2 CLI: 기본(E2)으로 되돌리고 `default-metric`으로 정리

```bash
configure terminal
router ospf 1
 no redistribute rip subnets metric 20 metric-type 1
 default-metric 20                      # 이 프로세스로 들어오는 모든 재분배의 기본값
 redistribute rip subnets
 exit
router rip
 default-metric 3                       # RIP 쪽도 마찬가지로 한 번에
 redistribute ospf 1
end
show running-config | section router     # 설정이 짧아진 것을 확인
```

재분배 줄이 여러 개가 되면 `default-metric` 한 줄로 몰아 쓰는 것이 실무 습관이다.

저장: 세 라우터에서 `copy run start`를 입력하고 파일은 `Ctrl + S`로 저장한다.

최종 체크: 되돌린 뒤에도 PC0에서 PC2로 ping이 여전히 성공한다.

---

## 부록 A. 기본 경로(디폴트) 내보내기

실무에서 제일 많이 쓴다. 인터넷으로 나가는 길처럼 "나머지 전부"를 한 줄로 뿌리는 방법이다(개념만, 시간 남으면 실습).

```bash
configure terminal
ip route 0.0.0.0 0.0.0.0 g0/1           # ① 내가 먼저 디폴트 경로를 가진다
router ospf 1
 default-information originate          # ② "나한테 오면 밖으로 나갈 수 있다" 고 광고
end
```

- RIP 쪽은 `router rip` 안에서 `default-information originate`(같은 이름)를 쓴다.
- 받는 라우터의 테이블에는 `O*E2 0.0.0.0/0`처럼 뜬다(`*`는 디폴트 후보).
- 4일차 디폴트 라우트의 확장이다. → [2. 라우터 동작 원리](../day-04/lesson-2.md)

## 부록 B. 오늘 새로 나온 명령 사전

| 무엇 | 명령 | 어느 모드 |
|---|---|---|
| OSPF로 RIP 경로 주입 | `redistribute rip subnets metric 20` | `(config-router)#` (`router ospf 1`) |
| RIP으로 OSPF 경로 주입 | `redistribute ospf 1 metric 3` | `(config-router)#` (`router rip`) |
| 정적 경로 주입 | `redistribute static subnets metric 20` | `(config-router)#` |
| 직접연결 주입 | `redistribute connected subnets metric 20` | `(config-router)#` |
| 기본 메트릭 한 번에 | `default-metric 20` | `(config-router)#` |
| External 타입 지정 | `metric-type 1` (기본은 2) | `redistribute` 뒤에 |
| 디폴트 경로 광고 | `default-information originate` | `(config-router)#` |
| 재분배 취소 | 앞에 `no`. 예: `no redistribute rip` | `(config-router)#` |
| 설정 일부만 보기 | `show running-config \| section router` | `#` |
| 외부 경로만 보기 | `show ip route ospf` / `show ip route rip` | `#` |

4·5일차 명령은 [4일차 명령어](../day-04/commands.md), [5일차 명령어](../day-05/commands.md)를 본다.

## 부록 C. 재분배 명령 만드는 공식

헷갈릴 때 여기를 본다.

```
(내가 넣고 싶은 곳으로 들어가서)   router <받는 프로토콜>
(가져올 곳을 지목)                  redistribute <주는 프로토콜> <옵션> metric <받는 쪽 단위>
```

| 방향 | 어디로 들어가서 | 무엇을 친다 |
|---|---|---|
| RIP → OSPF | `router ospf 1` | `redistribute rip subnets metric 20` |
| OSPF → RIP | `router rip` | `redistribute ospf 1 metric 3` |
| 정적 → OSPF | `router ospf 1` | `redistribute static subnets metric 20` |

{% hint style="warning" %}
CAUTION: 가장 흔한 실수는 넣고 싶은 쪽이 아니라 주는 쪽에 들어가서 치는 것이다. "받는 집에 들어가서, 어디서 가져올지 말한다"로 외운다.
{% endhint %}

| 받는 쪽 | 메트릭 기본값 | 지정 필요 |
|---|---|---|
| RIP | 무한대(∞) | 필수(예: `metric 3`) |
| EIGRP | 무한대(∞) | 필수(대역폭, 지연 등 5개 값) |
| OSPF | 20 | 선택(안 줘도 동작) |

## 부록 D. 안 될 때 30초 점검

| 증상 | 원인·조치 |
|---|---|
| 재분배했는데 경로가 안 온다 | RIP은 30초가 걸린다. 한 번 더 `show ip route`를 입력한다 |
| 그래도 안 온다(RIP 쪽) | `metric`을 안 줬다. 무한대 취급이므로 `metric 3`을 추가한다 |
| 한쪽 방향만 된다 | 재분배도 왕복이다. 양쪽 `redistribute`를 다 넣었는지 확인한다 |
| ping은 가는데 응답이 없다 | 돌아오는 구역이 우리 네트워크를 모른다. 반대 방향 재분배를 확인한다 |
| `redistribute`가 안 먹는다 | 받는 프로토콜 안에 들어가서 쳤는지 확인한다(부록 C 공식) |
| R2만 잘 되고 나머지는 안 된다 | 정상적인 재분배 전 상태다(STEP 2) |
| `O E2` 메트릭이 안 변한다 | E2의 정상 동작(항상 seed 값)이다. `metric-type 1`로 비교한다 |
| 프로토콜이 하나만 보인다 | `show ip protocols`로 R2에 둘 다 도는지 확인한다 |
| 껐다 켜니 설정이 사라진다 | `copy running-config startup-config`를 안 했다 |

5일차 공통 증상(경로 안 생김, 와일드카드, `no shutdown`)은 [5일차 명령어](../day-05/commands.md)의 부록 E를 본다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 명령 대본을 AMM 형식(REF)으로 재작성. 이모지 제거, 평서체 정리 |
