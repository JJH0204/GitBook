# df

{% stepper %}
{% step %}
### 스크립트 생성 및 권한 설정

```bash
vi ./disk_check.sh
###########################
#!/bin/bash

#Designation of e-mail address
MAIL="<your mailaddress>"

DVAL=`/bin/df / | /usr/bin/tail -1 | /bin/sed 's/^.* \([0-9]*\)%.*$/\1/'`

if [ $DVAL -gt 80 ]; then
        echo "Disk usage alert: $DVAL %" | mail -s "Disk Space Alert in `hostname`" $MAIL
fi
###########################
chmod 700 disk_check.sh
```
{% endstep %}

{% step %}
### 테스트를 위한 더미 파일 생성

```shell
dd if=/dev/zero of=dummyfile bs=1M count=7000

## dd: 파일 생성 명령어
```

df 출력 예시:

```
df
Filesystem          1K-blocks     Used Available Use% Mounted on
devtmpfs                 4096        0      4096   0% /dev
tmpfs                  909172        0    909172   0% /dev/shm
tmpfs                  363672     5036    358636   2% /run
/dev/mapper/rl-root  17756160 16500472   1255688  93% /
/dev/sda1              983040   413228    569812  43% /boot
tmpfs                  181832        0    181832   0% /run/user/0
```
{% endstep %}

{% step %}
### 스크립트 실행

```shell
./disk_check.sh
#############################
s-nail: Warning: $LOGNAME (test) not identical to user (root)!
s-nail: Warning: $USER (test) not identical to user (root)!
s-nail: Cannot start /usr/sbin/sendmail: executable not found (adjust *mta* variable)
/root/dead.letter 8/192
s-nail: ... message not sent
#############################
```
{% endstep %}

{% step %}
### 테스트 환경 정리

```shell
rm -rf dummyfile
```

df 출력 예시:

```
df
##################################
Filesystem          1K-blocks    Used Available Use% Mounted on
devtmpfs                 4096       0      4096   0% /dev
tmpfs                  909172       0    909172   0% /dev/shm
tmpfs                  363672    5036    358636   2% /run
/dev/mapper/rl-root  17756160 2164480  15591680  13% /
/dev/sda1              983040  413228    569812  43% /boot
tmpfs                  181832       0    181832   0% /run/user/0
##################################
```
{% endstep %}

{% step %}
### cron 으로 자동화

crontab 편집:

```shell
crontab -e
######################
0 0 * * * /var/www/system/disk_check.sh

## 매일 새벽 0 시에 disk_check.sh를 실행해라
* */2 * * * * /var/www/system/disk_check.sh

## 2시간 마다 disk_check.sh를 실행해라
######################
```

현재 crontab 확인:

```shell
crontab -l
#####################
0 0 * * * /var/www/system/disk_check.sh
#####################
```
{% endstep %}

{% step %}
### 크론 로그 및 삭제

크론 로그 확인:

```shell
# 크론 로그 확인
cat /var/log/cron-20240920
```

사용자 crontab 삭제:

```shell
# 사용자의 crontab 삭제
crontab -r 
```
{% endstep %}
{% endstepper %}
