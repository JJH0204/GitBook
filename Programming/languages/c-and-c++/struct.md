# Struct

{% stepper %}
{% step %}
### 값 타입 (Value Type)

* 구조체의 인스턴스를 변수나 상수에 할당하거나 전달할 때, 해당 인스턴스의 복사본이 생성되고 전달된다.
* 클래스는 참조 타입이고, 참조(메모리 주소)가 전달된다.
* 데이터 무결성을 유지하는 데 유용하다.
{% endstep %}

{% step %}
### 초기화 (Initialization)

* 모든 프로퍼티가 초기화될 때까지 인스턴스가 생성되지 않는다.
* 자동으로 멤버와이즈 이니셜라이저를 제공한다.
* 프로퍼티 초기화를 위해 개별적으로 값을 제공할 수 있도록 한다.
* 사용자 정의 이니셜라이저를 추가할 수도 있다.
{% endstep %}

{% step %}
### 메서드 (Methods)

* 구조체 내부에서 메서드를 정의할 수 있으며, 기능을 수행하는데 사용할 수 있다.
* 메서드 내에서 구조체의 프로퍼티 값을 수정하기 위해서는 mutating 키워드를 메서드 앞에 추가해야 한다.
{% endstep %}

{% step %}
### 프로토콜 (Protocols)

* 원하는 프로토콜을 채택할 수 있다.
* 구조체가 특정 인터페이스를 준수하도록 강제하고, 다양한 유형과 함께 사용할 수 있는 일관된 기능을 제공한다.
{% endstep %}

{% step %}
### 유연성과 사용

* 커스텀 데이터 타입을 정의할 때 자주 사용된다.
* 좌표 시스템, 구성 설정, 복잡한 데이터 모델 등 표현할 때 유용하다.
* 값의 복사가 필요하거나 데이터의 불변성을 유지해야 할 때 특히 유용하다.
{% endstep %}
{% endstepper %}

#### 예제 코드

{% code title="dog.swift" %}
```swift
struct dog
{
    private let name: String     // 불변프로퍼티
    private var age: Int        // 가변프로퍼티
    private static var count: Int = 0

    init(name: String, age: Int = 1)      // 생성자
    {
        self.name = name
        self.age = age
        dog.count += 1
    }

    func getName() -> String { return name }
    func getAge() -> Int { return age }
    static func getCount() -> Int { return count }
    // mutating func setName(name : String) { self.name = name }
    mutating func setAge(age : Int) { self.age = age }
    func makeSound() -> String { return "멍멍" }
    static func call(_dog: dog, _name: String) -> String
    {
        if _name == _dog.name
        {
            return _dog.makeSound()
        }
        else
        {
            return "No Response"
        }
    }
}

let DDomi = dog(name: "또미", age: 12)
var Lemi = dog(name: "레미")

print(dog.call(_dog: DDomi, _name: "또미"))
print(dog.call(_dog: Lemi, _name: "레미"))

//print(DDomi.age)    // 프로퍼티를 private 으로 설정해 접근을 제한했다.

/* 구조체는 접근 제어 키워드를 설정하지 않으면 public 으로 동작한다. */

/* static 키워드를 활용해 dog 객체의 수량을 관리할 수 있다. */
print("현재 \(dog.getCount()) 마리 서식 중")

//DDomi.setAge(age: 11)  // DDomi라는 이름의 dog 객체는 상수(let)으로 선언되어 값 수정이 불가능하다
Lemi.setAge(age: 9)    // 변수(var)선언된 Lemi라는 이름의 dog 객체는 자유롭게 값 수정이 가능하다.
```
{% endcode %}

[클래스 와 구조체의 차이점](/broken/pages/fba7b2b039833de8f21bb8c224cf4a4bc533a229)
