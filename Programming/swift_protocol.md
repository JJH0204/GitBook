# Swift\_Protocol

* 코드의 모듈성과 유연성을 높이는데 중요한 역할을 수행한다.

{% stepper %}
{% step %}
### 기본 구성

* 클래스, 구조체, 열거형이 프로토콜을 채택하여 구현할 수 있는 메서드, 속성, 이니셜라이저의 청사진을 제공한다.

```swift
protocol Identifiable   // Identifiable 이라는 이름의 프로토콜 정의

{

    var id : String { get }

    func displayID()

    /* 모든 타입에 id 속성(일기 가능)과 displayID() 메서드를 요구한다. */

}

  

struct User : Identifiable

{

    var id : String

    func displayID() {

        print("My ID is \(id).")

    }

}

  

let user = User(id: "12345")

user.displayID()
```
{% endstep %}

{% step %}
### 속성 요구사항

* 프로토콜을 채택한 타입에 특정 속성을 가지고 있어야 함을 명시할 수 있다.
* 속성은 읽기 전용(get) 또는 읽기/쓰기 가능(get and set)으로 설정할 수 있다.

```swift
protocol FullName

{

    var fullName: String { get set }

}

  

struct Person: FullName

{

    var fullName: String

}

  

var person = Person(fullName: "Jaeho Jung")

print(person.fullName)

person.fullName = "JaeYoung Jung"

print(person.fullName)
```
{% endstep %}

{% step %}
### 메서드 요구사항

* 채택한 타입이 구현해야 하는 메서드를 정의할 수 있다.
* 채택한 모든 타입이 반드시 구현해야 하는 메서드를 정의하는 것을 말함
* 다양한 타입들이 일관된 기능을 제공할 수 있게 되며, 코드의 일반성과 유연성을 높일 수 있다.

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

* 다형성을 활용해 다른 타입(Car와 Bicycle)이 같은 인터페이스를 공유하고 있음을 알 수 있다.
* 다른 기능을 가진 객체가 같은 메서드 호출을 통해 동작할 수 있게 된다.
{% endstep %}

{% step %}
### 이니셜라이저의 요구사항

* 프로토콜을 채택하는 타입이 특정 이니셜라이저를 반드시 구현하도록 강제하는 것을 의미한다.
* 해당 타입의 인스턴스가 일관된 방식으로 생성될 수 있도록 보장한다.
* 클래스, 구조체, 열거형에 적용될 수 있으며, 타입의 초기화 과정에서 필수적인 조건을 명확하게 설정하는데 사용한다.

{% stepper %}
{% step %}
#### 클래스에서 이니셜라이저 요구사항

```swift
protocol Initializable
{
    init(name: String)
}

  

class Person: Initializable
{
    var name: String
    required init(name: String) {
        self.name = name
    }
}

  

class Employee: Person
{
    var job: String
    required init(name: String) {
        self.job = "Unknown"
        super.init(name: name)
    }
}

var char__ = Employee(name: "jaeho")
print(char__)
```

* 지정 이니셜라이저(designated initializer) 또는 편의 이니셜라이저(convenience initializer) 로 구현할 수 있다.
* 서브 클래스가 프로토콜 이니셜라이저 요구사항을 상속받고, 그 요구사항을 충족시키는 이니셜라이저를 오버라이드 해야 할 때, required 키워드를 사용하여 모든 서브클래스가 이 이니셜라이저를 구현하도록 강제한다.
* 서브클래스에서 해당 프로토콜을 자유롭게 채택할 수 있도록 보장하기 위해 필요하다
{% endstep %}

{% step %}
#### 구조체에서 이니셜라이저 요구사항

* 클래스와 달리 required 키워드가 필요하지 않다.
* 상속을 지원하지 않기 때문에, 이니셜라이저를 각 구조체마다 명시적으로 제공하면 된다.

```swift
struct Rectangle: Initializable

{

    var name: String

    init(name: String) {

        self.name = name

    }

}

  

var temp = Rectangle(name: "Jaeho")

print(temp.name)
```
{% endstep %}
{% endstepper %}
{% endstep %}

{% step %}
* 스위프트 프로토콜의 확장: [스위프트 프로토콜의 확장](file:///4766478/network/SwiftProtocolExtension.md)
* 프로토콜 지향 프로그래밍 (P.O.P): [프로토콜 지향 프로그래밍 (P.O.P)](/broken/pages/937e4b3c53169b38cb5d417e0291f12443cb96f3)
{% endstep %}
{% endstepper %}
