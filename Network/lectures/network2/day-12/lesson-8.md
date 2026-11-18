# 8. 오늘의 서버 총정리 — 그리고 안 될 때 찾는 법

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-008-TS |
| 유형 | TS (문제 해결) |
| 목적 | 오늘 세운 서버를 한 표로 정리하고, "접속이 안 된다"는 증상을 5단계로 좁혀 원인을 찾는 방법과 로그 읽는 법을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 오늘 세운 서버들을 패키지, 데몬, 포트, 설정 파일, 검증 명령으로 한 표에 정리한다.
- 서버가 안 될 때 아래에서 위로 순서대로 좁혀 가는 5단계 점검을 익힌다.
- 로그를 읽는 법(`journalctl`, `/var/log/`)을 안다.

## 1. 증상

아침에 칠판에 적은 ① 설치 ② 설정 ③ 기동 ④ 확인 ⑤ 개방 ⑥ 검증을 여섯 번 반복했다. 이제 외울 것은 명령어가 아니라 표 한 장과 점검 순서 하나다.

가장 흔한 증상은 하나다. "접속이 안 돼요."

## 2. 참조 표: 오늘의 서버 한 장 정리

| 서비스 | 패키지 | 데몬(systemd) | 포트 | 설정 파일 | 검증 |
|---|---|---|---|---|---|
| SSH | `openssh-server` | `ssh`(`sshd`) | TCP 22 | `/etc/ssh/sshd_config` | `ssh student@192.168.x.x`, `sshd -t` |
| FTP | `vsftpd` | `vsftpd` | TCP 21 + 데이터 | `/etc/vsftpd.conf` | `ftp localhost` |
| NFS | `nfs-kernel-server` | `nfs-server` | TCP 2049 | `/etc/exports` | `mount -t nfs`, `showmount -e` |
| DNS | `bind9` | `named` | UDP/TCP 53 | `/etc/bind/named.conf.*`, `db.*` | `dig @127.0.0.1 ...`, `named-checkzone` |
| Mail | `postfix` | `postfix` | TCP 25(587, 465) | `/etc/postfix/main.cf` | `nc localhost 25`, `mail` |
| Proxy | `squid` | `squid` | TCP 3128 | `/etc/squid/squid.conf` | `curl -x http://127.0.0.1:3128 ...` |
| (참고) Telnet | `telnetd` | - | TCP 23 | - | 평문이라 세우지 않았다 |
| (예고) Web | `nginx` | `nginx` | TCP 80, 443 | `/etc/nginx/...` | `curl localhost`, `nginx -t` → 13, 16일차 |

포트 번호는 10일차 표에서 이미 외운 것들이다. 오늘은 그 포트를 여는 프로그램의 이름을 채워 넣었다. → [10일차 포트 번호표](../day-10/lesson-8.md)

### 문법 검사 도구

| 서비스 | 검사 명령 |
|---|---|
| SSH | `sudo sshd -t` |
| DNS | `sudo named-checkconf`, `sudo named-checkzone <존> <파일>` |
| NFS | `sudo exportfs -v` |
| Postfix | `sudo postfix check` |
| Squid | `sudo squid -k parse` |
| (예고) nginx | `sudo nginx -t` |

## 3. 가능 원인

원인은 다섯 층 중 하나다. 아래에서 위로 좁힌다.

| 층 | 원인 | 의심 신호 |
|---|---|---|
| ① | 설치가 안 됐다 | `Unable to locate package`, 데몬 없음 |
| ② | 서비스가 안 떠 있다(설정 오타로 죽었다) | `inactive (dead)`, `Job for X.service failed` |
| ③ | 엉뚱한 주소에서 듣는다(`127.0.0.1`에만 LISTEN) | `localhost`는 되고 밖에서 안 된다 |
| ④ | 방화벽이 막는다(`ufw`, 오늘 ⑤ 단계에서 켰다) | 한참 기다린 뒤 타임아웃 |
| ⑤ | 클라이언트가 잘못(주소, 포트, 계정 오타) | 의외로 1위 |

## 4. 격리 절차

```bash
# 1단계 - 살아 있나
systemctl status <서비스>
# 2단계 - 듣고 있나, 어느 주소에서
sudo ss -tulnp | grep <포트>
# 3단계 - 나 자신에게는 되나 (되면 ①②③ 정상)
curl localhost:<포트>   또는  telnet localhost <포트>  또는  전용 클라이언트
# 4단계 - 방화벽
sudo ufw status numbered
# 5단계 - 로그가 정답을 알고 있다
sudo journalctl -u <서비스> -n 30 --no-pager
```

| 구분선 | 이 경계가 알려주는 것 |
|---|---|
| `localhost`로는 되는데 밖에서 안 된다 | 서버는 정상이다. LISTEN 주소 또는 방화벽, 포트포워딩 문제다 |
| `localhost`로도 안 된다 | 서버 자체 문제다. 설정, 기동, 로그를 본다 |

이 한 줄만 기억한다. "`localhost`는 되나요?" 이 질문 하나로 문제가 절반으로 쪼개진다.

### 에러 메시지 읽는 법

| 메시지 | 뜻 | 볼 곳 |
|---|---|---|
| `Connection refused` | 그 포트에 아무도 없다 | 서비스 죽음, 포트 오타 |
| `Connection timed out` | 답이 없다(누가 삼켰다) | 방화벽, 경로, 잘못된 IP |
| `Address already in use` | 그 포트를 남이 쥐고 있다 | `ss -tulnp`의 Process 칸(bind9와 systemd-resolved) |
| `Permission denied` | 권한 | `sudo`, 파일 권한, `~/.ssh` 권한 |
| `No route to host` | 경로가 없다 | IP, 게이트웨이(1단계 내용) |
| `Job for X.service failed` | 설정 오타로 기동 실패 | `journalctl -u X -n 30` |

### 로그가 사는 곳

```bash
journalctl -u named -n 50 --no-pager       # systemd 서비스 로그 (거의 다 여기)
journalctl -u named -f                      # 실시간
sudo tail -f /var/log/squid/access.log      # 프록시 접근 기록
sudo tail -f /var/log/mail.log              # 메일 배달 기록
sudo tail -f /var/log/auth.log              # 로그인, sudo 기록 (보안)
sudo tail -f /var/log/syslog                # 전체
```

`tail -f`는 로그를 실시간으로 지켜보는 명령이다. 한 창에서 `-f`로 띄워두고 다른 창에서 접속을 시도하면 실패하는 그 순간의 줄이 찍힌다. 10일차에 배운 창 3개 습관이 여기서 진가를 낸다.

## 5. 시정 조치 참조

| 원인 | 시정 | 참조 문서 |
|---|---|---|
| ② 설정 오타 | `.bak`에서 복구하고 한 줄씩 다시 고친다 | [서버 구축의 공통 문법](lesson-1.md) |
| ③ LISTEN 주소 | 설정 파일의 `listen-on` 등 주소 항목을 고친다 | [DNS 서버](lesson-5.md) |
| ④ 방화벽 | `sudo ufw allow <포트>/tcp` | [ufw 방화벽 켜기 실습](lesson-1-lab.md) |
| `Address already in use` | 포트를 쥔 프로세스를 확인하고 주소를 지정한다 | [bind9 DNS 서버 구축 실습](lesson-5-lab.md) |
| FTP `ls`에서 멈춤 | 패시브 포트 범위를 방화벽에 연다 | [vsftpd FTP 서버 구축과 평문 확인 실습](lesson-3-lab.md) |
| SSH 키를 넣었는데 비밀번호를 물음 | `~/.ssh` 권한(`700`, `600`)을 고친다 | [SSH 설정 강화와 공개키 인증 실습](lesson-2-lab.md) |

### 서버를 세웠다면: 최소한의 마무리

| 할 일 | 명령 |
|---|---|
| 부팅 때 자동 시작 걸기 | `sudo systemctl enable <서비스>` |
| 안 쓰는 서비스는 끈다 | `sudo systemctl disable --now <서비스>` |
| 열린 포트를 다시 확인 | `sudo ss -tulnp` |
| 방화벽 규칙 점검 | `sudo ufw status numbered` |

오늘 문을 여섯 개 열었다. 열어 둔 문은 전부 남이 두드릴 수 있는 문이다. 보안의 첫걸음은 어려운 설정이 아니라 안 쓰는 서비스를 끄는 것(공격 표면 줄이기)이다. 11일차 방화벽과 한 쌍이다.

## 6. 질문과 실습

- 실습: 대본 STEP 8에서 `ss -tulnp`로 오늘 연 포트 전부 세어 보기, 안 쓰는 서비스 끄기를 한다. → [0. 12일차 실습 명령어](commands.md)
- "밖에서 FTP 접속이 안 돼요. `ftp localhost`는 됩니다." 어디를 볼까?
- `Connection refused`와 `Connection timed out` 중 방화벽이 원인인 쪽은?
- 오늘 연 포트 중 실제 회사 서버라면 인터넷에 절대 열면 안 되는 것을 골라 본다(NFS 2049, FTP 21, Mail 25 등).

## 약어·용어

| 용어 | 뜻 |
|---|---|
| 공격 표면 (attack surface) | 외부에서 접근할 수 있는 열린 문의 전체. 줄일수록 안전하다 |
| `journalctl` | systemd 서비스 로그를 보는 명령 |
| `tail -f` | 파일 끝을 실시간으로 따라 보는 명령 |
| `Connection refused` / `timed out` | 포트에 서비스가 없음 / 응답이 없음 |

## 강의 메모

- 이 노트는 정리와 안전망이다. 실습 중 막힌 학생에게 "8번 노트를 보세요"라고 가리킬 수 있게 만들어 뒀다.
- 칠판에 "`localhost`는 되나요?"를 크게 써 두고, 질문이 나올 때마다 그것부터 되묻는다.
- 마지막 메시지는 "열어둔 문은 닫아야 한다"이다. 11일차 방화벽 복습이자 16일차 클라우드 배포의 예고다.
- 되짚기: 10일차 `ss`와 `Address already in use`, 11일차 ACL, 오늘 ufw와 서버 3개.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] "`localhost`는 되나요?"라는 질문이 문제를 절반으로 쪼개는 이유를 내 말로 적는다.
- [ ] 오늘 서버가 안 돼서 막혔던 경험이 있다면 어느 층의 문제였는지 적는다.
- [ ] 오늘 연 포트 중 평소에는 꺼 두겠다고 고른 것과 이유를 적는다.
