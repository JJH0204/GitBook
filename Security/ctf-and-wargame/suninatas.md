# suninatas

a = aad\
i = in

```javascript
function chk_form(){
	var id = document.web02.id.value ;
	var pw = document.web02.pw.value ;
	if ( id == pw )
	{
		alert("You can't join! Try again");
		document.web02.id.focus();
		document.web02.id.value = "";
		document.web02.pw.value = "";
	}
	else
	{
		document.web02.submit();
	}
}
```

유저가 입력할 때는 아이디와 패스워드가 같으면 안되는데 결과를 계산할 때는 같아야 한다.\
프록시 툴을 이용해 입력은 다르게 결과는 같게 바꾸면 해결된다.

{% stepper %}
{% step %}
### 리피터(반복 자동화)

리피터를 사용해 반복작업을 자동화
{% endstep %}

{% step %}
### 난독화된 자바스크립트 해석

원본 난독화 코드:

{% code title="obfuscated.js" %}
```
```
{% endcode %}

```javascript
eval(function(p,a,c,k,e,r){e=function(c){return c.toString(a)};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return p}('g l=m o(\'0\',\'1\',\'2\',\'3\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\',\'a\',\'b\',\'c\',\'d\',\'e\',\'f\');p q(n){g h=\'\';g j=r;s(g i=t;i>0;){i-=4;g k=(n>>i)&u;v(!j||k!=0){j=w;h+=l[k]}}x(h==\'\'?\'0\':h)}',34,34,'||||||||||||||||var|result||start|digit|digitArray|new||Array|function|PASS|true|for|32|0xf|if|false|return'.split('|'),0,{}))
```

디코딩 후:

{% code title="deobfuscated.js" %}
```
```
{% endcode %}

```javascript
var digitArray=new Array('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
function PASS(n)
{
	var result='';
	var start=true;
	for(var i=32;
	i>0;
	)
	{
		i-=4;
		var digit=(n>>i)&0xf;
		if(!start||digit!=0)
		{
			start=false;
			result+=digitArray[digit]
		}
	}
	return(result==''?'0':result)
}
```
{% endstep %}

{% step %}
### SQL Injection 기초 및 활용

SQL Injection - 쿼리에 대해 참인 결과 값을 이용해 DB의 응답을 유발하는 공격

특수 문자:

* ': 문자 데이터 구분 기호
* ;: 쿼리 구분 기호
* \--, #: 해당 라인 주석 기호
* /\* \*/: /\*와 \*/사이 구문 주석 기호

예시 페이로드:

* 'or 1=1 --
* 'or 1 like 1 --
* 'or 1=1 #
* 'or 2>1 --
* DB에서 잘못된 쿼리에도 반응하는 것을 알 수 있다.

입력 예: ' or 1 like 1

문자열 힌트: suninatastopofworld!

hash를 md5로 설정하고 해싱

이후 페이지 소스를 보면 다른 힌트를 얻을 수 있다.
{% endstep %}

{% step %}
### 빠른 스크롤/키보드 이벤트 우회

스크롤을 빨리 내려서 yes 를 눌러야 하는 워게임

페이지에서 키 이벤트를 차단하는 스크립트:

{% code title="blockKeys.js" %}
```
```
{% endcode %}

```javascript
function noEvent() {
    if (event.keyCode == 116 || event.keyCode == 9) {
        alert('No!');
        return false;
    }
    else if (event.ctrlKey && (event.keyCode = 78 || event.keyCode == 82)) {
        return false;
    }
}
document.onkeydown = noEvent;
```

키코드:

* 9 = tab
* 116 = f5
* 78 = n
* 82 = r

해결 팁: frm의 submit() 을 실행하면 직접 클릭을 하지 않아도 버튼을 누를 수 있다.
{% endstep %}

{% step %}
### 인트루트(규칙적 값 자동 주입) 및 페이로드 자동화

인트루트 기능을 사용하면 규칙적으로 변경되는 값을 자동으로 넣을 수 있다.

페이로드 설정하고 규칙을 설정!

start attack 누르면 동작!
{% endstep %}
{% endstepper %}
