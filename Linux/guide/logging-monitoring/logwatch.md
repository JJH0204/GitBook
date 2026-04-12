# logwatch

로그를 보기 쉽게 보고서로 작성하고 관리자의 이메일로 전송하는 서비스: logwatch

설치 명령:

{% code title="설치 (dnf)" %}
```bash
dnf install -y logwatch
```
{% endcode %}

디렉터리 구조 (예시)

```
/etc/logwatch
  ├─ conf        (설정파일)
  └─ scripts     (관련 스크립트)
```

설정 파일 샘플 및 주요 항목

* /etc/logwatch/conf/logwatch.conf (로컬 설정 파일)

{% code title="/etc/logwatch/conf/logwatch.conf" %}
```
# Local configuration options go here (defaults are in /usr/share/logwatch/default.conf/logwatch.conf)
```
{% endcode %}

* /usr/share/logwatch/default.conf/logwatch.conf (기본 설정 파일, 일부 발췌)

{% code title="/usr/share/logwatch/default.conf/logwatch.conf (발췌)" %}
```
########################################################
# This was written and is maintained by:
#    Kirk Bauer <kirk@kaybee.org>
# Please send all comments, suggestions, bug reports,
#    etc, to kirk@kaybee.org.
########################################################

(생략)
#Output/Format Options
#By default Logwatch will print to stdout in text with no encoding.
#To make email Default set Output = mail to save to file set Output = file
Output = stdout
#To make Html the default formatting Format = html
Format = text # 출력 형태
#To make Base64 [aka uuencode] Encode = base64
Encode = none # 암호화 여부

# Input Encoding
# Logwatch assumes that the input is in UTF-8 encoding.  Defining CharEncoding
# will use iconv to convert text to the UTF-8 encoding.  Set CharEncoding
# to an empty string to use the default current locale.  If set to a valid
# encoding, the input characters are converted to UTF-8, discarding any
# illegal characters.  Valid encodings are as used by the iconv program,
# and `iconv -l` lists valid character set encodings.
# Setting CharEncoding to UTF-8 simply discards illegal UTF-8 characters.
#CharEncoding = ""

# Default person to mail reports to.  Can be a local account or a
# complete email address.  Variable Output should be set to mail, or
# --output mail should be passed on command line to enable mail feature.
MailTo = root # (중요) 시스템 관리자의 메일 주소 입력

(생략)

# The default detail level for the report.
# This can either be Low, Med, High or a number.
# Low = 0
# Med = 5
# High = 10
Detail = Low # log 출력의 상세함 정도 (중요)
(생략)
```
{% endcode %}

중요 설정 요약

{% hint style="info" %}
* Output: 출력 방식 (예: stdout, mail, file)
* Format: 출력 포맷 (text, html 등)
* MailTo: 보고서를 받을 관리자 이메일 또는 로컬 계정 (중요)
* Detail: 보고서의 상세 수준 (Low / Med / High 또는 숫자) — 예시에서 Detail = Low
{% endhint %}

실행 예시 (stdout 출력)

{% code title="명령" %}
```bash
logwatch --output stdout
```
{% endcode %}

출력 예시:

{% code title="logwatch 출력 (예시)" %}
```
 ################### Logwatch 7.5.5 (01/22/21) ####################
        Processing Initiated: Fri Sep 20 16:29:54 2024
        Date Range Processed: yesterday
                              ( 2024-Sep-19 )
                              Period is day.
        Detail Level of Output: 10
        Type of Output/Format: stdout / text
        Logfiles for Host: Linux1
 ##################################################################

 --------------------- Disk Space Begin ------------------------

 Filesystem           Size  Used Avail Use% Mounted on
 /dev/mapper/rl-root   17G  2.1G   15G  13% /
 /dev/sda1            960M  404M  557M  43% /boot


 ---------------------- Disk Space End -------------------------


 ###################### Logwatch End #########################
```
{% endcode %}

참고

* 기본/로컬 설정 파일의 옵션을 적절히 변경하여 Output = mail 및 MailTo에 관리자 이메일을 지정하면 이메일 전송이 가능합니다.
* 위에 포함된 설정 파일 내용은 발췌본이며, 실제 전체 파일에는 추가 주석 및 옵션이 존재합니다. 필요 시 전체 파일을 열어 확인하세요.
