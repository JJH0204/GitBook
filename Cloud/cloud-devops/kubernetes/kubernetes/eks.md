# EKS

{% hint style="warning" %}
⚠ Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document.\
You can decompress Drawing data with the command palette: "Decompress current Excalidraw file". For more info check in plugin settings under "Saving".
{% endhint %}

## Excalidraw Data

### Text Elements (extracted)

* AWS EKS workshop ^xVzkfkd6
* DevOps (CI/CD) + Security = DevSecOps ^JR0xVyrG
* CI (Continous Intergrity): 빌드, 테스트
* CD (Continous Deployment): 서비스 배포, 퍼블리싱 ^GGmsFSNn
* CI/CD PipeLine (see stepper below)
* IDE ^83OmlA1d
* Jenkins ^dakv0gAh
* Github ^v03hzEiu
* Marven ^Vixuvrp3
* JUnit ^ntGviMdi
* SonarQuibe ^wA3I59Ps
* ELK Stack ^sc9585fv

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

* 예상 가능한 보안 위협 모델링 - ^3od4irxf
{% endstep %}

{% step %}
### 2. 구현 (SAST, DAST)

* 구현 단계의 보안 위협 점검 - ^f89PWWLM
{% endstep %}

{% step %}
### 3. 테스트 (DAST)

* ^JG1tO2KI
{% endstep %}

{% step %}
### 4. 배포

* 접근 제어, 침투 테스트 - ^WOVPFi5a
{% endstep %}

{% step %}
### 5. 운영

* 로깅, WAF, 보안 패치 - ^MW7ISBr3
{% endstep %}

{% step %}
### 6. 모니터링 (SIEM)

* 취약점 모니터링 도구로 공격검출 - ^2nwLxtxf
{% endstep %}
{% endstepper %}

### DevSecOps 흐름

{% stepper %}
{% step %}
### 소스 수정

* 소스 수정 ^o3NO2HZZ
{% endstep %}

{% step %}
### 수정 사항 커밋

* 복구 ^SjsWvJ5v
{% endstep %}

{% step %}
### 빌드

* 빌드 ^bFpMlqxu
{% endstep %}

{% step %}
### 테스트

* 테스트 ^fokqieAa
{% endstep %}

{% step %}
### 품질 테스트

* 품질 테스트 ^dHYpXnrw
{% endstep %}

{% step %}
### 배포

* 배포 ^LJsxeXx1
{% endstep %}

{% step %}
### 모니터링

* 모니터링 ^AHiGGyq6
{% endstep %}
{% endstepper %}

* 보안 요구 사항과 위협 모델링을 통해 초기 계획 단계에서 보안 고려 ^DJOXIeTG
* 코드가 안전하게 작성되고 저장되도록 보안 검증 수행 ^bpa2Fzbt
* 빌드 된 애플리케이션의 보안 검증 ^gsXKbnwD
* 애플리케이션을 안전하게 배포 ^oIPzEmqH
* 운영 중인 애플리케이션의 보안 유지 ^4lzqXLdX
* 지속적인 모니터링을 통해 보안 상태를 유지/개선 사항 수집 ^IneKDv0P

### SAST / DAST

* SAST - Static Application Security Testing\
  : 코드가 실행되기 전의 정적 분석을 통해 코드 내부의 보안 취약점을 점검(식별)하는 소스 코드 분석 기술 및 솔루션 ^cbDKG2ON
* DAST - Dynamic Application Security Testing\
  : 코드를 실행하여 동적 분석을 통해 프로그램의 보안 취약점을 식별하는 기술 및 솔루션 ^fI696IgK
* 직접 분석: 개발자의 의도를 파악해 코드를 점검할 수 있다. / 대량의 코드를 점검하는데 적절하지 않다.
* 자동 분석: 객관적인 분석 결과를 얻을 수 있다. / 이미 알려진 취약점에 대해서만 대응이 가능하다. ^wUJub0uE
* 소프트웨어 개발보안 검사원(진단원) ^FJzv7Lwv

### Embedded Images

(The original image references are preserved as provided.)

* \[\[topics/assets/images/devsecops4.PNG]] (598c529cac3d54d49edee4f8da21b11e913fc188)
* \[\[topics/assets/images/devsecops-aws.PNG]] (8cd121806ebdce8b2377566f32071d7867515aec)
* \[\[topics/assets/images/devsecops2.PNG]] (a435e2225dcc3406586661a2c240d8bfaa2df5c6)
* \[\[topics/assets/images/devsecops3.PNG]] (847ce52e0c8f4f843621a87791d8727a44f86179)
* \[\[topics/assets/images/devsecops1.PNG]] (28b6b188d104c8ba8a4f7554df76ebab1f2f32bd)

### Element Links

* ToAO2LkD: https://www.eksworkshop.com/

### Drawing (compressed JSON)

```compressed-json
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

... (truncated for brevity in this view; full compressed JSON retained in original file)
```

(Note: the full compressed drawing JSON block is preserved above as provided. If you need the entire raw block extracted separately, use the Excalidraw view / Decompress command in the plugin.)
