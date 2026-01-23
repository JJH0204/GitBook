# Closures

* 코드에 전달되고 사용될 수 있는 자체 포함 기능 블록
* 다른 프로그래밍 언어의 람다 함수나 익명 함수와 유사
* 주변 상수와 변수를 캡쳐할 수 있다.
* 클로저가 정의된 범위의 상수와 변수를 참조하고 수정할 수 있음

### 기본 형태

```swift
{ (parameters) -> return type in
    statements
}
```

* parameters : 클로저가 받는 입력 파라미터 목록, 함수의 파라미터와 유사하게 작성
* return type : 클로저가 반환하는 데이터의 타입
* in : 파라미터와 반환 타입을 코드 본문과 분리하는 키워드
* statements : 클로저의 실행 코드를 포함하여, 필요한 작업을 수행하고 값을 반환

### 예제

```swift
let add: (Int, Int) -> Int = { (a, b) in
    return a + b
}

print(add(3, 4)) // 7 출력
```

### 축약 형태

* Swift는 클로저를 작성할 때 문법적 편의성을 제공한다.
* 코드를 더 간결하게 만들 수 있다.

```swift
/*
let multiply = { $0 * $1 }
print(multiply(3, 5))  // 15 출력
*/ // 위 방식의 축약에 에러가 발생했다. ([Ambiguous use of operator "*"](Ambiguous%20use%20of%20operator%20%22%2A%22.md))

/* 에러를 우회하는 축약 */
let multiply: (Int, Int) -> Int = { $0 * $1 }
print(multiply(3, 5))

/* 또 다른 축약 형태 */ 
let Minus = { (x: Int, y: Int) -> Int in x - y }

print(Minus(5, 1))
```

{% hint style="info" %}
* 문맥을 통한 타입 유추: 클로저의 파라미터와 반환 타입이 이미 알려진 [컨텍스트](file:///4766478/cs_basics/Context.md)에서 사용되는 경우 생략할 수 있다.
* 단일 표현식 클로저의 암시적 반환: 클로저가 [단일 표현식](/broken/pages/7a4b52a8ca15d1e99c56dbfaf60971e78ee7ecc6)으로만 구성된 경우, return 키워드를 생략할 수 있다.
* 단축 인자 이름: 클로저의 파라미터를 $0, $1, $2 등으로 간단히 참조할 수 있다.
{% endhint %}

### 활용

* 비동기 작업, 컬렉션 처리, 함수 인자로서의 기능 전달 등 다양한 곳에서 사용된다.

예제 (배열의 요소를 정렬하거나 변환하는 데 사용되는 클로저):

```swift
let numArray = [1, 5, 3, 12, 2]

// 정렬 조건 인자로 클로저를 전달해 내림차순 정렬을 수행
let sortArray = numArray.sorted(by: { $0 > $1 })

print(sortArray)
```

* C의 [함수 포인터](/broken/pages/483d19201f67796ee20673b9787ef0aedef51565) 사용 방법과 유사한 것 같다
