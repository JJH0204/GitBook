# OWASP Juice Shop 실습 풀이

{% hint style="info" %}
{% endhint %}

### 요약 (텍스트 요소)

* OWASP JuiceShop 서비스를 모의 해킹 하며 웹 보안 점검 사항들을 숙지한다.
* dirb http://192.168.56.142:3000/
* dirb 툴로 접근 가능한 웹 디렉터리를 점검하면 에러가 생성되며 웹 서비스가 종료된다.
* http://192.168.56.142:3000/ftp
* gobuster 명령어가 정상적으로 동작하지 않는다.
* nikto -h 192.168.56.142 -port 3000 -root / -C all
* 회원 가입 후 추가 페이지를 확인함
* http://192.168.27.4:3000/#/score-board
* email : ' or 1=1 --
* 숨겨진 페이지 찾기
* 로그인 페이지 취약점
* ' or 1=1 and email not like('%admin%');--
* ' or 1=1 and email like('%bender%');--
* 자바 스크립트 입력에도 검색창이 아무 반응이 없다. (인코딩해서 입력해보자)
* %3Cscript%3Ealert(%22XSS1%22)%3C%2Fscript%3E
* HTML 인코딩 확인
* 스크립트 정상 출력
* WAF 우회 스크립트 확인
* \<img src=x onerror=alert('XSS1')>
* 얼럿 팝업이 활성화 되는 것을 확인
* 검색 창에 XSS 취약점이 존재하는 것을 확인\
  WAF로 잘 알려진 XSS 를 차단 했지만 근본 원인을 해결하지 않았음을 알 수 있다.
* 회원 가입 시도
* 로그인 시도 페킷을 proxy로 잡아서 확인
* 관리자 권한을 얻기 위한 필드 추가
* https://github.com/juice-shop/juice-shop/blob/master/SOLUTIONS.md
* https://github.com/Whyiest/Juice-Shop-Write-up?tab=readme-ov-file
* 임의의 사용자 계정을 생성하고 로그인 한다.
* Proxy 활성화
* 사용자 이름을 변경하기 위해 입력 필드에 원하는 문자열 입력
* 'Set Username' 버튼을 클릭하고 요청 정보 확인

### 요청 / 패킷 예시

요청 헤더/바디 예시(가로챈 프로필 변경 요청):

{% code title="Captured request" %}
```
```
{% endcode %}

요청/쿠키로부터 확인 가능한 내용:

* 서비스 요청 도메인(IP)과 요청 방식 식별 가능
* 토큰 정보로 사용자를 식별하고 서비스를 제공하는 대상에 적용되는 것으로 보임

추정 가능한 Cookie 기능:

* 사용자 세션 유지: token
* 사용자 진행 상태 복원: continueCode
* 다국어 지원: language
* 쿠키 동의 상태 관리: cookieconsent\_status

### 서버 응답(예시 JSON)

{% code title="Response JSON" %}
```
```
{% endcode %}

* "admin으로 변경하면 어떻게 될까?" — 텍스트상 아이디어 제시
* 로그인 또는 회원 가입 시 role을 조작하는 방식으로 권한 상승 시도 가능
* 회원가입 시 서버에 요청하는 데이터를 가로채어 {"role":"admin",} 추가 후 Forward → 관리자 계정 생성 성공(기록됨)

### 참고 링크 / 파일

* Element Links: Juiceshop\_main.js → Juiceshop.md
