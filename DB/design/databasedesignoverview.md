# 데이터베이스 설계 개요

## 데이터베이스 설계란?

* 효율적인 데이터 저장, 검색, 관리를 위해 데이터베이스 구조를 정의하는 과정을 의미한다.
* 설계가 잘못되면 데이터 중복, 성능 저하, 유지보수 문제가 발생할 수 있기 때문에 체계적인 접근이 필요하다.

***

## 데이터베이스 설계과정

데이터베이스 설계는 아래 순서에 맞춰 단계별로 진행한다.

{% stepper %}
{% step %}
### 요구 사항 분석 (Requirement Analysis)

* 사용자 요구 사항을 수집하고 분석
* 관련 문서: 요구 사항 분석
{% endstep %}

{% step %}
### 개념적 설계 (Conceptual Design)

* ERD(Entity-Relationship Diagram) 작성
* 관련 문서: 개념적 설계
{% endstep %}

{% step %}
### 논리적 설계 (Logical Design)

* 정규화(Normalization), 관계형 모델 변환
* 관련 문서: 논리적 설계
{% endstep %}

{% step %}
### 물리적 설계 (Physical Design)

* 성능 최적화를 고려한 저장 구조 및 인덱스 설계
* 관련 문서: 물리적 설계
{% endstep %}

{% step %}
### 구현 및 운영 (Implementation & Maintenance)

* 실제 데이터베이스 구축, 튜닝 및 유지보수
* 관련 문서: 구현 및 운영
{% endstep %}
{% endstepper %}
