# SystemSecurityAssignment

## 1. Linux 보안 설정

### 1-1. root 원격 접속 제한

참고자료: [Remote Access Management](file:///2237607/linux_admin/Remote%20Access%20Management.md)

* ssh 프로토콜을 활용한 root 접속을 제한한다.(/etc/ssh/sshd\_config)\
  &#x20;문제는 이후에도 root 접속이 가능했다.
* &#x20;01-permitrootlogin.conf 파일이 의심스럽다.
* &#x20;역시 여기서 root 로그인이 허용되어서 그랬다. 이 값을 no 로 설정하거나 파일을 삭제한다.
* root 원격 접속이 불가능하게 수정되었다.&#x20;
* 사용하지 않는 telnet, rsh 시스템을 삭제한다.&#x20;

{% hint style="info" %}
ssh root login deny

* `/etc/ssh/sshd_config`의 PermitRootLogin 값이 no 인지 확인
* `/etc/ssh/sshd_config.d/`의 세부 설정 파일에서 PermitRootLogin 값이 있는지, 있다면 no 인지 확인

사용하지 않는 원격 접속 서비스 삭제
{% endhint %}

### 1-2. 비밀번호 생성 규칙 설정

보안을 위해 비밀번호 생성 규칙을 지정한다.

* (대,소문자,특수문자,숫자) 최소 1개 이상 조합, 8자리 이상\
  참고자료: [Account Management](file:///2237607/linux_admin/Account%20Management.md)
* libpwquality 서비스가 설치되었는지 확인한다.&#x20;
* `/etc/security/pwquality.conf`에서 규칙을 설정한다.&#x20;
* 적용 여부 확인&#x20;

{% hint style="info" %}
- root 사용자가 신규 계정을 생성할 때는 점검을 하지 않는 것 같다.
- 일반 사용자가 자신의 초기에 설정된 비밀번호 대신 다른 비밀번호로 설정할 때 pwquality 설정이 적용되어 높은 수준의 보안이 적용된 비밀번호를 만들도록 한다.
{% endhint %}

### 1-3. 패스워드 만료일 설정

참고자료: [Account Management](file:///2237607/linux_admin/Account%20Management.md)

* 계정 패스워드 만료일 설정을 위해 chage 명령어를 사용한다.
* 우선 서버에 등록되어 있는 사용자 들을 확인한다.&#x20;
* 이 유저들의 패스워드에 만료일이 설정되어 있는지 확인한다.&#x20;
* test 유저에는 만료일이 설정되어 있는데 jaeho 계정에는 만료일이 설정되어 있지 않다. (만료일을 설정해준다.)&#x20;

{% hint style="info" %}
계정 비밀번호의 만료일(유효기간)을 설정하려면 "chage" 명령어를 사용하면 된다.
{% endhint %}

### 1-4. 디스크 용량 확인 작업 자동화

참고자료: [df](file:///2237607/linux_admin/df.md)

{% stepper %}
{% step %}
### 디스크 사용량 점검 스크립트 작성

다음 스크립트를 작성한다:

```bash
#!/bin/bash

fun_disk_check()
{
        # Log 저장 경로
        LOG_DIR="/root/log"

        # Log 폴더 존재 확인(없으면 생성)
        if [ ! -d "$LOG_DIR" ]; then
                mkdir -p "$LOG_DIR"
        fi

        # 점검 결과 로그 저장 설정
        exec > "$LOG_DIR/diskcheck_$(date +%Y%m%d_%H%M%S).log" 2>&1

        # 현재 디스크 사용률 변수에 저장
        DVAL=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
        echo "# Disk Check ##################"
        df
        echo "###############################"
        # 현재 사용률 출력
        printf "Disk usage: %s%%\n" "$DVAL"

        # 기준치(인자값 1)를 넘으면 경고 출력
        if [ "$DVAL" -gt "$1" ]; then
                echo "[Warning]"
        fi

        echo "###############################"
}

fun_disk_check $1
```
{% endstep %}

{% step %}
### cron으로 자동 실행 설정 (매주 금요일 5시)

* crond 활성 여부 확인: `systemctl status crond`
*   crontab -e에 다음 형식으로 작업 추가: _예시 (매주 금요일 5시):_

    ```
    * 5 * * 5 nohup /root/disk_check.sh 80
    ```
* systemctl restart crond
{% endstep %}
{% endstepper %}

### 1-5. 공격자의 http/ssh 접속 차단(log)

참고자료: [firewalld](file:///2237607/linux_admin/firewalld.md)

* 방화벽 설정 확인&#x20;
* 공격자가 enp0s8을 통해 공격을 시도한다 가정하고 공격을 차단한 방법을 구상할 수 있다.
  * 공격자의 IP를 차단한다.
  * 공격자가 소속된 네트워크 대역을 차단한다.
* enp0s8 인터페이스의 네트워크 대역은 192.168.56.0/24로 이 인터페이스에 다른 zone을 설정해준다.&#x20;
* 요청 사항에 맞게 방화벽 룰 적용&#x20;

### 1-6. SetUID Bit 설정 점검 및 권한 점검

* 일반 사용자에서 관리자 권한을 얻을 수 있는지 확인
* 간단한 백도어 스크립트를 만들어서 점검(아래 과정은 root 계정에서 진행)

```c
#include<stdio.h>

int main()
{
        setuid(0);
        setgid(0);
        system("/bin/bash");
        return 0;
}
```

* 빌드 후 설정 수정

```bash
gcc -o 실행파일이름 소스.c
cp 실행파일 /일반사용자가/접근/가능한/경로/실행파일
chmod 4755 실행파일
# setUID bit 설정으로 해당 파일은 root 권한이 없어도 실행할 수 있게 설정
```

* 일반 사용자로 테스트\
  \
  (관리자 계정을 가져오는데 성공)<br>

내부 직원이 이러한 방식으로 백도어를 심어 둔다면 보안에 취약해진다.

### 1-7. Sticky Bit 설정 확인

* 예: `chmod +t /home/test`&#x20;
* ./test 디렉터리는 sticky bit가 설정되어 있어 디렉터리의 사용자(소유자), root 사용자가 아니면 삭제할 수 없게 되었다.
* 요청 사항에 맞게 작업을 진행했다.&#x20;
* 다른 사용자로 접속해 삭제를 시도한다.&#x20;
* root 계정으로는 삭제가 된다.&#x20;

## 2. Snort Setting

참고자료: [snort](/broken/pages/a75b0c29eb137905c4dee50191af73dc48241bab)

* 참고자료를 참고해 snort를 설치한다.&#x20;
* 서비스 설정 작업을 한다.&#x20;
  * 탐지할 네트워크 대역이 연결된 인터페이스를 설정에 적용한다.(enp0s8)
*   패킷 탐지 활성화:

    ```
    ip link set dev enp0s8 promisc on
    ```
* 커뮤니티 룰 설치
* snort 설정(vi /usr/local/etc/snort/snort.lua)

```
HOME_NET = '192.168.56.0/24'

-- set up the external network addresses.
-- (leave as "any" in most situations)
EXTERNAL_NET = '!$HOME_NET'
```

* 요청사항을 반영한 rule 파일 작성

```
# kali는 IP를 위변조하여 패킷을 던질 가능성이 있기 때문에 네트워크 대역을 설정
alert icmp 192.168.56.0/24 any -> $HOME_NET any (msg:"icmp packet";sid:1000001;rev:1;)
alert tcp 192.168.56.0/24 any -> $HOME_NET 80 (msg:"Suspicious access to /etc/passwd"; content:"/etc/passwd"; sid:1000002; rev:1;)

# 공격자가 CTF에 접속해 다신의 서버에 접속을 유도하는 패킷을 검출
alert tcp $HOME_NET any -> 192.168.56.102 22 (msg:"Outgoing SSH connection to attacker"; sid:1000003; rev:1;)
```

* 이후 설정은 참고자료를 참고
* snort 실행 예:

```
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules -i enp0s8 -A alert_fast -s 65535 -k none
```

테스트 결과\
&#x20;

{% hint style="success" %}
공격이 의심되는 패킷을 검출할 수 있게되었다.
{% endhint %}

## 3. CTF

[CTF\_TechSupport](file:///2237607/ctf_writeups/CTF_TechSupport.md)
