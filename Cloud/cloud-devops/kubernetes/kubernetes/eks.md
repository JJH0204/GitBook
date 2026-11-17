# AWS EKS 구축 및 운영

{% hint style="warning" %}
{% endhint %}

* AWS EKS workshop
* DevOps (CI/CD) + Security = DevSecOps
* CI (Continous Intergrity): 빌드, 테스트
* CD (Continous Deployment): 서비스 배포, 퍼블리싱
* CI/CD PipeLine (see stepper below)
* IDE
* Jenkins
* Github
* Marven
* JUnit
* SonarQuibe
* ELK Stack

### CI/CD Pipeline

{% stepper %}
{% step %}
### 버전관리 시스템

Git, Github, Gitlab, Bitbu, ...
{% endstep %}

{% step %}
### CI Server

Jenkins, Gitlab CI, Circle CI, Travis CI, ...
{% endstep %}

{% step %}
### 빌드

Marven, Gradle, Ant, ...
{% endstep %}

{% step %}
### 테스트 프레임워크

JUnit, TestNG, Selenium, Pytest, ...
{% endstep %}

{% step %}
### 코드 품질 테스트

SonarQube, ESlint, ...
{% endstep %}

{% step %}
### 배포

Jenkins, Gitlab CI, Spinmaker, Kubernetis, ...
{% endstep %}

{% step %}
### 모니터링 및 로깅

Prometheus, Grafana, ELK Stack, ...
{% endstep %}
{% endstepper %}

### 보안 중심 SDLC 단계

{% stepper %}
{% step %}
### 1. 기획

* 예상 가능한 보안 위협 모델링 -
{% endstep %}

{% step %}
### 2. 구현 (SAST, DAST)

* 구현 단계의 보안 위협 점검 -
{% endstep %}

{% step %}
### 3. 테스트 (DAST)

*
{% endstep %}

{% step %}
### 4. 배포

* 접근 제어, 침투 테스트 -
{% endstep %}

{% step %}
### 5. 운영

* 로깅, WAF, 보안 패치 -
{% endstep %}

{% step %}
### 6. 모니터링 (SIEM)

* 취약점 모니터링 도구로 공격검출 -
{% endstep %}
{% endstepper %}

### DevSecOps 흐름

{% stepper %}
{% step %}
### 소스 수정

* 소스 수정
{% endstep %}

{% step %}
### 수정 사항 커밋

* 복구
{% endstep %}

{% step %}
### 빌드

* 빌드
{% endstep %}

{% step %}
### 테스트

* 테스트
{% endstep %}

{% step %}
### 품질 테스트

* 품질 테스트
{% endstep %}

{% step %}
### 배포

* 배포
{% endstep %}

{% step %}
### 모니터링

* 모니터링
{% endstep %}
{% endstepper %}

* 보안 요구 사항과 위협 모델링을 통해 초기 계획 단계에서 보안 고려
* 코드가 안전하게 작성되고 저장되도록 보안 검증 수행
* 빌드 된 애플리케이션의 보안 검증
* 애플리케이션을 안전하게 배포
* 운영 중인 애플리케이션의 보안 유지
* 지속적인 모니터링을 통해 보안 상태를 유지/개선 사항 수집

### SAST / DAST

* SAST - Static Application Security Testing\
  : 코드가 실행되기 전의 정적 분석을 통해 코드 내부의 보안 취약점을 점검(식별)하는 소스 코드 분석 기술 및 솔루션
* DAST - Dynamic Application Security Testing\
  : 코드를 실행하여 동적 분석을 통해 프로그램의 보안 취약점을 식별하는 기술 및 솔루션
* 직접 분석: 개발자의 의도를 파악해 코드를 점검할 수 있다. / 대량의 코드를 점검하는데 적절하지 않다.
* 자동 분석: 객관적인 분석 결과를 얻을 수 있다. / 이미 알려진 취약점에 대해서만 대응이 가능하다.
* 소프트웨어 개발보안 검사원(진단원)

### 참고 링크

* https://www.eksworkshop.com/
