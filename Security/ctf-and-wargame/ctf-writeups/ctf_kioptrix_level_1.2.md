# CTF\_KIOPTRIX\_Level\_1.2

{% hint style="warning" %}
DISCLAIMER! We at Kioptrix are not responsible for any damaged directly, or indirectly, caused by using this system. We suggest you do not connect this installation to the Internet. It is, after all, a vulnerable setup. Please keep this in mind when playing the game.

This machine is setup to use DHCP. Before playing the game, please modify your attacker's hosts file. kioptrix3.com This challenge contains a Web Application.

If you have any questions, please direct them to: comms\[at]kioptrix.com

Hope you enjoy this challenge. -Kioptrix Team
{% endhint %}

vmw 파일을 버츄얼 머신에서 구동하는 방법은 없을까?

### vmdk 파일 실행하기

* https://brunch.co.kr/@moaikim/60

## 정보 탐색

{% stepper %}
{% step %}
### nmap

* 22/tcp : ssh 서비스 동작 중
* 80/tcp : http 서비스 동작 중
{% endstep %}

{% step %}
### http://192.168.56.119

#### host 설정

#### 접속
{% endstep %}

{% step %}
### dirb http://kioptrix3.com/

http://kioptrix3.com/phpmyadmin/index.php<br>

http://kioptrix3.com/cache/index.html<br>
{% endstep %}

{% step %}
### nikto -h http://kioptrix3.com/

`+ /favicon.ico: Server may leak inodes via ETags, header found with file /favicon.ico, inode: 631780, size: 23126, mtime: Fri Jun 5 15:22:00 2009. See: http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2003-1418`

`+ /icons/README: Apache default file found. See: https://www.vntweb.co.uk/apache-restricting-access-to-iconsreadme/ /phpmyadmin/: phpMyAdmin directory found. /phpmyadmin/Documentation.html: phpMyAdmin is for managing MySQL databases, and should be protected or limited to authorized hosts.`
{% endstep %}

{% step %}
### search CVE-2003-1418

> 해당 정보에 대한 액세스 권한이 명시적으로 부여되지 않은 행위자에게 민감한 정보를 노출합니다. 영향으로 기밀성에 영향을 미치는 것으로 알려져 있습니다. 이 공격은 원격으로 시작할 수 있습니다. 이 익스플로잇에는 어떠한 형태의 인증도 필요하지 않습니다.
{% endstep %}

{% step %}
### SQL Injection

* 로그인 페이지에 가볍게 sql injection 구문 입력
* 로그인 성공 한 것은 아닌 것 같고 어떤 사용자든 DB에 접속 가능한 것 같다.
{% endstep %}

{% step %}
### msfconsole
{% endstep %}

{% step %}
### sqlmap

* 흠... sql DB라서 sqlmap으로 검색하면 뭔가 있을 것 같아서 실행했지만 결과는 아쉬웠다.
{% endstep %}

{% step %}
### gobuster

(기록 없음)
{% endstep %}
{% endstepper %}
