# SwiftProtocolExtension

프로토콜의 확장을 통해 프로토콜을 채택한 모든 타입에 대해 메서드, 계산된 속성 등의 기본 구현을 제공할 수 있다.

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

{% hint style="info" %}
* 본 예제에서 Greetable 프로토콜은 greet() 메서드의 기본 구현을 제공한다.
{% endhint %}
