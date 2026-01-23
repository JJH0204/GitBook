# EnumerationType

* 관련된 값들을 그룹화하여 코드를 더 안전하고 쉽게 작성할 수 있도록 돕는 타입
* 각 케이스가 하나의 구체적인 값과 연결될 수 있으며, 각 값의 의미를 명확하게 표현할 수 있다.

### 열거형 정의

```swift
enum Planet {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}
/* 또는 */

enum Planet {
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

### 열거형 값 사용

```swift
var homePlanet = Planet.earth   // 기본적인 사용

var targetPlanet : Planet

targetPlanet = .mars      // 변수 타입이 명확한 경우, 열거형 이름을 생략하고 사용 가능
```

### 열거형과 switch

```swift
switch targetPlanet {
    case .mercury:
        print("태양과 너무 가까워")
    case .venus:
        print("공기가 부족해")
    case .earth:
        print("현재 살고 있는 행성이야")
    case .mars:
        print("어쩌면 우리와 비슷한 생명체가 살지도?")
    case .jupiter:
        print("생명체가 살기 좋지 않는 것 같아")
    case .saturn:
        print("척박한 행성이야")
    case .uranus:
        print("정말 여기를 목표로 한다고?")
    case .neptune:
        print("다시 생각해봐")
}
```

{% hint style="info" %}
* 모든 케이스를 처리해야 하는 switch 문의 특성과 열거형의 값을 열거하는 성질이 잘 맞아 같이 사용되는 경우가 많다.
* 꼭 모든 case에 대해서 별도의 처리를 진행할 필요는 없다.
{% endhint %}

```swift
var targetPlanet : Planet

targetPlanet = .jupiter

switch targetPlanet {
    case .earth:
        print("현재 살고 있는 행성이야.")
    case .mars:
        print("어쩌면 우리와 비슷한 생명체가 살지도?")
    default:
        print("생명체가 살기 좋지 않은 환경이야.")
}
```

### [프로토콜(Protocol)](/broken/pages/3a8c9d85b0fd8374c5c4e5da9d23b69c7949397c)을 응용한 작업

* 아래 코드는 CaseIterable 프로토콜을 채택하여 필요한 부가 기능을 사용할 수 있도록 한 예시다.

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

### 연관값(Associated Value) : 타입으로 응용

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

* 각 케이스에 대한 타입의 관련 값을 연결할 수 있다.
* 같은 열거형 내에서도 다양한 유형의 데이터를 저장할 수 있다.

```swift
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

var productBarcode = Barcode.upc(8, 85909, 51226, 3)
productBarcode = .qrCode("ABCDEFGHIJKLMNOP")
```

### 기본값(원시값: Raw Values)

* 동일한 타입의 미리 설정된 기본값을 모든 케이스에 제공하는 기능

```swift
enum ASCIIControlCharacter: Character {
    case tab = "\t"
    case lineFeed = "\n"
    case carriageReturn = "\r"
}
```

* 보다 안전하게 값을 비교하고 검증할 수 있게 된다.
* Int 타입을 rawValue로 가지도록 선언하고 case에 값을 할당하지 않을 경우, 0부터 순차적으로 값이 할당된다.

```swift
enum Planet : Int {
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

* 첫 case에 1을 할당하면 그 뒤 case 들은 2부터 순차적으로 채워진다.

```swift
enum Planet : Int {
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

* raw Value로 String을 선언하고 case에 값을 할당하지 않으면 case 이름으로 자동 할당된다.

```swift
enum Planet : String {
    case mercury   // = "mercury"
    case venus
    case earth
    case mars
    case jupiter
    case saturn
    case uranus
    case neptune
}
```

### 재귀 열거형 (Recursive Enumerations)

* 재귀 열거형은 열거형 케이스가 다른 인스턴스의 열거형을 연관 값으로 가질 수 있습니다. 이 경우 indirect 키워드를 사용합니다:

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
