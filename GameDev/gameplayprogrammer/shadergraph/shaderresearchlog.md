# ShaderResearchLog

## Text Elements

https://sketchfab.com/search?q=gundam\&type=models ^2t8La3nr

sketchfab 사이트에서 마음에 드는 3D 모델을 구했다. ^y3NGnevw

블랜더 > FBX 추출 > 유니티 프로젝트에 추가 > 텍스처 파일 업로드 ^AQDW4Bd2

나중에 한번 다뤄보면서 익히면 되겠다. ^5UEDqFRj

한동안 텍스처 파일을 넣지 않았었다.\
FBX 파일을 추가하면 자동으로 연결되는 줄 알았다.\
추가한 후 텍스처 파일을 꼭 같이 넣어주자 ^eF7Umw2T

0 일차 ^fuXm8QFz

우선 아무 메테리얼을 선택해 임의로 생성한 쉐이더를 추가했다. ^Jc1vcS8V

일정 거리 이상 가까워지면 그림자가 지는데 이것도 Shader로 구현되는지 궁금하다. ^k32b7hPX

서로다른 셰이더를 적용한 탓인지 다리 표현이 어색해졌다. ^t2eAETA7

이 상태에서 내가 표현하고 싶은 효과를 하나씩 구현해 가면 되겠다. ^Ng0p3tfa

우선 택스처를 적용하는 방법을 연구해보자 ^ugjmY23t

1 ^p76TRu4T

2 ^0Wl2x6nG

3 ^MtNvwbcE

4 ^QZz5Skfc

공유받은 텍스처에는 총 4 종의 택스처가 각 부위별로 존재한다. ^9wXuWbDR

1: UC\_LLEG\_OTHER\_BUMP\
2: UC\_LLEG\_OTHER\_COL\
3: UC\_LLEG\_WHITE\_BUMP\
4: UC\_LLEG\_WHITE\_COL ^2qARnjbb

> Other의 역할과 White의 역할은 무엇일까\
> BUMP와 COL의 역할은 무엇일까 ^xA9qh9cQ

무엇이 둘의 차이를 나누는 걸까 ^txU2C6nU

부록\
liltoon: https://lilxyzw.booth.pm/ ^loI8gUtw

모델의 색상/질감에 따른 분할 ^fjBw1uWl

Color Map: 표면의 실제 색상을 표현하는 텍스처\
Bump Map: 표면의 세부 높낮이, 굴곡 효과를 주기위한 정보(광원 반응, 쉐이딩 효과에 사용됨) ^l6bfH9Qb

메탈 제질 추가하기 ^9XHsCOll

쉐이더 그래프에서 float 값을 받도록 한 다음 그 값을 Metallic에 추가한다. ^5Sg7exXD

0 - 1 사이 값이 적용되며 낮을 수록 광택 효과가 줄어들고 클 수록 광택효과가 강조된다. ^aRqGpkCF

0 ^azoWtPHw

1 ^1oI4qxGX

확실히 광택효과를 받으니 광원을 표함해 주변 요소가 반사되는 효과도 있는 것 같다.\
(착각인가?) ^h0lpPudY

스크립트로 컨트롤 하기 ^gdwZBZqj

추가 ^M2NRPqXK

} ^fcWBLTNp

스크립트에서 Reference 이름으로 변수 접근 ^TWRYB2R0

인자값 적용 ^0vkz5IJ7

반짝반짝 빛나던 공이 무광이 되었다. ^jlPkPMUH

Material 클래스를 활용해 동일한 Material에 일괄적용 가능 ^KdfZ4YHI

실행 전 ^OeAaDBkR

실행 후 ^mmfk93M7

Outline 표현하기 ^2vn9oVpC

Unlit Shader 파일 생성 > Outline은 그림자 표현이 필요없기 때문에 ^d48lDobJ

Lit : 광원 위치에 따라 그림자 표현 계산 적용 (그림자 표현 O)\
Unlit : 그림자 표현 x ^nDLUDbyA

Normal Vector: 각각의 버텍스의 위치값\
Thickness(float): 두깨를 정의할 실수 ^7z6XAgRE

둘을 곱하면 지정한 두깨 만큼 이동한 버택스가 나온다. ^72hTYUrq

오브젝트(버택스)의 원 위치 ^gK45z4Om

둘을 더하면 이동한 방향이 적용된다. ^zg4nkt2x

버텍스를 표현할 위치에 직접 대입하면\
두깨감이 생긴다. ^o9qTwqO6

2일차 ^lmvHOu7n

* 고라니TV의 영상을 정독하고 건담을 원하는 디자인으로 만들어보자 ^ODKneYAG

원래 얼굴에 그림자가 져야 하는데 SDF를 따로 적용해서 밝게 보임 ^WKVW39y4

빛 ^wNb7laaR

현실적인 효과 적용 ^Z385S4O1

분위기 중심으로 (캐릭터 묘사보다는 상황연출 중심) ^EfBeNpI2

많이 먼 곳에서 빛이 출발 ^8SHlXVpn

빛이 멀 수록 잔잔한 분위기 연출 가능 ^bLSOiHpv

빛의 색 차이로 다른 분위기 연출 ^ZkwMVgpG

따뜻 ^elh8pdoc

이른 아침 느낌 ^QR4K2DpO

극적인 상황연출을 위한 역광 사용예시 ^kxaF2l9t

하이라이트는 직접 ^wwJ3E2Zs

얼굴 그림자 묘사를 위한 SDF ^fcH9x87j

촛불 정도의 약한 광원 ^nBLB73CQ

단계를 최소한으로 하는 ^UFIRbBd0

머리로 눈을 가릴 것인가 아닌가(눈썹 포함) ^ZeA0jWHF

외각선만 살리는 경우 ^puc3t73n

우선 외각선 효과 비스무리 한 것은 만드는데 성공했다.\
이걸 아웃라인이라 할 수 있는가 ^XVIxpIF9

각각의 버택스를 얼마나 띄울 것인가? (외각선의 두깨를 결정) ^MsysEGFs

실제 오브젝트 메시의 버택스에 더하여 위치 조정 ^ncK66TEj

조정한 위치를 적용해 출력 ^yRN4S2ty

이때 출력할 색상을 지정( 외각선의 경우 주로 검정/ 추후 사용자로 하여금 선택할 수 있도록 하자) ^2EW8ZNkK

그래프의 설정을 수정해야 아웃라인이 적용된다고 한다. ^rvATYslY

다른 강의에서는 켜라는데 켜나 끄나 큰 변화가 없다. ^vnvE4RsS

출력하는 메시의 버텍스가 앞을 보는 중이라면 0\
뒤를 보는 중이라면 1\
즉 앞 뒤를 뒤집어서 랜더링 하겠다는 뜻 ^DP8IdfKm

변경사항 ^1eNXXGnD

큐브처럼 각진 메시에 아웃라인 설정을 부드럽게 하려면 모델의 설정을 수정해주어야 한다.\
(안하면 면이 조각나 보임) ^RyWLUm85

사용자의 입력 실수를 방지 ^1F5aHvtK

카메라가 75 이상 멀어지면 아웃라인 사라짐 ^z1WIf3Z0

단순한 오브젝트에는 아웃라인이 잘 먹힘 ^dYj4Zhn6

캐릭터 같이 복잡한 메시를 가진 오브젝트에서는 흉측해진다. ^RyM6AYFS

Inverted Hull 방식의 구조적 한계 ^IVGZ2SQG

추가로 이번 쉐이더 RnD의 목표는 상용 쉐이더 툴 개발이다.\
툴 이름과 RnD 프로젝트 이름은 만트라"이다.\
RnD 레퍼런스는 LilToon 과 유니티창 쉐이더다. (둘 모두 서브컬처 모델링에 많이 사용된다고 한다.) ^49q4mcyo

***

## Embedded Files

25690e58536f608fa6f79ddbb0b4f378192aeb0a: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.36.11.png]]

56ca67fc4c5646993e3333425d2238b4fbbb7eae: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.40.27.png]]

00b1f9805c77b9a0150962c323ee9e675486b6e3: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.40.58.png]]

c053c9b6dfc0ddadbbe8bfa6098018b82fc5c80d: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.42.24.png]]

66b8334b11a20e9cbe448a560b6b719eb17d42ba: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.43.05.png]]

051b6798a9a868e720a003bc6ecfaf13ac23a14b: \[\[topics/assets/images/스크린샷 2025-06-26 오후 2.44.49.png]]

62ee1d45ede2c32501f7f282ca81834a1e63e214: \[\[topics/assets/images/UC\_LLEG\_OTHER\_BUMP.jpg]]

0eccbde66775516627143c8bc033da6e5c6f8ea2: \[\[topics/assets/images/UC\_LLEG\_OTHER\_COL.jpg]]

e8ece8aa896c01b4244e7a8bea3e49fcadff93e7: \[\[topics/assets/images/UC\_LLEG\_WHITE\_BUMP.jpg]]

c65d6a0a5a482ec24c5739ec353d3a9c03897c39: \[\[topics/assets/images/UC\_LLEG\_WHITE\_COL.jpg]]

cbd847b3cdbfb0dc7b83052fbfa5f6d050eb7688: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.40.43.png]]

29e6a50d4cd6783229ca589d5422c9a5f5f7bd03: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.42.09.png]]

9245799caafd4d5a925388fb8e6d9e7c5c706ac8: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.42.30.png]]

ebf20d55519dc2c8a60494fc4657a493254b5c60: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.43.31.png]]

e944a32735a1783c516086fcfa9507df92e4341d: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.43.47.png]]

938bb3a33a269e4ae15d7899aaa9e6e3645a9c1f: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.44.55.png]]

73ac3be2219dacc755b8b18c50f4c68a66252293: \[\[topics/assets/images/스크린샷 2025-06-26 오후 3.45.14.png]]

4439aa78b7a69736eca56ffd5a4aacfaf888f6b9: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.44.26.png]]

40795d410098d088ac18450589cc93582bb0e68d: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.45.05.png]]

33508fb7ca1fb9a6ab085e9073020c2de441e314: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.45.26.png]]

24b8bba7537ea5a873480d38366b6c5c21f95d4c: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.47.16.png]]

c906d98dc137719fcc48934bbaec1438b0a45c5c: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.49.27.png]]

38b76ff2c3ad347fa9d2c307ab5c7264f416f357: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.54.18.png]]

1c833733a1153b023eff66ec0c19f84a0a9c59fc: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.54.48.png]]

6934980ce7e69f258dbb69486a008cdbaf5aa854: \[\[topics/assets/images/스크린샷 2025-06-26 오후 7.55.56.png]]

3a6358195ce1ee48eb20ffc6deaf327b302e5200: \[\[topics/assets/images/스크린샷 2025-06-26 오후 9.58.54.png]]

a9667f13cf2552c5f2407a34521da7cc222db5f8: \[\[topics/assets/images/스크린샷 2025-06-26 오후 9.59.25.png]]

3d051b1c9d47bd90e13e68f6001caf0d18ca1bb5: \[\[topics/assets/images/스크린샷 2025-06-26 오후 11.13.58.png]]

7a49f225621859bd2752538843c50d5e4e4e1764: \[\[topics/assets/images/스크린샷 2025-07-01 오후 12.55.15.png]]

5edd2e024cbae555461007db07e7ef9c66132d7a: \[\[topics/assets/images/스크린샷 2025-07-01 오후 12.57.06.png]]

1ea1453bc6897192de330f0a6dada0d10762a36d: \[\[topics/assets/images/스크린샷 2025-07-01 오후 12.59.00.png]]

98acc47cdfed70b5516232d46359c6d045f3a679: \[\[topics/assets/images/스크린샷 2025-07-01 오후 12.59.06.png]]

c8f0d3e06a81ee71a323cbd0765296ef2785048c: \[\[topics/assets/images/스크린샷 2025-07-01 오후 12.59.13.png]]

cf903d6627eee6dd032aee3bb2fe8d136a353606: \[\[topics/assets/images/Pasted Image 20250701130811\_340.png]]

4dada5d9cde53622a254e24eeb63bea527c1262f: \[\[topics/assets/images/스크린샷 2025-07-01 오후 1.09.03.png]]

6d63b32d83dc62253e3f66244d7aae44b4edc8c4: \[\[topics/assets/images/스크린샷 2025-07-01 오후 1.18.55.png]]

9ea03b35063a51ba429eb14390138bd3705a34f6: \[\[topics/assets/images/스크린샷 2025-07-01 오후 1.20.16.png]]

535012e7f7654d099fd8b632b3be594dcdea2225: \[\[topics/assets/images/스크린샷 2025-07-01 오후 1.21.20.png]]

4448609948bfc46c6da551c4a6b4b8059c0e126a: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.13.40.png]]

9b11057d96053f0fce48d4972befe547cd3e45c7: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.15.44.png]]

22cf64255018cc7811f678dbb3b27c928cf0def4: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.18.28.png]]

4c05f3bbf9033b9e4e53156544be34972d0f2282: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.53.55.png]]

d562e1a23166e3a86cef454463e4f6a90a786aab: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.55.24.png]]

1b8e3125ba552aa20349bd4dd6fd5e23835c1f3d: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.55.32.png]]

75603aa0315a8dca18a647e1ce87b81f7efc21be: \[\[topics/assets/images/스크린샷 2025-07-02 오후 9.55.56.png]]

9a58f828845504a994ab6a24a975bc45485d594c: \[\[topics/assets/images/스크린샷 2025-07-02 오후 10.02.38.png]]

191a3e06cdadf3796b00f065b273df661959cc99: \[\[topics/assets/images/스크린샷 2025-07-02 오후 10.06.34.png]]

7688df9173d804764416bf1e0894134e4240c1d0: \[\[topics/assets/images/스크린샷 2025-07-02 오후 10.07.03.png]]

(이미지 파일 목록은 원본에 포함된 파일명과 매핑을 유지합니다.)

***

## Drawing

```compressed-json
N4KAkARALgngDgUwgLgAQQQDwMYEMA2AlgCYBOuA7hADTgQBuCpAzoQPYB2KqATLZMzYBXUtiRoIACyhQ4zZAHoFAc0JRJQgEYA6bGwC2CgF7N6hbEcK4OCtptbErHALRY8RMpWdx8Q1TdIEfARcZgRmBShcZQUebQBGOIAWGjoghH0EDihmbgBtcDBQMBKIEm4IAEFSAAYAeUr8AAUAa1SSyFhECsJ9aKR+UsxuZwBWUaSE+IBmHgAORNHByBgR

2dHtADZNmvjRzZ4lwsgKEnVuUZqa5akEQmVpbmnE7STpuemanhqAdk/L6ZHDoQazKYLca7HCDMKCkNgtBAAYTY+DYpAqsOszDguEC2XapU0uGwLWUcKEHGIyNR6IkmI42NxWSgBMgADNCPh8ABlWDgiSSYkaQKs6Gw+EIADqZ0k3HiNxhcIRvJg/PQgg8ovJDw44VyaHlULYOOwalWBquN3JlN1zH1qA4Qi5CoQCGIcpm7xujBY7C4aCSQNKPtYn

AAcpwxHKAJx7OajaPRuabG5CODEXBQN1yn6XWObeI/JIFyHAwjMAAi6Sz7rQbIIYRuZOEcAAksR7XkALo3TTCSkAUWCmWynZ7UKIHDaaEdzonbBJ2brDYQNw5wXbFUOm2jNQQo3j002bJ2c3rx5+0eIxE0mhqmiSbOmPwW0Z4uAQd9wouY7nEqAKDowENID4mOccy0pLAKlwGpRTZchMk3GcnXwBUoigIR7QgRBKUIDhlFFbA4TgbhZ3wQoAF9Bm

KUpygkHgoDmAAZXBpg4dEbi6f9oCwFkbmGNBnHieJtC+UY9iSQ45jmQMfhTKFzVQZxnmjbQ/neeIZPiQMkmjIMThlC5A1eeJ9PGbYkhqA4DNue5HjQQ4blBNVS1KRUJWpNEKgAYniBB/P80UiRJZsKSpFFvLpcgGRxPF+KhdceT5HiNXKdClSlIzHIyiUVTVaEUXSqFtUkW17RA0pjWJM05UtKEwrbDt8gg0oENwJDawdVCbnw4hoIkXAeC1ftiH

... (압축된 드로잉 데이터 계속)
```

(위 compressed-json 블록은 원본 드로잉 데이터를 그대로 포함합니다.)
