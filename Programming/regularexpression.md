# RegularExpression

{% hint style="info" %}
특정한 패턴으로 문자열을 표현하는 식

* 일반적으로 문자열 내에서 원하는 [패턴](/broken/pages/0912790ccf9aa0cac14eb04cdab79f05c12f45de)의 문자열을 찾거나 치환할 때 사용한다.
* 정규 표현식에 부합하는 문자열의 경우, 정규 표현식 혹은 패턴에 '매치한다'고 표현
{% endhint %}

#### 정규 표현식의 필요성

* 주로 로직을 수행하기 전, 이용자가 입력한 값을 검증하기 위해 사용된다.
* 이메일 뿐만 아니라 전화번호, 주민등록번호, 웹 사이트 주소 등 입력 값이 특정 형식이어야 하는 경우에 유용하게 쓰인다.
* 매우 긴 문자열에서 원하는 형식의 문자열을 검색하여 추출할 때도 사용된다.

## 정규 표현식 구성

### 정규 표현식 패턴

* 정규 표현식은 '패턴' 혹은 /패턴/ 의 형태로 작성한다.
* /로 패턴을 감싸는 경우, / 뒤에 플래그를 작성할 수 있다.

#### 매치

| **패턴**                                                                        | **설명**                                                                                   | **예시**                                                                                            |
| ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 문자 혹은 문자열                                                                     | 해당 문자 혹은 문자열과 매치합니다.                                                                     | <p>dreamhack → Hello <strong>dreamhack</strong><br><br>/c/ → Hello dreamha<strong>c</strong>k</p> |
| `.`                                                                           | 모든 문자와 매치합니다.                                                                            | d.eamhack → Hello **dxeamhack**                                                                   |
| `\|`                                                                          | 앞 또는 뒤의 패턴과 매치합니다.                                                                       | hi\|dream → Hello **dream**hack                                                                   |
| `[]`                                                                          | `[]`안의 문자와 매치합니다.                                                                        | \[aeiou] → H**i**                                                                                 |
| `[^ ]`                                                                        | `^`뒤의 패턴을 제외한 나머지와 매치합니다.                                                                | \[^aeiou] → **H**i                                                                                |
| `^`                                                                           | 어떤 문자열의 시작이 특정 패턴인 경우 매치합니다.                                                             | <p>^dream → <strong>dream</strong>hack Hello<br><br>^dream → Hello dreamhack</p>                  |
| `$`                                                                           | 어떤 문자열의 끝이 특정 패턴인 경우 매치합니다.                                                              | <p>hack$ → dreamhack Hello<br><br>hack$ → Hello dream<strong>hack</strong></p>                    |
| `\`                                                                           | <p><code>\</code>뒤의 특수 문자와 매치합니다.<br><br>특별한 목적으로 사용되는 특수 문자를 문자 그대로 쓰기 위한 이스케이핑입니다.</p> | hack$ → Hello dream**hack$**                                                                      |
| <p><code>[a-z]</code><br><br><code>[A-Z]</code><br><br><code>[0-9]</code></p> | 두 문자 사이 범위의 문자와 매치합니다.                                                                   | \[b-d] → ha**c**k                                                                                 |
| `\w`                                                                          | <p>알파벳 또는 숫자 또는 <code>_</code>와 매치합니다.<br><br><code>[A-Za-z0-9_]</code></p>              | \w → **a**!                                                                                       |
| `\d`                                                                          | <p>숫자와 매치합니다.<br><br><code>[0-9]</code></p>                                              | \d → a**1**                                                                                       |
| `\s`                                                                          | <p>공백 문자와 매치합니다.<br><br><code>[\b\f\n\r\t\v]</code></p>                                  |                                                                                                   |

#### 수량자

| **패턴**     | **설명**                                                         | **예시**                                                                                                                                                                                                                                       |
| ---------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `*`        | 앞에 나온 문자가 0개 이상이면 매치합니다.                                       | <p>Hac*k → <strong>Hak</strong><br><br>Hac*k → <strong>Hack</strong></p>                                                                                                                                                                     |
| `+`        | 앞에 나온 문자가 1개 이상이면 매치합니다.                                       | <p>Hac+k → Hak<br><br>Hac+k → <strong>Hack</strong></p>                                                                                                                                                                                      |
| `?`        | 앞에 나온 문자가 0개 혹은 1개이면 매치합니다.                                    | <p>Hac?k → <strong>Hak</strong><br><br>Hac?k → <strong>Hack</strong></p>                                                                                                                                                                     |
| 수량자?       | <p>수량자 뒤에 <code>?</code>를 붙이면 게으른 수량자로,<br>최소한의 문자만 매치합니다.</p> | <p>&#x3C;p>.*&#x3C;/p> → <strong>&#x3C;p>Hello&#x3C;/p>&#x3C;p>Hi&#x3C;/p></strong><br><br>&#x3C;p>.*?&#x3C;/p> → <strong>&#x3C;p>Hello&#x3C;/p></strong>&#x3C;p>Hi&#x3C;/p><br><br>Hack+? → <strong>Hack</strong><br><br>Hack+? → Hackk</p> |
| `{n}`      | 앞에 나온 문자가 정확히 n개이면 매치합니다.                                      | Hac{3}k → **Haccck**                                                                                                                                                                                                                         |
| `{n, }`    | 앞에 나온 문자가 n개 이상이면 매치합니다.                                       | Hac{2,}k → **Haccck**                                                                                                                                                                                                                        |
| `{n1, n2}` | 앞에 나온 문자가 n1개 이상, n2개 이하면 매치합니다.                               | <p>Hac{2,3}k → <strong>Hacck</strong><br><br>Hac{2,3}k → <strong>Haccck</strong></p>                                                                                                                                                         |

#### 그룹화

| **패턴** | **설명**                            | **예시**                 |
| ------ | --------------------------------- | ---------------------- |
| `()`   | `()`로 감싼 부분을 그룹화하여 하나의 문자처럼 여깁니다. | (ha)+ck → **hahahack** |

{% hint style="info" %}
탐욕적 수량자와 게으른 수량자

기본적으로 정규 표현식의 수량자는 탐욕적(greedy) 수량자에 속한다. 탐욕적 수량자는 가능한 많은 문자를 매치한다. 과한 매치를 막기 위해 등장한 것이 게으른(lazy) 수량자다. 게으른 수량자는 기존 수량자의 뒤에 `?`를 붙인 형태로, 가능한 적은 문자를 매치한다.
{% endhint %}

### 정규 표현식 플래그

* 검색의 옵션을 지정하는 역할을 수행한다.
* 일반적으로 /패턴/플래그 형식으로 작성한다.

| **플래그** | **설명**                                                                               | **예시**                                                                                                                                                         |
| ------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| g       | <p><strong>g</strong>lobal search<br><br>매치하는 모든 문자/문자열을 검색합니다.</p>                  | <p>/[aeiou]/ → H<strong>e</strong>llo dreamhack<br><br>/[aeiou]/g → H<strong>e</strong>ll<strong>o</strong> dr<strong>ea</strong>mh<strong>a</strong>ck</p>    |
| i       | <p><strong>i</strong>gnore case<br><br>대소문자를 구분하지 않고 검색합니다.</p>                      | <p>/h/g → Hello dream<strong>h</strong>ack<br><br>/h/ig → <strong>H</strong>ello dream<strong>h</strong>ack</p>                                                |
| m       | <p><strong>m</strong>ultiline<br><br>여러 줄에서 검색합니다.</p>                               | <p>/^Hello/g → <strong>Hello</strong> dream<br><br>Hello hack<br><br>/^Hello/gm → <strong>Hello</strong> dream<br><br><strong>Hello</strong> hack</p>          |
| s       | <p><strong>s</strong>ingle line(dotall)<br><br>메타문자 <code>.</code>가 개행문자도 포함합니다.</p> | <p>/Hello.+hack/g → Hello dream<br><br><strong>Hello hack</strong><br><br>/Hello.+hack/s → <strong>Hello dream</strong><br><br><strong>Hello hack</strong></p> |

### Python 정규 표현식

* Python에서는 re 모듈을 통해 정규 표현식을 사용할 수 있다.
* re 모듈의 함수를 호출하여 패턴에 일치하는 문자열을 검색하거나 치환하는 등 다양한 동작을 수행한다.

| **함수**                                 | **설명**                            | **반환 값**                                                                                                                |
| -------------------------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `re.compile(pattern, flags)`           | 정규 표현식 패턴을 컴파일합니다.                | 패턴 객체를 반환합니다. 만들어진 패턴 객체는 변수에 저장하여 사용할 수 있습니다.                                                                          |
| `re.search(pattern, string, flags)`    | 문자열 내에서 패턴에 처음으로 매치하는 문자열을 검색합니다. | <p>매치하는 문자열이 있으면 문자열 객체를 반환하고, 없으면 None을 반환합니다.<br><br>문자열 객체의 <code>group()</code> 메소드를 사용하여 객체에서 문자열만 반환할 수 있습니다.</p> |
| `re.match(pattern, string, flags)`     | 문자열 시작 부분에서 패턴에 매치하는 문자열을 검색합니다.  |                                                                                                                         |
| `re.fullmatch(pattern, string, flags)` | 전체 문자열이 패턴과 정확하게 매치하는지 확인합니다.     |                                                                                                                         |
| `re.findall(pattern, string, flags)`   | 문자열 내에서 패턴에 매치하는 모든 문자열을 검색합니다.   | 모든 문자열을 리스트 형식으로 반환합니다. 각 문자열은 리스트의 인덱스로 접근합니다.                                                                         |
| `re.finditer(pattern, string, flags)`  | 모든 문자열 객체를 리스트 형식으로 반환합니다.        |                                                                                                                         |

#### flags (Python)

* python에서 정규 표현식 플래그는 함수의 flags 인자 값으로 지정하거나, 패턴에 인라인 형식으로 작성한다.

| **플래그** | **flags 인자 값**       | **인라인 플래그** |
| ------- | -------------------- | ----------- |
| i       | re.I (re.IGNORECASE) | (?i)        |
| m       | re.M (re.MULTILINE)  | (?m)        |
| s       | re.S (re.DOTALL)     | (?s)        |
| g       | 자동으로 적용됩니다.          |             |

#### Raw String (r-string)

* python에서 사용하는 이스케이프 문자와의 충돌을 고려해 패턴을 작성할 때 Raw String을 활용한다.
* Raw String은 문자열 앞에 'r'을 붙여 나타낸다.
* Raw String은 이스케이프 문자를 문자 그대로 인식하는 특수한 문자열이다.

{% code title="예시.py" %}
```python
print('\t'+'Hi')
# 결과:        Hi

# Raw String
print(r'\t'+'Hi')
# 결과: \tHi
```
{% endcode %}

아래 코드는 정규 표현식을 활용해 전체 문자열에서 알파벳 대문자만 출력하는 예시 코드다.

{% code title="example.py" %}
```python
import re

result = re.findall('[A-Z]', 'Hello, DreamHack!')

#same
pattern = re.compile('[A-Z]')
result = pattern.findall('Hello, DreamHack!')

print(result)

# 결과: ['H', 'D', 'H']
```
{% endcode %}

### JavaScript 정규 표현식

* 2가지 방법으로 정규 표현식을 사용할 수 있다.

{% stepper %}
{% step %}
### 리터럴 방식

* `/패턴/` 혹은 `/패턴/플래그` 형태로 작성합니다.
{% endstep %}

{% step %}
### RegExp 객체 생성 방식

* `new RegExp(정규 표현식 리터럴, '플래그')` 혹은 `new RegExp('패턴', '플래그')`로 객체를 생성합니다.
{% endstep %}
{% endstepper %}

아래 표에 있는 함수들을 호출하여 패턴에 매치하는 문자열을 검색한다.

| **함수**                  | **설명**                                       |
| ----------------------- | -------------------------------------------- |
| `pattern.exec(string)`  | 패턴에 처음으로 매치하는 문자열의 일치 정보를 나타내는 결과 배열을 반환합니다. |
| `pattern.test(string)`  | 패턴에 매치하는 부분이 있으면 `true`, 없으면 `false`를 반환합니다. |
| `string.match(pattern)` | 패턴에 매치하는 모든 문자열을 배열 형태로 반환합니다.               |

javascript 정규 표현식을 활용해 전체 문자열에서 숫자만 출력하는 예시 코드다.

{% code title="example.js" %}
```javascript
const r = /\d/g;
// same
// const r = new RegExp('\\d','g');
// const r = new RegExp(/\d/,'g');

const str = 'H3ll0, DreamH4ck!';
const result = str.match(r);
console.log(result);

// 결과: ['3', '0', '4']
```
{% endcode %}

### 정규 표현식 연습

* 올바른 패턴 사용이 맞는지 검증이 필요하기에 아래 사이트를 활용한다.
* https://regexr.com/ : 정규 표현식을 작성하고 문자열이 패턴에 매치하는지 확인할 수 있습니다. 패턴에 대한 해석도 제공합니다.
* https://regexper.com/ : 정규 표현식 시각화 도구로, 작성한 패턴을 시각화하여 알기 쉽게 보여줍니다.
* https://tools.dreamhack.games/cyberchef : 정규 표현식을 작성하고 문자열이 패턴에 매치하는지 확인하거나, 자주 쓰는 정규 표현식 목록을 확인할 수 있습니다. **Operations**에서 **Regular expression**을 선택하여 사용합니다.
* 이메일 정규 표현식 `^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$`을 [Regexper](https://regexper.com/)를 사용해서 도식화한 모습

도식도 설명:

* `^`: 문자열의 시작을 매치합니다. 도식도에서도 마찬가지로 Start of line으로 나타납니다.
* `[\w-\.]+`: 이메일의 앞 부분을 매치합니다. word(`\w`)와 하이픈(`-`), 마침표(`.`) 문자 중 하나 이상이 여러 번 반복되는 문자열을 매치합니다. 여기서 word(`\w`)는 알파벳 소문자, 알파벳 대문자, 숫자, 그리고 언더스코어(`_`)를 나타냅니다.
* `@`: 이메일 가운데에 위치한 `@` 문자를 매치합니다.
* `([\w-]+\.)+`: `@` 문자 뒤의 도메인 부분을 매치합니다. word(`\w`)와 하이픈(`-`) 문자 중 하나 이상이 여러 번 반복되는 문자열인데, 마지막에 마침표(`.`)가 있는 문자열을 매치합니다. 그런데 이 자체가 여러 번 반복될 수 있도록 `(`와 `)`로 감싼 후 가장 우측에 `+` 기호를 사용했기 때문에 해당 정규 표현식은 `domain.`도 매치하고, `subdomain.domain.` 도 매치합니다.
* `[\w-]{2,4}`: 이 부분은 도메인 이름의 최상위 도메인(`com`, `net` 등)을 매치합니다. word(`\w`)와 하이픈(-) 문자 중 하나 이상이 2개에서 4개까지 반복되는 문자열을 매치합니다.
* `$`: 문자열의 끝을 매치합니다. 도식도에서도 마찬가지로 End of line으로 나타납니다.
