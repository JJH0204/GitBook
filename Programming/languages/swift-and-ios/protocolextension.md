# 프로토콜 확장 (Extension)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-011-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 프로토콜 확장으로 기본 구현을 제공하는 방법과 호출 방식(디스패치)의 차이를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 보강했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

프로토콜 확장(protocol extension)은 `extension 프로토콜이름 { }`으로 프로토콜을 채택한 모든 타입에 메서드와 계산 프로퍼티의 기본 구현을 제공하는 문법이다.

## 2. 구성 요소

| 요소 | 설명 |
|---|---|
| 프로토콜 요구사항 | 프로토콜 본문에 선언한 멤버. 채택 타입이 구현을 재정의할 수 있다 |
| 확장의 기본 구현 | 요구사항에 대한 기본 구현. 채택 타입이 구현하지 않으면 이것을 쓴다 |
| 확장에만 있는 멤버 | 프로토콜 본문에는 없고 확장에만 선언한 멤버 |
| 조건부 확장 | `extension P where Self: Q`처럼 조건을 붙인 확장 |

## 3. 동작 원리

1. 프로토콜 본문에 선언된 요구사항은 동적 디스패치된다. 변수의 타입이 프로토콜이어도 채택 타입의 구현이 호출된다.
2. 프로토콜 본문에 없고 확장에만 있는 멤버는 정적 디스패치된다. 변수의 선언된 타입에 따라 구현이 정해진다.

## 4. 예제 코드

### 4-1. 기본 구현

{% code title="Greetable.swift" %}
```swift
protocol Greetable
{
    var name: String { get }
    func greet()
}

extension Greetable
{
    func greet()
    {
        print("Hello, \(name)")
    }
}

struct Emp: Greetable
{
    var name: String
}

let emp = Emp(name: "Steve")
emp.greet()
```
{% endcode %}

### 4-2. 디스패치 차이 (보강)

```swift
protocol Speaker
{
    func speak()            // 요구사항
}

extension Speaker
{
    func speak() { print("...") }          // 기본 구현
    func shout() { print("(extension) AH") }   // 확장에만 있는 멤버
}

struct Dog: Speaker
{
    func speak() { print("Woof") }
    func shout() { print("(Dog) WOOF") }
}

let d1 = Dog()
let d2: Speaker = Dog()

d1.speak()   // Woof
d2.speak()   // Woof  (요구사항: 동적 디스패치)
d1.shout()   // (Dog) WOOF
d2.shout()   // (extension) AH  (확장 전용 멤버: 정적 디스패치)
```

{% hint style="info" %}
NOTE: 4-2는 원본에 없던 예제이며, 주석의 출력은 Swift 언어 규칙에서 도출한 것으로 실행해 확인하지 않았다.
{% endhint %}

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-1 | `Emp`는 `greet()`를 구현하지 않았지만 확장의 기본 구현을 쓴다. `name`은 요구사항이라 `Emp`가 제공한다 |
| 4-2 `d2.speak()` | `speak`가 요구사항이므로 실제 타입 `Dog`의 구현이 호출된다 |
| 4-2 `d2.shout()` | `shout`는 확장에만 있어 `Speaker` 타입으로 선언된 변수에서는 확장의 구현이 호출된다 |

## 6. 한계·주의

{% hint style="warning" %}
CAUTION: 채택 타입이 재정의하게 하려는 멤버는 프로토콜 본문에도 선언한다. 확장에만 선언하면 프로토콜 타입 변수로 호출할 때 재정의한 구현이 무시된다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 요구사항과 확장 전용 멤버의 호출 결과가 다른 이유를 내 말로 설명해 본다.
- [ ] 기본 구현을 쓰면 상속과 비교해 무엇이 좋아지는가?
