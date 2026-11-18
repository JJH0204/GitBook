# 옵셔널 (Optionals)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-006-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 옵셔널의 정의와 값을 안전하게 꺼내는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `if let x`처럼 이름을 반복하지 않는 단축 문법은 Swift 5.7 이상에서 쓸 수 있다(버전 확인 필요).
{% endhint %}

## 1. 정의

옵셔널(Optional)은 "값이 있거나 `nil`이다"를 나타내는 타입이다. `Int?`는 `Int` 값 또는 `nil`을 가진다. 값이 없을 수 있음을 타입으로 표시하므로 컴파일러가 `nil` 처리를 강제한다.

`Optional`의 내부는 두 케이스를 가진 열거형이다.

```swift
enum Optional<Wrapped> {
    case none           // nil
    case some(Wrapped)  // 값이 있음
}
```

## 2. 구성 요소

| 문법 | 이름 | 값이 없을 때 | 용도 |
|---|---|---|---|
| `if let x = opt { }` | 옵셔널 바인딩 | 블록을 실행하지 않는다 | 값이 있을 때만 처리한다 |
| `guard let x = opt else { }` | guard 바인딩 | `else` 블록에서 빠져나간다 | 값이 없으면 조기 종료한다 |
| `opt ?? 기본값` | nil 병합 연산자 | 기본값을 쓴다 | 대체값을 지정한다 |
| `opt?.member` | 옵셔널 체이닝 | 전체 결과가 `nil`이다 | 연쇄 접근을 안전하게 한다 |
| `opt!` | 강제 언랩핑 | 런타임 오류(크래시) | 값이 반드시 있을 때만 쓴다 |
| `var x: Int!` | 암시적 언랩 옵셔널 | 접근 시 런타임 오류 | 초기화 직후부터 값이 보장될 때 쓴다 |

## 3. 동작 원리

1. 옵셔널 값은 일반 값과 다른 타입이다. `Int?`에 `Int`를 더할 수 없다.
2. 바인딩(`if let`, `guard let`)은 값이 있으면 언랩한 값을 새 상수에 넣는다.
3. 언랩한 값은 중괄호 `{}` 안(스코프)에서만 쓸 수 있다. `guard let`은 이후 같은 스코프 전체에서 쓸 수 있다.

## 4. 예제 코드

### 4-1. 변환 실패와 `??`

```swift
var string = "홍길동"

var number1 = Int(string)
// 문자열을 정수로 변환할 수 있을 때는 정상적인 값을 출력하지만 그렇지 않은 경우 nil 값을 반환한다

/* 옵셔널을 활용해서 nil 값일 경우 다른 어떤 값을 대입할 것인지 설정이 가능하다. */
var number2 = Int(string) ?? 0  // nil 값일 경우 ?? 이후 설정한 0이 대신 대입된다
```

`Int(string)`의 반환 타입은 `Int?`다. 변환할 수 없으면 `nil`이다.

### 4-2. 옵셔널 타입

```swift
/* 옵셔널 타입 */
var optionalNum: Int?   // 옵셔널 타입 선언
optionalNum = 10
// optionalNum + 3   // 값이 있을 수도 없을 수도 있는 옵셔널 타입에는 다른 자료형의 값을 더하거나 뺄 수 없음
```

### 4-3. 옵셔널 바인딩

```swift
/* 옵셔널 바인딩 */
// 옵셔널 타입의 변수에서 안전하게 값을 가져올 수 있는 방법
if var num = optionalNum {
    print(num)
}
// 옵셔널 타입 변수에서 꺼낸 값은 중괄호 `{}` 안(스코프)에서만 사용 가능

var optString: String? = nil

if let str = optString {
    print(str)  // nil 값을 가지고 있어 표시할 정보가 없어서 실행되지 않음
}

print(optString ?? "빈 문자열") // 디폴트 값을 활용한 예외처리

optString = "gildong"

if let str = optString {
    print(str)  // nil 값이 아니라서 출력됨
}

if let optString {      // Swift 5.7 이상: 같은 이름으로 언랩 (str 생략)
    print(optString)
}
```

### 4-4. `guard let`

`guard`는 함수 안에서 쓴다. 원본은 최상위 코드(Playground)에 `return`을 써서 오류가 났으므로 함수로 감쌌다.

```swift
func printNumber(_ value: Int?) {
    guard let number = value else {
        return  // 값을 꺼내오기 실패했을 때 처리를 작성
    }
    print(number)   // 이후 코드에서 number를 계속 쓸 수 있다
}

printNumber(10)
printNumber(nil)
```

### 4-5. 옵셔널 체이닝과 강제 언랩핑

```swift
let text: String? = "swift"
print(text?.count ?? 0)    // 값이 있으면 5, nil이면 0

print(optString!)  // 무조건 값이 존재할 것이라는 확신이 있을 때 사용하는 기능(강제 언랩핑)
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 4-1 | `Int(string)`은 변환 실패 시 `nil`을 반환하는 실패 가능 이니셜라이저다 |
| 4-2 | 옵셔널에는 `+`를 쓸 수 없다. 언랩하거나 `??`로 기본값을 줘야 한다 |
| 4-3 `if var` | 언랩한 값을 블록 안에서 수정하려면 `var`를 쓴다. 수정하지 않으면 `if let`을 쓴다 |
| 4-4 | `guard`의 `else` 블록은 반드시 함수 종료(`return`, `throw`) 또는 반복 종료(`break`, `continue`)로 끝나야 한다 |
| 4-5 `?.` | 중간에 `nil`이 나오면 이후 접근을 건너뛰고 결과를 `nil`로 만든다 |

## 6. 한계·주의

{% hint style="danger" %}
WARNING: 값이 `nil`인 옵셔널을 `!`로 강제 언랩핑하면 앱이 즉시 종료된다(런타임 오류). 값이 있다는 근거가 코드에서 확인될 때만 쓴다. 그렇지 않으면 `if let`, `guard let`, `??`를 쓴다.
{% endhint %}

- 원본 요약의 "값이 있거나(nil) 없을 수 있는"은 "값이 있거나 `nil`이다"가 정확하다.
- 원본의 "대괄호 안에서만 사용"은 중괄호 `{}`가 정확하다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `if let`과 `guard let`을 어떤 경우에 각각 쓰는가?
- [ ] `!`로 강제 언랩핑해서 앱이 죽은 경험이나 그럴 수 있는 상황을 적어 본다.
