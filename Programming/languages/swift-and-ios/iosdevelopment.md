# iOS 개발 도구 (Xcode)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-IOS-001-DO |
| 유형 | D&O (개념) |
| 목적 | iOS 앱 개발에 쓰는 통합 개발 환경 Xcode의 구성 요소와 역할을 설명한다 |
| 확인 상태 | 미검증 (원본과 공개된 일반 지식을 정리했으며 Xcode에서 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: Xcode는 macOS에서만 실행된다. 메뉴 이름과 화면 구성은 Xcode 버전에 따라 다르다(버전 확인 필요).
{% endhint %}

## 1. 정의

Xcode는 Apple 플랫폼 앱을 개발하는 통합 개발 환경(IDE, Integrated Development Environment)이다. 코드 편집, 빌드, 디버깅, 시뮬레이터 실행, 성능 분석을 한 도구에서 한다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| 코드 편집기 | Swift, Objective-C 코드를 편집한다. 자동 완성과 오류 표시를 제공한다. 다른 코드 편집기(VS Code 등)와 비슷한 사용 방식이다 |
| Playground | 코드를 한 줄씩 실행해 결과를 보는 별도 환경. Swift 문법을 익힐 때 쓴다 |
| Simulator | Mac에서 iPhone, iPad를 흉내 내어 앱을 실행한다 |
| Interface Builder | 스토리보드와 `.xib` 파일을 시각적으로 편집한다. [스토리보드](storyboard.md) 참조 |
| Instruments | 메모리, CPU, 네트워크 등 성능을 분석한다 |
| 디버거 | 중단점(breakpoint)과 변수 검사로 오류를 찾는다 |
| Swift Package Manager | 외부 라이브러리를 패키지로 추가한다 |

## 3. 동작 원리

1. 코드와 리소스를 프로젝트에 모은다.
2. 빌드가 소스를 컴파일하고 앱 번들로 묶는다.
3. 실행 대상(Simulator 또는 실제 기기)을 골라 앱을 설치하고 실행한다.

앱 만들기: [Xcode 새 앱 프로젝트 생성](createxcodeproject.md). UI 프레임워크: [UIKit](uikitreference.md), [UIView](uiviewreference.md), [SwiftUI](swiftui.md).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| IDE | 통합 개발 환경 |
| Playground | 즉시 실행 결과를 보여 주는 학습용 코드 환경 |
| Simulator | 기기 시뮬레이터 |
| SPM | Swift Package Manager |

{% hint style="info" %}
NOTE: 원본에 제목만 있고 내용이 없던 "UIView", "UIKit", "프로젝트 생성" 절은 각각 별도 문서로 연결했다. 개인 감상 문장과 "통합 캘린더 어플 만들기" 한 줄은 삭제했다.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Playground와 앱 프로젝트는 어떤 점이 다른가?
- [ ] Simulator로 확인할 수 없어 실제 기기가 필요한 기능은 무엇이라고 생각하는가?
