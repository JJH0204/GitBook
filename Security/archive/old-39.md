# Webhacking.kr old 39: 문자열 길이 제한과 SQL 이스케이프

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-010-TS |
| 유형 | TS (문제 풀이) |
| 목적 | 이스케이프 처리 뒤에 길이를 자르는 서버 코드의 처리 순서를 정리한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱, 워게임 문제) |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 문서로 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본이 단편이다. 풀이 과정이 적혀 있지 않아 원본에 있는 내용만 구조화했고, 없는 내용은 지어 쓰지 않았다. 풀이 입력은 원본에 한 줄(`1 '`)만 있다. 원본 코드의 질의 문자열에서 닫는 부분(`}'"`)이 빠져 있어 정정했다.
{% endhint %}

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 문서는 의도적으로 취약하게 만든 워게임 문제의 학습용 풀이다.
{% endhint %}

## 1. 증상

| 항목 | 내용 |
|---|---|
| 화면 | `id` 입력란(최대 15자)과 제출 버튼이 표시된다 |
| 목표 | 질의 결과의 첫 열이 `1`이 되게 해 `solve(39)`가 호출되게 한다 |

## 2. 가능 원인

| 번호 | 처리 | 근거 코드 |
|---|---|---|
| 1 | 백슬래시를 제거한다 | `str_replace("\\","",...)` |
| 2 | 작은따옴표를 두 개로 바꾼다(이스케이프) | `str_replace("'","''",...)` |
| 3 | 그 뒤에 앞 15자만 남긴다 | `substr(...,0,15)` |
| 4 | 질의 조건에 `length(id)<14`가 있다 | `select 1 from member where length(id)<14 and id='...'` |

처리 순서(이스케이프 뒤에 길이 제한)가 취약점의 원인이다.

서버 코드(`index.php`)는 다음과 같다.

{% code title="index.php" %}
```php
<?php  include "../../config.php";  
  if($_GET['view_source']) view_source();  
?><html>  
<head>  
<title>Chellenge 39</title>  
</head>  
<body>  
<?php  
  $db = dbconnect();  
  if($_POST['id']){    $_POST['id'] = str_replace("\\","",$_POST['id']);    $_POST['id'] = str_replace("'","''",$_POST['id']);    $_POST['id'] = substr($_POST['id'],0,15);    $result = mysqli_fetch_array(mysqli_query($db,"select 1 from member where length(id)<14 and id='{$_POST['id']}'"));  
    if($result[0] == 1){      solve(39);  
    }  
  }  
?>  
<form method=post action=index.php>  
<input type=text name=id maxlength=15 size=30>  
<input type=submit>  
</form>  
<a href=?view_source=1>view-source</a>  
</body>  
</html>
```
{% endcode %}

## 3. 격리 절차

원본에는 입력 후보로 다음 한 줄만 적혀 있다.

```
1 '
```

이 입력이 위 처리 순서에서 어떻게 동작하는지, 최종 질의가 무엇인지는 원본에 없다. 풀이 과정은 기록되어 있지 않다.

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 이스케이프 이후에 문자열을 자르면 이스케이프가 깨질 수 있다.
- 완화: 매개변수화된 질의(prepared statement)를 쓴다. 입력 길이는 DB에 넣기 전, 이스케이프 이전에 검사한다.
- 로그 흔적: `id` 값에 작은따옴표가 포함된 POST 요청이 반복되고, SQL 오류나 비정상적인 로그인 성공이 기록된다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-39.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이스케이프 처리와 길이 제한의 순서를 바꾸면 왜 결과가 달라지는가?
- [ ] 문자열을 이어 붙인 SQL을 매개변수화된 질의로 바꾸면 무엇이 달라지는가?
