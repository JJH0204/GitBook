# 6. 리눅스 방화벽 ufw — 내 서버의 현관문 ⭐

> 상위: [11일차 · 서버 보안](README.md)

## 🎯 학습 목표

- `iptables` 와 `ufw` 의 관계를 한 줄로 설명한다
- **`ufw enable` 전에 `ufw allow 22/tcp`** 를 해야 하는 이유를 말한다 ⚠️
- `allow` · `deny` · `status numbered` · `delete` 로 규칙을 만들고 지운다
- **출발지를 지정한 규칙**(`allow from`)이 확장 ACL 과 같은 생각임을 안다
- 옆자리 PC 에서 **막히는 것을 직접 확인**한다

## 🌉 다리 놓기: "우리 교실에는 라우터가 없다"

[4_ACL_표준](lesson-4.md) · [5_ACL_확장](lesson-5.md) 에서 라우터에 검문소를 세웠다. 좋은 방법이다. 그런데 —

> 🗣 **"우리 교실에 시스코 라우터가 있나요?"**

없다. 우리 VM 은 **브릿지**로 교실 공유기에 직접 붙어 있고, 그 공유기는 **ACL 을 걸 수 없는 가정용**이다.
[3_왜_막아야_하나](lesson-3.md) 의 3층 그림에서 **① 네트워크 장비 칸이 비어 있는 상태**다.

```
 [ 교실 ] ──▶ ① 네트워크 장비 ──▶ ② 서버 자신 ──▶ ③ 서비스
                  (없음)            ufw            설정 파일
                                     ▲
                                  여기가 유일한 방어선
```

그래서 오늘 진짜 주인공은 **서버 스스로가 가진 문지기 — `ufw`** 다.

---

## 📖 ① iptables 와 ufw — 엔진과 운전대

리눅스 커널에는 원래부터 패킷을 걸러 내는 기능이 있다. 그걸 다루는 전통적인 명령이 **`iptables`** 인데, 문법이 험하다.

```bash
# iptables — 22번 열기
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# ufw — 같은 일
sudo ufw allow 22/tcp
```

> 📌 **`ufw` = Uncomplicated FireWall.** `iptables` 를 **쉽게 쓰라고 감싼 껍데기**다. 우분투 기본 탑재.

> 💡 **9일차의 비유를 그대로 쓰자.** `iptables` = **커널 쪽 엔진**, `ufw` = **운전대**.
> 운전대를 돌리면 엔진이 돈다. 우리는 운전대만 잡으면 된다.

---

## 📖 ② 지금 상태 보기 — 그리고 ⚠️ 최대 함정

```bash
sudo ufw status
```

```
Status: inactive        ← 우분투 기본값. 방화벽이 꺼져 있다 = 아무것도 안 막힌다
```

- 그래서 [3_왜_막아야_하나](lesson-3.md) 에서 **옆자리가 내 서버에 그냥 들어왔던 것**이다

### ⚠️ 오늘 1번 함정 — 순서를 바꾸면 내가 쫓겨난다

> 🗣 **"`sudo ufw enable` 을 먼저 치면, 지금 이 SSH 창이 그 자리에서 끊깁니다. 그리고 다시 못 들어옵니다."**

`ufw` 의 기본 정책은 **들어오는 것 전부 거부**다. SSH 도 "들어오는 것"이다.
우리는 **SSH 로 원격 접속한 상태**이므로, 22번을 열지 않고 방화벽을 켜면 **내가 앉아 있는 의자를 내가 치우는 셈**이다.

```bash
sudo ufw allow 22/tcp        # ① 먼저 내 통로부터 연다  ⭐⭐
sudo ufw enable              # ② 그 다음에 켠다
```

> 🆘 **이미 끊겼다면?** 원격으로는 방법이 없다. **VirtualBox 창(콘솔)으로 직접 들어가** `sudo ufw disable` 또는 `sudo ufw allow 22/tcp` 로 복구한다.
> 그래서 **콘솔 접근이 가능한 지금** 연습해 두는 것이다. 실제 클라우드 서버에서 이 실수를 하면 **서버를 다시 만들어야 할 수도** 있다.

---

## 📖 ③ 기본 명령 — 여섯 개면 충분하다

```bash
sudo ufw allow 22/tcp               # 열기 (포트/프로토콜)
sudo ufw deny  23/tcp               # 막기
sudo ufw enable                     # 켜기   ← 22 를 연 뒤에!
sudo ufw disable                    # 끄기
sudo ufw status numbered            # 규칙을 번호와 함께 보기 ⭐
sudo ufw delete 3                   # 3번 규칙 지우기
```

```
$ sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 23/tcp                     DENY IN     Anywhere
```

| 조각 | 뜻 |
|------|-----|
| **To** | 어느 포트로 들어오는 것인가 |
| **Action** | `ALLOW IN` 허용 · `DENY IN` 조용히 버림 · `REJECT IN` 거부했다고 알려 줌 |
| **From** | 어디서 온 것인가 (`Anywhere` = 아무 데서나) |

> 📌 **포트 범위**는 **콜론**으로 쓴다 — `sudo ufw allow 40000:40010/tcp`
> (12일차 FTP 패시브 데이터 포트에서 바로 쓴다)

### deny 와 reject — 실패하는 모양이 다르다 ⭐

| | 상대가 보는 것 | 비유 |
|---|---|---|
| **deny** (기본) | **아무 대답 없음 → 타임아웃**. 한참 기다리다 실패 | 문을 **두드려도 대답이 없다** |
| **reject** | **즉시 `Connection refused`** | **"안 됩니다"** 하고 문을 닫는다 |

- 보안상 **deny 가 낫다.** 대답을 안 하면 공격자는 **서버가 있는지조차 모른다**
- 하지만 **진단할 때는 헷갈린다** — 10일차 FTP 에서 "접속은 됐는데 목록이 안 나온" 것과 같은 상황이다
- 12일차에 **"밖에서만 안 되고 타임아웃이 난다"** 는 증상을 만나면 **제일 먼저 ufw 를 의심**한다

---

## 📖 ④ 출발지를 지정한다 — 확장 ACL 과 같은 생각 ⭐

```bash
# 교실 전체에 22번을 여는 대신 —
sudo ufw allow from 192.168.0.50 to any port 22 proto tcp     # 이 PC 에서만
sudo ufw allow from 192.168.0.0/24 to any port 80             # 이 대역에서만
```

**[5_ACL_확장](lesson-5.md) 과 나란히 놓고 보자. 똑같은 말이다.**

| | 시스코 확장 ACL | 리눅스 ufw |
|---|---|---|
| 허용 | `permit tcp host 192.168.0.50 host 서버 eq 22` | `ufw allow from 192.168.0.50 to any port 22 proto tcp` |
| 거부 | `deny tcp any host 서버 eq 22` | `ufw deny 22/tcp` |
| 기본 정책 | **암묵적 deny any** | **`default deny incoming`** |
| 순서 | **위에서부터, 처음 맞는 줄** | 위에서부터, 처음 맞는 줄 |
| 적용 위치 | 인터페이스 (`ip access-group`) | **서버 자신** |

> 🗣 **"이름만 다릅니다. 생각은 하나입니다 — 필요한 것만 열고, 나머지는 막는다."**

### 기본 정책 직접 확인하기

```bash
sudo ufw status verbose
```

```
Default: deny (incoming), allow (outgoing), disabled (routed)
          │                 │
          │                 └── 나가는 것은 다 허용 (서버가 apt 로 패키지 받아야 하니까)
          └── 들어오는 것은 기본 거부  ⭐ = 화이트리스트
```

- 이 한 줄이 [3_왜_막아야_하나](lesson-3.md) 의 **기본 거부(Default Deny)** 원칙 그 자체다

---

## 🧪 실습 — 옆자리를 막아 본다 ⭐

> 🖐 자세한 순서는 [대본 STEP 6](commands.md) 참고. **브릿지**라서 이 실습이 가능하다.

### 1단계 — 막히지 않는 것을 먼저 본다

```bash
# 🪟 옆자리 Windows 에서 (내 서버 주소로)
ping 192.168.x.x          ✅ 응답 온다
ssh student@192.168.x.x   ✅ 로그인 창이 뜬다
```

### 2단계 — 방화벽을 켠다 (순서 엄수!)

```bash
# 🐧 내 VM 에서
sudo ufw allow 22/tcp     # ⭐ 반드시 먼저
sudo ufw enable           # Command may disrupt existing ssh connections. Proceed? → y
sudo ufw status verbose
```

- **내 SSH 창은 안 끊긴다** — 22번을 먼저 열었으니까. 여기서 "순서"의 의미가 몸에 남는다

### 3단계 — 웹서버를 올리고 막아 본다

```bash
# 🐧 내 VM — 연습용 웹서버 (10일차에 했던 그것)
python3 -m http.server 8000
```

```
# 🪟 옆자리 → 내 서버       http://192.168.x.x:8000
→ ❌ 안 열린다 (한참 기다리다 타임아웃)   ← ufw 가 막았다!
```

```bash
# 🐧 내 VM — 8000 을 연다
sudo ufw allow 8000/tcp
```

```
# 🪟 옆자리 → 다시          http://192.168.x.x:8000
→ ✅ 열린다
```

### 4단계 — 특정 PC 에게만 열어 준다

```bash
sudo ufw status numbered
sudo ufw delete <8000 번 규칙 번호>                        # 전체 개방을 지우고
sudo ufw allow from <내 Windows IP> to any port 8000      # 나에게만 연다
```

- **옆자리는 ❌ · 내 Windows 는 ✅** → **확장 ACL 로 한 일을 서버 혼자서 해냈다** ⭐

### 5단계 — 되돌리기

```bash
sudo ufw status numbered         # 지금 뭐가 있나
sudo ufw disable                 # 수업용: 일단 끈다
# sudo ufw reset                 # 규칙을 전부 지우고 초기화 (주의)
```

> 📌 **12일차를 위해**: 방화벽을 **켜 둔 채로** 가면 서버 6개를 세울 때마다 `ufw allow` 가 필요하다.
> 그게 바로 12일차 6단계의 **⑤ 개방** 이다. **켜 두고 가는 쪽을 권한다** — 안 그러면 ⑤ 단계가 실감이 안 난다.

---

## 🤖 AI 활용 — 방화벽 규칙은 특히 검증이 필요하다

10일차 [AI 검증 원칙](../day-10/lesson-5.md) 그대로다. 다만 방화벽은 **틀리면 내가 쫓겨난다.**

> **좋은 질문**: "Ubuntu 24.04 에서 ufw 를 쓴다. **192.168.0.0/24 대역에서만** 8000번 TCP 를 허용하고 나머지는 막고 싶다. 명령을 알려줘."

**받은 답은 세 가지를 확인한다.**

1. **22번이 먼저 열려 있나?** — `enable` 이 포함된 답이면 **특히** 확인
2. **`deny` 와 `allow` 의 순서**가 내 의도와 맞나
3. **포트 범위 표기** — ufw 는 콜론(`40000:40010`), iptables 는 콜론, 시스코는 `range` 로 서로 다르다

> 🛑 **AI 가 `ufw reset` · `ufw disable` · `iptables -F` 를 주면 3초 멈춘다.** 규칙이 **전부** 날아간다.

---

## 🧪 실습 / 질문

- `sudo ufw enable` 만 먼저 쳤다. 무슨 일이 일어나고, 어떻게 복구하나?
- `deny` 와 `reject` 중 공격자에게 정보를 덜 주는 것은? 대신 무엇이 불편해지나?
- 10일차에 세운 FTP(21번)를 옆자리에서 쓰게 하려면 어떤 규칙이 필요한가? 패시브 포트까지 고려하면?
- `ufw` 를 켜도 **내 VM 안에서 `curl localhost:8000`** 은 된다. 왜 그럴까?

## 📝 강의 메모

- ⭐⭐ **이 절이 11일차의 핵심이자 12일차의 전제**다. 시간이 모자라면 ACL(4·5번)을 줄이고 여기를 지킨다
- 🚨 **`ufw enable` 함정은 반드시 먼저 경고**한 뒤 실습시킨다. 그래도 몇 명은 순서를 바꿔 친다
  - 복구 경로를 **칠판에 미리 적어 둔다**: **VirtualBox 창 → 로그인 → `sudo ufw disable`**
  - "클라우드였으면 서버를 다시 만들어야 했다"는 말을 꼭 덧붙일 것
- ⭐ **옆자리 실습(3·4단계)이 오늘 전체의 하이라이트**다. [3_왜_막아야_하나](lesson-3.md) 에서 "열려 있다"를 보여 주고 여기서 "닫았다"를 보여 주는 **수미상관** 구조
  - 짝을 미리 정해 두고 **서로의 IP 를 칠판에 적게** 하면 빠르다
- 비유: **`iptables` = 엔진 · `ufw` = 운전대** (9일차 커널/쉘 비유와 같은 꼴)
- 12일차 연결: **방화벽을 켜 둔 채로 마무리**해야 12일차 6단계 ⑤(`ufw allow`)가 살아난다. 꺼 두면 12일차 ⑤ 가 전부 공회전한다
- ⏱ 이론 15분 + 실습 25분. 4단계(특정 IP 허용)는 시간이 없으면 **시연만**
