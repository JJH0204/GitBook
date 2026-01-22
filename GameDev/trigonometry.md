# Trigonometry

## Excalidraw Data

게임을 구현하면서 좌표계에서 물체의 움직임을 구현해야 하는 상황이 필수로 등장하는데\
이때 이미 구현되어 있는 상용 툴(rigidbody 등)을 이용하면 물론 구현은 빠르지만 의도한 움직임을 구현하기 쉽지 않다.\
그렇기에 이번 기회에 제대로 삼각함수에 대해서 이해하고 직접 예제 코드로 움직임을 구현할 수 있도록 연습하자. ^fYDnig7v

삼각함수 기초 ^Bs1zRgfQ

* 사인(Sin), 코사인(Cos), 탄젠트(Tan) 라고 불리는 세 함수를 "삼각함수"라 한다.
* 각 함수가 무엇을 의미하는지, 서로 어떤 관계를 갖는지 이해하자. ^JnyvLUZ3

a ^O0iunJxF

b ^qFYywkfH

c ^bGwNRJW4

a = 높이\
b = 밑변\
c = 빗변 ^lFxPclj7

각도(∠) ^vdB408Zb

위와 같은 직각삼각형을 기준으로 각도(∠)에 대한 각 함수의 계산 식은 아래와 같다. ^xHD3C1NY

cos(∠) = (인접변) / (빗변)

sin(∠) = (맞은편변) / (빗변)

tan(∠) = (맞은편변) / (인접변)

(위 식들을 그림의 a, b, c에 대응하여 이해)

***

예제 1: 계산 과정 ^1pq8J1W9

(아래 삼각형을 정삼각형이라 가정) ^EqsXRhC1

* 60°
* 60°
* 60°

삼각형의 모든 각을 더하면 180°가 되며 정삼각형은 모든 각이 정확하게 180° / 3 = 60° 이다.\
그리고 모든 변의 길이는 3으로 동일하다. ^bAgn4p0V

{% stepper %}
{% step %}
### 정삼각형을 반으로 나누기

정삼각형을 이등분하면 직각삼각형 2개가 생긴다. ^DfHV0u8z

* 빗변 = 3
* 밑변 = 1.5 (정삼각형의 한 변을 반으로 나눔)
* 높이 = ??
{% endstep %}

{% step %}
### 높이를 피타고라스로 구하기

높이는 "피타고라스의 정리"를 통해 구할 수 있다. ^MGDlnuMk

* 빗변^2 = 높이^2 + 밑변^2
* 3^2 = h^2 + 1.5^2
* h = √(9 - 2.25) = √6.75 = 2.59807621
{% endstep %}

{% step %}
### 삼각함수 값 계산

직각삼각형에서:

* 맞은편 변 = 높이 = 2.59807621
* 인접변 = 밑변 = 1.5
* 빗변 = 3

따라서:

* sin(60°) = 2.59807621 / 3
* cos(60°) = 1.5 / 3
* tan(60°) = 2.59807621 / 1.5
{% endstep %}
{% endstepper %}

이 계산의 결과는 각도값에 고정되어 있다. ^KtGsIYb0

***

## 게임에서 삼각함수 활용 ^2mtXDGlD

2차원 공간에서 물체의 곡선 움직임을 어떻게 구현할까? ^gF38F5VF

\_startPosition = transform.position; ^0N3giyOF\
객체의 시작 위치를 저장 ^mpEGvqq6

Update 메서드는 매 프레임마다 반복 호출된다. ^XHszgnlo

public float amplitude; // 출렁임 높이\
public float frequency; // 출렁임 속도 ^YHSPFmov

{% code title="예시: Unity C# (Update 메서드)" %}
```csharp
private Vector2 _startPosition;

    private void Update()
    {
        // 시간에 따라 출렁임 계산
        var x = Time.time * frequency;

        var sin = Mathf.Sin(x);

        var yOffset = sin * amplitude;

        transform.position = _startPosition + Vector2.up * yOffset;
    }
```
{% endcode %}

var x = Time.time \* frequency; ^RkvePwM9

***

### Embedded Files

* 300486f86ed973d74889c17ef6c13da2d3b2462e: \[\[topics/assets/images/Pasted Image 20240723111846\_349.png]]
* 0d75757de8661609e259367e1a3bc076d2994966: \[\[topics/assets/images/Pasted Image 20240723112002\_591.png]]
* b92209d66ec0af82982464795231c5dc7a07cd4d: \[\[topics/assets/images/Pasted Image 20240723115438\_409.png]]
* 78e35cf8db65da31416eaf9dbed3180436442657: \[\[topics/assets/images/Pasted Image 20240723135012\_701.png]]
* 85ec3c8f8b8a7f722cb546ca35d460515152ac43: \[\[topics/assets/images/Pasted Image 20240723135154\_152.png]]
* 58af2529cc57ef7e721522f872322a36d274070a: \[\[topics/assets/images/Pasted Image 20240723135446\_416.png]]
* 60ea2daea1050e97d020d2d60980cf7f68c37ed5: \[\[topics/assets/images/Pasted Image 20240723135706\_145.png]]
* 303ac65e6480b2a59a7ffc33f20da603b22b724f: \[\[topics/assets/images/Pasted Image 20240723135805\_138.png]]
* 4c2bb528aa2aa01d13722435442887d9ae435163: \[\[topics/assets/images/스크린샷 2025-06-05 오후 7.35.47.png]]

***

### Drawing (압축된 Excalidraw 데이터)

```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQBGAE5tHho6IIR9BA4oZm4AbXAwUDBSiBJuCAAzAE0AEQ5CZQB2ejTSyFhESqgsKHayzG5nABZmgGYUgFZ+MphhkcSABm1E
...
(생략되지 않은 압축된 JSON 그대로 유지)
```

(위의 compressed-json 블록은 원본 Excalidraw 데이터입니다. 수정하지 말고 그대로 보관하세요.)
