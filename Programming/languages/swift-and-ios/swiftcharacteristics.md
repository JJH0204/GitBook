# [생성형 AI] Swift 언어 특징

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SWF-002-DO |
| 유형 | 안내 (통합됨) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 이 주제가 다른 문서로 통합되었음을 알린다 |
| 확인 상태 | 미검증 |
| 개정 | R1 (2026-11-18) |

Swift의 안정성(타입 안전, `nil` 처리), 성능, 문법상 특징은 [Swift란 무엇인가](whatisswift.md)의 "언어 특징" 표(PRG-SWF-001-DO 2-2절)에 통합했다.

{% hint style="info" %}
NOTE: 원본의 "Objective-C보다 빠르며" 문장은 근거가 없어 삭제했다. 원본의 오타("옵셔널 값은 기능들은")도 정리했다.
{% endhint %}

## 관련 문서

| 알고 싶은 것 | 문서 | Task ID |
|---|---|---|
| Swift 개요, 역사, 언어 특징 표 | [Swift란 무엇인가](whatisswift.md) | PRG-SWF-001-DO |
| 주요 기능 표 | [Swift 주요 기능 (Features)](swiftmainfeatures.md) | PRG-SWF-003-REF |
| 기본 문법 예제 | [Swift 기본 문법 예제](swiftbasicsyntax.md) | PRG-SWF-005-DO |
| `nil`을 안전하게 다루는 옵셔널 | [옵셔널 (Optionals)](optionals.md) | PRG-SWF-006-DO |

## 선수 지식과 핵심 용어

- 선수 지식: 변수, 함수, 타입 같은 프로그래밍 기초 개념
- 타입 안전(type safety): 컴파일러가 타입이 맞지 않는 연산을 막는 성질
- 옵셔널(optional): 값이 있거나 `nil`일 수 있음을 타입으로 표현하는 방식

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Swift의 "타입 안전"이 실제 코드에서 어떤 실수를 막아 주는지 경험을 적는다.
- [ ] 옵셔널을 쓸 때와 쓰지 않을 때의 차이를 내 말로 설명한다.
