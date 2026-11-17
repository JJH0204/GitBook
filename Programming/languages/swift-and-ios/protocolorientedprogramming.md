# 프로토콜 지향 프로그래밍 (POP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-010-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 프로토콜 지향 프로그래밍(POP)의 원리와 객체지향과의 차이를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 보강했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

프로토콜 지향 프로그래밍(Protocol-Oriented Programming, POP)은 프로토콜과 프로토콜 확장을 중심으로 타입을 설계하는 Swift의 방식이다. 클래스 상속 대신 프로토콜 채택으로 공통 동작을 정의한다. 구조체, 열거형, 클래스 모두 프로토콜을 채택할 수 있다.

## 2. 구성 요소

| 요소 | 역할 | 문서 |
|---|---|---|
| 프로토콜 | 공통 인터페이스를 정의한다 | [Swift 프로토콜](swift_protocol.md) |
| 프로토콜 확장 | 요구사항의 기본 구현을 제공한다 | [프로토콜 확장](protocolextension.md) |
| 값 타입 | 구조체, 열거형으로 구현한다 | [구조체](swift-language-basics/struct.md) |

## 3. 동작 원리

1. 프로토콜로 공통 인터페이스를 정한다.
2. 프로토콜 확장으로 기본 구현을 둔다.
3. 각 타입이 프로토콜을 채택하며 필요하면 기본 구현을 재정의한다.
4. 호출하는 쪽은 프로토콜 타입만 알면 되므로 구체 타입에 의존하지 않는다(다형성).

## 4. 예제 코드

### 4-1. 프로토콜과 클래스 (원본)

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

### 4-2. 값 타입과 프로토콜 확장 (보강)

```swift
protocol Movable
{
    var name: String { get }
    func move()
}

extension Movable
{
    func move() { print("\(name) is moving.") }   // 기본 구현
}

struct Scooter: Movable
{
    let name: String                // 기본 구현을 그대로 쓴다
}

struct Boat: Movable
{
    let name: String
    func move() { print("\(name) is sailing.") }   // 기본 구현 재정의
}

let items: [Movable] = [Scooter(name: "Scooter"), Boat(name: "Boat")]
items.forEach { $0.move() }
```

{% hint style="info" %}
NOTE: 4-2는 원본에 없던 예제다. 원본 예제는 클래스 기반이라 POP의 핵심인 프로토콜 확장 기본 구현과 값 타입 채택이 드러나지 않아 보강했다.
{% endhint %}

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-1 `startJourney` | `Drivable`을 채택한 어떤 타입이든 받아 `drive()`를 호출한다. 호출되는 구현은 전달된 객체의 타입에 따라 정해진다 |
| 4-2 `extension Movable` | `move()`의 기본 구현. `Scooter`는 이를 쓰고 `Boat`는 재정의한다 |
| 4-2 `items` | 서로 다른 구조체를 `[Movable]` 배열에 담아 같은 방식으로 호출한다 |

## 6. 한계·주의

- 객체지향과 비교한 표는 [OOP와 POP 비교](../../software-design/oop/oopvspopcomparison.md)에 있다.
- 클래스가 필요한 경우(참조 의미, 상속 필요, Objective-C 연동)에는 POP만으로 해결되지 않는다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상속 계층 대신 프로토콜 확장을 쓰면 어떤 문제를 피하는가?
- [ ] 내가 만든 클래스 계층 중 프로토콜로 바꿀 만한 것이 있는가?
