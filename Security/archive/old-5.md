# Webhacking.kr old 5: 난독화된 클라이언트 검사 우회

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ARC-004-TS |
| 유형 | TS (문제 풀이) |
| 목적 | 난독화된 자바스크립트가 요구하는 쿠키·URL 조건을 만족시켜 가입 폼에 접근한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱, 워게임 문제) |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이며 이 문서로 다시 풀어 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 난독화 해제 결과와 풀이가 모두 있었다. 문서 끝의 AI 응답 문구("제공해 주시면 이어서 분석해 드립니다")는 삭제했다.
{% endhint %}

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 이 문서는 의도적으로 취약하게 만든 워게임 문제의 학습용 풀이다.
{% endhint %}

## 1. 증상

| 항목 | 내용 |
|---|---|
| 대상 페이지 | `mem/join.php` |
| 화면 | 쿠키 또는 URL 조건이 맞지 않으면 알림창(`bye`, `access_denied`)이 뜨고 중단된다 |
| 목표 | 가입 폼(`id`, `pw`)이 출력되게 한다 |

## 2. 가능 원인

난독화를 해제한 스크립트는 다음 두 조건을 검사한다. 난독화에 쓴 문자 매핑(`l`은 `a`, `ll`은 `b` 등)은 원본에서 생략되어 있다.

```javascript
var requiredSubstring = "oldzombie";
var cookieExpr = "document.cookie";

if (eval(cookieExpr).indexOf(requiredSubstring) == -1) {
    alert('bye');
    throw "stop";
}

if (eval("document.URL").indexOf("mode=1") == -1) {
    alert('access_denied');
    throw "stop";
} else {
    document.write('<font size=2 color=white>Join</font><p>');
    document.write('.<p>.<p>.<p>.<p>.<p>');
    document.write('<form method=post action=join.php>');
    document.write('<table border=1><tr><td><font color=gray>id</font></td><td><input type=text name=id maxlength=20></td></tr>');
    document.write('<tr><td><font color=gray>pass</font></td><td><input type=text name=pw></td></tr>');
    document.write('<tr align=center><td colspan=2><input type=submit></td></tr></form></table>');
}
```

| 번호 | 취약점 | 설명 |
|---|---|---|
| 1 | 접근 통제를 클라이언트 쪽 문자열 검사로 한다 | 쿠키와 URL은 사용자가 마음대로 정한다 |
| 2 | 검사가 포함 여부(`indexOf`)뿐이다 | 값이 무엇이든 문자열만 들어 있으면 통과한다 |
| 3 | 난독화에 의존한다 | 난독화는 접근 통제가 아니며 해제할 수 있다 |

## 3. 격리 절차

1. (3-01) 주소에 `mode=1`을 추가한다. 예: `mem/join.php?mode=1`. → 결과: URL 조건이 만족된다. `mode=1`은 `?mode=1` 또는 `&mode=1` 형태로 정확히 들어가야 한다.
2. (3-02) 쿠키에 문자열 `oldzombie`가 포함되게 한다. 값은 무엇이든 상관없다. 개발자 도구 콘솔에서 다음을 실행하거나 `Application`(또는 `Storage`) > `Cookies`에서 직접 추가한다.

```javascript
document.cookie = "oldzombie=1; path=/";
```

3. (3-03) `mem/join.php?mode=1` 페이지를 새로고침한다. → 결과: 가입 폼이 표시된다.
4. (3-04) `id`와 `pw`를 입력해 제출한다. → 결과: `join.php`로 POST 요청이 전송된다.

## 4. 탐지·방어

이 절은 원본에 없던 일반 지식이며 미검증이다.

- 원인: 접근 통제 판단이 브라우저에서 실행되는 코드에 있다.
- 완화: 쿠키와 URL 검사는 서버에서 하고, 인증은 서버 세션으로 판정한다. 난독화는 보호 수단으로 보지 않는다.
- 로그 흔적: 접근 로그에 `mode=1`이 붙은 요청과 비정상적인 `Cookie` 값이 함께 나타난다.

## 참조

| 참조 문서 | 제목 |
|---|---|
| [webhacking.kr.md](../ctf-and-wargame/webhacking.kr.md) | Webhacking.kr 워게임 |


## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 보관 페이지 `old-5.md`를 AMM 형식(TS)으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 클라이언트 쪽 검사가 접근 통제가 될 수 없는 이유는 무엇인가?
- [ ] 난독화된 자바스크립트를 분석할 때 어떤 방법을 썼는가?
