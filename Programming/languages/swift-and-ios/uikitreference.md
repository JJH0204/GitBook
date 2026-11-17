# UIKit 프레임워크 (UIKit)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-IOS-004-REF |
| 유형 | REF (표) |
| 목적 | UIKit의 주요 구성 요소, 뷰 컨트롤러 생명주기, 이벤트 전달 순서를 찾는다 |
| 확인 상태 | 미검증 (공개된 일반 지식을 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: UIKit은 iOS와 tvOS의 그래픽, 이벤트 처리, 사용자 인터페이스 요소를 관리한다. 터치 이벤트 처리, 애니메이션, 그리기, 이미지·텍스트 처리 도구를 제공한다. 이벤트 전달과 앱 생명주기 중 iOS 버전(특히 iOS 13의 Scene 도입)에 따라 달라지는 부분은 버전 확인 필요.
{% endhint %}

## 1. 주요 구성 요소

| 구성 요소 | 설명 |
|---|---|
| `UIView` | 화면의 사각형 영역. [UIView 클래스](uiviewreference.md) 참조 |
| `UIViewController` | 뷰 계층을 관리하고 화면 단위 로직을 담당한다 |
| `UIControl` 계열 | `UIButton`, `UISwitch`, `UISlider` 등 사용자 입력 요소 |
| `UILabel`, `UITextField`, `UIImageView` | 텍스트 표시·입력, 이미지 표시 |
| `UITableView`, `UICollectionView` | 목록, 그리드 표시 |
| `UIResponder` | 이벤트(터치 등)를 받는 객체의 기반 클래스 |
| 애니메이션 | `UIView.animate(withDuration:animations:)` 등 |

## 2. `UIViewController` 생명주기

| 순서 | 메서드 | 호출 시점 | 주로 하는 일 |
|---|---|---|---|
| 1 | `viewDidLoad()` | 뷰가 메모리에 로드된 직후, 한 번 | 초기 설정, 뷰 구성 |
| 2 | `viewWillAppear(_:)` | 화면에 나타나기 직전, 나타날 때마다 | 데이터 갱신 |
| 3 | `viewWillLayoutSubviews()` | 하위 뷰 배치 직전 | 레이아웃 보정 |
| 4 | `viewDidLayoutSubviews()` | 하위 뷰 배치 직후 | 크기 의존 작업 |
| 5 | `viewDidAppear(_:)` | 화면에 나타난 직후 | 애니메이션 시작 |
| 6 | `viewWillDisappear(_:)` | 사라지기 직전 | 입력 저장 |
| 7 | `viewDidDisappear(_:)` | 사라진 직후 | 작업 정리 |

{% hint style="warning" %}
CAUTION: 생명주기 메서드를 오버라이드할 때는 `super`의 같은 메서드를 호출한다(예: `super.viewDidLoad()`).
{% endhint %}

```swift
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
```

## 3. 이벤트와 응답자 체인

1. 터치가 발생하면 UIKit이 화면의 가장 깊은 뷰를 찾는다(hit-testing).
2. 그 뷰가 이벤트를 처리하지 않으면 응답자 체인(responder chain)을 따라 다음 응답자로 넘긴다.
3. 체인 순서(일반적인 경우): 뷰 → 슈퍼뷰 → ... → 뷰 컨트롤러(뷰의 루트인 경우 뷰 바로 다음) → `UIWindow` → `UIApplication` → 앱 델리게이트.
4. `UIControl`은 터치 이벤트를 타깃-액션 방식으로 전달한다.

```swift
button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

@objc func didTap() {
    print("tapped")
}
```

## 4. `UIButton` 요약

| 항목 | 설명 |
|---|---|
| 역할 | 사용자가 탭할 때 액션을 실행하는 버튼 |
| 상태 | `normal`, `highlighted`, `selected`, `disabled`. 상태마다 제목·색을 다르게 설정한다 |
| 이벤트 | `.touchUpInside` 등 `UIControl.Event` |

## 5. 관련 문서

- [UIView 클래스](uiviewreference.md) (PRG-IOS-005-REF)
- [스토리보드](storyboard.md) (PRG-IOS-003-DO)
- [SwiftUI 프레임워크](swiftui.md) (PRG-IOS-006-DO)
