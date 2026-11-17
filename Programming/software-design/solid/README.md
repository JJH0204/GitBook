# SOLID 원칙 (SOLID)

객체지향 설계의 다섯 가지 원칙(SRP, OCP, LSP, ISP, DIP)을 정리한 그룹이다. 문서 번호(Task ID)는 `PRG-SLD-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-SLD-001-DO | D&O | [SOLID 원칙 개요](solidprinciples.md) | 다섯 원칙의 정의와 관계를 한 표로 확인한다 |
| PRG-SLD-002-DO | D&O + 예제 | [단일 책임 원칙 (SRP)](srpsingleresponsibilityprinciple.md) | 변경 이유가 하나인 클래스로 나누는 방법을 이해한다 |
| PRG-SLD-003-DO | D&O + 예제 | [개방 폐쇄 원칙 (OCP)](ocpopenclosedprinciple.md) | 수정 없이 확장하는 구조를 이해한다 |
| PRG-SLD-004-DO | D&O + 예제 | [리스코프 치환 원칙 (LSP)](lspliskovsubstitutionprinciple.md) | 하위 타입이 상위 타입의 계약을 지키는 조건을 이해한다 |
| PRG-SLD-005-DO | D&O + 예제 | [인터페이스 분리 원칙 (ISP)](ispinterfacesegregationprinciple.md) | 쓰지 않는 메서드에 의존하지 않도록 인터페이스를 나눈다 |
| PRG-SLD-006-DO | D&O + 예제 | [의존관계 역전 원칙 (DIP)](dipdependencyinversionprinciple.md) | 고수준 모듈이 추상에 의존하게 만든다 |

## 읽는 순서

1. PRG-SLD-001-DO로 전체 그림을 본다.
2. PRG-SLD-002-DO부터 PRG-SLD-006-DO까지 순서대로 읽는다.
3. 응집도·결합도와의 관계는 [응집도 (Cohesion)](../oop/cohesion.md)와 [결합도 (Coupling)](../oop/coupling.md)에서 확인한다.
