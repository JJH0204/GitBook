# 10. DNS 와 DHCP 다시 보기 — 리눅스 쪽에서

> 상위: [10일차 · 서버 기초](README.md)
> 실습: [LEC-N2-10-024-MP](lesson-10-lab.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-010-DO |
| 유형 | D&O (개념) |
| 목적 | 리눅스 클라이언트의 이름 해석 순서, DNS 계층 구조와 캐시, `dig` 읽기, DHCP 임대와 netplan을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 VM에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 리눅스가 이름을 찾는 순서(`/etc/hosts` → DNS)를 안다.
- `resolv.conf`, `resolvectl`로 내 DNS 서버를 찾고 `dig`로 레코드를 조회한다.
- DNS의 재귀 질의, 계층 구조(루트 → TLD → 권한 서버), 캐시와 TTL을 설명한다.
- `ip a`의 임대 시간(`valid_lft`)과 netplan으로 리눅스의 DHCP를 확인한다.

## 이전 학습과의 연결

8일차에 PT Server0로 DNS, DHCP 서버를 켰다. → [2. DHCP와 DNS](../../network1/day-08/lesson-2.md) 오늘은 반대편이다. 리눅스 서버가 손님(클라이언트)이 되어 이름과 주소를 받는 과정을 본다.

12일차에 리눅스로 DNS 서버를 직접 만들기 전에, 클라이언트가 어떻게 묻는지부터 알아야 한다.

## 1. 리눅스가 이름을 찾는 순서

```
 ping www.google.com
   │
   ├─ ① /etc/hosts       "내 수첩에 적혀 있나?"  → 있으면 끝 (DNS 안 물어봄)
   │
   └─ ② DNS              /etc/resolv.conf 의 nameserver 에게 질문
          127.0.0.53  ← systemd-resolved (내 PC 안의 DNS 도우미 · 캐시)
              └──▶ 실제 DNS 서버 (DHCP로 받은 것 · 예: 192.168.0.1 · 강의실 공유기)
```

| 파일·명령 | 뜻 |
|---|---|
| `/etc/hosts` | 개인 수첩. 이름과 IP를 손으로 적는다. DNS보다 먼저 본다 |
| `/etc/resolv.conf` | "DNS는 누구에게 묻는가". 우분투는 `nameserver 127.0.0.53`(도우미) |
| `resolvectl status` | 도우미가 실제로 묻는 DNS 서버 |

{% hint style="info" %}
NOTE: 휴대폰 연락처와 114 안내에 비유한다. 연락처(`/etc/hosts`)에 저장된 이름은 바로 건다. 없으면 114(DNS)에 묻는다. 연락처에 틀린 번호를 저장하면 114에 묻지도 않고 엉뚱한 곳으로 건다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `/etc/hosts`가 DNS보다 먼저라서, 악성코드가 이 파일을 고쳐 은행 사이트를 가짜 서버로 보내기도 한다(파밍). 그래서 root만 수정할 수 있다(`-rw-r--r-- root`). 오전 권한의 회수다.
{% endhint %}

## 2. DNS는 어떻게 답을 찾나 — 계층 구조

```
 내 PC ──① "www.naver.com?" ──▶ [DNS 서버 (재귀)] ─② "com 담당 누구?" ──▶ 루트 (.)
                                      │            ─③ "naver.com 담당 누구?" ──▶ .com TLD
                                      │            ─④ "www.naver.com IP?" ──▶ naver.com 권한 서버
 내 PC ◀──⑤ "<공인 IP>" ─────────────┘  (그리고 TTL 동안 캐시에 기억)
```

| 용어 | 뜻 |
|---|---|
| 재귀 질의 | 내 PC는 한 번만 묻고, DNS 서버가 대신 끝까지 찾아온다 |
| 루트, TLD, 권한 서버 | `.` → `.com` → `naver.com` 순서로 위에서부터 물어 내려간다 |
| 캐시 | 한 번 찾은 답은 기억해 둔다. 두 번째는 즉시 답한다 |
| TTL | 캐시 유효 기간(초). 지나면 다시 묻는다 |

{% hint style="info" %}
NOTE: 114 상담원에 비유한다. 나는 상담원에게 한 번 묻는다(재귀). 상담원이 여기저기 전화해서 알아낸 뒤 알려 주고, 메모해 둔다(캐시).
{% endhint %}

### 레코드 다시 보기 (8일차 표 + 오늘 볼 것)

| 레코드 | 뜻 | 오늘 `dig`로 |
|---|---|---|
| A | 이름 → IPv4 | `dig www.google.com` |
| AAAA | 이름 → IPv6 | `dig AAAA www.google.com` |
| CNAME | 이름 → 다른 이름(별명) | `dig www.naver.com` — 별명을 몇 번 거친다 |
| MX | 메일 서버 | `dig MX gmail.com` (12일차 메일 서버) |
| NS | 이 도메인의 권한 서버 | `dig NS naver.com` |
| PTR | IP → 이름(역방향) | `dig -x 8.8.8.8` |

### `dig` 읽기

```
;; QUESTION SECTION:
;www.google.com.            IN  A              ← 내가 물은 것

;; ANSWER SECTION:
www.google.com.     172  IN  A  <공인 IP>      ← 답 · 172 = TTL(초)

;; Query time: 12 msec                         ← 한 번 더 입력하면 0 msec에 가깝다 = 캐시
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)     ← 누가 답했나 · 53번 · UDP (7, 8번 노트 회수)
```

- `dig +short <이름>`은 답만 짧게 보여 준다.
- 마지막 줄 `#53 ... (UDP)`에서 [7. TCP와 UDP](lesson-7.md), [8. 포트 번호와 소켓](lesson-8.md)에서 배운 것이 실제로 찍힌다.

## 3. 리눅스의 DHCP — 임대는 눈에 보인다

```
2: enp0s3: ...
    inet 192.168.0.42/24 metric 100 brd 192.168.0.255 scope global dynamic enp0s3
       valid_lft 86123sec preferred_lft 86123sec
       ────────┬───────
               └ 임대 남은 시간 (약 24시간) — 8일차 DORA의 "8일간 쓰세요"가 이것
```

- `dynamic`은 DHCP로 받았다는 뜻이다(오전 [4. 리눅스의 네트워크](lesson-4.md)). `valid_lft`는 임대 남은 시간이다.
- 반쯤 지나면 클라이언트가 알아서 연장을 요청한다(Request → Ack). DORA의 뒤 두 단계만 다시 일어난다.

### 누가 DHCP를 켜 놨나 — netplan

```bash
sudo cat /etc/netplan/*.yaml        # 파일 이름은 설치마다 다를 수 있다 (보통 50-cloud-init.yaml)
```
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true          # ← "이 랜카드는 DHCP로 받아라"
```

- 우분투의 네트워크 설정 파일은 netplan(`/etc/netplan/*.yaml`)이다. 오전 "설정은 `/etc`의 파일" 회수다.
- 고정 IP로 바꾸려면 `dhcp4: false`와 `addresses`, `routes`, `nameservers`를 적는다. 12일차 서버 구축 때 한다(서버는 고정 IP다. → [6. 서버란 무엇인가](lesson-6.md)).

{% hint style="info" %}
NOTE: 우리 VM은 브릿지라서 강의실 공유기가 DHCP, DNS 중계, NAT를 전부 해 준다. 공유기 한 상자가 다 한다. 11일차 [공유기 실습](../day-11/lesson-1.md)에서 그 상자를 뜯어본다.
{% endhint %}

## 4. 확인 질문

- `/etc/hosts`에 `127.0.0.1 www.google.com`을 적으면? → 구글 대신 내 VM으로 간다(DNS를 묻지도 않는다).
- `dig`를 두 번 입력했더니 Query time이 확 줄었다. → 캐시 덕분이다.
- `ip a`의 `valid_lft`가 줄어들다 다시 늘어났다. → 임대 연장(Request, Ack)이 일어났다.
- `resolv.conf`의 `127.0.0.53`은 인터넷 DNS 서버인가? → 아니다. 내 안의 도우미다. 실제 서버는 `resolvectl status`로 본다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| DNS | Domain Name System. 이름을 IP로 바꾸는 체계 |
| 재귀 질의 | 서버가 대신 끝까지 찾아서 답을 돌려주는 질의 방식 |
| TTL | Time To Live. 캐시 유효 시간(초) |
| `dig` | DNS 조회 명령 |
| DHCP | Dynamic Host Configuration Protocol. IP 자동 배포 |
| `valid_lft` | 주소의 임대 남은 시간(초) |
| netplan | 우분투의 네트워크 설정 체계(`/etc/netplan/*.yaml`) |

## 진행 메모

- "8일차에는 서버, 오늘은 손님"으로 연다.
- `/etc/hosts` 실험은 재미있고 강력하다. `myserver.local`을 만들어 오늘의 8080 웹서버를 이름으로 부르게 한다.
- 파밍 한 줄로 "그래서 root만 고친다"를 오전 권한과 묶는다.
- `dig`는 ANSWER 한 줄, TTL, SERVER 줄 세 곳만 읽게 한다.
- 루트, TLD, 권한 서버는 그림 한 장과 "114 상담원"으로 끝낸다. 12일차 DNS 서버 구축에서 권한 서버를 직접 만든다.
- netplan 고정 IP 설정은 보여 주기만 한다. 지금 바꾸면 SSH가 끊길 수 있다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 리눅스가 이름을 IP로 바꿀 때 거치는 순서를 내 말로 적어 본다.
- [ ] DNS 캐시와 TTL이 왜 필요한지 내 말로 설명해 본다.
- [ ] 내 VM의 IP가 DHCP로 왔다는 것을 어떤 출력에서 확인했는지 적어 본다.
