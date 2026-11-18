# Webhacking.kr old 4: 반복 해시와 사전 계산 표

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-003-TS |
| 유형 | TS (문제 풀이) |
| 목적 | SHA-1을 500회 반복한 값에서 원문을 찾기 위해 사전 계산 표를 만드는 접근을 정리한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱, 워게임 문제) |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 문서로 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 "레인보우 테이블?"은 의문형 메모이며 풀이 결과가 없다. 아래 스크립트의 출력 파일 이름은 병렬 프로세스가 서로 덮어쓰는 문제가 있어 프로세스별 파일로 정정했다(확인 필요 참조).
{% endhint %}

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 문서는 의도적으로 취약하게 만든 워게임 문제의 학습용 풀이다.
{% endhint %}

## 1. 증상

| 항목 | 내용 |
|---|---|
| 화면 | 해시 문자열 한 개와 `Password` 입력란이 표시된다 |
| 목표 | 표시된 해시의 원문을 입력해 `solve(4)`가 호출되게 한다 |

## 2. 가능 원인

| 번호 | 취약점 | 근거 코드 |
|---|---|---|
| 1 | 원문의 공간이 작다. 8자리 숫자 뒤에 고정 문자열 `salt_for_you`를 붙인다 | `rand(10000000,99999999)."salt_for_you"` |
| 2 | 솔트가 고정값이라 사전 계산이 가능하다 | 같은 코드 |
| 3 | 반복 횟수(500회)가 연산량을 늘릴 뿐 공간을 늘리지 않는다 | `for($i=0;$i<500;$i++) $hash = sha1($hash)` |

## 3. 격리 절차

원본의 서버 코드(`challenge4.php`)는 다음과 같다.

{% code title="challenge4.php" %}
```php
<?php  include "../../config.php";  
  if($_GET['view-source'] == 1) view_source();  
?><html>  
<head>  
<title>Challenge 4</title>  
<style type="text/css">  
body { background:black; color:white; font-size:9pt; }  
table { color:white; font-size:10pt; }  
</style>  
</head>  
<body><br><br>  
<center>  
<?php  
  sleep(1); // anti brute force
  if((isset($_SESSION['chall4'])) && ($_POST['key'] == $_SESSION['chall4'])) solve(4);  $hash = rand(10000000,99999999)."salt_for_you";  $_SESSION['chall4'] = $hash;  
  for($i=0;$i<500;$i++) $hash = sha1($hash);  
?><br>  
<form method=post>  
<table border=0 align=center cellpadding=10>  
<tr><td colspan=3 style=background:silver;color:green;><b><?=$hash?></b></td></tr>  
<tr align=center><td>Password</td><td><input name=key type=text size=30></td><td><input type=submit></td></tr>  
</table>  
</form>  
<a href=?view-source=1>[view-source]</a>  
</center>  
</body>  
</html>
```
{% endcode %}

원본의 접근 방법은 후보 원문 전체를 미리 계산해 표로 만드는 것이다. 후보 범위는 10000000부터 99999999까지다. 원본의 계산 스크립트는 다음과 같다(출력 파일 이름만 정정했다).

{% code title="generate_table.py" %}
```python
from hashlib import *

from multiprocessing import *

def create(num):

    start = 10000000*num

    end = 10000000*(num+1)

    f = open(f'table_{num}.csv', mode = 'w', encoding = 'utf-8')

    for i in range(start, end):

        txt = str(i) + "salt_for_you"

        result = txt

        for j in range(0, 500):

            result = sha1(result.encode('utf-8')).hexdigest()

        print(result)

        f.write(f'{txt} ======> result : {result}\n')

    f.close()

  
if __name__ == '__main__':

    procs = []

    for i in range(1, 10):

        proc = Process(target = create, args = (i,))

        procs.append(proc)

        proc.start()

  
    for proc in procs:

        proc.join()
```
{% endcode %}

1. (3-01) 화면의 해시를 기록한다.
2. (3-02) 계산한 표에서 그 해시를 찾아 원문을 확인한다.
3. (3-03) 원문을 `Password`에 입력한다.

{% hint style="warning" %}
CAUTION: 후보가 약 9천만 개이고 후보마다 SHA-1을 500회 계산한다. 실행 시간과 디스크 용량을 먼저 추정한다. 이 문서는 실행해 확인하지 않았다.
{% endhint %}

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 원문 공간이 작고 솔트가 고정이다.
- 완화: 요청마다 서로 다른 무작위 솔트와 충분히 긴 비밀값을 쓴다. 비밀번호 저장에는 bcrypt, scrypt, Argon2 같은 전용 해시를 쓴다.
- 로그 흔적: 같은 세션에서 `key` 값을 바꿔 반복 제출한다. 서버가 `sleep(1)`을 걸어 두었으므로 요청 간격이 1초 이상으로 일정하다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-4.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 솔트(salt)는 무엇을 막기 위한 것이고, 고정 솔트는 왜 약한가?
- [ ] 해시를 500회 반복하는 것은 왜 원문 공간 문제를 해결하지 못하는가?
