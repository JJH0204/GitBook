# 데이터베이스 설계 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DB-DSN-001-DO |
| 유형 | D&O (개념) |
| 목적 | 데이터베이스 설계의 5단계와 단계별 산출물을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

데이터베이스 설계는 효율적인 저장·검색·관리를 위해 데이터베이스 구조를 정의하는 과정이다. 설계가 잘못되면 데이터 중복, 성능 저하, 유지보수 문제가 생기므로 단계를 나눠 진행한다.

{% hint style="info" %}
NOTE: 설계 단계의 개수와 이름은 교재마다 다르다. 이 문서는 요구사항 분석, 개념적 설계, 논리적 설계, 물리적 설계, 구현 및 운영의 5단계로 나눈다.
{% endhint %}

## 2. 구성 요소

| 번호 | 단계 | 주요 작업 | 산출물 | 관련 문서 |
|---|---|---|---|---|
| 1 | 요구사항 분석(Requirement Analysis) | 사용자 요구사항을 수집하고 분석한다 | 요구사항 명세서, DFD | [DB-DSN-002-DO](requirementanalysisoverview.md) |
| 2 | 개념적 설계(Conceptual Design) | 엔터티와 관계를 정의하고 ERD를 그린다 | ERD | [DB-DSN-004-DO](conceptual-design.md) |
| 3 | 논리적 설계(Logical Design) | ERD를 관계형 모델로 변환하고 정규화한다 | 테이블·키·제약 조건 정의(스키마) | [DB-DSN-005-DO](logicaldesignoverview.md) |
| 4 | 물리적 설계(Physical Design) | 저장 구조, 인덱스, 파티셔닝 등을 정한다 | 물리 스키마, DDL | [DB-DSN-007-DO](physical-design.md) |
| 5 | 구현 및 운영(Implementation & Maintenance) | 데이터베이스를 구축하고 튜닝·유지보수한다 | 운영 중인 데이터베이스 | [DB-DSN-008-DO](implementation-and-maintenance.md) |

## 3. 동작 원리

1. 앞 단계의 산출물이 다음 단계의 입력이 된다.
2. 개념적 설계는 특정 DBMS와 무관하다. 논리적 설계는 데이터 모델(주로 관계형)에 맞추고, 물리적 설계는 선택한 DBMS의 저장 방식에 맞춘다.
3. 뒤 단계에서 앞 단계의 오류가 발견되면 해당 단계로 돌아가 수정한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ERD(Entity-Relationship Diagram) | 엔터티와 관계를 그린 다이어그램 |
| DBMS | 데이터베이스 관리 시스템 |
| DDL(Data Definition Language) | `CREATE TABLE` 같은 구조 정의 SQL |
| 스키마(Schema) | 테이블, 컬럼, 키, 제약 조건 등 데이터베이스 구조의 정의 |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [데이터베이스 기초](../overview/databasebasics.md) | 데이터베이스 개요 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 개념적 설계와 논리적 설계는 무엇이 다른가?
- [ ] 설계 단계를 건너뛰고 바로 테이블을 만들면 어떤 문제가 생길 수 있을까?
