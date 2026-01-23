# ProtocolOrientedProgramming

* Swift는 프로토콜을 통해 강력한 프로토콜 지향 프로그래밍 패러다임을 지원합니다.
* 이를 통해 구조체, 클래스, 열거형 등이 프로토콜을 기반으로 유연하게 설계될 수 있습니다.
* 프로토콜을 채택함으로써 다양한 타입들이 프로토콜을 공통 인터페이스로 사용할 수 있어, 코드의 재사용성과 유지보수성이 향상됩니다. (다형성 지원)

### 예제

{% code title="Drivable.swift" %}
```swift
protocol Drivable
{
    func drive()
}

class Car: Drivable
{
    func drive()
    {
        print("Car is moving.")
    }
}

class Bicycle: Drivable
{
    func drive() {
        print("Bicycle is moving.")
    }
}

func startJourney(drivable: Drivable)
{
    drivable.drive()
}

let car = Car()
let bicycle = Bicycle()

startJourney(drivable: car)
startJourney(drivable: bicycle)
```
{% endcode %}

* 이 예에서 Drivable 프로토콜은 drive() 메서드를 요구하며, 다양한 타입(Car, Bicycle)이 이를 구현합니다.
* startJourney() 함수는 Drivable 프로토콜을 채택하는 모든 객체를 매개변수로 받아, 해당 타입에 맞는 drive() 메서드를 호출합니다.

### 관련 문서

[객체지향과 프로토콜 지향의 비교](/broken/pages/d2f2c2bc2357f0e77ac109105cea42b94be8de7a)
