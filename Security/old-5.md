# old 5

아래는 mem/join.php 에 포함된 자바스크립트 난독화를 해제한 내용과 풀이(해결 방법)입니다.

Deobfuscated 스크립트

```javascript
// 문자 매핑(원래 파일 상단에서 정의된 것들)
// l='a', ll='b', lll='c', llll='d', lllll='e', ...
// I='1', II='2', ... , li='.', 등

// 재조합된 문자열들
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

의미 요약 (원본 동작)

* 스크립트는 먼저 document.cookie에 "oldzombie"라는 문자열이 포함되어 있는지를 검사합니다. 포함되어 있지 않으면 "bye" 알림 후 중단됩니다.
* 그 다음 현재 URL(document.URL)에 "mode=1"이 포함되어 있는지를 검사합니다. 포함되어 있지 않으면 "access\_denied" 알림 후 중단됩니다.
* 두 조건을 모두 만족하면 회원가입 폼(아이디, 비밀번호)을 동적으로 출력합니다. 폼 action은 join.php (POST)이고, 필드명은 id 와 pw 입니다.

풀이(해결 방법)

{% stepper %}
{% step %}
### 1) URL에 mode=1 추가

주소창에서 mem/join.php 를 요청할 때 다음처럼 mode=1 파라미터를 추가합니다:

예) mem/join.php?mode=1
{% endstep %}

{% step %}
### 2) 쿠키에 required 문자열 추가

브라우저에 document.cookie 에 "oldzombie"가 포함되도록 쿠키를 추가합니다. 값은 무엇이든 상관없습니다. (예: oldzombie=1)

방법 예시 (개발자 도구 콘솔에서 실행):

```javascript
document.cookie = "oldzombie=1; path=/";
```

또는 브라우저 개발자도구 > Application (또는 Storage) > Cookies 에서 직접 추가해도 됩니다.
{% endstep %}

{% step %}
### 3) 페이지 새로고침 및 폼 제출

쿠키를 설정하고 mem/join.php?mode=1 페이지를 새로고침하면 가입 폼이 보입니다. id 와 pw 를 입력 후 제출하면 join.php로 POST 요청이 전송됩니다.
{% endstep %}
{% endstepper %}

힌트

{% hint style="info" %}
* 검사 조건은 단순 문자열 포함 여부(indexOf)입니다. 쿠키에 정확히 oldzombie 라는 문자열만 포함하면 됩니다.
* URL에는 정확히 "mode=1"이 포함되어야 합니다 (예: ?mode=1 또는 \&mode=1).
{% endhint %}

원문에서 중요한 점만 보존했습니다. 추가로 join.php(서버 측) 코드가 필요하다면 제공해 주시면 이어서 분석해 드립니다.
