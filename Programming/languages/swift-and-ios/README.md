---
description: Swift 언어 문법과 iOS 개발 도구(Xcode, UIKit, SwiftUI) 정리
---

# Swift 및 iOS (Swift & iOS)

Swift 언어와 iOS 앱 개발의 기초를 정리한다. 문서 번호(Task ID)는 `PRG-SWF-<번호>-<유형>`(Swift 언어)과 `PRG-IOS-<번호>-<유형>`(iOS 개발) 형식이다.

{% hint style="info" %}
NOTE: 이 그룹의 문서는 코드를 읽고 정리한 것이며 컴파일·실행하지 않았다(확인 상태: 미검증). Swift 버전과 iOS 버전에 따라 달라지는 문법·API는 각 문서에 "버전 확인 필요"로 표시했다.
{% endhint %}

## 문서 목록: Swift 언어

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-SWF-001-DO | D&O | [Swift란 무엇인가](whatisswift.md) | 언어의 정의, 역사, 플랫폼, 특징을 파악한다 |
| PRG-SWF-002-DO | 안내 | [Swift 언어 특징](swiftcharacteristics.md) | 통합된 문서의 위치를 찾는다 |
| PRG-SWF-003-REF | 표 | [Swift 주요 기능](swiftmainfeatures.md) | 주요 기능과 상세 문서를 찾는다 |
| PRG-SWF-004-DO | D&O | [Objective-C 상호 운용성](objectivecinterop.md) | 브리징 헤더와 `@objc`의 용도를 파악한다 |
| PRG-SWF-005-DO | D&O + 예제 | [Swift 기본 문법 예제](swiftbasicsyntax.md) | 자료형, 문자열, 컬렉션, 제어문 문법을 본다 |
| PRG-SWF-006-DO | D&O + 예제 | [옵셔널](optionals.md) | `nil` 처리 방법을 파악한다 |
| PRG-SWF-007-DO | D&O + 예제 | [클로저](closures.md) | 클로저 문법과 캡처를 파악한다 |
| PRG-SWF-008-DO | D&O + 예제 | [단일 표현식](singleexpression.md) | `return` 생략 규칙을 파악한다 |
| PRG-SWF-009-DO | D&O + 예제 | [Swift 프로토콜](swift_protocol.md) | 프로토콜 요구사항 문법을 파악한다 |
| PRG-SWF-010-DO | D&O + 예제 | [프로토콜 지향 프로그래밍](protocolorientedprogramming.md) | POP의 원리를 파악한다 |
| PRG-SWF-011-DO | D&O + 예제 | [프로토콜 확장](protocolextension.md) | 기본 구현과 디스패치 차이를 파악한다 |

## 문서 목록: Swift 언어 기초 하위 그룹

[Swift 언어 기초](swift-language-basics/README.md)에 구조체, 클래스, 비교, 열거형 문서(PRG-SWF-012 ~ 015)가 있다.

## 문서 목록: iOS 개발

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-IOS-001-DO | D&O | [iOS 개발 도구 (Xcode)](iosdevelopment.md) | Xcode 구성 요소를 파악한다 |
| PRG-IOS-002-MP | MP | [Xcode 새 앱 프로젝트 생성](createxcodeproject.md) | iOS 앱 프로젝트를 만든다 |
| PRG-IOS-003-DO | D&O | [스토리보드](storyboard.md) | 스토리보드의 구조와 장단점을 파악한다 |
| PRG-IOS-004-REF | 표 | [UIKit 프레임워크](uikitreference.md) | UIKit 구성 요소와 뷰 컨트롤러 생명주기를 찾는다 |
| PRG-IOS-005-REF | 표 | [UIView 클래스](uiviewreference.md) | `UIView` 프로퍼티와 메서드를 찾는다 |
| PRG-IOS-006-DO | D&O + 예제 | [SwiftUI 프레임워크](swiftui.md) | SwiftUI의 선언적 방식과 UIKit과의 차이를 파악한다 |

## 읽는 순서

1. PRG-SWF-001-DO로 언어 전체상을 본다.
2. PRG-SWF-005-DO로 기본 문법을 본다.
3. PRG-SWF-006-DO(옵셔널)와 PRG-SWF-007-DO(클로저)를 읽는다.
4. 하위 그룹에서 구조체, 클래스, 열거형을 읽는다.
5. PRG-SWF-009-DO부터 프로토콜 문서를 읽는다.
6. PRG-IOS-001-DO부터 iOS 개발 문서를 읽는다.
