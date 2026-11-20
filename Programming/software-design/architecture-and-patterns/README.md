# 아키텍처 및 패턴 (Architecture)

소프트웨어 설계 분석 기법을 정리한 그룹이다. 현재 수록된 내용은 럼바우 객체지향 분석(OMT)뿐이다. 디자인 패턴은 옵저버, 전략, 싱글턴, 팩토리, 데코레이터를 수록했고(PRG-ARP-005~009는 생성형 AI 초안, 사람 검토 전), 아키텍처 스타일 문서는 아직 없다. 문서 번호(Task ID)는 `PRG-ARP-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-ARP-001-DO | D&O | [럼바우 OOA 개요 (Rumbaugh)](rumbaughooaoverview.md) | 세 모델의 역할과 관계를 비교한다 |
| PRG-ARP-002-DO | D&O | [객체 모델 (Object Model)](object-model.md) | 클래스, 속성, 연산, 관계로 구조를 표현한다 |
| PRG-ARP-003-DO | D&O | [동적 모델 (Dynamic Model)](rumbaughooa/dynamic-model.md) | 상태, 이벤트, 전이로 시간에 따른 변화를 표현한다 |
| PRG-ARP-004-DO | D&O | [기능 모델 (Functional Model)](rumbaughooa/functional-model.md) | 데이터 흐름도로 처리 흐름을 표현한다 |
| PRG-ARP-005-DO | D&O | [[생성형 AI] 옵저버 패턴 (Observer)](observer-pattern.md) | 상태 변화를 여러 객체에 알리는 구조를 이해한다 |
| PRG-ARP-006-DO | D&O | [[생성형 AI] 전략 패턴 (Strategy)](strategy-pattern.md) | 알고리즘을 객체로 분리해 교체하는 구조를 이해한다 |
| PRG-ARP-007-DO | D&O | [[생성형 AI] 싱글턴 패턴 (Singleton)](singleton-pattern.md) | 인스턴스를 하나로 제한하는 구조를 이해한다 |
| PRG-ARP-008-DO | D&O | [[생성형 AI] 팩토리 메서드 패턴 (Factory)](factory-pattern.md) | 객체 생성 책임을 분리하는 구조를 이해한다 |
| PRG-ARP-009-DO | D&O | [[생성형 AI] 데코레이터 패턴 (Decorator)](decorator-pattern.md) | 래퍼로 기능을 겹쳐 쌓는 구조를 이해한다 |

## 읽는 순서

1. PRG-ARP-001-DO로 전체 그림을 본다.
2. PRG-ARP-002-DO, PRG-ARP-003-DO, PRG-ARP-004-DO 순서로 읽는다.
3. 관계 기호는 [UML 관계 개요 (Relationships)](../uml-and-modeling/uml/umlrelationshipsoverview.md)에서 확인한다.
