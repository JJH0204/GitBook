# 열거형 (Enumeration)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-015-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 열거형의 케이스, `switch`, 연관값, 원시값, 재귀 열거형을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

열거형(`enum`)은 관련된 값들을 하나의 타입으로 묶어 코드를 안전하게 쓰게 하는 값 타입이다. 각 케이스는 이름으로 의미를 표현하며 연관값이나 원시값을 가질 수 있다.

## 2. 구성 요소

| 구성 요소 | 문법 | 설명 |
|---|---|---|
| 케이스 | `case mercury` | 열거형이 가질 수 있는 값 |
| 연관값 (Associated Value) | `case int(Int)` | 케이스마다 다른 타입의 값을 붙인다. 인스턴스마다 값이 다르다 |
| 원시값 (Raw Value) | `enum E: Int { case a = 1 }` | 케이스에 미리 정해진 같은 타입의 값. 모든 인스턴스가 같다 |
| `CaseIterable` | `enum E: CaseIterable` | `allCases`로 모든 케이스를 순회한다 |
| `indirect` | `indirect case` | 자기 자신을 연관값으로 갖는 재귀 열거형에 쓴다 |

연관값과 원시값은 한 열거형에서 함께 쓸 수 없다.

## 3. 동작 원리

1. 값은 `타입.케이스`로 만든다. 타입이 정해진 곳에서는 `.케이스`로 줄여 쓴다.
2. `switch`는 모든 케이스를 다뤄야 한다. 일부만 다루면 `default`가 필요하다.
3. 원시값 타입이 `Int`면 첫 케이스는 0, 이후 1씩 늘어난다. `String`이면 케이스 이름이 원시값이 된다.

## 4. 예제 코드

각 코드 조각은 독립이다. 한 파일에서 이어 실행하려면 열거형 이름이 겹치지 않아야 하므로 원시값 예제의 이름을 구분했다.

### 4-1. 열거형 정의

```swift
enum Planet {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}
/* 또는 */

enum PlanetSeparate {
    case mercury
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}
```

### 4-2. 값 사용

```swift
var homePlanet = Planet.earth   // 기본적인 사용

var targetPlanet : Planet

targetPlanet = .mars      // 변수 타입이 명확한 경우, 열거형 이름을 생략하고 사용 가능
```

### 4-3. `switch`

```swift
switch targetPlanet {
    case .mercury:
        print("태양과 너무 가깝다")
    case .venus:
        print("공기가 부족하다")
    case .earth:
        print("현재 살고 있는 행성이다")
    case .mars:
        print("어쩌면 우리와 비슷한 생명체가 살지도 모른다")
    case .jupiter:
        print("생명체가 살기 좋지 않은 것 같다")
    case .saturn:
        print("척박한 행성이다")
    case .uranus:
        print("목표로 삼기에는 먼 행성이다")
    case .neptune:
        print("다시 생각해 본다")
}
```

{% hint style="info" %}
NOTE: 모든 케이스를 처리해야 하는 `switch`의 성질과 열거형의 값을 나열하는 성질이 잘 맞아 함께 쓰인다. 모든 케이스를 별도로 처리하지 않아도 되며, 그때는 `default`를 쓴다.
{% endhint %}

```swift
var nextPlanet : Planet

nextPlanet = .jupiter

switch nextPlanet {
    case .earth:
        print("현재 살고 있는 행성이다.")
    case .mars:
        print("어쩌면 우리와 비슷한 생명체가 살지도 모른다.")
    default:
        print("생명체가 살기 좋지 않은 환경이다.")
}
```

### 4-4. 프로토콜 응용: `CaseIterable`

[Swift 프로토콜](../swift_protocol.md)을 채택해 부가 기능을 쓰는 예다.

```swift
enum Beverage : CaseIterable {
    case coffee, tea, juice
}

let numOfChoices = Beverage.allCases.count  // case의 개수를 반환
print("\(numOfChoices)")

for beverage in Beverage.allCases {  // 모든 case를 순회하며 이름을 출력
    print(beverage)
}
```

### 4-5. 연관값

```swift
/* 타입으로 응용 */

enum JsonType {
    case int(Int)   // (Int)를 연관값(Associated Value)이라 하며, 해당 케이스를 따르면 Int형을 저장할 수 있다는 의미
    case string(String)
    case bool(Bool)
    case object([String : JsonType])
    case array([JsonType])
}

var jsonInt : JsonType = JsonType.int(3)
jsonInt = JsonType.int(4)
var jsonString = JsonType.string("Hello")
var jsonBool = JsonType.bool(false)
var jsonObject = JsonType.object(["예제" : jsonBool])
var jsonArray = JsonType.array([jsonInt, jsonString, jsonBool, jsonObject])
```

```swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

var productBarcode = Barcode.upc(8, 85909, 51226, 3)
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
```

### 4-6. 원시값

```swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
```

`Int` 원시값에서 값을 지정하지 않으면 0부터 순차 할당된다.

```swift
enum IndexedPlanet : Int {
    case mercury   // 0
    case venus     // 1
    case earth     // 2
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}
```

첫 케이스에 1을 지정하면 이후 케이스는 2부터 채워진다.

```swift
enum OneBasedPlanet : Int {
    case mercury = 1
    case venus    // 2
    case earth    // 3
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}
```

`String` 원시값에서 값을 지정하지 않으면 케이스 이름이 원시값이 된다.

```swift
enum NamedPlanet : String {
    case mercury   // = "mercury"
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}

let p = NamedPlanet(rawValue: "earth")   // NamedPlanet? (없는 값이면 nil)
print(NamedPlanet.venus.rawValue)         // "venus"
```

### 4-7. 재귀 열거형

케이스가 자기 자신 타입을 연관값으로 가지면 `indirect`를 쓴다.

```swift
enum ArithmeticExpression {
    case number(Int)
    indirect case addition(ArithmeticExpression, ArithmeticExpression)
    indirect case multiplication(ArithmeticExpression, ArithmeticExpression)
}

let five = ArithmeticExpression.number(5)
let four = ArithmeticExpression.number(4)
let sum = ArithmeticExpression.addition(five, four)
let product = ArithmeticExpression.multiplication(sum, ArithmeticExpression.number(2))
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-2 `.mars` | 변수 타입이 `Planet`으로 정해져 있어 `Planet.`을 생략했다 |
| 4-4 `allCases` | `CaseIterable`을 채택하면 컴파일러가 `allCases`를 만든다. 연관값이 없는 열거형에서 자동 합성된다 |
| 4-5 `JsonType` | 배열(`[JsonType]`)과 딕셔너리는 저장 공간이 간접이라 `indirect` 없이 자기 참조가 가능하다 |
| 4-6 `rawValue` | 원시값으로 열거형을 만드는 `init(rawValue:)`는 실패 가능이라 옵셔널을 반환한다 |
| 4-7 `indirect` | 값 타입이 자기 자신을 직접 포함하면 크기가 무한해지므로 간접 저장을 지시한다 |

## 6. 한계·주의

{% hint style="info" %}
NOTE: 원본 소제목 "기본값(원시값)"은 "원시값(Raw Value)"이 정확하다. 원본에서 `Planet`을 여러 번 재정의한 예제는 이름을 구분했고, 같은 변수 `targetPlanet`을 두 번 선언한 부분은 `nextPlanet`으로 바꿨다. 행성 설명 문구의 반말은 평서체로 바꿨다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 연관값과 원시값의 차이를 내 말로 설명해 본다.
- [ ] 내 프로젝트에서 상태를 열거형으로 표현하면 좋을 곳을 하나 적어 본다.
