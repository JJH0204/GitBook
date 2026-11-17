# Swift 프로토콜 (Protocol)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-009-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 프로토콜의 정의와 요구사항(속성, 메서드, 이니셜라이저) 문법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

프로토콜(protocol)은 메서드, 프로퍼티, 이니셜라이저 같은 요구사항의 청사진이다. 클래스, 구조체, 열거형이 프로토콜을 채택(adopt)해 요구사항을 구현한다. 프로토콜은 코드의 모듈성과 유연성을 높인다.

{% hint style="info" %}
NOTE: 이 문서의 프로토콜은 Swift 언어의 프로토콜이다. 네트워크 프로토콜이 아니다.
{% endhint %}

## 2. 구성 요소

| 요구사항 | 문법 | 설명 |
|---|---|---|
| 읽기 전용 속성 | `var id: String { get }` | 채택 타입은 읽을 수 있는 속성을 제공한다 |
| 읽기/쓰기 속성 | `var fullName: String { get set }` | 읽고 쓸 수 있어야 한다 |
| 메서드 | `func startEngine()` | 채택 타입이 구현한다 |
| 이니셜라이저 | `init(name: String)` | 채택 타입이 구현한다. 클래스는 `required`를 붙인다 |

## 3. 동작 원리

1. 프로토콜이 요구사항을 선언한다.
2. 타입이 `: 프로토콜이름`으로 채택하고 요구사항을 구현한다.
3. 요구사항을 하나라도 구현하지 않으면 컴파일 오류가 난다.
4. 프로토콜 타입 변수에 채택한 타입의 인스턴스를 담아 같은 방식으로 호출한다(다형성).

## 4. 예제 코드

### 4-1. 기본 구성

```swift
protocol HasID   // HasID 라는 이름의 프로토콜 정의
{
    var id: String { get }
    func displayID()
    /* 모든 채택 타입에 id 속성(읽기 가능)과 displayID() 메서드를 요구한다. */
}

struct User: HasID
{
    var id: String
    func displayID() {
        print("My ID is \(id).")
    }
}

let user = User(id: "12345")
user.displayID()
```

{% hint style="info" %}
NOTE: 원본의 프로토콜 이름 `Identifiable`은 표준 라이브러리의 `Identifiable`(Swift 5.1 이상, 연관 타입 `ID` 요구)과 이름이 겹쳐 `HasID`로 바꿨다. 원본 주석의 "일기 가능"은 "읽기 가능"이다.
{% endhint %}

### 4-2. 속성 요구사항

```swift
protocol FullName
{
    var fullName: String { get set }
}

struct Person: FullName
{
    var fullName: String
}

var person = Person(fullName: "Gildong Hong")
print(person.fullName)
person.fullName = "Chulsu Kim"
print(person.fullName)
```

### 4-3. 메서드 요구사항

```swift
// 프로토콜 정의
protocol Vehicle
{
    var hasEngine: Bool { get }
    func startEngine()
    func stopEngine()
}

// 프로토콜을 채택한 첫 번째 구조체
struct Car: Vehicle
{
    var hasEngine = true
    func startEngine() {
        print("Car engine started.")
    }
    func stopEngine() {
        print("Car engine stopped.")
    }
}

// 프로토콜을 채택한 두 번째 구조체
struct Bicycle: Vehicle
{
    var hasEngine = false
    func startEngine() {
        print("Bicycle has no engine.")
    }
    func stopEngine() {
        print("Bicycle has no engine to stop.")
    }
}

let car = Car()
let bike = Bicycle()

car.startEngine()
bike.startEngine()

car.stopEngine()
bike.stopEngine()
```

### 4-4. 이니셜라이저 요구사항: 클래스

```swift
protocol Initializable
{
    init(name: String)
}

class Person2: Initializable
{
    var name: String
    required init(name: String) {
        self.name = name
    }
}

class Employee: Person2
{
    var job: String
    required init(name: String) {
        self.job = "Unknown"
        super.init(name: name)
    }
}

var employee = Employee(name: "gildong")
print(employee.name)
```

### 4-5. 이니셜라이저 요구사항: 구조체

```swift
struct Rectangle: Initializable
{
    var name: String
    init(name: String) {
        self.name = name
    }
}

var temp = Rectangle(name: "Gildong")
print(temp.name)
```

{% hint style="info" %}
NOTE: 원본의 클래스 `Person`은 4-2의 구조체 `Person`과 이름이 겹쳐 `Person2`로 바꿨다. 같은 Playground 파일에서 이어 실행하려면 이름이 달라야 한다. 마지막 출력은 `print(char__)`(타입 정보 출력)에서 `print(employee.name)`으로 바꿨다.
{% endhint %}

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-1 `{ get }` | 채택 타입은 저장 프로퍼티 또는 계산 프로퍼티 어느 쪽으로든 구현할 수 있다 |
| 4-2 `{ get set }` | 상수(`let`)나 읽기 전용 계산 프로퍼티로는 구현할 수 없다 |
| 4-3 | `Car`와 `Bicycle`이 같은 프로토콜을 채택해 같은 메서드 호출로 다르게 동작한다 |
| 4-4 `required` | 서브클래스가 이니셜라이저를 구현할 때도 `required`를 붙여 모든 하위 클래스가 이 요구사항을 만족하게 한다. 재정의할 때 `override`는 쓰지 않는다 |
| 4-5 | 구조체는 상속이 없으므로 `required`가 필요하지 않다 |

이니셜라이저 요구사항은 지정 이니셜라이저(designated) 또는 편의 이니셜라이저(convenience)로 구현할 수 있다. 클래스, 구조체, 열거형 모두 이니셜라이저를 요구하는 프로토콜을 채택할 수 있다.

## 6. 한계·주의

- 프로토콜을 만족시키지 않으면 컴파일 단계에서 알 수 있다. 런타임 오류가 아니다.
- `final` 클래스는 `required`가 필요하지 않다.

## 7. 관련 문서

- [프로토콜 확장](protocolextension.md) (PRG-SWF-011-DO)
- [프로토콜 지향 프로그래밍](protocolorientedprogramming.md) (PRG-SWF-010-DO)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상속 대신 프로토콜을 쓰면 무엇이 달라지는가?
- [ ] 직접 프로토콜을 만든다면 어떤 요구사항을 넣겠는가?
