# Webhacking.kr old 16: 키 입력 이벤트 분석

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-007-TS |
| 유형 | TS (문제 풀이) |
| 목적 | 키 입력으로 별(`*`) 문자를 움직이는 문제의 클라이언트 코드를 정리한다 |
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
| 화면 | 검은 배경에 노란 별(`*`)이 표시되고 키 입력에 반응한다 |
| 목표 | 원본에 적혀 있지 않다. 코드의 주석 `// do it!`이 가리키는 분기를 실행하는 것이 목표로 보인다 |

## 2. 가능 원인

| 번호 | 관찰 | 근거 코드 |
|---|---|---|
| 1 | 키 코드에 따라 별의 위치가 50픽셀씩 움직인다 | `cd==100`(오른쪽), `97`(왼쪽), `119`(위), `115`(아래) |
| 2 | 키 코드가 124이면 `String.fromCharCode(cd)+".php"` 주소로 이동한다 | `if(cd==124) location.href=...` |
| 3 | 마우스를 올리면 생성된 별이 지워진다 | `onmouseover=this.innerHTML=''` |

## 3. 격리 절차

원본의 클라이언트 코드(`challenge16.html`)는 다음과 같다.

{% code title="challenge16.html" %}
```html
<html>
<head>
<title>Challenge 16</title>
<body bgcolor=black onload=kk(1,1) onkeypress=mv(event.keyCode)>
<font color=silver id=c></font>
<font color=yellow size=100 style=position:relative id=star>*</font>
<script> 
document.body.innerHTML+="<font color=yellow id=aa style=position:relative;left:0;top:0>*</font>";
function mv(cd){
  kk(star.style.left-50,star.style.top-50);
  if(cd==100) star.style.left=parseInt(star.style.left+0,10)+50+"px";
  if(cd==97) star.style.left=parseInt(star.style.left+0,10)-50+"px";
  if(cd==119) star.style.top=parseInt(star.style.top+0,10)-50+"px";
  if(cd==115) star.style.top=parseInt(star.style.top+0,10)+50+"px";
  if(cd==124) location.href=String.fromCharCode(cd)+".php"; // do it!
}
function kk(x,y){
  rndc=Math.floor(Math.random()*9000000);
  document.body.innerHTML+="<font color=#"+rndc+" id=aa style=position:relative;left:"+x+";top:"+y+" onmouseover=this.innerHTML=''>*</font>";
}
</script>
</body>
</html>
```
{% endcode %}

원본에는 풀이 과정이 없다.

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 이동 대상 주소와 조건이 클라이언트 코드에 노출된다.
- 완화: 접근 가능한 페이지는 서버에서 인증·권한으로 통제하고, 주소를 숨기는 것에 의존하지 않는다.
- 로그 흔적: 일반 화면 흐름에서 거치지 않는 `.php` 주소로 직접 요청이 들어온다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-16.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 이 코드에서 키 코드 124는 어떤 문자에 대응하는가?
- [ ] 클라이언트 코드에 노출된 주소를 보호하려면 서버에서 무엇을 해야 하는가?
