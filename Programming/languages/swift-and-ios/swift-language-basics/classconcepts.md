# ClassConcepts

{% stepper %}
{% step %}
### 참조 타입 (Reference Type)

* 클래스의 인스턴스가 변수나 상수에 할당될 때, 그 값이 아닌 참조(메모리 주소)가 전달된다.
* 여러 변수가 같은 인스턴스를 참조할 수 있다.
* 변수에서 인스턴스의 데이터를 변경하면 다른 모든 참조자에게도 반영된다.
{% endstep %}

{% step %}
### 상속 (Inheritance)

* 기존 클래스의 메서드, 프로퍼티, 기타 특성을 상속받아 사용하거나 확장할 수 있다.
* 코드의 재사용성을 높이고, 복잡한 관계를 효과적으로 모델링 할 수 있다.
{% endstep %}

{% step %}
### 생성자와 소멸자 (Initializers N Deinitializers)

* 클래스는 생성자 (init)를 사용하여 인스턴스 초기화를 수행한다.
* 생성자는 인스턴스 생성 시 초기 설정을 위해 호출된다.
* deinit을 사용하여 인스턴스가 메모리에서 해제되기 전에 필요한 작업을 수행할 수 있다.
{% endstep %}

{% step %}
### 참조 카운팅 (Reference Counting) 또는 가비지 콜랙터

* swift에서는 자동 참조 카운팅(ARC)을 사용하여 클래스 인스턴스의 메모리 관리를 수행한다.
* 인스턴스에 대한 참조가 더 이상 필요하지 않을 때 자동으로 메모리를 해제한다.
{% endstep %}

{% step %}
### 메서드 오버라이딩 (Method Overriding)

* 상속 받은 메서드를 override 키워드를 사용하여 재정의 할 수 있다.
* 상속 받은 클래스의 기능을 자식 클래스에 맞게 조정할 수 있다.
{% endstep %}

{% step %}
### 타입 캐스팅 (Type Casting)

* swift의 클래스 인스턴스는 런타임 시 그 타입이 확인될 수 있으며, as? 또는 as!를 사용하여 다운캐스팅할 수 있다.
* 클래스 계층 내에서 인스턴스 타입을 변환하고 확인하는 데 사용된다.
{% endstep %}

{% step %}
### 접근 제어 (Access Control)

* 프로퍼티, 메서드 및 기타 멤버는 public, internal, private 등 접근 제어자를 사용하여 캡슐화를 관리할 수 있다.
* 클래스 내부의 데이터를 보호하고 인터페이스를 명확하게 할 수 있다.
{% endstep %}

{% step %}
### 클래스 프로퍼티와 메서드 (Class Properties and Methods)

* static 키워드를 사용해 클래스 자체에 속한 프로퍼티와 메서드를 정의할 수 있다.
* 클래스 이름을 통해 접근된다.
* class 키워드를 사용한 메서드는 서브클래스에서 오버라이드 될 수 있다.
{% endstep %}
{% endstepper %}

#### 예제 코드

{% code title="Dog.swift" %}
```swift
class Dog

{

    private var _name : String

    private var _age : Int

    private static var _count : Int = 0

    init(_name: String = "", _age: Int = 1) {

        self._name = _name

        self._age = _age

        Dog._count += 1

    }

    func getName() -> String { return _name }

    func getAge() -> Int { return _age }

    static func getCount() -> Int { return _count }

    func setName(name : String = "") { _name = name }

    func setAge(age : Int = 1) { _age = age }

    func makeSound() -> String { return "멍멍" }

    func makeSound(count : Int) -> String       // 동일한 함수 이름에 파라미터를 다르게 하여 서로 다른 함수로 인식하도록 한다.

    {

        var sound : String = ""

        for n in 0 ..< count

        {

            sound += "멍"

        }

        return sound

    }

    static func _call(_dog : Dog, _name : String) -> String

    {

        if _name == _dog._name

        {

            return _dog.makeSound(count: 5)     // 파라미터에 따라 호출되는 메서드가 달라진다.

        }

        else

        {

            return "No Response"

        }

    }

}

  

let dogDDomi = Dog(_name : "또미", _age : 12)

dogDDomi.setAge(age: 11)      // dogDDomi라는 이름의 객체를 상수로 선언했음에도 값 수정이 가능하다.

print(Dog._call(_dog: dogDDomi, _name: "또미"))

print("현재 \(Dog.getCount()) 마리 서식 중")

  

class Minipin : Dog     // Dog 클래스를 상속 받아 minipin 클래스를 새롭게 만든다.

{

    override func makeSound() -> String {

        return "캉!"

    }

    override func makeSound(count: Int) -> String {

        var sound : String = ""

        for n in 0 ..< count

        {

            sound += "캉!"

        }

        return sound

    }

}

  

let dogLemi = Minipin(_name: "레미", _age: 10)

dogLemi.setAge(age: 9)

print(Minipin._call(_dog: dogLemi, _name: "레미"))

print("현재 \(Minipin.getCount())")
```
{% endcode %}

[클래스 와 구조체의 차이점](classvsstructdifference.md)
