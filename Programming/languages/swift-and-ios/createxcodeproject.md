# Xcode 새 앱 프로젝트 생성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-IOS-002-MP |
| 목적 | Xcode에서 빈 iOS 앱 프로젝트를 만들고 Simulator에서 실행한다 |
| 적용 대상 | macOS, Xcode (버전 확인 필요) |
| 소요 시간 | 약 10분 (Xcode 설치 제외) |
| 확인 상태 | 미검증 (원본에 제목만 있어 공개된 일반 절차로 작성했으며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 [iOS 개발 도구](iosdevelopment.md)의 빈 절 "프로젝트 생성"을 채우기 위해 새로 만든 문서다. 대화 상자 이름과 선택지는 Xcode 버전에 따라 다르다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [iosdevelopment.md](iosdevelopment.md) | PRG-IOS-001-DO | iOS 개발 도구 (Xcode) |
| [storyboard.md](storyboard.md) | PRG-IOS-003-DO | 스토리보드 |
| [swiftui.md](swiftui.md) | PRG-IOS-006-DO | SwiftUI 프레임워크 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Mac | macOS (Xcode가 요구하는 버전) | |
| 2 | Xcode | 설치 완료 | 버전 확인 필요 |
| 3 | 빈 폴더 | 저장 위치 | |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 실제 기기에 설치하려면 Apple ID 서명 설정이 필요하다. 이 문서는 Simulator 실행까지만 다룬다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Xcode를 연다 | 시작 창 또는 메뉴 막대에 `Xcode`가 보인다 |

## 5. 절차

### A. 프로젝트 만들기

1. (5-A-01) 메뉴 `File > New > Project...`를 선택한다. → 결과: 템플릿 선택 창이 열린다.
2. (5-A-02) 위쪽 탭에서 `iOS`를 선택한다.
3. (5-A-03) `App`을 선택하고 `Next`를 누른다. → 결과: 프로젝트 옵션 창이 열린다.
4. (5-A-04) `Product Name`에 `<앱 이름>`을 입력한다.
5. (5-A-05) `Interface`에서 `Storyboard` 또는 `SwiftUI` 중 하나를 선택한다.
6. (5-A-06) `Language`에서 `Swift`를 선택한다.
7. (5-A-07) `Next`를 누르고 저장 폴더를 선택한 뒤 `Create`를 누른다. → 결과: 프로젝트 창이 열린다.

{% hint style="info" %}
NOTE: `Storyboard`를 고르면 UIKit과 스토리보드 기반 프로젝트가 만들어진다. `SwiftUI`를 고르면 SwiftUI 기반 프로젝트가 만들어진다.
{% endhint %}

### B. Simulator에서 실행

1. (5-B-01) 창 위쪽 도구 막대의 실행 대상 메뉴에서 iPhone 시뮬레이터를 하나 선택한다.
2. (5-B-02) `Run`(재생 모양) 버튼을 누른다. 단축키는 `Command + R`이다. → 결과: 빌드가 끝나고 Simulator가 열려 앱이 실행된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-B-02 실행 | Simulator에 앱 화면이 나타난다 | 빌드 오류 없이 화면이 보인다 |

## 7. 복구

1. (7-01) 만든 프로젝트가 필요 없으면 `<저장 폴더>/<앱 이름>` 폴더를 휴지통으로 옮긴다. → 결과: Xcode 최근 프로젝트 목록에서 열 수 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (원본 빈 절 보충) |
