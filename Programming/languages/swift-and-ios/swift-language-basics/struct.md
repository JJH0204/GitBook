# 구조체 (Struct)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-012-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 구조체의 값 타입 성질, 이니셜라이저, `mutating`, 접근 수준을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

구조체(`struct`)는 프로퍼티와 메서드를 묶는 값 타입(value type)이다. 변수나 상수에 대입하거나 함수에 전달할 때 인스턴스의 복사본이 만들어진다. 클래스는 참조 타입이며 참조(메모리 주소)가 전달된다. 둘의 비교는 [클래스 대 구조체 비교](classvsstructdifference.md)에 있다.

## 2. 구성 요소

| 구성 요소 | 설명 |
|---|---|
| 값 타입 | 복사본이 독립적이라 데이터 무결성을 유지하기 쉽다 |
| 멤버와이즈 이니셜라이저 | 모든 저장 프로퍼티를 인자로 받는 이니셜라이저를 자동 제공한다. 구조체 본문에 사용자 정의 `init`을 만들면 자동 제공이 사라진다. 사용자 정의 `init`을 `extension`에 만들면 둘 다 쓸 수 있다 |
| 메서드 | 구조체 안에 정의한다. 프로퍼티 값을 바꾸는 메서드에는 `mutating`을 붙인다 |
| 프로토콜 채택 | 프로토콜을 채택해 일관된 인터페이스를 제공한다 |
| 접근 수준 | 접근 제어 키워드를 쓰지 않으면 `internal`이다(같은 모듈 안에서 접근 가능) |
| 용도 | 좌표, 설정값, 데이터 모델처럼 복사 의미가 자연스럽거나 불변성이 필요한 경우 |

## 3. 동작 원리

1. 모든 저장 프로퍼티가 초기화되어야 인스턴스가 만들어진다.
2. 인스턴스를 `let`으로 선언하면 프로퍼티가 `var`여도 값을 바꿀 수 없다(값 타입이므로 인스턴스 전체가 상수다).
3. 인스턴스를 `var`로 선언하면 `mutating` 메서드를 호출할 수 있다.

## 4. 예제 코드

{% code title="Dog.swift" %}
```swift
struct Dog
{
    private let name: String     // 불변프로퍼티
    private var age: Int        // 가변프로퍼티
    private static var count: Int = 0

    init(name: String, age: Int = 1)      // 생성자
    {
        self.name = name
        self.age = age
        Dog.count += 1
    }

    func getName() -> String { return name }
    func getAge() -> Int { return age }
    static func getCount() -> Int { return count }
    // mutating func setName(name : String) { self.name = name }
    mutating func setAge(age : Int) { self.age = age }
    func makeSound() -> String { return "멍멍" }
    static func call(_ dog: Dog, _ name: String) -> String
    {
        if name == dog.name
        {
            return dog.makeSound()
        }
        else
        {
            return "No Response"
        }
    }
}

let ddomi = Dog(name: "또미", age: 12)
var lemi = Dog(name: "레미")

print(Dog.call(ddomi, "또미"))
print(Dog.call(lemi, "레미"))

//print(ddomi.age)    // 프로퍼티를 private 으로 설정해 접근을 제한했다.

/* 접근 제어 키워드를 설정하지 않으면 internal(같은 모듈 안에서만 접근)로 동작한다. */

/* static 키워드를 활용해 Dog 인스턴스의 수량을 관리할 수 있다. */
print("현재 \(Dog.getCount()) 마리 서식 중")

//ddomi.setAge(age: 11)  // ddomi는 상수(let)로 선언되어 값 수정이 불가능하다
lemi.setAge(age: 9)    // 변수(var)로 선언된 lemi는 값 수정이 가능하다.
```
{% endcode %}

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `private let name` | 선언된 타입 안에서만 접근 가능한 불변 프로퍼티. `let`이라 `init`에서 한 번만 대입한다 |
| `private static var count` | 타입 자체에 속한 변수. 인스턴스를 만들 때마다 `init`에서 1 증가한다 |
| `init(name:age:)` | 사용자 정의 이니셜라이저. 이것이 있으므로 자동 멤버와이즈 이니셜라이저는 없다. `age`의 기본값 1 때문에 `Dog(name: "레미")`로 만들 수 있다 |
| `mutating func setAge` | 자기 프로퍼티를 바꾸므로 `mutating`이 필요하다. `let` 인스턴스에서는 호출할 수 없다 |
| `call(_ dog:_ name:)` | 원본은 `call(_dog:_name:)`이라 인자 라벨이 `_dog`, `_name`이 되었다. `_ dog`로 고쳐 라벨을 생략했다 |

## 6. 한계·주의

{% hint style="info" %}
NOTE: 원본 타입 이름 `dog`를 관례(UpperCamelCase)에 맞춰 `Dog`로, `DDomi`, `Lemi`를 `ddomi`, `lemi`로 바꿨다. 원본 주석 "접근 제어 키워드가 없으면 public"은 사실과 달라 `internal`로 정정했다. `static var`는 Swift 6 언어 모드에서 동시성 안전 오류가 날 수 있다(버전 확인 필요).
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 구조체를 `let`으로 선언하면 왜 프로퍼티도 못 바꾸는지 내 말로 설명해 본다.
- [ ] 구조체로 만들어 보고 싶은 데이터 모델을 하나 적어 본다.
