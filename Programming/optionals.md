# Optionals

* 값이 있을 수도 없을 수도 있는 것을 의미
* 값이 없을 수도 있음을 가정하고 예외처리하는 것을 의미

```swift
var string = "정재호"

var number1 = Int(string)
// 문자열을 정수로 변환할 수 있을 때는 정상적인 값을 출력하지만 그렇지 않은 경우 nil 값을 반환한다

/* 옵셔널을 활용해서 nil 값일 경우 다른 어떤 값을 대입할 것인지 설정이 가능하다. */
var number2 = Int(string) ?? 0  // nil 값일 경우 ?? 이후 설정한 0이 대신 대입된다

/* 옵셔널 타입 */
var optionalNum: Int?   // 옵셔널 타입 선언
optionalNum = 10
// optionalNum + 3   // 값이 있을 수도 없을 수도 있는 옵셔널 타입에는 다른 자료형의 값을 더하거나 뺄 수 없음

/* 옵셔널 바인딩 */
// 위 같은 상황을 해결하기 위해 필요한 기능
// 옵셔널 타입의 변수에서 안전하게 값을 가져올 수 있는 방법
if var num = optionalNum {
    print(num)
}
// 옵셔널 타입 변수에서 꺼낸 값은 대괄호 안에서만 사용 가능

guard var guardNum = optionalNum else {
    return  // 값을 꺼내오기 실패했을 때 처리를 작성
}
guardNum
// 플레이그라운드에서는 사용 불가능

var optString: String? = nil

if let str = optString {
    print(str)  // nil 값을 가지고 있어 표시할 정보가 없어서 실행되지 않음
}

print(optString ?? "빈 문자열") // 디폴트 값을 활용한 예외처리

optString = "jaeho"

if let str = optString {
    print(str)  // nil 값이 아니라서 출력됨
}

print(optString!)  // 무조건 값이 존재할 것이라는 확신이 있을 때 사용하는 기능(강제 언랩핑)
```

간단 요약:

* Optional은 값이 있거나(nil) 없을 수 있는 타입을 뜻함.
* 안전하게 값을 꺼내려면 옵셔널 바인딩(if let / if var), guard let / guard var를 사용.
* 기본값을 주려면 nil 병합 연산자(??)를 사용.
* 강제 언랩핑(!)은 값이 반드시 존재한다고 확신할 때만 사용(실행 시 nil이면 런타임 오류).
