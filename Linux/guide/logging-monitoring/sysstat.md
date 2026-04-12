# sysstat

{% stepper %}
{% step %}
### 설치

```bash
dnf install -y sysstat
systemctl start sysstat
systemctl enable sysstat
```
{% endstep %}
{% endstepper %}

### vi /etc/sysconfig/sysstat

{% code title="/etc/sysconfig/sysstat" %}
```bash
# sysstat-12.5.4 configuration file.

# How long to keep log files (in days).
# If value is greater than 28, then use sadc's option -D to prevent older
# data files from being overwritten. See sadc(8) and sysstat(5) manual pages.
HISTORY=28

# Compress (using xz, gzip or bzip2) sa and sar files older than (in days):
COMPRESSAFTER=31

# Parameters for the system activity data collector (see sadc manual page)
# which are used for the generation of log files.
SADC_OPTIONS=" -S DISK"

# Directory where sa and sar files are saved. The directory must exist.
SA_DIR=/var/log/sa

# Compression program to use.
ZIP="xz"

# By default sa2 script generates yesterday's summary, since the cron job
# usually runs right after midnight. If you want sa2 to generate the summary
# of the same day (for example when cron job runs at 23:53) set this variable.
#YESTERDAY=no

# By default sa2 script generates reports files (the so called sarDD files).
# Set this variable to false to disable reports generation.
#REPORTS=false

# Tell sa2 to wait for a random delay in the range 0 .. ${DELAY_RANGE} before
# executing. This delay is expressed in seconds, and is aimed at preventing
# a massive I/O burst at the same time on VM sharing the same storage area.
# Set this variable to 0 to make sa2 generate reports files immediately.
DELAY_RANGE=0

# The sa1 and sa2 scripts generate system activity data and report files in
# the /var/log/sa directory. By default the files are created with umask 0022
# and are therefore readable for all users. Change this variable to restrict
# the permissions on the files (e.g. use 0027 to adhere to more strict
# security standards).
UMASK=0022
```
{% endcode %}

### sar

{% code title="sar 1 3" %}
```bash
sar 1 3
Linux 5.14.0-427.33.1.el9_4.x86_64 (Linux1)     09/24/2024      _x86_64_        (1 CPU)

10:17:23 AM     CPU     %user     %nice   %system   %iowait    %steal     %idle
10:17:24 AM     all      0.00      0.00      0.00      0.00      0.00    100.00
10:17:25 AM     all      0.00      0.00      1.00      0.00      0.00     99.00
10:17:26 AM     all      0.00      0.00      1.00      0.00      0.00     99.00
Average:        all      0.00      0.00      0.67      0.00      0.00     99.33
```
{% endcode %}

* 1회 실행에 3번 검사한 결과 출력

{% code title="sar 1 3 | grep Average" %}
```bash
sar 1 3 | grep Average
Average:        all      0.00      0.00      0.67      0.00      0.00     99.33
```
{% endcode %}

* awk 명령을 통해 원하는 필드의 값을 추출 할 수 있다.

### iostate
