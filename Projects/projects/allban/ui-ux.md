---
description: UI/UX 디자인 초안
---

# UI/UX 디자인

#### 문제 인식

* 사설 업체에서 제공한 프로그램은 웹 서버로 동작해 항상 브라우저를 통해야만 접속이 가능하다.
* PC의 경우 F11(전체화면으로 보기) 기능으로 브라우저의 불필요한 URL 입력 필드나 탭을 표시하지 않을 수 있으나 안드로이드 브라우저에서는 불가능한 것으로 판단된다.
* 별도의 호스트 PC (매장 내 관리 PC) 와 통신하는데 별도의 앱 없이 브라우저만 사용하는 것은 상품성이 떨어진다 판단
* 사설 업체에서 제공한 프로그램의 UX 또한 현재 매장내에서 관리중인 메뉴들의 전체 정보와 현재 들어온 주문 정보 및 진행하상을 확인하기에 적절한 구성과 동선을 디자인했다고 생각되지 않는다.
* 위 문제를 해결하기 위해서는 별도의 안드로이드 앱 구현을 위한 차별화된 디자인 구상이 필요함

***

#### 사용자 친화적 UI/UX 초안

{% embed url="https://www.figma.com/site/zlsGIt2DteHXGoVuCZE1in/%EC%98%AC%EB%B2%A4%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8?node-id=0-3&t=Bqv9TCDXL9c06XvN-0" fullWidth="false" %}
안드로이드 태블릿 UI 디자인 초안
{% endembed %}

{% embed url="https://www.figma.com/site/zlsGIt2DteHXGoVuCZE1in/%EC%98%AC%EB%B2%A4%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8?node-id=23-359&t=Bqv9TCDXL9c06XvN-0" fullWidth="false" %}
윈도우 호스트 서버 프로그램 디자인 초안
{% endembed %}

{% hint style="info" %}
위 디자인은 구현과정에서 일부 변경 혹은 수정될 수 있습니다.
{% endhint %}

***

#### 활용 예시

<figure><img src="../../.gitbook/assets/Kapture 2026-01-29 at 17.56.03.gif" alt=""><figcaption><p>좌측 카테고리바 활용 예제</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/Kapture 2026-01-29 at 18.02.53.gif" alt=""><figcaption><p>검색 기능 예제</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/Kapture 2026-01-29 at 18.32.16.gif" alt=""><figcaption><p>우측 주문현황바 사용 예제</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/Kapture 2026-01-29 at 18.34.59.gif" alt=""><figcaption><p>레시피 확인 및 타이버 사용 예제</p></figcaption></figure>

<figure><img src="../../.gitbook/assets/Kapture 2026-01-29 at 18.40.17.gif" alt=""><figcaption><p>서버 프로그램 동작 예제</p></figcaption></figure>

{% hint style="info" %}
서버 프로그램의 경우 큰 디자인 틀만 만들어 두고 기능 개발 과정에서 필요한 것들을 각 항목에 맞게 추가할 예정
{% endhint %}

***

#### 결론

* 서버 프로그램을 통해 매장 관리자가 간편하게 매뉴를 등록하고 사용할 수 있는 환경 제공
* 서버 프로그램에서 원터치 버튼으로 간변하게 서버를 활성화하고 운용할 수 있도록 기능 제공
* 안드로이드 앱 화면을 가로로 3등분하여 좌측 우측에 카테고리와 주문 현황을 출력함으로 공간 사용성을 개선
* 매뉴 정보를 시각적으로 확인하기 쉽게 카드형태로 디자인
* 각 매뉴마다 독립적으로 동작하는 타이머 기능으로 현재 어떤 음식의 조리가 진행 중인지 인지하기 쉽게 개선됨
* 각 매뉴 별 상세 정보(레시피)를 별도의 모달 창을 표시해 사용자가 읽기 쉽게 개선함
