# SwiftUI 프레임워크 (SwiftUI)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-IOS-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | SwiftUI의 선언적 방식, 장단점, 최소 예제를 설명한다 |
| 확인 상태 | 미검증 (예제 코드를 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `@main`과 `App` 프로토콜 기반 구조는 iOS 14 이상 SDK에서 쓴다. 이 문서의 예제와 API는 SwiftUI 버전에 따라 다를 수 있다(버전 확인 필요).
{% endhint %}

## 1. 정의

SwiftUI는 2019년 Apple이 도입한 UI 프레임워크다. 선언적(declarative) 방식으로 UI를 구성한다. 개발자는 UI의 각 요소가 어떻게 보이고 동작하는지 기술하고, 시스템이 이를 화면에 구현한다. iOS 13 이상에서 쓸 수 있다.

## 2. 구성 요소

| 구분 | 항목 | 설명 |
|---|---|---|
| 장점 | 선언적 구문 | UI 코드가 간결하고 이해하기 쉽다 |
| 장점 | 여러 Apple 플랫폼 | iOS, macOS, watchOS, tvOS 등 Apple 플랫폼에서 쓸 수 있다(Apple 플랫폼에 한정) |
| 장점 | 동적 UI | 상태가 바뀌면 UI가 자동으로 갱신된다 |
| 장점 | 코드 통합 | UI와 로직을 같은 코드 안에서 관리한다 |
| 단점 | 학습 곡선 | UIKit 사용자는 새 개념과 구문을 익혀야 한다 |
| 단점 | 하위 호환성 | iOS 13 이상에서만 동작한다 |

## 3. 동작 원리

1. 뷰를 `View` 프로토콜을 채택한 구조체로 만들고 `body`에 UI를 기술한다.
2. 상태를 `@State` 같은 프로퍼티 래퍼로 선언한다.
3. 상태가 바뀌면 SwiftUI가 `body`를 다시 계산해 바뀐 부분을 갱신한다.

UIKit과 함께 쓸 수 있다. `UIHostingController`는 SwiftUI 뷰를 UIKit에 넣고, `UIViewRepresentable`은 UIKit 뷰를 SwiftUI에 넣는다.

## 4. 예제 코드

```swift
import SwiftUI

struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Add") {
                count += 1
            }
        }
    }
}
```

{% hint style="info" %}
NOTE: 이 예제는 원본에 없던 최소 예제다. 원본에는 코드 예시가 없었다.
{% endhint %}

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `struct CounterView: View` | 뷰는 구조체다. `View` 프로토콜은 `body`를 요구한다 |
| `@State private var count` | 뷰가 소유하는 상태. 값이 바뀌면 `body`가 다시 계산된다 |
| `VStack` | 자식 뷰를 세로로 배치한다 |
| `Button("Add") { }` | 눌렀을 때 클로저가 실행된다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 선언적 방식과 UIKit의 명령형 방식은 어떻게 다른가?
- [ ] 기존 UIKit 앱에 SwiftUI를 도입한다면 어디부터 적용하겠는가?
