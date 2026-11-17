# 모바일 조작계 구현 (SimpleInput)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-001-DO |
| 유형 | D&O (조사 기록) |
| 목적 | 모바일 조작을 위해 `SimpleInput` 라이브러리를 쓴 방법과 확인할 점을 기록한다 |
| 확인 상태 | 미검증 (원본의 두 줄 메모를 정리한 것이며 이 환경에서 재현하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | `SimpleInput` (외부 오픈소스, 저장소는 참조 절) | `Input` 클래스와 같은 형태의 API와 화면 위 조이스틱·버튼을 제공한다 |
| 2 | 기존 입력 코드 | `Input.GetAxis` 같은 호출이 있는 스크립트 |

## 2. 동작 원리

기존 코드의 `Input` 클래스 호출을 `SimpleInput`으로 바꾸면 그대로 모바일 입력을 받는다. 작성자는 호출 이름만 바꾸면 되어 간편했다고 기록했다.

{% hint style="info" %}
NOTE: 이 라이브러리는 구 Input Manager(`UnityEngine.Input`) 방식의 API를 흉내 낸다. Machina는 새 Input System 패키지(`com.unity.inputsystem`)도 쓴다. 두 방식을 같이 쓰려면 `Project Settings > Player > Active Input Handling`이 `Both`여야 하는지 확인해야 한다. 원본에 이 설정은 없었다. 확인 필요.
{% endhint %}

{% hint style="info" %}
NOTE: 새 Input System에는 `On-Screen Stick`, `On-Screen Button` 컴포넌트가 자체 제공된다. 이 프로젝트에서 `SimpleInput`을 고른 이유와 두 방식을 비교한 기록은 원본에 없다.
{% endhint %}

## 3. 참조

- [UnitySimpleInput (외부 오픈소스 저장소)](https://github.com/yasirkula/UnitySimpleInput)

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 모바일 조작에 새 Input System의 화면 위 컨트롤 대신 `SimpleInput`을 고른 이유는 무엇인가?
- [ ] 입력 코드에서 `Input`을 `SimpleInput`으로 바꾼 뒤 PC 입력은 어떻게 유지했는가?
