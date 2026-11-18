# Swift란 무엇인가 (Swift)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-001-DO |
| 유형 | D&O (개념) |
| 목적 | Swift 언어의 정의, 역사, 지원 플랫폼, 주요 특징을 설명한다 |
| 확인 상태 | 미검증 (원본과 공개된 일반 지식을 정리했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

Swift는 Apple이 개발한 범용 프로그래밍 언어다. iOS, iPadOS, macOS, watchOS, tvOS, visionOS 앱 개발에 쓰이며, Objective-C를 대체하는 언어로 설계되었다. 컴파일 언어이며 컴파일러는 LLVM을 기반으로 한다.

## 2. 구성 요소

### 2-1. 역사와 플랫폼

| 항목 | 내용 | 비고 |
|---|---|---|
| 발표 | 2014년 WWDC | |
| 오픈소스 공개 | 2015년 12월 | 컴파일러와 표준 라이브러리 |
| Swift 5 | 2019년 | Apple 플랫폼에서 ABI 안정화 |
| Apple 플랫폼 | iOS, iPadOS, macOS, watchOS, tvOS, visionOS | |
| 그 밖의 플랫폼 | Linux, Windows | 지원 범위는 버전 확인 필요 |

### 2-2. 언어 특징

| 특징 | 설명 | 상세 문서 |
|---|---|---|
| 타입 안전 | 타입이 맞지 않는 값의 사용을 컴파일 시점에 막는다 | [기본 문법](swiftbasicsyntax.md) |
| 옵셔널 | `nil`을 가질 수 있는 변수는 `Int?`처럼 타입에 표시한다. `nil`을 가질 수 없는 타입에 `nil`을 대입하면 컴파일 오류가 난다 | [옵셔널](optionals.md) |
| 클로저 | 이름 없는 함수 값. 주변 변수를 캡처한다 | [클로저](closures.md) |
| 프로토콜 | 메서드·프로퍼티 요구사항의 묶음. 클래스, 구조체, 열거형이 채택한다 | [Swift 프로토콜](swift_protocol.md) |
| 제네릭 | 타입을 매개변수로 두어 하나의 코드를 여러 타입에 쓴다. 타입 안전을 유지한다 | |
| 값 타입 중심 | `struct`, `enum`은 값 타입이다. `class`는 참조 타입이다 | [클래스 대 구조체 비교](swift-language-basics/classvsstructdifference.md) |
| 메모리 관리 | 가비지 컬렉터 없이 자동 참조 카운팅(ARC, Automatic Reference Counting)을 쓴다 | [클래스 개념](swift-language-basics/classconcepts.md) |
| 문법 | 문자열 보간(`"\(x)"`), 타입 추론 등으로 간결하게 쓴다 | [기본 문법](swiftbasicsyntax.md) |

{% hint style="info" %}
NOTE: 원본에 있던 "Objective-C보다 빠르다"는 문장은 삭제했다. 속도는 작업과 컴파일러 최적화에 따라 달라지며 일반화할 수 없다. 이 문서는 Swift가 성능을 고려해 설계되고 컴파일러 최적화를 받는다는 사실만 적는다.
{% endhint %}

### 2-3. Objective-C와의 관계

같은 프로젝트에서 Swift와 Objective-C 코드를 함께 쓸 수 있다. 방법은 [Objective-C 상호 운용성](objectivecinterop.md)에 있다.

## 3. 동작 원리

1. 소스 코드(`.swift`)를 Swift 컴파일러가 컴파일한다.
2. 컴파일러가 LLVM으로 대상 플랫폼의 기계어를 생성한다.
3. 실행 중 클래스 인스턴스의 메모리는 참조 횟수가 0이 될 때 해제된다(ARC).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ARC | Automatic Reference Counting. 참조 횟수로 클래스 인스턴스를 해제하는 방식 |
| ABI | Application Binary Interface. 컴파일된 바이너리 사이의 호출 규약 |
| LLVM | 컴파일러 기반 구조(인프라) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Swift가 Objective-C와 비교해 어떤 점에서 더 안전한가?
- [ ] 옵셔널이 없는 언어에서 겪은 오류를 하나 적어 본다.
