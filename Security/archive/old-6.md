# Webhacking.kr old 6: 반복 Base64 쿠키 조작

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-005-TS |
| 유형 | TS (문제 풀이) |
| 목적 | 쿠키 `user`와 `password`에 20회 Base64와 문자 치환을 적용한 값을 만들어 관리자 값으로 바꾼다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱, 워게임 문제) |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 문서로 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 영문 설명은 한국어로 옮겼다. 코드와 스크립트는 원본 그대로다.
{% endhint %}

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 문서는 의도적으로 취약하게 만든 워게임 문제의 학습용 풀이다.
{% endhint %}

## 1. 증상

| 항목 | 내용 |
|---|---|
| 화면 | `ID : <복호화 결과>`와 `PW : <복호화 결과>`가 표시된다 |
| 목표 | 복호화 결과가 ID `admin`, PW `nimda`가 되게 해 `solve(6)`이 호출되게 한다 |

## 2. 가능 원인

| 번호 | 취약점 | 설명 |
|---|---|---|
| 1 | 인증 정보를 쿠키에 저장하고 그대로 신뢰한다 | 쿠키는 사용자가 수정할 수 있다 |
| 2 | 인코딩을 보호 수단으로 쓴다 | Base64와 문자 치환은 암호화가 아니며 가역이다 |

서버는 기본값(`guest`, `123qwe`)을 다음 두 단계로 변환해 쿠키에 넣는다.

- 문자열을 Base64로 20회 반복 인코딩한다.
- 숫자 1~8을 특수문자로 치환한다: 1은 `!`, 2는 `@`, 3은 `$`, 4는 `^`, 5는 `&`, 6은 `*`, 7은 `(`, 8은 `)`.

서버 코드(`index.php`)는 다음과 같다.

{% code title="index.php" %}
```php
<?php  
include "../../config.php";  
if($_GET['view_source']) view_source();  
if(!$_COOKIE['user']){  $val_id="guest";  $val_pw="123qwe";  
  for($i=0;$i<20;$i++){    $val_id=base64_encode($val_id);    $val_pw=base64_encode($val_pw);  
  }  $val_id=str_replace("1","!",$val_id);  $val_id=str_replace("2","@",$val_id);  $val_id=str_replace("3","$",$val_id);  $val_id=str_replace("4","^",$val_id);  $val_id=str_replace("5","&",$val_id);  $val_id=str_replace("6","*",$val_id);  $val_id=str_replace("7","(",$val_id);  $val_id=str_replace("8",")",$val_id);  $val_pw=str_replace("1","!",$val_pw);  $val_pw=str_replace("2","@",$val_pw);  $val_pw=str_replace("3","$",$val_pw);  $val_pw=str_replace("4","^",$val_pw);  $val_pw=str_replace("5","&",$val_pw);  $val_pw=str_replace("6","*",$val_pw);  $val_pw=str_replace("7","(",$val_pw);  $val_pw=str_replace("8",")",$val_pw);  Setcookie("user",$val_id,time()+86400,"/challenge/web-06/");  Setcookie("password",$val_pw,time()+86400,"/challenge/web-06/");  
  echo("<meta http-equiv=refresh content=0>");  
  exit;  
}  
?>  
<html>  
<head>  
<title>Challenge 6</title>  
<style type="text/css">  
body { background:black; color:white; font-size:10pt; }  
</style>  
</head>  
<body>  
<?php  
$decode_id=$_COOKIE['user'];  
$decode_pw=$_COOKIE['password'];  
  
$decode_id=str_replace("!","1",$decode_id);  
$decode_id=str_replace("@","2",$decode_id);  
$decode_id=str_replace("$","3",$decode_id);  
$decode_id=str_replace("^","4",$decode_id);  
$decode_id=str_replace("&","5",$decode_id);  
$decode_id=str_replace("*","6",$decode_id);  
$decode_id=str_replace("(","7",$decode_id);  
$decode_id=str_replace(")","8",$decode_id);  
  
$decode_pw=str_replace("!","1",$decode_pw);  
$decode_pw=str_replace("@","2",$decode_pw);  
$decode_pw=str_replace("$","3",$decode_pw);  
$decode_pw=str_replace("^","4",$decode_pw);  
$decode_pw=str_replace("&","5",$decode_pw);  
$decode_pw=str_replace("*","6",$decode_pw);  
$decode_pw=str_replace("(","7",$decode_pw);  
$decode_pw=str_replace(")","8",$decode_pw);  
  
for($i=0;$i<20;$i++){  $decode_id=base64_decode($decode_id);  $decode_pw=base64_decode($decode_pw);  
}  
  
echo("<hr><a href=./?view_source=1 style=color:yellow;>view-source</a><br><br>");  
echo("ID : $decode_id<br>PW : $decode_pw<hr>");  
  
if($decode_id=="admin" && $decode_pw=="nimda"){  solve(6);  
}  
?>  
</body>  
</html>
```
{% endcode %}

## 3. 격리 절차

서버는 쿠키를 거꾸로 변환(특수문자를 숫자로 되돌린 뒤 Base64 20회 디코딩)해 ID와 PW를 얻는다. 따라서 `admin`과 `nimda`에 같은 변환을 적용한 값을 쿠키로 넣으면 된다. 변환 스크립트는 다음과 같다.

{% code title="encode.py" %}
```python
import base64

def multi_base64_encode(input_string, times=20):
    encoded = input_string.encode()
    for _ in range(times):
        encoded = base64.b64encode(encoded)
    return encoded.decode()

def replace_special_characters(encoded_string):
    replacements = {
        "1": "!",
        "2": "@",
        "3": "$",
        "4": "^",
        "5": "&",
        "6": "*",
        "7": "(",
        "8": ")"
    }
    for key, value in replacements.items():
        encoded_string = encoded_string.replace(key, value)
    return encoded_string

# 입력 받기
input_string = input()

# 20번 base64 인코딩하기
result = multi_base64_encode(input_string)

# 특수문자로 치환하기
result = replace_special_characters(result)

# 결과 출력
print("20번 인코딩된 결과:")
print(result)
```
{% endcode %}

1. (3-01) 스크립트를 실행하고 `admin`을 입력한다. → 결과: ID 쿠키에 쓸 변환값이 출력된다.
2. (3-02) 스크립트를 다시 실행하고 `nimda`를 입력한다. → 결과: PW 쿠키에 쓸 변환값이 출력된다.
3. (3-03) 브라우저 개발자 도구(`Application` 또는 `Storage` > `Cookies`)나 HTTP 클라이언트로 경로 `/challenge/web-06/`의 쿠키를 설정한다. 쿠키 `user`에는 3-01의 값을, 쿠키 `password`에는 3-02의 값을 넣는다.
4. (3-04) 페이지를 새로고침한다. → 결과: 복호화 결과가 `admin`과 `nimda`이면 `solve(6)`이 호출된다.

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 인코딩과 암호화를 혼동하고, 인증 상태를 클라이언트가 보관한다.
- 완화: 인증 정보를 쿠키에 담지 않고 서버 세션과 무작위 세션 식별자를 쓴다. 변조를 막아야 하는 값에는 서버 비밀키 기반 서명(HMAC)을 붙인다.
- 로그 흔적: 접근 로그의 `Cookie` 헤더가 정상 발급값과 다른 길이로 나타난다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-6.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인코딩, 암호화, 해시는 무엇이 다른가?
- [ ] 쿠키에 담긴 값의 변조를 막으려면 어떤 방법이 있는가?
