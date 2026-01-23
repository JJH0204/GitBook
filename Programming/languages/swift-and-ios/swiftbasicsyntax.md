# SwiftBasicSyntax

아래는 원본 Swift 코드 예제입니다. 주석과 코드 내용을 그대로 유지했습니다.

{% code title="playground.swift" %}
```swift
import UIKit

// 텍스트
var greeting = "Hello, playground"

  

// 정수 Int

25

2024

  

// 실수 Double

3.14

  

//  타입 확인 방법

print(type(of: 3.14))

// 사칙연산

15 + 2022

3.14 * 2

  

15 / 2.0    // 값이 정수로만 이뤄질 경우 나머지는 버려진다. // 실수가 포함될 경우 소수점까지 나누기를 한다.

  

// 정수 자료형의 최대 저장 가능한 값 확인방법

Int.max

Int.min

  

// 상수 선언

let age: Int = 27

print(age)

  

// 변수 선언

var PI: Float = 3.14

print(PI)

  

PI += 2

print(PI)

  

// 변수 선언 시 타입을 꼭 명시할 필요는 없다.

var ID = 990204

print("ID: \(ID)")  // 문자열 보간 방법 (변수 값을 문자열 안에 직접 포함시키는 방법)

print("ID: " + String(ID))  // 타입 변환방법

  

// 문자열과 문자

print(type(of: "jungjaeho"))

print(type(of: Array("jungjaeho"))) // 문자열을 통째로 배열에 저장할 수 있다. 이때 저장되는 배열의 각 요소는 문자 타입이 된다.

  

var Greetings = "안녕하세요.\n"

  

// """ 내용 """ 을 활용해 여러 줄의 문자열을 저장할 수 있다.

var SelfPR = """

IOS 개발을 처음 시작하게 된 \"정재호\"라고 합니다.

만나서 반갑습니다.

"""

  

// 두 문자열 타입을 합쳐서 출력할 수 있다.

print(Greetings + SelfPR)

  

// 개행(\n)을 포함한 문자열 요소의 개수를 확인할 수 있다.

print(Greetings.count)

  

// 문자열 자르기 (띄어쓰기를 기준으로 문자열을 나눴다)

print(SelfPR.split(separator: " "))

  

// 첫 문자 또는 마지막 문자 삭제 방법

print(Greetings.dropFirst())

print(Greetings.dropLast())

  

// 문자열이 비었는지 확인하는 방법

print(Greetings.isEmpty)

print("".isEmpty)

  

// 배열 (Array)

var List = [1,2,3,4,5]

print(List[1])

print(List.min() ?? 0)

print(List.contains(3))

print(List.count)

  

List.remove(at: 0)  // 배열의 요소 삭제

print(List)

  

// 딕셔너리(Dictionary)

var person = ["이름":"정재호", "주소지":"대구"]

print(person.keys)

print(person["이름"] ?? "미정")

print(person["주소지"] ?? "미정")

print(person["나이"] ?? "0") //?? 의 기능 > 키 값으로 찾는 값이 없는 경우 nil 반환 > nil 값이 반환되었을 때 이를 대체할 값을 지정

  

// Expression implicitly coerced from 'String?' to 'Any'

// 의도하지 않은 형변환 가능성이 있음을 알리는 메시지 > print 함수 사용시 자주 발생 > 출력할 데이터의 기본 값을 전달해서 보완가능함 > ?? 기본값

  

// 변수의 선언과 정의를 분리할 수 있다.

var name: String

name = "jaeho"

print(name)

  

// 조건문

var Condition = 0

  

if Condition == 5

{

    print("condition is " + String(Condition))

}

else if Condition > 5

{

    print("condition is bigger than 5." + String(Condition))

}

else

{

    print("condition is smaller than 5." + String(Condition))

}

  

switch Condition

{

case 11...:

    print("11 ~")

case 5...10:

    print("10~5")

case 1..<5:

    print("4~1")

default

    print(String(Condition))

}

  

// 반복문

  

let nArray = [1,2,3,4,5,6,7,8,9,10]

  

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

  

let nameArray = ["재호", "재영", "주영"]

  

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
{% endcode %}
