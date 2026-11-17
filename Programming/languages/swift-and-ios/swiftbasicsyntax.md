# Swift 기본 문법 예제

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-005-DO |
| 유형 | D&O (문법 개요) + 예제 코드 |
| 목적 | Swift 기본 문법(자료형, 변수와 상수, 문자열, 컬렉션, 제어문)을 예제로 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 Playground에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 아래 코드는 Xcode Playground 기준이다. Playground는 값만 적은 식(`25` 등)과 `num` 같은 단독 식을 결과 영역에 표시한다. 일반 `.swift` 파일(앱 프로젝트)에서는 값을 쓰지 않는 식이 경고를 낸다. 코드는 Swift 5 계열 기준이며 버전 확인 필요.
{% endhint %}

## 1. 정의

Swift는 정적 타입 언어다. 상수는 `let`, 변수는 `var`로 선언한다. 타입은 값에서 추론되므로 생략할 수 있다. 문장 끝에 세미콜론이 필요하지 않다.

## 2. 구성 요소

| 문법 | 키워드·표기 | 설명 |
|---|---|---|
| 상수 | `let` | 한 번 대입하면 바꿀 수 없다 |
| 변수 | `var` | 값을 바꿀 수 있다 |
| 문자열 보간 | `"\(값)"` | 값을 문자열 안에 넣는다 |
| 배열 | `[1, 2, 3]` | 순서 있는 같은 타입의 목록 |
| 딕셔너리 | `["키": 값]` | 키-값 쌍. 키로 찾으면 옵셔널을 반환한다 |
| 범위 | `0..<4`, `5...10`, `11...` | 반개방 범위, 닫힌 범위, 한쪽 범위 |

## 3. 동작 원리

타입은 `let age: Int = 27`처럼 명시하거나 `var id = 990204`처럼 생략한다. 생략하면 컴파일러가 우변 값에서 타입을 정한다. 이름은 변수·상수·함수는 lowerCamelCase, 타입은 UpperCamelCase를 쓴다.

## 4. 예제 코드

### 4-1. 값과 연산

```swift
import UIKit

// 텍스트
var greeting = "Hello, playground"

// 정수 Int
25
2024

// 실수 Double
3.14

// 타입 확인 방법
print(type(of: 3.14))

// 사칙연산
15 + 2022
3.14 * 2

15 / 2.0    // 값이 정수로만 이뤄질 경우 나머지는 버려진다. // 실수가 포함될 경우 소수점까지 나누기를 한다.

// 정수 자료형의 최대 저장 가능한 값 확인방법
Int.max
Int.min
```

### 4-2. 상수와 변수

```swift
// 상수 선언
let age: Int = 27
print(age)

// 변수 선언
var pi: Float = 3.14
print(pi)

pi += 2
print(pi)

// 변수 선언 시 타입을 꼭 명시할 필요는 없다.
var id = 990204
print("ID: \(id)")  // 문자열 보간 방법 (변수 값을 문자열 안에 직접 포함시키는 방법)
print("ID: " + String(id))  // 타입 변환방법

// 변수의 선언과 초기화를 분리할 수 있다.
var name: String
name = "gildong"
print(name)
```

{% hint style="info" %}
NOTE: 원본 주석의 "선언과 정의 분리"는 "선언과 초기화 분리"가 정확하다. 위 코드에서 `name`은 사용하기 전에 반드시 대입해야 한다.
{% endhint %}

### 4-3. 문자열과 문자

```swift
print(type(of: "gildong"))
print(type(of: Array("gildong"))) // 문자열을 통째로 배열에 저장할 수 있다. 이때 저장되는 배열의 각 요소는 문자(Character) 타입이 된다.

var greetings = "안녕하세요.\n"

// """ 내용 """ 을 활용해 여러 줄의 문자열을 저장할 수 있다.
var selfPR = """
iOS 개발을 처음 시작하게 된 \"홍길동\"이라고 합니다.
만나서 반갑습니다.
"""

// 두 문자열 타입을 합쳐서 출력할 수 있다.
print(greetings + selfPR)

// 개행(\n)을 포함한 문자열 요소의 개수를 확인할 수 있다.
print(greetings.count)

// 문자열 자르기 (띄어쓰기를 기준으로 문자열을 나눴다)
print(selfPR.split(separator: " "))

// 첫 문자 또는 마지막 문자 삭제 방법
print(greetings.dropFirst())
print(greetings.dropLast())

// 문자열이 비었는지 확인하는 방법
print(greetings.isEmpty)
print("".isEmpty)
```

### 4-4. 배열과 딕셔너리

```swift
// 배열 (Array)
var list = [1, 2, 3, 4, 5]
print(list[1])
print(list.min() ?? 0)
print(list.contains(3))
print(list.count)

list.remove(at: 0)  // 배열의 요소 삭제
print(list)

// 딕셔너리(Dictionary)
var person = ["이름": "홍길동", "주소지": "서울"]
print(person.keys)
print(person["이름"] ?? "미정")
print(person["주소지"] ?? "미정")
print(person["나이"] ?? "0") // ?? 의 기능 > 키 값으로 찾는 값이 없는 경우 nil 반환 > nil 값이 반환되었을 때 이를 대체할 값을 지정

// Expression implicitly coerced from 'String?' to 'Any'
// 의도하지 않은 형변환 가능성이 있음을 알리는 메시지 > print 함수 사용시 자주 발생 > 출력할 데이터의 기본 값을 전달해서 보완가능함 > ?? 기본값
```

### 4-5. 조건문

```swift
var condition = 0

if condition == 5
{
    print("condition is " + String(condition))
}
else if condition > 5
{
    print("condition is bigger than 5. " + String(condition))
}
else
{
    print("condition is smaller than 5. " + String(condition))
}

switch condition
{
case 11...:
    print("11 ~")
case 5...10:
    print("10~5")
case 1..<5:
    print("4~1")
default:
    print(String(condition))
}
```

### 4-6. 반복문

```swift
let nArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

for num in nArray
{
    num
}

let numOfLegs = ["spider": 8, "ant": 6, "cat": 4]

for (animalName, legCount) in numOfLegs
{
    animalName
    legCount
}

for index in 0..<4
{
    index
}

let nameArray = ["길동", "철수", "영희"]

for (idx, name) in nameArray.enumerated()
{
    idx
    name
}

var i = 0
while i < 3
{
    i += 1
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-1 `15 / 2.0` | 피연산자 중 하나가 `Double`이면 결과도 `Double`이다. `15 / 2`처럼 둘 다 정수면 몫만 남는다 |
| 4-2 `var pi: Float` | `Float`은 32비트 부동소수점 수다. 이름 `pi`는 변수라 lowerCamelCase로 썼다 |
| 4-3 `"""` | 여러 줄 문자열 리터럴. 닫는 `"""`의 들여쓰기가 기준이 된다 |
| 4-4 `person["나이"]` | 없는 키를 찾으면 `nil`을 반환한다. `??` 뒤의 값이 대신 쓰인다 |
| 4-5 `switch` | 모든 경우를 다뤄야 한다. 정수는 `default:`가 필요하다. 각 `case`는 자동으로 끝나며 `break`가 필요하지 않다 |
| 4-5 `case 11...:` | 11 이상의 모든 값. 범위가 겹치지 않아야 의도대로 읽힌다 |
| 4-6 `num` | 단독 식. Playground에서는 결과가 기록되지만 앱 코드에서는 "사용하지 않는 값" 경고가 난다 |

## 6. 한계·주의

{% hint style="warning" %}
CAUTION: `switch`의 `default` 뒤에는 콜론(`default:`)이 필요하다. 콜론이 없으면 컴파일 오류가 난다.
{% endhint %}

- 변수 이름의 대문자 시작(`Greetings`, `List`, `PI`)은 관례 위반이라 소문자로 시작하게 정정했다.
- 원본의 코드 사이 공백 줄과 AI가 붙인 첫 문장("원본 Swift 코드 예제입니다…")은 삭제했다.
- 원본 코드의 실명, 지역명은 일반 예시값(홍길동, 서울)으로 바꿨다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `let`과 `var`를 어떤 기준으로 고르는가?
- [ ] 딕셔너리에서 없는 키를 찾으면 왜 옵셔널이 나오는지 내 말로 설명해 본다.
