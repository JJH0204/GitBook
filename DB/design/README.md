---
description: 요구사항 분석부터 구현·운영까지 데이터베이스 설계 단계별 개념 문서 모음
---

# 데이터베이스 설계

데이터베이스 설계 단계를 순서대로 정리한 개념 문서(D&O) 모음이다. 문서 번호(Task ID)는 `DB-DSN-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DB-DSN-001-DO | 개념 | [데이터베이스 설계 개요](databasedesignoverview.md) | 설계 5단계와 단계별 산출물을 파악한다 |
| DB-DSN-002-DO | 개념 | [요구사항 분석 개요](requirementanalysisoverview.md) | 요구사항 수집·분류·명세화·검증 방법을 파악한다 |
| DB-DSN-003-DO | 개념 | [데이터 흐름도 (DFD)](data_flow_diagram.md) | DFD 기호, 레벨, 작성 규칙을 파악한다 |
| DB-DSN-004-DO | 개념 | [개념적 설계 (Conceptual Design)](conceptual-design.md) | 엔터티, 속성, 관계, ERD 작성 순서를 파악한다 |
| DB-DSN-005-DO | 개념 | [논리적 설계 개요](logicaldesignoverview.md) | ERD를 관계형 테이블과 제약 조건으로 바꾸는 과정을 파악한다 |
| DB-DSN-006-DO | 개념 | [데이터베이스 정규화 (Normalization)](databasenormalization.md) | 함수적 종속, 이상 현상, 1NF~5NF를 파악한다 |
| DB-DSN-007-DO | 개념 | [물리적 설계 (Physical Design)](physical-design.md) | 저장 구조, 인덱스, 파티셔닝 등 성능 설계 항목을 파악한다 |
| DB-DSN-008-DO | 개념 | [데이터베이스 구현 및 운영](implementation-and-maintenance.md) | 구축, 마이그레이션, 연동, 튜닝, 보안, 유지보수를 파악한다 |

## 읽는 순서

1. DB-DSN-001-DO로 전체 단계를 본다.
2. DB-DSN-002-DO, DB-DSN-003-DO, DB-DSN-004-DO, DB-DSN-005-DO(필요 시 DB-DSN-006-DO), DB-DSN-007-DO, DB-DSN-008-DO 순서로 읽는다.
