# 2. SSH 다시 보기 — Telnet 과의 차이 · 키 인증 · 파일 전송

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-002-DO |
| 유형 | D&O (개념) |
| 목적 | Telnet과 SSH의 차이, `sshd_config`의 주요 항목, 공개키 인증의 원리, `scp`와 `sftp`의 쓰임을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- Telnet(23)과 SSH(22)의 차이를 평문과 암호화로 설명한다.
- 9일차에 세운 SSH 서버의 설정 파일 `/etc/ssh/sshd_config`를 읽고 고친다.
- 비밀번호 인증과 공개키 인증의 차이를 알고, 키로 로그인한다.
- `scp`, `sftp`로 Windows와 리눅스 사이에 파일을 옮긴다.

## 1. 목적

9일차에 SSH 서버를 세웠다. 다만 설치하고 켜기까지였고 설정 파일은 열어보지도 않았다. [1. 서버 구축의 공통 문법](lesson-1.md)의 여섯 단계로 보면 ①, ③, ④, ⑥만 했고 ② 설정을 건너뛴 셈이다.

오늘 첫 대상으로 SSH를 고르는 이유는 두 가지다.

1. 이미 아는 서버라서 "설정 파일을 고친다"는 감각에만 집중할 수 있다.
2. 오늘 세울 다른 서버들의 파일을 옮길 통로가 SSH다(`scp`, `sftp`).

절차는 [SSH 설정 강화와 공개키 인증 실습](lesson-2-lab.md)에 있다.

## 2. 구성 요소

### Telnet과 SSH: 8일차의 그 짝

8일차에 라우터를 원격 관리하면서 Telnet 대신 SSH를 썼다. → [8일차 평문 vs 암호화 표](../../network1/day-08/lesson-3.md)

| | Telnet | SSH |
|---|---|---|
| 포트 | TCP 23 | TCP 22 |
| 내용 | 평문. 비밀번호가 그대로 흐른다 | 암호화 |
| 요즘 | 실무에서 금지. 장비 초기 설정 정도 | 표준 |
| 데몬 | `telnetd` | `sshd` |

비유: 엽서와 밀봉 편지다. 엽서(Telnet)는 배달하는 사람이 읽으면서 간다. SSH는 봉해서 보낸다.

커리큘럼에 Telnet 서버가 있지만 일부러 세우지 않는다. 대신 "왜 세우면 안 되는지"를 [3. FTP 서버](lesson-3.md)에서 비밀번호가 실제로 보이는 장면으로 증명한다.

### 설정 파일 두 개

파일이 두 개다. 헷갈리면 오늘 하루가 꼬인다.

| 파일 | 누구의 설정 |
|---|---|
| `/etc/ssh/sshd_config` | 서버(sshd) 설정. `d`가 붙는다. 오늘 고칠 것 |
| `/etc/ssh/ssh_config` | 클라이언트(`ssh` 명령) 설정 |

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak     # ② 백업 먼저
grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'          # 주석 뺀 실제 설정만 보기
```

### `sshd_config` 주요 항목

| 항목 | 뜻 | 오늘 권장 |
|---|---|---|
| `Port 22` | 듣는 포트 | 수업에서는 그대로 둔다(아래 포트 변경 절) |
| `PermitRootLogin` | root로 직접 로그인 허용 | `no` |
| `PasswordAuthentication` | 비밀번호 로그인 허용 | 키를 만든 뒤 `no`(실무). 수업은 `yes` 유지 |
| `PubkeyAuthentication` | 공개키 로그인 허용 | `yes`(기본값) |
| `AllowUsers student` | 이 사용자만 접속 | 선택 |

고친 뒤의 순서는 `sudo sshd -t`(문법 검사, 조용하면 정상), `sudo systemctl restart ssh`(③ 적용)이다.

{% hint style="danger" %}
WARNING: SSH 설정을 고칠 때는 지금 접속한 창을 닫지 않는다. 새 창으로 접속이 되는 것을 확인한 뒤에 원래 창을 닫는다. 잘못 고치고 창을 닫으면 VirtualBox 화면으로 직접 들어가 복구해야 한다.
{% endhint %}

### 포트를 바꾸고 싶다면: 우분투 24.04의 함정

우분투 22.10부터 SSH는 소켓 활성화(`ssh.socket`) 방식이라서, `sshd_config`의 `Port`만 고치면 바뀌지 않는다.

```bash
sudo systemctl status ssh.socket                     # 포트를 쥐고 있는 진짜 주인
sudo systemctl disable --now ssh.socket              # 소켓 방식 끄고
sudo systemctl enable --now ssh.service              # 서비스가 직접 듣게
```

설정 파일이 맞는데 안 먹는다면 그 포트를 쥔 프로세스가 따로 있는 것이다. 10일차 `ss -tulnp`의 Process 칸이 답을 알려준다.

수업에서는 포트를 바꾸지 않는다. 바꾸면 방화벽 규칙도 같이 고쳐야 한다. `sudo ufw allow <새 포트>/tcp`를 먼저 하지 않으면 다시 들어갈 수 없다. → [11일차 ufw](../day-11/lesson-6.md)

### 공개키 인증: 비밀번호 없이, 더 안전하게

비밀번호는 짧고, 재사용되고, 무차별 대입(brute force)을 당한다. 키는 길고, 유일하고, 옮겨지지 않는다.

```
 Windows (클라이언트)                           Ubuntu (서버)
 개인키  id_ed25519      ← 절대 남 주지 않는다
 공개키  id_ed25519.pub  ──── 복사 ────▶  ~/.ssh/authorized_keys
                                          "이 공개키를 가진 사람은 통과"
```

비유: 자물쇠와 열쇠다. 공개키는 자물쇠다. 서버 문에 내가 만든 자물쇠를 달아 두는 것이다. 자물쇠는 아무나 봐도 되지만(그래서 "공개"키), 여는 열쇠(개인키)는 내 PC에만 있다.

- 리눅스에는 `ssh-copy-id`가 있지만 Windows에는 없다. 대본의 한 줄짜리 복사 명령을 쓴다.
- `~/.ssh`는 권한이 까다롭다. `.ssh`는 `700`, `authorized_keys`는 `600`이어야 한다. 아니면 sshd가 조용히 무시한다. 10일차 [권한 rwx](../day-10/lesson-3.md)가 여기서 실제로 쓰인다.

```bash
ls -ld ~/.ssh ; ls -l ~/.ssh/authorized_keys     # drwx------ · -rw-------
sudo journalctl -u ssh -n 20 --no-pager          # 키가 무시된 이유가 여기 찍힌다
```

### 파일을 옮긴다: `scp`, `sftp`

설정 파일을 백업하거나 홈페이지 파일을 서버에 올릴 때 쓴다. 둘 다 SSH(22) 위에서 돈다. 새 포트를 열 필요가 없다.

| 명령 | 성격 | 예 |
|---|---|---|
| `scp` | 복사 한 방(`cp`의 네트워크판) | `scp a.txt student@192.168.x.x:~/` |
| `sftp` | 대화형(`ftp`와 같은 느낌, `put`, `get`) | `sftp student@192.168.x.x` |

{% hint style="warning" %}
CAUTION: 포트를 지정할 때 대소문자가 다르다. `ssh`는 소문자 `-p`, `scp`와 `sftp`는 대문자 `-P`다. 오늘은 기본 포트(22)를 쓰므로 생략하지만, 포트를 바꾼 서버에서는 오타 1위다.
{% endhint %}

```powershell
scp C:\Users\<사용자>\Desktop\hello.txt student@192.168.x.x:~/      # 올리기
scp student@192.168.x.x:~/lab/memo.txt .                           # 내려받기
```

- 서버끼리도 된다: `scp file student@192.168.x.x:/srv/share/`
- 폴더째 옮길 때는 `-r`이다(10일차 `cp -r`과 같은 약속).

오늘 배울 FTP와 하는 일이 같다. 그런데 FTP는 포트를 새로 열어야 하고, 평문이고, 방화벽이 싫어한다. 그럼 왜 아직도 FTP를 배울까? → [3. FTP 서버](lesson-3.md)

## 3. 동작 원리

로그인 한 번의 흐름은 다음과 같다.

1. 클라이언트가 서버 22번 포트에 접속한다.
2. 클라이언트와 서버가 암호화 채널을 만든다.
3. 클라이언트가 인증을 시도한다. 공개키 인증이 켜져 있고 `authorized_keys`에 맞는 공개키가 있으면 개인키로 증명해 비밀번호 없이 통과한다.
4. 키 인증이 실패하면 `PasswordAuthentication`이 `yes`일 때 비밀번호를 묻는다.

## 4. 질문과 실습

- 실습: 대본 STEP 2에서 `sshd_config` 수정, 키 인증, `scp`를 한다. → [SSH 설정 강화와 공개키 인증 실습](lesson-2-lab.md), [0. 12일차 실습 명령어](commands.md)
- `sshd_config`를 고쳤는데 그대로다. 무엇을 빠뜨렸나?
- 공개키와 개인키 중 서버에 올리는 것은? 왜 그것을 올려도 안전한가?
- `scp`로 파일을 올렸는데 `Permission denied`다. 어디에 올리려 했을까? `/etc` 같은 곳이다. 내 홈으로 보낸다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| SSH (Secure Shell) | 암호화된 원격 접속 프로토콜. TCP 22 |
| Telnet | 평문 원격 접속 프로토콜. TCP 23 |
| `sshd` | SSH 서버 데몬 |
| 공개키, 개인키 | 한 쌍의 키. 공개키는 서버에 두고 개인키는 내 PC에만 둔다 |
| `authorized_keys` | 서버에서 접속을 허용할 공개키 목록 파일 |
| `scp` | SSH 위에서 파일을 복사하는 명령 |
| `sftp` | SSH 위에서 대화형으로 파일을 주고받는 명령 |
| brute force | 가능한 비밀번호를 무차별로 대입하는 공격 |

## 강의 메모

- 모두가 SSH로 들어와 있는 상태에서 SSH 설정을 고친다. 시작 전에 "창 하나 더 열어 두세요"를 강제한다.
- `sshd_config`의 `d`를 칠판에 크게 쓴다. 서버는 데몬이고 `d`다.
- 키 인증은 13일차 GitHub에서 그대로 재등장한다(SSH 키로 push). → [13일차](../day-13/README.md) 예고 한 줄.
- 시간이 모자라면 키 인증은 시연만 하고 `scp`만 각자 해보게 한다(`scp`는 16일차 배포에서 계속 쓴다).
- 되짚기: 8일차 Telnet/SSH, FTP/SFTP, HTTP/HTTPS 평문과 암호화 짝 표.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 공개키 인증이 비밀번호 인증보다 안전한 이유를 자물쇠와 열쇠 비유가 아닌 내 말로 적는다.
- [ ] 설정 파일을 고치고 접속 창을 닫아도 되는 때와 안 되는 때를 적는다.
- [ ] Telnet을 쓰던 경험이나 SSH로 처음 접속했던 경험을 한두 줄로 적는다.
