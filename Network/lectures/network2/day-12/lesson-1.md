# 1. 서버 구축의 공통 문법 — 무엇을 세우든 여섯 단계

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 🎯 학습 목표

- 리눅스에서 서버를 세우는 **여섯 단계**를 순서대로 말할 수 있다
- `apt` · `systemctl` · `ss` · `ufw` · 클라이언트 검증이 **각 단계 어디에 해당하는지** 안다
- ⭐ **`ufw`** 로 포트를 열고 닫고, **`enable` 전에 22번을 먼저 여는 이유**를 안다 (11일차 이월)
- 설정 파일을 고치기 전에 **백업**하고, 고친 뒤에는 **문법 검사 → 재시작 → 확인**을 거친다
- **재시작(`restart`)과 리로드(`reload`)** 의 차이를 안다

## 🌉 다리 놓기: "오늘 서버를 일곱 개 세웁니다"

9일차에 우리는 서버를 **하나** 세웠다. `apt install openssh-server` → `systemctl enable --now ssh` → Windows 에서 접속.
그때는 **주문처럼** 따라 쳤지만, 10일차에 `ss` 로 `0.0.0.0:22 LISTEN` 을 직접 보면서 그 주문의 정체를 알았다.

오늘은 FTP · NFS · DNS · Mail · Proxy 까지 **여러 개**를 세운다. 그런데 좋은 소식이 있다.

> 🗣 **"서버 종류는 달라도, 세우는 순서는 똑같습니다. 오늘 외울 건 명령어 50개가 아니라 순서 6개입니다."**

8일차 패킷트레이서 `Server0` 에서는 **체크박스 하나**로 켰던 것들이다 → [8일차](../../network1/day-08/README.md).
오늘은 그 체크박스 안에서 실제로 무슨 일이 벌어지는지를 **손으로** 한다.

---

## 📖 ① 여섯 단계 ⭐ — 오늘 하루를 관통하는 뼈대

```
 ① 설치      apt install <패키지>          "프로그램을 가져온다"
 ② 설정      nano /etc/<서비스>/<파일>     "어떻게 일할지 알려준다"   ← 백업 먼저!
 ③ 기동      systemctl restart <서비스>    "문을 연다"
 ④ 확인      systemctl status / ss -tulnp  "정말 열렸나 (LISTEN?)"
 ⑤ 개방      ufw allow <포트>              "방화벽에 구멍을 낸다"      ← 오늘 처음 켠다 ⭐
 ⑥ 검증      클라이언트로 직접 접속해 본다  "손님이 되어 들어가 본다"   ⭐
```

| 단계 | 하는 일 | 대표 명령 | 실패하면 보이는 것 |
|------|---------|-----------|--------------------|
| ① 설치 | 패키지 가져오기 | `sudo apt install vsftpd` | `Unable to locate package` |
| ② 설정 | 설정 파일 편집 | `sudo nano /etc/vsftpd.conf` | (아직 조용하다 — 무서운 단계) |
| ③ 기동 | 데몬 켜기 · 자동 시작 | `sudo systemctl enable --now vsftpd` | `Job failed` |
| ④ 확인 | 떠 있나 · 듣고 있나 | `systemctl status` · `ss -tulnp` | `inactive (dead)` · LISTEN 없음 |
| ⑤ 개방 | 방화벽 열기 | `sudo ufw allow 21/tcp` | 밖에서만 안 된다 (타임아웃) |
| ⑥ 검증 | 클라이언트로 접속 | `ftp localhost` · `dig @...` | `Connection refused` |

> 💡 **비유: 가게를 여는 순서.** ① 물건 들이고 → ② 메뉴판 쓰고 → ③ 문 열고 → ④ "정말 열렸나" 밖에서 보고 → ⑤ 셔터를 올리고 → ⑥ **직접 손님처럼 들어가서 주문해 본다.**
> 대부분의 사고는 ⑥ 을 건너뛰고 "설정했으니 됐겠지" 할 때 난다.

- 오늘 만드는 모든 서버에 이 표를 **그대로** 갖다 댈 것이다. 노트 3~7번의 각 `📖 구축` 절은 **전부 이 순서**다

---

## 📖 ② 단계별로 한 번 더 — 왜 그 명령인가

### ① 설치 — `apt`

```bash
sudo apt update                 # 목록 새로고침 (설치 전 습관)
sudo apt install vsftpd         # 설치
apt list --installed | grep vsftpd
```

- 우분투는 **패키지 하나를 깔면 설정 파일 · 서비스 등록까지 같이** 된다 (9일차 `openssh-server` 가 그랬다)
- 그래서 **깔자마자 이미 켜져 있는** 서비스가 많다 → ④ 부터 해보고 ② 로 돌아가도 된다

### ② 설정 — 고치기 전에 백업 ⭐

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak     # 원본 보관
sudo nano /etc/vsftpd.conf
```

| 규칙 | 이유 |
|------|------|
| **`.bak` 백업 먼저** | 망가뜨렸을 때 `sudo cp *.bak` 한 줄로 복구 (10일차 `/etc/hosts` 에서 배운 것) |
| **한 번에 한 줄만** | 두 군데 고치고 안 되면 **어느 쪽이 범인인지** 모른다 |
| **주석 `#` 을 지우지 말고 새 줄 추가** | 원래 값이 무엇이었는지 남는다 |

- 리눅스 설정 파일은 거의 다 **`/etc/` 아래**에 있다 — 10일차 "`/etc` = 설정의 집"

### ③ 기동 — `systemctl` 4형제 + 하나

```bash
sudo systemctl start vsftpd      # 지금 켠다
sudo systemctl enable vsftpd     # 부팅 때 자동으로 켜진다
sudo systemctl enable --now vsftpd   # 둘을 한 번에 (9일차에 쓴 그것)
sudo systemctl restart vsftpd    # 껐다 켠다 — 설정을 고쳤으면 이것!
sudo systemctl reload vsftpd     # 설정만 다시 읽는다 (연결을 끊지 않는다)
```

| | `restart` | `reload` |
|---|---|---|
| 하는 일 | 프로세스를 **죽였다 새로** 띄운다 | 떠 있는 채로 **설정만** 다시 읽는다 |
| 접속 중인 손님 | **끊긴다** | 유지된다 |
| 언제 | 포트 변경 등 큰 변경 · 안 되면 일단 이것 | 존 파일 추가 등 가벼운 변경 |

> ⚠️ **"설정을 고쳤는데 그대로예요"** — 오늘 가장 많이 나올 질문. 답은 대부분 **③ 을 안 했다**.

### ④ 확인 — 두 개를 같이 본다

```bash
systemctl status vsftpd         # active (running) 인가?  (q 로 나가기)
sudo ss -tulnp | grep vsftpd    # 어느 포트를 LISTEN 하나?
```

- `systemctl status` = **"프로그램이 살아 있나"** · `ss` = **"문을 열고 기다리나"** → 10일차 [서버 = LISTEN 하는 프로그램](../day-10/lesson-6.md)
- 둘은 다르다. **떠 있는데 엉뚱한 주소에서 듣고 있는** 경우가 실제로 자주 있다 (예: `127.0.0.1` 에만 LISTEN → 밖에서 못 들어옴)

### ⑤ 개방 — 방화벽 `ufw` ⭐ (11일차에서 이월)

11일차에 **라우터에서** 막는 법(ACL)을 배웠다. 그런데 우리 VM 은 **브릿지**라서 그 앞에 라우터가 없다.
→ **서버 자신이 문지기**를 해야 한다. 그게 리눅스의 **`ufw`** 다.

```
 [ 교실 ] ──▶ ① 네트워크 장비 ──▶ ② 서버 자신 ──▶ ③ 서비스
                 ACL (11일차)        ufw          설정 파일
                  (우리는 없음)        ▲ 오늘 여기
```

> 📌 **`ufw` = Uncomplicated FireWall.** 커널의 `iptables` 를 쉽게 쓰라고 감싼 껍데기다.
> 💡 9일차 비유 그대로 — **`iptables` = 엔진 · `ufw` = 운전대**.

**지금 상태부터 본다.**

```bash
sudo ufw status                  # Status: inactive  ← 아직 아무것도 안 막혀 있다
```

#### ⚠️ 오늘 1번 함정 — 순서를 바꾸면 내가 쫓겨난다 🚨

> 🗣 **"`sudo ufw enable` 을 먼저 치면, 지금 이 SSH 창이 그 자리에서 끊깁니다. 그리고 다시 못 들어옵니다."**

`ufw` 의 기본 정책은 **들어오는 것 전부 거부**다. **SSH 도 "들어오는 것"** 이다.

```bash
sudo ufw allow 22/tcp            # ① 먼저 내 통로부터 연다  ⭐⭐
sudo ufw enable                  # ② 그 다음에 켠다  (Proceed? → y)
sudo ufw status verbose          # Default: deny (incoming) 확인
```

> 🆘 **이미 끊겼다면** 원격으로는 방법이 없다. **VirtualBox 창(콘솔)으로 직접 로그인** → `sudo ufw disable`.
> 실제 클라우드 서버에서 이 실수를 하면 **서버를 다시 만들어야 할 수도** 있다.

#### 명령은 여섯 개면 충분하다

```bash
sudo ufw allow 21/tcp               # 열기
sudo ufw deny  23/tcp               # 막기
sudo ufw allow 40000:40010/tcp      # 포트 범위는 콜론
sudo ufw status numbered            # 번호와 함께 보기 ⭐
sudo ufw delete 3                   # 3번 규칙 지우기
sudo ufw disable                    # 끄기
```

| 거부 방식 | 상대가 보는 것 | 진단할 때 |
|-----------|---------------|-----------|
| **deny** (기본) | 대답 없음 → **타임아웃** | "한참 기다리다 실패" = **방화벽 의심** ⭐ |
| reject | 즉시 `Connection refused` | 문은 닿았는데 거절당함 |

> ⭐ **오늘 가장 많이 쓸 지식**: **`localhost` 는 되는데 밖에서만 타임아웃 → ⑤ 를 빠뜨린 것.**

#### 11일차 ACL 과 나란히 — 같은 생각이다

| | 시스코 **ACL** (11일차) | 리눅스 **ufw** (오늘) |
|---|---|---|
| 어디서 | 라우터 | **서버 자신** |
| 기본 정책 | 암묵적 **deny any** | **`default deny incoming`** |
| 출발지 지정 | `permit tcp host A ... eq 22` | `ufw allow from A to any port 22` |
| 확인 | `show access-lists` | `ufw status numbered` |

> 🗣 **"이름만 다릅니다. 필요한 것만 열고 나머지는 막는다 — 생각은 하나입니다."**

### ⑥ 검증 — 손님이 되어 본다 ⭐

| 서버 | 검증 명령 |
|------|-----------|
| SSH | `ssh student@192.168.x.x` (🪟 에서) |
| FTP | `ftp localhost` |
| NFS | `sudo mount -t nfs 127.0.0.1:/srv/share /mnt/share` |
| DNS | `dig @127.0.0.1 www.student.local` |
| Mail | `nc localhost 25` |
| Proxy | `curl -x http://127.0.0.1:3128 http://example.com` |

- **`localhost`(=`127.0.0.1`) 로 되는 것 → 밖에서 되는 것**은 별개다. `localhost` 로 되면 ①~④ 는 성공, 안 되면 ⑤ 나 LISTEN 주소 문제

---

## 📖 ③ 안 될 때 — 순서를 거꾸로 되짚는다

```
 ⑥ 접속 실패 → ⑤ 방화벽? → ④ LISTEN? → ③ 재시작했나? → ② 설정 오타? → ① 설치됐나?
```

```bash
journalctl -u vsftpd -n 30 --no-pager     # 그 서비스의 최근 로그 30줄 ⭐
journalctl -u vsftpd -f                    # 실시간으로 지켜보기 (Ctrl+C)
```

> 🗣 **"리눅스는 조용히 실패하지 않습니다. 반드시 어딘가에 써 둡니다."** 오늘 하루 `journalctl -u <서비스>` 를 입에 붙이자.
> 자세한 점검표 → [8_서비스_정리와_문제해결](lesson-8.md)

---

## 🧪 실습 / 질문

- 실습: 대본 **STEP 1** — `systemctl` 4형제를 SSH 로 연습하고 `ss` 로 확인 → [0_실습_명령어_모음](commands.md)
- "설정을 고쳤는데 안 바뀌어요" → 무엇을 빠뜨렸나? (**③ restart**)
- `start` 만 하고 `enable` 을 안 하면 무슨 일이? (**재부팅하면 사라진다** — 9일차에 `--now` 를 쓴 이유)
- `systemctl status` 는 `active (running)` 인데 밖에서 접속이 안 된다. 무엇부터 볼까? (**`ss` 의 LISTEN 주소 → 방화벽**)

## 📝 강의 메모

- 칠판 왼쪽 위에 **① 설치 ② 설정 ③ 기동 ④ 확인 ⑤ 개방 ⑥ 검증** 을 적고 **하루 종일 지우지 않는다**
- 서버를 하나 끝낼 때마다 **"몇 번까지 했죠?"** 로 되묻는다 → 여섯 번 반복하면 외워진다
- 오늘의 정신: **"명령어를 외우지 말고 순서를 외운다. 명령어는 `apt` 가 알려주고 AI 도 알려준다"** → [10일차 AI 검증 원칙](../day-10/lesson-5.md)
- 다음: 첫 번째 대상은 **이미 우리가 세운 서버** — [2_SSH_다시보기와_파일전송](lesson-2.md)
