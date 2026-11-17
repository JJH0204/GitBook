# 8. 오늘의 서버 총정리 — 그리고 안 될 때 찾는 법

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 🎯 학습 목표

- 오늘 세운 서버들을 **패키지 · 데몬 · 포트 · 설정 파일 · 검증 명령**으로 한 표에 정리한다
- 서버가 안 될 때 **아래에서 위로** 순서대로 좁혀가는 **5단계 점검**을 몸에 익힌다
- **로그를 읽는 법**(`journalctl` · `/var/log/`)을 안다

## 🌉 다리 놓기: "여섯 개를 세웠는데, 다 같은 모양이었다"

아침에 칠판에 적은 **① 설치 ② 설정 ③ 기동 ④ 확인 ⑤ 개방 ⑥ 검증** — 여섯 번 반복했다.
이제 외울 것은 명령어가 아니라 **표 한 장과 점검 순서 하나**다.

---

## 📖 ① 오늘의 서버 한 장 정리 ⭐

| 서비스 | 패키지 | 데몬(systemd) | 포트 | 설정 파일 | 검증 |
|--------|--------|---------------|------|-----------|------|
| **SSH** | `openssh-server` | `ssh` (`sshd`) | TCP **22** | `/etc/ssh/sshd_config` | `ssh student@192.168.x.x` · `sshd -t` |
| **FTP** | `vsftpd` | `vsftpd` | TCP **21** + 데이터 | `/etc/vsftpd.conf` | `ftp localhost` |
| **NFS** | `nfs-kernel-server` | `nfs-server` | TCP **2049** | `/etc/exports` | `mount -t nfs` · `showmount -e` |
| **DNS** | `bind9` | **`named`** | **UDP/TCP 53** | `/etc/bind/named.conf.*` · `db.*` | `dig @127.0.0.1 ...` · `named-checkzone` |
| **Mail** | `postfix` | `postfix` | TCP **25**(587 · 465) | `/etc/postfix/main.cf` | `nc localhost 25` · `mail` |
| **Proxy** | `squid` | `squid` | TCP **3128** | `/etc/squid/squid.conf` | `curl -x http://127.0.0.1:3128 ...` |
| *(참고)* Telnet | `telnetd` | — | TCP 23 | — | ❌ **평문이라 세우지 않았다** |
| *(예고)* Web | `nginx` | `nginx` | TCP **80 · 443** | `/etc/nginx/...` | `curl localhost` · `nginx -t` → 13 · 16일차 |

> 🗣 **"포트 번호는 10일차 표에서 이미 외운 것들입니다. 오늘은 그 포트를 여는 프로그램의 이름을 채워 넣었습니다."**
> → [10일차 포트 번호표](../day-10/lesson-8.md)

### 문법 검사 도구가 있는 서비스는 꼭 쓴다

| 서비스 | 검사 명령 |
|--------|-----------|
| SSH | `sudo sshd -t` |
| DNS | `sudo named-checkconf` · `sudo named-checkzone <존> <파일>` |
| NFS | `sudo exportfs -v` |
| Postfix | `sudo postfix check` |
| Squid | `sudo squid -k parse` |
| *(예고)* nginx | `sudo nginx -t` |

---

## 📖 ② 안 될 때 — 아래에서 위로 5단계 ⭐⭐

증상은 대개 하나다: **"접속이 안 돼요."** 원인은 다섯 층 중 하나다.

```
 ⑤ 클라이언트가 잘못 (주소 · 포트 · 계정 오타)      ← 의외로 1위
 ④ 방화벽이 막는다        (ufw — 오늘 ⑤ 단계에서 켰다)
 ③ 엉뚱한 주소에서 듣는다 (127.0.0.1 에만 LISTEN)
 ② 서비스가 안 떠 있다    (설정 오타로 죽었다)
 ① 설치가 안 됐다
```

```bash
# 1단계 — 살아 있나
systemctl status <서비스>
# 2단계 — 듣고 있나 · 어느 주소에서
sudo ss -tulnp | grep <포트>
# 3단계 — 나 자신에게는 되나  (되면 ①②③ 정상)
curl localhost:<포트>   또는  telnet localhost <포트>  또는  전용 클라이언트
# 4단계 — 방화벽
sudo ufw status numbered
# 5단계 — 로그가 정답을 알고 있다 ⭐
sudo journalctl -u <서비스> -n 30 --no-pager
```

| 구분선 | 이 경계가 알려주는 것 |
|--------|----------------------|
| **`localhost` 로는 되는데 밖에서 안 된다** | 서버는 정상. **LISTEN 주소** 또는 **방화벽 / 포트포워딩** 문제 ⭐ |
| **`localhost` 로도 안 된다** | 서버 자체 문제 — **설정 · 기동 · 로그** |

> 🗣 **"이 한 줄만 기억하세요. `localhost 는 되나요?` 이 질문 하나로 문제가 절반으로 쪼개집니다."**

### 에러 메시지 읽는 법

| 메시지 | 뜻 | 볼 곳 |
|--------|----|-------|
| `Connection refused` | **그 포트에 아무도 없다** | 서비스 죽음 · 포트 오타 |
| `Connection timed out` | **답이 없다** (누가 삼켰다) | **방화벽** · 경로 · 잘못된 IP |
| `Address already in use` | **그 포트를 남이 쥐고 있다** | `ss -tulnp` 의 Process 칸 (bind9 ↔ systemd-resolved!) |
| `Permission denied` | 권한 | `sudo` · 파일 권한 · `~/.ssh` 권한 |
| `No route to host` | 경로가 없다 | IP · 게이트웨이 (1단계 내용) |
| `Job for X.service failed` | 설정 오타로 기동 실패 | `journalctl -u X -n 30` |

### 로그가 사는 곳

```bash
journalctl -u named -n 50 --no-pager      # systemd 서비스 로그 (거의 다 여기)
journalctl -u named -f                     # 실시간
sudo tail -f /var/log/squid/access.log     # 프록시 접근 기록
sudo tail -f /var/log/mail.log             # 메일 배달 기록
sudo tail -f /var/log/auth.log             # 로그인 · sudo 기록 ⭐ 보안
sudo tail -f /var/log/syslog               # 전체
```

> 💡 **`tail -f` = 로그를 실시간으로 지켜보기.** 한 창에서 `-f` 로 띄워두고 **다른 창에서 접속을 시도**하면, 실패하는 그 순간의 줄이 찍힌다. 오늘 배운 **창 3개 습관**(10일차)이 여기서 진가를 낸다.

---

## 📖 ③ 서버를 세웠다면 — 최소한의 마무리

| 할 일 | 명령 |
|-------|------|
| 부팅 때 자동 시작 걸기 | `sudo systemctl enable <서비스>` |
| 안 쓰는 서비스는 **끈다** | `sudo systemctl disable --now <서비스>` ⭐ |
| 열린 포트를 **다시 확인** | `sudo ss -tulnp` |
| 방화벽 규칙 점검 | `sudo ufw status numbered` |

> 🗣 **"오늘 우리는 문을 여섯 개 열었습니다. 열어 둔 문은 전부 남이 두드릴 수 있는 문입니다."**
> 보안의 첫걸음은 어려운 설정이 아니라 **안 쓰는 서비스를 끄는 것**(공격 표면 줄이기) → 11일차 방화벽과 한 쌍

---

## 🧪 실습 / 질문

- 실습: 대본 **STEP 8** — `ss -tulnp` 로 오늘 연 포트 전부 세어 보기 · 안 쓰는 서비스 끄기 → [0_실습_명령어_모음](commands.md)
- "밖에서 FTP 접속이 안 돼요. `ftp localhost` 는 됩니다." → 어디를 볼까?
- `Connection refused` 와 `Connection timed out` 중 **방화벽**이 원인인 쪽은?
- 오늘 연 포트 중 **실제 회사 서버라면 인터넷에 절대 열면 안 되는 것**을 골라 보자 (NFS 2049 · FTP 21 · Mail 25 …)

## 📝 강의 메모

- 이 노트는 **정리 + 안전망**이다. 실습 중 막힌 학생에게 **"8번 노트 ② 를 보세요"** 라고 가리킬 수 있게 만들어 뒀다
- 칠판에 **`localhost 는 되나요?`** 를 크게 써 두고, 질문이 나올 때마다 그것부터 되묻는다
- ⭐ 마지막 메시지: **"열어둔 문은 닫아야 한다"** → 11일차 방화벽 복습이자 16일차 클라우드 배포의 예고
- 되짚기: 10일차 `ss` · `Address already in use` · 11일차 ACL · 오늘 **ufw + 서버 3개**
