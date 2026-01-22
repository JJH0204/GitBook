# CTF\_Pwned

## IP 탐지

{% hint style="info" %}
victim ip: 192.168.56.113\
service: 21/tcp(ftp), 22/tcp(ssh), 80/tcp(http)
{% endhint %}

{% stepper %}
{% step %}
### 1) 웹 탐색 (초기)

`http://192.168.56.113:80`

> I am Annlynn. I am the hacker hacked your server with your employees but they don't know how i used them. Now they worry about this. Before finding me investigate your employees first. (LOL) then find me Boomers XD..!!

> 저는 앤린입니다. 해커가 직원들과 함께 귀하의 서버를 해킹했지만 그들은 제가 어떻게 사용했는지 모릅니다. 이제 그들은 이것에 대해 걱정합니다. 저를 찾기 전에 먼저 직원들을 조사하세요. (LOL) 그런 다음 저를 Boomers XD를 찾아주세요..!!!

* 주석에서 힌트 같은 것을 획득했다.

>
{% endstep %}

{% step %}
### 2) 접속 가능한 웹 디렉터리 탐색

* `http://192.168.56.113/index.html` (CODE:200|SIZE:3065)
* `http://192.168.56.113/robots.txt` (CODE:200|SIZE:41)<br>
* `http://192.168.56.113/server-status` (CODE:403|SIZE:279)<br>

서버와 클라이언트가 주고 받는 액션이 없어 쿠키나 그 외 다른 장치는 의미 없는 것 같다.
{% endstep %}

{% step %}
### 3) FTP 접속 시도 (1차)

* 웹 페이지에서 획득한 정보를 활용해 FTP 서버에 접속 시도.
* 실패할 경우 웹 페이지에서 추가 정보를 찾아본다.
* Anonymous 접속 불가능
* 다른 사용자 계정으로 유추할 만한 이름들을 모두 넣었지만 접속 실패
* 다시 웹 탐색으로 넘어간다.
{% endstep %}

{% step %}
### 4) 웹 탐색 2차

`http://192.168.56.113/robots.txt`의 정보를 기반으로 `http://192.168.56.113/nothing/`에 접속 성공

* 농락당하는 느낌이다.
* 유의미한 정보를 얻지 못했다.
* 접속할 수 있는 다른 웹 디렉터리는 없는 걸까?
{% endstep %}

{% step %}
### 5) nikto 스캔

* 웹 사이트 내 취약점 탐색\
  https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2003-1418
* `http://192.168.56.113/icons/README`에 접속 가능 확인<br>
{% endstep %}

{% step %}
### 6) dirbuster / gobuster

* dirb의 강화 버전으로 유의미한 정보를 찾지 못해 사용.&#x20;
* 굉장히 자세히 조사하는 만큼 시간도 매우 오래 걸린다.&#x20;

#### gobuster wordlist 변경

* 뭔가 새로운 정보가 찾아 진다.&#x20;
* 숨겨진 디렉토리 경로 리스트로 보임 — 하나씩 대입해서 접속 가능한지 확인
* 리스트 중 유일하게 접속 가능한 페이지를 발견&#x20;
* 주석 내용을 읽어보니 ID 와 Password를 찾을 수 있었다. `$un=='ftpuser' && $pw=='B0ss_B!TcH'`

ID와 Password를 찾았으니 FTP 접속을 다시 시도한다.
{% endstep %}

{% step %}
### 7) FTP 접속 (2차)

* id: ftpuser
* pw: B0ss\_B!TcH
* 공유 받을 수 있는 디렉터리를 찾았지만 정확한 정보는 확인 불가&#x20;
* SSH에 ftpuser 계정으로 접속을 시도하여 파일 정보를 알아냄&#x20;
* FTP로 SSH key 파일을 다운 받음 &#x20;
* 임시 관리자 권한을 받아 올 수 없다고 표시&#x20;
* 더 얻을 수 있는 정보가 없는지 추가로 탐색&#x20;
* ftpuser 계정으로 얻을 수 있는 정보는 더 이상 없음 — 다른 계정으로 로그인 시도
{% endstep %}

{% step %}
### 8) SSH 키 활용 및 권한 상승 시도

* FTP에서 가져온 ssh\_key를 활용
* user\_flag 발견\
  &#x20;

> 아리아나 개인 일기 ::: 오늘 셀레나는 저와 함께 아제이를 위해 싸웁니다. 그래서 서버에서 그녀의 hidden\_text를 열었습니다. 이제 그녀는 이 문제를 책임지고 있습니다.

* selena로 로그인 시도했으나 막혀있음<br>
* 다시 ariana로 로그인해 방법 탐색
* ariana 계정이 ./messenger.sh 를 실행할 권한을 가짐<br>
* home 디렉터리 아래 의심스러운 파일들   &#x20;
* selena의 쉘을 획득하는 데 성공&#x20;
* 두번째 플래그 획득&#x20;
* 서로 남탓만 하는 듯한 파일 내용&#x20;
* 아래 명령어로 안전한 쉘 확보&#x20;
{% endstep %}

{% step %}
### 9) 도커 권한 상승 (Docker privesc)

* 실행 중인 도커 정보&#x20;
* selena는 docker를 사용할 수 있는 사용자
* 이전에 docker를 이용해 root 쉘을 강탈한 적 있어 동일 방법 시도 https://www.google.com/search?q=docker+privesc\&oq=\&gs\_lcrp=EgZjaHJvbWUqCQgAEEUYOxjCAzIJCAAQRRg7GMIDMgkIARBFGDsYwgMyCQgCEEUYOxjCAzIJCAMQRRg7GMIDMgkIBBBFGDsYwgMyCQgFEEUYOxjCAzIJCAYQRRg7GMIDMgkIBxBFGDsYwgPSAQwxNjQ2MTIyMmowajeoAgiwAgE\&sourceid=chrome\&ie=UTF-8 https://flast101.github.io/docker-privesc/
* privesc 이미지가 설치되어 있음&#x20;
* 위 스크립트를 victim 서버에서 test.sh로 만들어 실행
{% endstep %}
{% endstepper %}

참고: 원문 워크스루 출처\
https://medium.com/@z6157881/pwned-1-vulnhub-walkthorugh-46dce5337e06
