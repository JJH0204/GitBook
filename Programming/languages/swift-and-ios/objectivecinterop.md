# Objective-C 상호 운용성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-004-DO |
| 유형 | D&O (개념) |
| 목적 | 한 프로젝트에서 Swift와 Objective-C를 함께 쓰는 방법의 원리를 설명한다 |
| 확인 상태 | 미검증 (공개된 일반 지식을 정리했으며 Xcode에서 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 한 문장뿐이었다. 이 문서의 브리징 헤더, `@objc`, `-Swift.h` 설명은 원본에 없던 내용을 보충한 것이다. 설정 항목 이름은 Xcode 버전에 따라 다를 수 있다(버전 확인 필요).
{% endhint %}

## 1. 정의

Swift는 Objective-C와 같은 프로젝트에서 함께 쓰도록 설계되었다. 기존 Objective-C 코드를 Swift 프로젝트에서 호출할 수 있고, Swift 코드를 Objective-C에서 호출할 수도 있다.

## 2. 구성 요소

| 구성 요소 | 방향 | 역할 |
|---|---|---|
| 브리징 헤더 (Bridging Header) | Objective-C를 Swift에서 사용 | 이 헤더에 `#import`한 Objective-C 헤더의 선언을 같은 앱 타깃의 Swift 코드가 본다 |
| `<제품 모듈 이름>-Swift.h` | Swift를 Objective-C에서 사용 | Xcode가 자동 생성하는 헤더. Objective-C 파일이 이를 `#import`한다 |
| `@objc` | Swift를 Objective-C에 노출 | 해당 선언을 Objective-C 런타임에 공개한다 |
| `@objcMembers` | Swift를 Objective-C에 노출 | 클래스의 모든 멤버에 `@objc`를 적용한다 |
| `NSObject` 상속 | Swift를 Objective-C에 노출 | 클래스를 Objective-C 클래스로 쓰려면 `NSObject`의 서브클래스로 만든다 |

## 3. 동작 원리

### 3-1. Objective-C를 Swift에서 사용

1. 앱 타깃에 Objective-C 파일을 추가한다. Xcode가 브리징 헤더 생성을 제안한다.
2. 브리징 헤더(예: `<프로젝트>-Bridging-Header.h`)에 사용할 Objective-C 헤더를 `#import`한다.
3. 빌드 설정 `Objective-C Bridging Header`가 그 헤더 경로를 가리킨다.
4. Swift 파일에서 `import` 없이 해당 클래스를 쓴다.

```objc
// MyBridging-Header.h
#import "LegacyLogger.h"
```

```swift
let logger = LegacyLogger()
```

### 3-2. Swift를 Objective-C에서 사용

1. Swift 클래스를 `NSObject`의 서브클래스로 만들고 필요한 멤버에 `@objc`를 붙인다.
2. Objective-C 파일에서 `#import "<제품 모듈 이름>-Swift.h"`를 쓴다.
3. 생성된 헤더에 노출된 Swift 선언을 Objective-C에서 호출한다.

```swift
import Foundation

@objc class Greeter: NSObject {
    @objc func greet(name: String) -> String {
        return "Hello, \(name)"
    }
}
```

```objc
#import "MyApp-Swift.h"

Greeter *g = [[Greeter alloc] init];
NSString *s = [g greetWithName:@"World"];
```

### 3-3. 한계

| 대상 | Objective-C에서 사용 |
|---|---|
| 구조체 (`struct`) | 불가 |
| 연관값이 있는 열거형 | 불가 |
| 튜플, Swift 전용 제네릭 | 불가 |
| `NSObject`를 상속하지 않은 클래스 | 불가 |
| 전역 함수 | 불가 |
| `Int` 원시값 열거형 | `@objc` 적용 시 가능 |

{% hint style="warning" %}
CAUTION: 프레임워크 타깃에서는 브리징 헤더를 쓸 수 없다. 프레임워크는 우산 헤더(umbrella header)로 Objective-C 헤더를 공개한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 브리징 헤더 | Swift가 보게 할 Objective-C 헤더를 모아 놓은 헤더 파일 |
| 제품 모듈 이름 | Xcode 빌드 설정의 Product Module Name. 생성 헤더 이름에 쓰인다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 구조체를 Objective-C에서 쓸 수 없는 이유를 내 말로 설명해 본다.
- [ ] 기존 Objective-C 프로젝트에 Swift를 도입한다면 어느 파일부터 바꾸겠는가?
