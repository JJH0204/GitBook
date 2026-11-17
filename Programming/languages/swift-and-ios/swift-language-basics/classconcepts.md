# 클래스 개념 (Class)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-013-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 클래스의 참조 타입 성질, 상속, 소멸자, ARC, 접근 제어를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 컴파일하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

클래스(`class`)는 프로퍼티와 메서드를 묶는 참조 타입(reference type)이다. 인스턴스를 변수나 상수에 대입하면 값이 아니라 참조(메모리 주소)가 전달된다. 여러 변수가 같은 인스턴스를 참조할 수 있다.

## 2. 구성 요소

| 구성 요소 | 설명 |
|---|---|
| 참조 타입 | 한 참조로 데이터를 바꾸면 같은 인스턴스를 가리키는 모든 참조에 반영된다 |
| 상속 | 기존 클래스의 메서드·프로퍼티를 물려받고 확장한다 |
| 생성자 `init` | 인스턴스 생성 시 초기 설정을 한다 |
| 소멸자 `deinit` | 인스턴스가 메모리에서 해제되기 전에 정리 작업을 한다 |
| ARC | 자동 참조 카운팅. 참조가 0이 되면 인스턴스를 해제한다. Swift에는 가비지 컬렉터가 없다 |
| 오버라이딩 | 상속받은 메서드를 `override`로 재정의한다 |
| 타입 캐스팅 | `is`로 타입을 확인하고 `as?`, `as!`로 다운캐스팅한다 |
| 접근 제어 | `open`, `public`, `internal`(기본), `fileprivate`, `private` |
| 타입 멤버 | `static`(오버라이드 불가), `class`(서브클래스에서 오버라이드 가능) |
| `final` | 상속과 오버라이드를 막는다 |

접근 수준은 넓은 쪽부터 `open` > `public` > `internal` > `fileprivate` > `private`이다. `open`은 모듈 밖에서 상속·오버라이드까지 허용한다. 키워드를 쓰지 않으면 `internal`이다.

## 3. 동작 원리

1. `Dog(...)`를 호출하면 인스턴스가 만들어지고 참조 횟수가 1이 된다.
2. 변수에 대입하거나 전달하면 참조 횟수가 늘고, 참조가 사라지면 줄어든다.
3. 참조 횟수가 0이 되면 `deinit`이 호출되고 메모리가 해제된다.
4. 두 인스턴스가 서로를 강하게 참조하면 횟수가 0이 되지 않아 해제되지 않는다(순환 참조). `weak`, `unowned`로 끊는다.

## 4. 예제 코드

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

    func makeSound(count : Int) -> String       // 동일한 함수 이름에 파라미터를 다르게 하여 서로 다른 함수로 인식하도록 한다.
    {
        var sound : String = ""
        for _ in 0 ..< count
        {
            sound += "멍"
        }
        return sound
    }

    static func _call(_dog : Dog, _name : String) -> String
    {
        if _name == _dog._name
        {
            return _dog.makeSound(count: 5)     // 파라미터에 따라 호출되는 메서드가 달라진다.
        }
        else
        {
            return "No Response"
        }
    }
}

let dogDDomi = Dog(_name : "또미", _age : 12)
dogDDomi.setAge(age: 11)      // dogDDomi라는 이름의 객체를 상수로 선언했음에도 값 수정이 가능하다.
print(Dog._call(_dog: dogDDomi, _name: "또미"))
print("현재 \(Dog.getCount()) 마리 서식 중")

class Minipin : Dog     // Dog 클래스를 상속 받아 Minipin 클래스를 새롭게 만든다.
{
    override func makeSound() -> String {
        return "캉!"
    }

    override func makeSound(count: Int) -> String {
        var sound : String = ""
        for _ in 0 ..< count
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

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `let dogDDomi` | 클래스 인스턴스를 `let`에 담아도 참조만 상수다. 프로퍼티는 `var`면 바꿀 수 있다. 구조체와 다르다 |
| `makeSound()`, `makeSound(count:)` | 이름은 같고 파라미터가 다른 오버로드 두 개다 |
| `class Minipin : Dog` | 서브클래스가 새 지정 이니셜라이저를 만들지 않으면 부모의 이니셜라이저를 상속하므로 `Minipin(_name:_age:)`를 쓸 수 있다 |
| `override` | 부모 메서드를 재정의한다. 두 오버로드를 각각 재정의했다 |
| `_call` | 정적(static) 메서드. `Minipin._call`로도 호출되며 마지막 출력의 개수는 `Dog`와 `Minipin`이 공유하는 하나의 값이다 |
| `for _ in 0 ..< count` | 반복 변수를 쓰지 않으므로 `_`로 받는다. 원본의 `n`은 미사용 경고가 난다 |

## 6. 한계·주의

{% hint style="info" %}
NOTE: 원본의 코드 사이 공백 줄은 삭제했다. `private static var`는 Swift 6 언어 모드에서 동시성 안전 오류가 날 수 있다(버전 확인 필요). 원본 진단 중 "또는 가비지 콜렉터"라는 표현은 Swift에 가비지 컬렉터가 없으므로 쓰지 않는다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] ARC가 해제하지 못하는 순환 참조가 어떤 상황에서 생기는지 내 말로 설명해 본다.
- [ ] 클래스로 만들어야 하는 데이터와 구조체로 충분한 데이터를 하나씩 적어 본다.
