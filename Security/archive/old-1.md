# Webhacking.kr old 1: 쿠키 값 검사 분석

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-001-TS |
| 유형 | TS (문제 풀이) |
| 목적 | 쿠키 `user_lv` 값으로 레벨을 판정하는 문제의 서버 코드를 정리한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱, 워게임 문제) |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 문서로 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본이 단편이다. 풀이 과정이 적혀 있지 않아 원본에 있는 내용만 구조화했고, 없는 내용은 지어 쓰지 않았다. 풀이는 원본에 없다.
{% endhint %}

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 문서는 의도적으로 취약하게 만든 워게임 문제의 학습용 풀이다.
{% endhint %}

## 1. 증상

| 항목 | 내용 |
|---|---|
| 문제 | Webhacking.kr old 1 |
| 화면 | 검은 배경에 `level : <값>`이 표시된다 |
| 목표 | 서버 코드가 `solve(1)`을 호출하게 만든다 |

## 2. 가능 원인

| 번호 | 취약점 | 근거 코드 |
|---|---|---|
| 1 | 권한 수준을 클라이언트가 보내는 쿠키 `user_lv`로 판정한다 | `$_COOKIE['user_lv']` |
| 2 | 값 검증이 숫자 여부와 크기 비교뿐이다 | `is_numeric`, `>=4`, `>3` 비교 |

## 3. 격리 절차

원본의 서버 코드(`challenge1.php`)는 다음과 같다.

{% code title="challenge1.php" %}
```php
<?php  include "../../config.php";  
  if($_GET['view-source'] == 1){ view_source(); }  
  if(!$_COOKIE['user_lv']){    SetCookie("user_lv","1",time()+86400*30,"/challenge/web-01/");  
    echo("<meta http-equiv=refresh content=0>");  
  }  
?>  
<html>  
<head>  
<title>Challenge 1</title>  
</head>  
<body bgcolor=black>  
<center>  
<br><br><br><br><br>  
<font color=white>  
---------------------<br>  
<?php  if(!is_numeric($_COOKIE['user_lv'])) $_COOKIE['user_lv']=1;  
  if($_COOKIE['user_lv']>=4) $_COOKIE['user_lv']=1;  
  if($_COOKIE['user_lv']>3) solve(1);  
  echo "<br>level : {$_COOKIE['user_lv']}";  
?>  
<br>  
<a href=./?view-source=1>view-source</a>  
</body>  
</html>
```
{% endcode %}

코드의 검사 순서는 다음과 같다.

1. (3-01) 쿠키 `user_lv`가 없으면 값 `1`로 쿠키를 설정한다.
2. (3-02) 쿠키 값이 숫자가 아니면 `1`로 바꾼다.
3. (3-03) 쿠키 값이 4 이상이면 `1`로 바꾼다.
4. (3-04) 쿠키 값이 3보다 크면 `solve(1)`을 호출한다.

원본에는 이 조건을 만족시키는 값과 풀이 과정이 적혀 있지 않다.

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 권한 수준을 사용자가 수정할 수 있는 쿠키로 판정한다.
- 완화: 권한 수준은 서버 세션에 저장하고 쿠키에는 추측할 수 없는 세션 식별자만 둔다. 검사는 한 번의 일관된 비교로 쓴다.
- 로그 흔적: 접근 로그의 `Cookie` 헤더에 정상 범위를 벗어난 `user_lv` 값이 나타난다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-1.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 쿠키를 서버 판단의 근거로 쓰면 왜 위험한가?
- [ ] 원본 코드의 세 가지 검사 조건 사이에서 어색한 점은 무엇인가?
