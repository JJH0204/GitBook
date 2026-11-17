# 5. DNS 서버 (bind9) — 이름을 남에게 받아 쓰다가, 직접 나눠주다

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 🎯 학습 목표

- **bind9** 로 내 도메인(`student.local`)의 **권한 있는(authoritative) DNS 서버**를 만든다
- **존 파일(zone file)** 의 구조(SOA · NS · A · CNAME · MX)를 읽고 쓴다
- 설정을 고친 뒤 **`named-checkconf` · `named-checkzone`** 으로 문법을 검사한다
- **`dig`** 로 내 서버에 직접 질의해서 검증한다
- 수정할 때마다 **Serial 을 올려야** 한다는 것을 안다

## 🌉 다리 놓기: "8일차엔 체크박스, 오늘은 존 파일"

8일차 패킷트레이서에서 우리는 `Server0` 의 **DNS** 를 켜고, `www.student.com → 192.168.10.100` 을 **칸에 입력**했다 → [2_DHCP와_DNS](../../network1/day-08/lesson-2.md).
10일차에는 리눅스 쪽에서 **`/etc/hosts`(내 수첩)** 와 **`dig`(물어보기)** 를 봤다 → [10_DNS와_DHCP_다시보기](../day-10/lesson-10.md).

지금까지 우리는 늘 **묻는 쪽**이었다. 오늘은 **대답하는 쪽**이 된다.

> 🗣 **"`/etc/hosts` 는 내 컴퓨터만 아는 수첩입니다. 회사 PC 100대에 같은 수첩을 일일이 적어 넣을 건가요? 그래서 DNS 서버를 세웁니다."**

---

## 📖 ① DNS 서버에도 종류가 있다

| 종류 | 하는 일 | 예 |
|------|---------|-----|
| **캐시 · 재귀(recursive)** | 클라이언트 대신 **찾아다녀 주는** 서버 | `8.8.8.8` · 통신사 DNS · 공유기(11일차) |
| **권한 있는(authoritative)** | **"그 도메인은 내가 관리한다"** 며 정답을 가진 서버 | 네이버의 DNS · **오늘 만들 것** ⭐ |

```
 PC ──"www.naver.com?"──▶ 캐시 DNS(8.8.8.8) ──▶ 루트 ──▶ .com ──▶ 네이버 권한 서버
                         ◀── 답 ──                                    "223.130.x.x 입니다"
```

- 오늘 만드는 서버는 **`student.local` 에 대해서만 정답을 아는** 서버다
- 동시에 **`forwarders`** 를 적어두면 모르는 질문은 `8.8.8.8` 에게 넘긴다 = 캐시 서버 역할도 겸한다

> 💡 **왜 `.local` 인가**: `.com` 은 돈 주고 사야 진짜 주인이 된다. 실습에서는 **사내 전용** 이름을 쓴다.

---

## 📖 ② 구축 — 여섯 단계 그대로

### ① 설치

```bash
sudo apt install bind9 bind9-utils bind9-dnsutils -y
```

- 데몬 이름은 **`named`** 다 (`bind9` 는 별칭) — "**name d**aemon". 이름부터 10일차 `d` 규칙 그대로

### ② 설정 — 파일 3개만 기억한다

| 파일 | 역할 |
|------|------|
| `/etc/bind/named.conf.options` | **서버 자체**의 동작 (어디서 들을지 · 누구에게 답할지 · forwarders) |
| `/etc/bind/named.conf.local` | **내가 관리할 존(도메인) 선언** |
| `/etc/bind/db.student.local` | 그 도메인의 **실제 레코드** (존 파일) ⭐ |

**options — 듣는 주소를 지정한다 (⚠️ 오늘 최대 함정)**

```
listen-on port 53 { 127.0.0.1; 192.168.x.x; };   # ⚠️ 내 IP 는 ip a 로 확인
listen-on-v6 { none; };
forwarders { 8.8.8.8; 1.1.1.1; };
allow-query { any; };
```

> 🚨 **`any` 를 쓰면 안 된다 — 실측으로 확인한 함정** (2026-10-11 Ubuntu 24.04 검증)
> 우분투에는 **`systemd-resolved`** 가 기본으로 돌면서 **`127.0.0.53:53` · `127.0.0.54:53`** 을 이미 쓰고 있다.
> 그 상태에서 `0.0.0.0:53` 바인딩은 **`Address already in use` 로 실패**한다.
>
> ```bash
> sudo ss -tulnp | grep ':53 '        # 설치 전에 먼저 확인 — resolved 가 보인다
> ```
>
> → 그래서 **주소를 콕 집어** 적는다. `127.0.0.1` 은 `dig @127.0.0.1` 검증용, 내 IP 는 ⑤ 개방 후 **밖에서** 물어보기용.
> → 📌 **브릿지+DHCP 라 IP 가 매주 바뀐다.** 다음 주에 안 되면 **이 줄부터** 고친다.
>
> 🗣 **"포트 하나는 한 프로그램만. 10일차에 `python3 -m http.server` 를 두 번 띄웠을 때와 똑같은 사고입니다."**

**named.conf.local — 존 선언**

```
zone "student.local" {
    type master;
    file "/etc/bind/db.student.local";
};
```

**존 파일 — 이름표 목록**

```
$TTL    604800
@   IN  SOA ns1.student.local. admin.student.local. (
            2026092001  ; Serial   ⭐ 고칠 때마다 올린다
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative TTL
;
@       IN  NS      ns1.student.local.
ns1     IN  A       192.168.x.x
www     IN  A       192.168.x.x
ftp     IN  A       192.168.x.x
web     IN  CNAME   www.student.local.
@       IN  MX  10  mail.student.local.
mail    IN  A       192.168.x.x
```

| 줄 | 뜻 |
|----|----|
| `$TTL` | 다른 서버가 이 답을 **얼마나 캐시**해도 되는지(초) |
| **SOA** | 이 존의 **주민등록** — 담당 서버 · 관리자 메일 · 갱신 주기 |
| **NS** | 이 존을 담당하는 **네임서버** |
| **A** | 이름 → **IPv4 주소** ⭐ 가장 많이 쓴다 |
| **CNAME** | 이름 → **다른 이름**(별명) |
| **MX** | 이 도메인의 **메일 받는 서버** (숫자는 우선순위) → [6_메일서버_원리](lesson-6.md) |
| `@` | **도메인 자기 자신**(`student.local`) |

> ⚠️ **끝의 점(`.`)이 문법이다.** `www.student.local.` 은 완전한 이름(FQDN), 점이 없으면 **뒤에 도메인이 자동으로 붙는다.**
> 점을 빠뜨리면 `www.student.local.student.local` 이 된다 — 오늘 오타 2위.

> ⚠️ **Serial 을 안 올리면 아무 일도 안 일어난다.** 다른 서버는 "번호가 그대로니 바뀐 게 없군" 하고 무시한다.
> 관례: **날짜 + 순번** `2026092001` → 같은 날 두 번째 수정이면 `2026092002`

### ③ 기동 전에 — **문법 검사** ⭐

```bash
sudo named-checkconf                                        # 설정 파일 문법 (조용하면 정상)
sudo named-checkzone student.local /etc/bind/db.student.local   # OK: loaded serial 2026092001
```

> 🗣 **"DNS 는 오타 하나면 서비스 전체가 사라지는 곳입니다. 그래서 검사 도구가 따로 있습니다."**
> [1_서버구축의_공통문법](lesson-1.md) 의 ② 와 ③ 사이에 **문법 검사**를 끼워 넣는 서비스들이 있다 — `named-checkconf` · `sshd -t` · (13·16일차) `nginx -t`

### ③ 기동 · ④ 확인

```bash
sudo systemctl restart named
systemctl status named
sudo ss -tulnp | grep :53                # 127.0.0.1:53 · 192.168.x.x:53 (TCP · UDP 둘 다!)
```

> 📌 **DNS 는 UDP 53 이 기본, TCP 53 도 쓴다**(응답이 크거나 존 전송). 10일차 TCP/UDP 표가 여기서 확인된다 → [7_TCP와_UDP](../day-10/lesson-7.md)

### ⑤ 개방

```bash
sudo ufw allow 53
```

### ⑥ 검증 — `dig` 로 내 서버에 직접 묻는다 ⭐

```bash
dig @127.0.0.1 www.student.local +short        # 192.168.x.x
dig @127.0.0.1 web.student.local               # CNAME → A 두 줄이 온다
dig @127.0.0.1 student.local MX +short         # 10 mail.student.local.
dig @127.0.0.1 nosuch.student.local           # status: NXDOMAIN
dig @127.0.0.1 www.google.com +short           # forwarders 가 대신 찾아온다
```

| `dig` 출력에서 볼 곳 | 뜻 |
|---------------------|-----|
| `status: NOERROR` / `NXDOMAIN` | 성공 / **그런 이름 없음** |
| `flags: ... aa` | **authoritative answer** = 내가 주인이라 직접 답했다 ⭐ |
| `ANSWER SECTION` | 실제 답 |
| `SERVER: 127.0.0.1#53` | **누구에게** 물었나 |

> 🗣 **"`aa` 플래그가 보이면, 이 서버가 바로 그 도메인의 주인이라는 뜻입니다. 방금 여러분이 주인이 됐습니다."**

---

## 📖 ③ 이 서버를 실제로 쓰게 하려면

`dig @127.0.0.1` 은 **콕 집어** 물은 것이다. 컴퓨터가 **평소에도** 이 서버에 묻게 하려면 클라이언트 설정을 바꿔야 한다.

| 어디서 | 방법 |
|--------|------|
| 리눅스 (일시) | `resolvectl dns enp0s3 127.0.0.1` · 확인은 `resolvectl status` |
| 리눅스 (영구) | `/etc/netplan/*.yaml` 의 `nameservers:` → `sudo netplan apply` (10일차) |
| 윈도우 PC | 어댑터 속성의 **기본 설정 DNS 서버** (1 · 8일차에 손으로 넣던 그 칸) |
| 집 · 회사 전체 | **DHCP 가 나눠준다** — 공유기의 Static DNS 칸(11일차) ⭐ |

> 🗣 **"DHCP 가 IP 만 주는 게 아니라 DNS 서버 주소도 같이 준다 — 8일차 DORA 에서 배운 그 네 번째 항목입니다."**
> 📌 수업에서는 VM 의 기본 DNS 를 **바꾸지 않는다.** 잘못되면 `apt` 가 멈춰 나머지 실습이 다 막힌다. 바꿔 볼 거면 **되돌리는 방법을 먼저** 적어둔다.

---

## 🧪 실습 / 질문

- 실습: 대본 **STEP 5** — 존 파일 작성 · 문법 검사 · `dig` 검증 · **레코드 추가 후 Serial 올리기** → [0_실습_명령어_모음](commands.md)
- `named` 가 안 뜬다. `journalctl -u named` 에 `Address already in use` — 범인은? (**systemd-resolved · 53번**)
- 레코드를 고쳤는데 `dig` 결과가 그대로다. 두 가지 원인은? (**restart 안 함** · **Serial 안 올림** · 캐시 TTL)
- `www` 와 `web` 중 **CNAME** 은 무엇이고, 왜 굳이 별명을 만들까?

## 📝 강의 메모

- ⭐ **오후의 중심 노트**. 시간을 가장 많이 배정한다 (이론 20 + 실습 30)
- 진행 요령: **존 파일을 처음부터 치게 하지 말고** 대본의 완성본을 붙여넣게 한 뒤 → **`ftp` A 레코드 한 줄을 각자 추가** → Serial 올리기 → `dig` 로 확인. **"고치고 → 검사 → 재시작 → 확인"** 사이클을 한 번 돌리는 게 목표
- 칠판: **`checkconf` → `checkzone` → `restart` → `dig`** 4단계를 세로로
- ⚠️ 리허설 포인트: `listen-on` 을 빼고 한 번 실패시킨 뒤 고치는 게 교육 효과가 크다. 다만 **시간이 빠듯하면 처음부터 정답**으로 간다
- 되짚기: 8일차 **A 레코드 · DNS 서버 칸** · 10일차 **`dig` · `/etc/hosts`** · 11일차 **공유기 Static DNS**
- 다음: 방금 **MX 레코드**를 적었다. 그 이름이 가리키는 메일 서버는 무엇을 하나? → [6_메일서버_원리](lesson-6.md)
