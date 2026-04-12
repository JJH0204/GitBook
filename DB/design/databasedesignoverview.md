# DatabaseDesignOverview

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
* 관련 문서: [요구 사항 분석](/broken/pages/5f62fb4547039f5e94cd44144d3bf1b3955f7504)
{% endstep %}

{% step %}
### 개념적 설계 (Conceptual Design)

* ERD(Entity-Relationship Diagram) 작성
* 관련 문서: [개념적 설계](/broken/pages/64fcfb50ef36ba2f881678daeaca60d96a3b6a06)
{% endstep %}

{% step %}
### 논리적 설계 (Logical Design)

* 정규화(Normalization), 관계형 모델 변환
* 관련 문서: [논리적 설계](/broken/pages/a32cc69e446106f35a6175f328d48448655f0f5f)
{% endstep %}

{% step %}
### 물리적 설계 (Physical Design)

* 성능 최적화를 고려한 저장 구조 및 인덱스 설계
* 관련 문서: [물리적 설계](/broken/pages/744004a4beafa9a12effe7ce3b994a072bea1d37)
{% endstep %}

{% step %}
### 구현 및 운영 (Implementation & Maintenance)

* 실제 데이터베이스 구축, 튜닝 및 유지보수
* 관련 문서: [구현 및 운영](/broken/pages/004636e64970a1c82c31501c77d744eca7b9381f)
{% endstep %}
{% endstepper %}
