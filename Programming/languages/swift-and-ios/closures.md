# 클로저 (Closures)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-007-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 클로저 문법, 축약 형태, 변수 캡처와 순환 참조를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

클로저(closure)는 코드에서 전달하고 사용할 수 있는 자체 포함 기능 블록이다. 다른 언어의 람다 함수, 익명 함수와 비슷하다. 클로저가 정의된 범위의 상수와 변수를 캡처(capture)해 참조하고 수정할 수 있다.

## 2. 구성 요소

### 2-1. 기본 형태

```swift
{ (parameters) -> return type in
    statements
}
```

| 부분 | 설명 |
|---|---|
| `parameters` | 입력 파라미터 목록. 함수의 파라미터와 비슷하게 쓴다 |
| `return type` | 반환 타입 |
| `in` | 파라미터·반환 타입과 본문을 나누는 키워드 |
| `statements` | 실행 코드 |

### 2-2. 축약 규칙

| 규칙 | 설명 |
|---|---|
| 문맥을 통한 타입 추론 | 파라미터와 반환 타입이 주변 코드에서 정해지면 생략한다 |
| 단일 표현식의 암시적 반환 | 본문이 식 하나면 `return`을 생략한다. 상세는 [단일 표현식](singleexpression.md) |
| 단축 인자 이름 | `$0`, `$1`, `$2`로 파라미터를 가리킨다 |
| 후행 클로저 (trailing closure) | 마지막 인자가 클로저면 괄호 밖에 쓴다 |

## 3. 동작 원리

1. 클로저는 참조 타입처럼 동작한다. 변수에 담아 전달하고 나중에 호출한다.
2. 클로저 본문이 바깥 변수를 쓰면 그 변수를 캡처한다. 캡처한 변수는 값이 아니라 변수 자체를 참조한다.
3. 클로저를 함수 밖에서 나중에 실행하려고 저장하거나 반환하면 그 파라미터에 `@escaping`을 붙인다.

## 4. 예제 코드

### 4-1. 기본 형태

```swift
let add: (Int, Int) -> Int = { (a, b) in
    return a + b
}

print(add(3, 4)) // 7 출력
```

### 4-2. 축약 형태

```swift
/*
let multiply = { $0 * $1 }
print(multiply(3, 5))  // 15 출력
*/ // 위 방식의 축약에서 컴파일 오류가 발생한다. (Ambiguous use of operator "*")

/* 오류를 피하는 축약: 타입을 명시한다 */
let multiply: (Int, Int) -> Int = { $0 * $1 }
print(multiply(3, 5))

/* 또 다른 축약 형태 */
let minus = { (x: Int, y: Int) -> Int in x - y }

print(minus(5, 1))
```

### 4-3. 정렬에 클로저 전달과 후행 클로저

```swift
let numArray = [1, 5, 3, 12, 2]

// 정렬 조건 인자로 클로저를 전달해 내림차순 정렬을 수행
let sortArray = numArray.sorted(by: { $0 > $1 })
print(sortArray)

// 후행 클로저: 마지막 인자이므로 괄호 밖에 쓴다
let sortArray2 = numArray.sorted { $0 > $1 }
print(sortArray2)
```

### 4-4. 캡처와 `@escaping`

```swift
func makeCounter() -> () -> Int {
    var count = 0
    return {            // 반환되는 클로저가 count를 캡처한다
        count += 1
        return count
    }
}

let counter = makeCounter()
print(counter())   // 1
print(counter())   // 2

var handlers: [() -> Void] = []
func register(handler: @escaping () -> Void) {   // 함수 밖에서 나중에 실행하므로 @escaping
    handlers.append(handler)
}
```

### 4-5. 순환 참조와 캡처 리스트

```swift
class Loader {
    var name = "loader"
    var onDone: (() -> Void)?
    func start() {
        onDone = { [weak self] in      // self를 약하게 캡처해 순환 참조를 끊는다
            print(self?.name ?? "해제됨")
        }
    }
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-2 첫 번째 블록 | 문맥이 없어 컴파일러가 `*`의 어떤 오버로드와 파라미터 타입을 쓸지 정하지 못한다. 클로저 변수에 타입을 적으면 해결된다 |
| 4-3 | `sorted(by:)`의 파라미터 타입은 `(Int, Int) -> Bool`이라 `$0`, `$1`의 타입이 추론된다 |
| 4-4 `count` | `makeCounter`가 반환된 뒤에도 클로저가 `count`를 유지한다. 호출할 때마다 같은 변수가 증가한다 |
| 4-5 `[weak self]` | `self`가 클로저를, 클로저가 `self`를 강하게 잡으면 둘 다 해제되지 않는다(강한 순환 참조). 캡처 리스트로 `weak` 또는 `unowned`를 지정한다 |

## 6. 한계·주의

{% hint style="warning" %}
CAUTION: `self`가 저장된 클로저를 소유하고 그 클로저가 `self`를 강하게 캡처하면 메모리가 해제되지 않는다. 저장되는 클로저에서는 `[weak self]`를 검토한다.
{% endhint %}

- C의 함수 포인터와 같이 함수를 값으로 넘기는 용도로 쓰지만, 클로저는 주변 변수를 캡처할 수 있고 C 함수 포인터는 캡처할 수 없다. 관련 문서: [함수 포인터](../c-and-c++/advanced-c/function-pointers.md).
- 클로저 활용 예: 비동기 작업의 완료 처리, 컬렉션 처리(`map`, `filter`, `sorted`), 함수 인자로 동작 전달.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 클로저가 변수를 "캡처한다"는 말을 내 말로 설명해 본다.
- [ ] `[weak self]`가 필요했던 코드나 필요할 만한 상황을 적어 본다.
