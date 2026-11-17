# UIView 클래스 (UIView)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-IOS-005-REF |
| 유형 | REF (표) |
| 목적 | `UIView`의 주요 프로퍼티와 메서드, 좌표계 차이를 찾는다 |
| 확인 상태 | 미검증 (공개된 일반 지식을 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `UIView`는 iOS 앱에서 화면에 보이는 것의 기본 블록이다. 화면에 표시되는 요소는 `UIView` 또는 그 서브클래스의 인스턴스다. 사각형 영역에 콘텐츠를 그리고, 이벤트에 반응하고, 애니메이션을 표시한다.
{% endhint %}

## 1. 기본 프로퍼티

| 프로퍼티 | 설명 | 좌표계·범위 |
|---|---|---|
| `frame` | 뷰의 위치와 크기. 위치나 크기를 설정할 때 쓴다 | 슈퍼뷰의 좌표계. 화면 전체(글로벌) 좌표계가 아니다 |
| `bounds` | 뷰 자체의 좌표계에서의 위치와 크기. 내부 그리기와 하위 뷰 배치에 쓴다 | 뷰 자신의 좌표계(로컬) |
| `center` | 뷰 중심점 | 슈퍼뷰의 좌표계 |
| `backgroundColor` | 배경색 | `UIColor?` |
| `alpha` | 투명도 | 0.0 ~ 1.0 |
| `isHidden` | 표시 여부 | `Bool` |
| `clipsToBounds` | 경계 밖의 하위 뷰 내용을 잘라낸다 | `Bool` |
| `tag` | 정수 식별자 | `Int` |
| `superview`, `subviews` | 부모 뷰, 자식 뷰 배열 | |

{% hint style="warning" %}
CAUTION: `transform`이 적용되면(회전·확대) `frame`의 값은 변형된 뷰를 감싸는 사각형을 나타내며 정의된 크기와 다를 수 있다. 이때 크기는 `bounds`로 다룬다.
{% endhint %}

## 2. 주요 메서드

| 메서드 | 설명 |
|---|---|
| `addSubview(_:)` | 다른 뷰를 자식으로 추가한다 |
| `removeFromSuperview()` | 부모로부터 제거한다 |
| `setNeedsDisplay()` | 다시 그려야 한다고 표시한다. `draw(_:)`는 즉시 호출되지 않고 다음 렌더링 주기에 호출된다 |
| `setNeedsLayout()` | 레이아웃을 다시 계산해야 한다고 표시한다 |
| `layoutIfNeeded()` | 표시된 레이아웃 갱신을 바로 수행한다 |
| `draw(_:)` | 콘텐츠를 그린다. 직접 호출하지 않고 재정의만 한다 |
| `UIView.animate(withDuration:animations:)` | 프로퍼티 변경을 애니메이션으로 적용한다 |

## 3. 사용 예

```swift
let box = UIView(frame: CGRect(x: 20, y: 100, width: 120, height: 80))
box.backgroundColor = .systemBlue
view.addSubview(box)

UIView.animate(withDuration: 0.3) {
    box.alpha = 0.5
}
```

{% hint style="info" %}
NOTE: `.systemBlue` 등 시스템 색 상수는 일부가 iOS 13 이상 전용이므로 지원 버전 확인 필요. 원본의 "`center`: 부모 뷰에 대한 중심의 좌표"는 "슈퍼뷰 좌표계에서의 중심점"으로 정리했다.
{% endhint %}

## 4. 관련 문서

- [UIKit 프레임워크](uikitreference.md) (PRG-IOS-004-REF)
