# fakerWEB 워게임 풀이

{% stepper %}
{% step %}
### 초기 탐색

* ./faker/home/ 접속
* ./faker/home/... (접근 가능한 다른 디렉터리 유무 확인)
* robots.txt 발견
{% endstep %}

{% step %}
### robots.txt 및 파일 확인

* robots.txt 접근
* ./home/wordList.txt 존재 확인
{% endstep %}

{% step %}
### 단서 파일 열람

* ./wordList.txt 접근
  * 계정 리스트 혹은 패스워드 리스트로 유추되는 텍스트 리스트를 확인
{% endstep %}

{% step %}
### 브루트포스 공격 준비 및 실행 (Burp Suite)

* Burp Suite Proxy 사용
* 브라우저의 요청 패킷 내용을 Intruder로 보낸다.
  * payload set 추가 (username, password)
  * attack type 선택 (cluster bomb 추천)
  * payload set 1, 2 각각 simple list 추가 (wordList.txt copy/paste)
* start attack
* fakergoat:F4k3r1996! 발견
* 관리자 페이지 접속 성공
{% endstep %}

{% step %}
### 워게임 서비스 관련 주의 및 분리

* 서비스 중인 웹에 CTF 형식의 워게임을 업로드하는 것은 위험하다.
  * 한번만 서비스 할 수 있다. (다수의 사용자에게 서비스 하기에 적합하지 않다.)
  * 서비스 중인 다른 워게임 문제에 영향을 줄 수 있다. (의도와 다르게 서비스 자체를 공격받을 수 있다.)
* CTF 형식의 워게임을 서비스하기 위해서는 웹 서비스와 워게임 문제를 분리할 필요가 있다.
  * Docker!!!

링크: https://chatgpt.com/share/6744a431-54f4-8004-8957-d98f5bc4fce5
{% endstep %}
{% endstepper %}

***

## 시나리오: 웹 관리자 페이지 취약점을 공략해 플래그 획득하기

이 시나리오는 학습 목적에 맞게 서버 취약점 및 탐색 과정을 체계적으로 익히게 해줍니다.

{% stepper %}
{% step %}
### 관리자 페이지 접속

* 참가자가 브루트 포스 공격을 통해 관리자 계정(`admin`)과 비밀번호를 알아내고 관리자 페이지에 성공적으로 접속합니다.
{% endstep %}

{% step %}
### 이미지 업로드 기능 탐색

* 관리자 페이지에서 이미지 업로드 기능을 발견합니다. 이는 이미지를 서버에 업로드한 뒤 URL로 액세스할 수 있도록 설계되어 있습니다.
* 참가자는 이 기능이 파일 업로드 취약점(예: 확장자 우회 또는 MIME 타입 조작)에 노출되었는지 확인합니다.
{% endstep %}

{% step %}
### 파일 업로드 취약점 공략

* 목표: PHP 웹 셸(`shell.php`) 또는 악성 스크립트를 업로드하여 서버에서 실행 가능하게 만듦.
* 참가자가 아래 방법으로 취약점을 공략합니다:
  * 파일 이름 확장자를 `.php.jpg`로 설정하여 서버의 필터를 우회.
  * MIME 타입을 변경하거나 서버의 콘텐츠 타입 검사를 우회.
  * 업로드된 파일 URL을 통해 직접 실행하여 코드 실행 권한 확보.
{% endstep %}

{% step %}
### 서버 내부 정보 확인

* 업로드된 웹 셸을 통해 서버의 디렉터리 구조를 탐색합니다:
  * `/var/www/html/flag.txt` 같은 플래그 파일 위치를 확인.
  * 또는, 데이터베이스 접근 정보를 포함한 구성 파일을 찾음(예: `config.php`).
{% endstep %}

{% step %}
### 플래그 획득

* 참가자가 서버 내부에서 플래그 파일을 열어 플래그 문자열을 확인합니다:
  * 파일 접근: `cat /var/www/html/flag.txt`.
  * 또는 데이터베이스 쿼리를 통해 플래그를 추출.
  * 예: `SELECT * FROM flags WHERE id=1;`.
{% endstep %}
{% endstepper %}

***

### 추가적인 난이도 요소

1. 디렉터리 탐색 제한
   * 참가자가 웹 셸을 통해 탐색할 수 있는 디렉터리 경로를 제한.
   * 플래그 파일의 경로를 특정 로직을 통해 유추하도록 설계.
2. 플래그 암호화
   * 플래그가 암호화되어 있고, 복호화 키가 특정 서버 환경 변수나 파일(`key.env`)에 숨겨져 있음.
   * 예: 암호화된 플래그를 복호화하기 위해 `openssl` 명령을 사용하도록 유도.
3. WAF 탐지 우회
   * 참가자가 업로드된 파일을 실행하려고 할 때, WAF(Web Application Firewall)가 URL 호출을 차단.
   * WAF 탐지 우회를 위한 특수 요청 패턴을 설계.
4. 추가 액세스 권한 상승
   * 업로드된 웹 셸로 루트 권한을 획득하기 위해 취약한 SUID 파일 또는 잘못된 권한 설정된 디렉터리를 공략.

***

### 시나리오 플로우 예시

{% stepper %}
{% step %}
참가자가 관리자 페이지 접속 → 이미지 업로드 기능 발견.
{% endstep %}

{% step %}
파일 업로드 취약점으로 PHP 웹 셸 업로드 → 실행 성공.
{% endstep %}

{% step %}
서버 탐색 → `/flag` 디렉터리 발견.
{% endstep %}

{% step %}
`flag.txt` 또는 데이터베이스 쿼리를 통해 플래그 확인.
{% endstep %}

{% step %}
플래그 입력 → 성공 메시지와 함께 다음 단계 안내.
{% endstep %}
{% endstepper %}

***

### 플래그 제출 시 유의사항

* 플래그는 난수 문자열이나 특정 포맷(`FLAG-{난수}`)으로 제공.
* 워게임 서버는 제출된 플래그를 확인하여 정답 여부를 평가하고 다음 단계로 진행.

***

### 참고 링크

* [Docker\_Hub](https://krjaeh0.gitbook.io/j-log/cloud/cloud-devops/docker/docker_hub)
