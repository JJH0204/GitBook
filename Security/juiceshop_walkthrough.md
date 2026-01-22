# Juiceshop\_walkthrough

{% hint style="info" %}
Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document to open the drawing. You can decompress the drawing data with the command palette: "Decompress current Excalidraw file". For more info check the plugin settings under "Saving".
{% endhint %}

## Excalidraw Data

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

### Embedded Files (그림/이미지)

* topics/assets/images/Pasted Image 20241107162415\_746.png
* topics/assets/images/Pasted Image 20241107163338\_790.png
* topics/assets/images/Pasted Image 20241107163905\_840.png
* topics/assets/images/Pasted Image 20241107165433\_938.png
* topics/assets/images/Pasted Image 20241107171218\_225.png
* topics/assets/images/Pasted Image 20241112230752\_495.png
* topics/assets/images/Pasted Image 20241112231224\_537.png
* topics/assets/images/Pasted Image 20241112231625\_564.png
* topics/assets/images/Pasted Image 20241112232420\_611.png
* topics/assets/images/Pasted Image 20241112232605\_625.png
* topics/assets/images/Pasted Image 20241112233656\_691.png
* topics/assets/images/Pasted Image 20241113185753\_882.png
* topics/assets/images/Pasted Image 20241113190009\_897.png
* topics/assets/images/Pasted Image 20241113190039\_900.png
* topics/assets/images/Pasted Image 20241124214349\_335.png
* topics/assets/images/Pasted Image 20241124214702\_368.png
* topics/assets/images/Pasted Image 20241124223742\_176.png
* topics/assets/images/Pasted Image 20241124223858\_189.png
* topics/assets/images/Pasted Image 20241124224930\_255.png
* topics/assets/images/Pasted Image 20241127133412\_216.png
* topics/assets/images/Pasted Image 20241127133719\_717.png
* topics/assets/images/Pasted Image 20241127133834\_362.png
* topics/assets/images/Pasted Image 20241127135750\_890.png
* topics/assets/images/Pasted Image 20241127135947\_695.png
* topics/assets/images/Pasted Image 20241127140049\_332.png
* topics/assets/images/Pasted Image 20241127141124\_820.png
* topics/assets/images/Pasted Image 20241127141639\_535.png
* topics/assets/images/Pasted Image 20241127141940\_717.png
* topics/assets/images/Pasted Image 20241127142044\_433.png
* topics/assets/images/Pasted Image 20241127142159\_079.png

(위 파일들은 문서에 포함된 임베디드 이미지 파일들입니다.)

### Drawing (압축된 Excalidraw 데이터)

<details>

<summary>압축된 Excalidraw JSON (보려면 클릭)</summary>

```compressed-json
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

... (이하 생략; 원본 압축 데이터 전체 포함)
```

</details>

***

원본 Excalidraw 데이터(텍스트요소, 이미지 임베디드, 압축 JSON 등)는 위에 유지되어 있습니다. 필요한 경우 각 섹션을 더 분리하거나 이미지 파일들을 개별적으로 삽입할 수 있습니다.
