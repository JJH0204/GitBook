---
description: UI/UX 디자인 초안
---

# UI/UX 디자인 초안

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-003-DO |
| 유형 | D&O (화면 설계) |
| 목적 | 올반 프로젝트의 Android 태블릿 화면과 Windows 호스트 서버 화면의 설계 의도를 설명한다 |
| 확인 상태 | 미검증 (원본 기록을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

## 1. 문제 인식

1. 기존 사설 업체 프로그램은 웹 서버로 동작해 항상 브라우저로만 접속할 수 있다.
2. PC에서는 F11(전체 화면)으로 URL 입력란과 탭을 숨길 수 있다. Android 브라우저에서는 불가능한 것으로 판단했다.
3. 매장 관리 PC와 통신하는 데 별도 앱 없이 브라우저만 쓰면 상품성이 떨어진다고 판단했다.
4. 기존 프로그램의 UX는 매장 메뉴 전체 정보, 들어온 주문, 진행 상황을 확인하기에 적절한 구성과 동선이 아니라고 판단했다.
5. 이를 해결하려면 별도 Android 앱과 차별화된 디자인이 필요하다.

## 2. 구성 요소

| 구성 요소 | 대상 | 설명 |
|---|---|---|
| 태블릿 UI 초안 | Android 태블릿 | Figma 초안 |
| 호스트 서버 UI 초안 | Windows 호스트 서버 프로그램 | Figma 초안 |

{% hint style="info" %}
NOTE: Figma 링크는 원본에 있는 것을 유지했다. 공유 설정에 따라 열리지 않을 수 있다(접근 권한 확인 필요).
{% endhint %}

{% embed url="https://www.figma.com/site/zlsGIt2DteHXGoVuCZE1in/%EC%98%AC%EB%B2%A4%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8?node-id=0-3" fullWidth="false" %}
안드로이드 태블릿 UI 디자인 초안
{% endembed %}

{% embed url="https://www.figma.com/site/zlsGIt2DteHXGoVuCZE1in/%EC%98%AC%EB%B2%A4%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8?node-id=23-359" fullWidth="false" %}
윈도우 호스트 서버 프로그램 디자인 초안
{% endembed %}

{% hint style="info" %}
NOTE: 위 디자인은 구현 과정에서 일부 바뀔 수 있다. 서버 프로그램은 큰 틀만 만들어 두고, 기능 개발 중에 필요한 항목을 추가할 예정이다.
{% endhint %}

## 3. 화면 동작 원리

Android 화면은 가로로 3등분한다. 좌측에 카테고리, 중앙에 메뉴 카드, 우측에 주문 현황을 둔다.

| 영역 | 동작 |
|---|---|
| 좌측 카테고리 바 | 카테고리를 골라 메뉴를 걸러 본다 |
| 중앙 메뉴 카드 | 메뉴 정보를 카드로 보여 준다. 메뉴마다 독립 타이머가 동작해 어떤 음식을 조리 중인지 알 수 있다 |
| 우측 주문 현황 바 | 들어온 주문과 진행 상황을 보여 준다 |
| 레시피 모달 | 메뉴별 상세 정보(레시피)를 모달 창으로 표시한다 |
| 서버 프로그램 | 원터치 버튼으로 서버를 켜고 끈다. 관리자가 메뉴를 등록한다 |

## 4. 활용 예시

아래 화면 녹화로 동작을 확인한다.

<figure><img src="../../../.gitbook/assets/Kapture 2026-01-29 at 17.56.03.gif" alt="좌측 카테고리 바 사용 화면"><figcaption><p>좌측 카테고리 바 활용 예제</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/Kapture 2026-01-29 at 18.02.53.gif" alt="검색 기능 사용 화면"><figcaption><p>검색 기능 예제</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/Kapture 2026-01-29 at 18.32.16.gif" alt="우측 주문 현황 바 사용 화면"><figcaption><p>우측 주문 현황 바 사용 예제</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/Kapture 2026-01-29 at 18.34.59.gif" alt="레시피 확인과 타이머 사용 화면"><figcaption><p>레시피 확인 및 타이머 사용 예제</p></figcaption></figure>

<figure><img src="../../../.gitbook/assets/Kapture 2026-01-29 at 18.40.17.gif" alt="서버 프로그램 동작 화면"><figcaption><p>서버 프로그램 동작 예제</p></figcaption></figure>

## 5. 결론

1. 서버 프로그램으로 매장 관리자가 메뉴를 쉽게 등록하고 쓸 수 있게 한다.
2. 서버 프로그램의 원터치 버튼으로 서버를 간편하게 켜고 운용한다.
3. Android 앱 화면을 가로 3등분해 좌우에 카테고리와 주문 현황을 두어 공간 사용성을 높인다.
4. 메뉴 정보를 카드 형태로 만들어 눈으로 확인하기 쉽게 한다.
5. 메뉴마다 독립 타이머를 두어 지금 어떤 음식을 조리 중인지 알기 쉽게 한다.
6. 메뉴별 상세 정보(레시피)를 모달 창으로 보여 읽기 쉽게 한다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| UI | 사용자 인터페이스, 화면 구성 |
| UX | 사용자 경험, 사용 흐름과 동선 |
| 모달 | 현재 화면 위에 띄우는 창 |
| 호스트 서버 프로그램 | 매장 PC에서 도는 Windows 서버 프로그램 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 화면을 가로 3등분한 이유를 주방 작업 동선과 연결해 설명하면?
- [ ] 브라우저 방식 대신 별도 앱을 택하면서 얻은 것과 늘어난 부담은 무엇인가?
