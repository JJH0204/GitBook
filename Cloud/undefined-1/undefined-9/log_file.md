# Log\_File

```
cd /var/log && ls

anaconda           cron-20240920        kdump.log          README            tallylog
audit              dnf.librepo.log      lastlog            samba             tuned
boot.log           dnf.log              maillog            secure            wtmp
boot.log-20240920  dnf.rpm.log          maillog-20240920   secure-20240920
btmp               firewalld            messages           spooler
chrony             hawkey.log           messages-20240920  spooler-20240920
cron               hawkey.log-20240920  private            sssd

```

### btmp

* 접속 실패 기록 저장
* 명령어로 확인:

```bash
lastb
# 또는
last -f /var/log/btmp
```

### utmp

* 사용자 기록
* 현재 시스템에 접속한 사용자 로그
* 확인 명령어:

```bash
who
who am i
```

### wtmp

* 로그인 성공한 기록
* 확인 명령어:

```bash
last
# 또는
last -f /var/log/wtmp
```

### lastlog

* 전체 사용자의 마지막 로그인 기록
* 확인 명령어:

```bash
lastlog
# 특정 사용자
lastlog -u root
# 기간 동안 로그인한 기록
lastlog -t 5
# 지정한 날짜 이전 로그 기록 출력
lastlog -b 19
```

### messages

* Linux 시스템 로그

### secure

* 인증 관련 로그

### cron

* 시스템 자동화(스케쥴러)
* 관련 문서: [cron](/broken/pages/2b8b6644c3589ea2571ba2ac264ca9caaa486cce)
