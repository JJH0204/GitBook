# CTF\_cybersploit2

* nmap tool 을 이용한 victim server IP 찾기<br>
* `http://192.168.56.106/` 접속<br>
* 페이지 소스 분석\
  \
  소스에 ROT47 알고리즘에 대한 언급이 있다. 무슨 연관이 있을까?
* `dirb http://192.168.56.106/`: 접근 가능한 웹 디렉터리 조사
* `http://192.168.56.106/noindex/common/css/styles`에 접근 가능 [cybersploit\_css\_styles](file:///5659318/misc/cybersploit_css_styles.md)
* [nikto\_cybersploit2\_result](file:///5659318/security/nikto_cybersploit2_result.md)

{% hint style="info" %}
소스에 ROT47이라는 주석과 소스 바디에 작성된 유저 이름, 비밀번호를 관찰해보면 적용 할만한 문자열이 보인다.\
컬럼 이름이 한칸씩 밀려서 잘 몰랐지만 첫 열이 계정 이름이고 둘째 열이 비밀번호다.
{% endhint %}

* `ssh shailendra@192.168.56.106` — 비밀번호 `cybersploit1`로 원격 접속에 성공.
* 힌트 발견 — 도커의 취약점을 활용해야 하는 것 같다.

\
도커 버전 확인: `docker --version`<br>

* 도커 관련 취약점 검색 결과 및 악성 코드(참고 이미지)<br>
* 로컬에서 실행하기 위해 공격자 PC에 서버를 구축하고 victim 서버에서 파일을 내려받게 시도했으나 `wget` 사용 불가.<br>
* 대안: victim에서 도커 사용 가능하므로, 도커를 이용해 파일을 올리고 내려받는 방법을 사용.

***

다른 공격 방법 요약 (Docker privilege escalation)

* Docker의 취약점을 활용해 루트 쉘을 얻을 수 있는 이미지가 있음.
* 참조: https://gtfobins.github.io/gtfobins/docker/ (alpine 예시)
* 이 이미지를 서버에서 실행하면 일반 사용자가 관리자 권한(루트) 쉘을 얻을 수 있음.<br>
* victim은 외부로 원격 접속/접근이 불가능하므로 Attacker → victim으로 이미지 파일을 전달할 방법 필요.<br>

이미지 설치 및 전송 과정 (스크린샷)

\
이미지 파일을 압축해 전달 준비\
\
도커의 scp 명령어를 통해 압축한 이미지 파일 전송<br>

victim에서 확인

* 사용자가 docker 그룹에 속해 있음을 확인: `id`<br>
* 공격자로부터 받은 압축파일 확인 및 압축 해제\
  <br>
* 취약점 이용 이미지 실행 및 쉘 획득<br>

***

{% stepper %}
{% step %}
### 정보 수집 및 초기 접근

* nmap으로 대상 탐지
* 웹 접속 및 소스 분석(ROT47 관련 주석 발견)
* dirb로 공개 디렉터리 확인
* 페이지 내 노출된 계정 정보로 SSH 접근 (shailendra / cybersploit1)
{% endstep %}

{% step %}
### 시스템/환경 확인

* SSH로 접속 후 `ls`, `uname -a`, `cat /etc/issue`, `cat hint.txt`, `id` 등으로 시스템 정보 확인
* 도커 사용 가능 여부 확인 (`docker --version`)
{% endstep %}

{% step %}
### 취약점 탐색

* 도커 관련 권한 상승 기법 검색 (GTFOBins 등)
* 루트 권한 쉘을 얻는 docker 이미지(예: alpine 기반) 확인
{% endstep %}

{% step %}
### 페이로드 전달 방법 설계

* victim에서 외부 네트워크 접근이 제한되어 wget 등 사용 불가
* 도커가 사용 가능하므로 도커 이미지를 압축해 공격자에서 전달
* 도커의 scp(또는 사용 가능한 파일 전송 방법)를 이용해 이미지 전송
{% endstep %}

{% step %}
### 권한 상승 및 플래그 획득

* victim에서 이미지 압축 해제 및 실행
* 취약한 docker 실행: docker run -v /:/mnt --rm -it alpine chroot /mnt sh (GTFOBins 예시)
* 루트 권한 확인 (`id`) 후 /root/flag.txt 확인
{% endstep %}
{% endstepper %}

***

결론 요약

* 페이지 소스의 ROT47 단서로 크리덴셜을 찾고 SSH로 초기 접근에 성공함.
* victim 호스트에서 도커 권한을 이용해 로컬 이미지를 실행하면 루트 쉘을 얻을 수 있음(권한 상승).
* 최종적으로 /root/flag.txt 확인으로 플래그 획득에 성공.

***

추가 자료 및 참고 링크

* cybersploit\_css\_styles: ../misc/cybersploit\_css\_styles.md
* nikto 결과: ../security/nikto\_cybersploit2\_result.md
* GTFOBins docker: https://gtfobins.github.io/gtfobins/docker/

FAQ나 심화 절차를 따로 확장할 필요가 있으면 알려주세요.
