# 정규 표현식 상세 (Regex)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PYT-003-DO |
| 유형 | D&O (문법 원리) + REF 표 + 예제 코드 |
| 목적 | 정규 표현식 문법, Python `re` 모듈과 JavaScript `RegExp`의 사용법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

정규 표현식(regular expression)은 특정한 패턴으로 문자열을 표현하는 식이다. 문자열에서 원하는 패턴을 찾거나 치환할 때 쓴다. 정규 표현식에 부합하는 문자열은 그 패턴에 "매치한다"고 한다.

| 용도 | 설명 |
|---|---|
| 입력값 검증 | 로직을 수행하기 전 이메일, 전화번호, 웹 사이트 주소 같은 입력값이 특정 형식인지 검사한다 |
| 검색·추출 | 긴 문자열에서 원하는 형식의 문자열을 찾아 뽑는다 |
| 치환 | 패턴에 매치한 부분을 다른 문자열로 바꾼다 |

패턴은 `'패턴'` 또는 `/패턴/` 형태로 쓴다. `/`로 감싸면 뒤에 플래그를 붙일 수 있다(`/패턴/플래그`). `/패턴/` 표기는 JavaScript 등에서 쓰며 Python은 문자열로 쓴다.

## 2. 구성 요소

### 2-1. 매치

| 패턴 | 설명 | 예시 |
|---|---|---|
| 문자 또는 문자열 | 해당 문자 또는 문자열과 매치한다 | `dreamhack` → Hello **dreamhack** |
| `.` | 개행을 제외한 모든 문자 한 개와 매치한다(`s` 플래그 사용 시 개행 포함) | `d.eamhack` → Hello **dxeamhack** |
| `\|` | 앞 또는 뒤의 패턴과 매치한다 | `hi\|dream` → Hello **dream**hack |
| `[]` | 대괄호 안의 문자 중 하나와 매치한다 | `[aeiou]` → H**i** |
| `[^ ]` | `^` 뒤에 나열한 문자를 제외한 문자 하나와 매치한다 | `[^aeiou]` → **H**i |
| `^` | 문자열의 시작이 패턴인 경우 매치한다 | `^dream` → **dream**hack Hello (Hello dreamhack은 매치하지 않는다) |
| `$` | 문자열의 끝이 패턴인 경우 매치한다 | `hack$` → Hello dream**hack** (dreamhack Hello는 매치하지 않는다) |
| `\` | 뒤의 특수 문자를 문자 그대로 매치한다(이스케이프) | `hack\$` → Hello dream**hack$** |
| `[a-z]` `[A-Z]` `[0-9]` | 두 문자 사이 범위의 문자와 매치한다 | `[b-d]` → ha**c**k |
| `\w` | 단어 문자와 매치한다. ASCII 기준 `[A-Za-z0-9_]` | `\w` → **a**! |
| `\d` | 숫자와 매치한다. ASCII 기준 `[0-9]` | `\d` → a**1** |
| `\s` | 공백 문자와 매치한다. `[ \t\n\r\f\v]` | 공백, 탭, 개행 |

{% hint style="info" %}
NOTE: Python 3의 `str` 패턴에서 `\w`와 `\d`는 기본적으로 유니코드 문자·숫자와 매치한다(한글 포함). 위 ASCII 범위는 `re.ASCII` 플래그를 줄 때와 JavaScript의 동작이다.
{% endhint %}

### 2-2. 수량자

| 패턴 | 설명 | 예시 |
|---|---|---|
| `*` | 앞의 문자가 0개 이상이면 매치한다 | `Hac*k` → **Hak**, **Hack** |
| `+` | 앞의 문자가 1개 이상이면 매치한다 | `Hac+k` → Hak(불일치), **Hack** |
| `?` | 앞의 문자가 0개 또는 1개이면 매치한다 | `Hac?k` → **Hak**, **Hack** |
| `{n}` | 정확히 n개이면 매치한다 | `Hac{3}k` → **Haccck** |
| `{n,}` | n개 이상이면 매치한다 | `Hac{2,}k` → **Haccck** |
| `{n1,n2}` | n1개 이상 n2개 이하이면 매치한다 | `Hac{2,3}k` → **Hacck**, **Haccck** |
| 수량자 + `?` | 게으른(lazy) 수량자. 최소한의 문자만 매치한다 | `<p>.*?</p>` → **\<p>Hello\</p>**\<p>Hi\</p> |

{% hint style="warning" %}
CAUTION: `{n,}`와 `{n1,n2}`의 쉼표 앞뒤에 공백을 넣으면 수량자로 해석되지 않고 글자 그대로 매치한다. `{2, 3}`이 아니라 `{2,3}`으로 쓴다.
{% endhint %}

탐욕적 수량자와 게으른 수량자는 다음과 같이 다르다.

| 구분 | 패턴 | 입력 `<p>Hello</p><p>Hi</p>`에서 매치 |
|---|---|---|
| 탐욕적(greedy, 기본) | `<p>.*</p>` | `<p>Hello</p><p>Hi</p>` 전체 |
| 게으른(lazy) | `<p>.*?</p>` | `<p>Hello</p>` |

### 2-3. 그룹화

| 패턴 | 설명 | 예시 |
|---|---|---|
| `()` | 괄호로 감싼 부분을 하나의 단위로 묶는다 | `(ha)+ck` → **hahahack** |

### 2-4. 플래그

플래그는 검색 옵션이다. `/패턴/플래그` 형식으로 쓴다.

| 플래그 | 이름 | 설명 | 예시 |
|---|---|---|---|
| `g` | global | 매치하는 모든 부분을 검색한다 | `/[aeiou]/g` → H**e**ll**o** dr**ea**mh**a**ck |
| `i` | ignore case | 대소문자를 구분하지 않는다 | `/h/ig` → **H**ello dream**h**ack |
| `m` | multiline | `^`와 `$`가 각 줄의 시작과 끝에 매치한다 | `/^Hello/gm` → 줄마다 시작하는 Hello |
| `s` | single line(dotall) | `.`가 개행 문자도 포함한다 | `/Hello.+hack/s` → 줄을 넘어 매치 |

## 3. Python 정규 표현식

Python은 `re` 모듈로 정규 표현식을 쓴다.

| 함수 | 설명 | 반환 값 |
|---|---|---|
| `re.compile(pattern, flags)` | 패턴을 컴파일한다 | 패턴 객체. 변수에 저장해 재사용한다 |
| `re.search(pattern, string, flags)` | 문자열 안에서 처음 매치하는 곳을 찾는다 | 매치하면 Match 객체, 없으면 `None`. `group()`으로 매치된 문자열을 얻는다 |
| `re.match(pattern, string, flags)` | 문자열의 시작에서 매치하는지 본다 | Match 객체 또는 `None` |
| `re.fullmatch(pattern, string, flags)` | 전체 문자열이 패턴과 정확히 매치하는지 본다 | Match 객체 또는 `None` |
| `re.findall(pattern, string, flags)` | 매치하는 모든 부분을 찾는다 | 문자열 리스트. 패턴에 그룹이 있으면 그룹 내용(그룹이 여럿이면 튜플)의 리스트 |
| `re.finditer(pattern, string, flags)` | 매치하는 모든 부분을 찾는다 | Match 객체의 이터레이터 |
| `re.sub(pattern, repl, string)` | 매치한 부분을 `repl`로 치환한다 | 치환된 문자열 |

### 3-1. flags

Python의 플래그는 함수의 `flags` 인자로 주거나 패턴 앞에 인라인으로 쓴다.

| 플래그 | flags 인자 값 | 인라인 |
|---|---|---|
| `i` | `re.I` (`re.IGNORECASE`) | `(?i)` |
| `m` | `re.M` (`re.MULTILINE`) | `(?m)` |
| `s` | `re.S` (`re.DOTALL`) | `(?s)` |
| `g` | 없음. `findall`, `finditer`, `sub`는 항상 모든 매치를 대상으로 한다 | 없음 |

{% hint style="info" %}
NOTE: Python 3.11 이상에서는 인라인 전역 플래그(`(?i)` 등)를 패턴의 맨 앞에만 쓸 수 있다.
{% endhint %}

### 3-2. 원시 문자열(raw string)

Python 문자열의 이스케이프(`\t` 등)와 정규 표현식의 이스케이프(`\d` 등)가 충돌하므로 패턴은 원시 문자열로 쓴다. 문자열 앞에 `r`을 붙이면 `\`를 이스케이프로 해석하지 않는다.

{% code title="예시.py" %}
```python
print('\t' + 'Hi')
# 결과: (탭)Hi

# 원시 문자열
print(r'\t' + 'Hi')
# 결과: \tHi
```
{% endcode %}

### 3-3. 예제: 대문자만 추출

{% code title="example.py" %}
```python
import re

result = re.findall('[A-Z]', 'Hello, DreamHack!')

# 위와 같은 결과
pattern = re.compile('[A-Z]')
result = pattern.findall('Hello, DreamHack!')

print(result)
# 결과: ['H', 'D', 'H']
```
{% endcode %}

### 3-4. 예제: Match 객체 사용

```python
import re

m = re.search(r'\d+', 'abc 123 def')
if m:
    print(m.group())   # 123
    print(m.span())    # (4, 7)
```

## 4. JavaScript 정규 표현식

JavaScript는 두 가지 방법으로 정규 표현식을 만든다.

| 방식 | 형태 |
|---|---|
| 리터럴 | `/패턴/` 또는 `/패턴/플래그` |
| `RegExp` 객체 | `new RegExp('패턴', '플래그')` 또는 `new RegExp(/패턴/, '플래그')` |

| 함수 | 설명 |
|---|---|
| `pattern.exec(string)` | 처음 매치한 부분의 정보(결과 배열)를 반환한다. 없으면 `null` |
| `pattern.test(string)` | 매치하는 부분이 있으면 `true`, 없으면 `false` |
| `string.match(pattern)` | `g` 플래그가 있으면 매치한 모든 문자열의 배열, 없으면 `exec`와 같은 결과 |

{% code title="example.js" %}
```javascript
const r = /\d/g;
// 위와 같은 정규 표현식
// const r = new RegExp('\\d', 'g');
// const r = new RegExp(/\d/, 'g');

const str = 'H3ll0, DreamH4ck!';
const result = str.match(r);
console.log(result);
// 결과: ['3', '0', '4']
```
{% endcode %}

## 5. 이메일 패턴 해설

원본의 이메일 패턴 `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`는 Python `re`에서 `[\w-\.]`의 `\w-\.`가 범위로 해석되어 `bad character range` 오류가 난다. 하이픈을 문자 클래스의 끝에 두어 정정한다.

```python
import re

pattern = r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$'
print(bool(re.fullmatch(pattern, 'user@example.com')))   # True
```

| 부분 | 의미 |
|---|---|
| `^` | 문자열의 시작 |
| `[\w.-]+` | 이메일 앞부분. 단어 문자, 마침표, 하이픈이 1개 이상 |
| `@` | `@` 문자 |
| `([\w-]+\.)+` | 도메인 레이블과 마침표의 반복. `domain.`과 `sub.domain.` 모두 매치한다 |
| `[\w-]{2,}` | 최상위 도메인(`com`, `net`, `museum` 등). 원본의 `{2,4}`는 `.museum` 같은 긴 TLD를 놓치므로 `{2,}`로 정정했다 |
| `$` | 문자열의 끝 |

{% hint style="warning" %}
CAUTION: 정규 표현식으로 이메일 형식을 완전히 검증할 수 없다. 이 패턴은 형식 점검용이며 실제 존재 여부는 확인 메일로 검증한다.
{% endhint %}

{% hint style="info" %}
NOTE: 정규 표현식 라이브러리는 문법이 조금씩 다르다. `\w`는 Python 3 `str`에서 유니코드, JavaScript에서 ASCII 기준이다.
{% endhint %}

## 6. 참조

* [RegExr](https://regexr.com/): 패턴을 쓰고 매치를 확인한다. 패턴 해석도 제공한다.
* [Regexper](https://regexper.com/): 패턴을 도식으로 보여 준다.
* [CyberChef (드림핵 도구)](https://tools.dreamhack.games/cyberchef): Operations에서 Regular expression을 선택해 쓴다.
* 이 문서의 개념 설명은 드림핵 정규 표현식 강의를 참고해 정리한 것이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 탐욕적 수량자와 게으른 수량자의 차이를 HTML 태그 추출 예로 설명하면?
- [ ] `re.search`, `re.match`, `re.fullmatch`를 어떤 상황에서 구분해 쓰는가?
- [ ] 내가 직접 정규 표현식으로 검증하거나 추출해 본 데이터는 무엇인가?
