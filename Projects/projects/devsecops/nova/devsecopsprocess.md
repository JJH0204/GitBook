# DevSecOpsProcess

{% stepper %}
{% step %}
### 코드 변경 감지

* Github Webhook
* 개발자(코드커밋/푸시) > Github(변경사항 알림) > Jenkins
{% endstep %}

{% step %}
### Jenkins 파이프라인

{% hint style="info" %}
관리자 역할
{% endhint %}

파이프라인 단계:

{% stepper %}
{% step %}
#### SonarQube

* 코드 품질 검사(버그 찾기 / 취약점 검사 / 코드 스타일 검사)
{% endstep %}

{% step %}
#### Docker Image 빌드

* 애플리케이션과 필요한 모든 것을 하나의 패키지로 만듦(코드 / 실행환경 / 설정)
* 생성한 이미지는 주로 Docker Hub에 저장됨
{% endstep %}

{% step %}
#### Kubernetes 매니페스트 업데이트

* 애플리케이션 실행을 위한 설계도 작성
* (몇 개의 노드 / 얼마만큼의 자원 / 어떻게 네트워크를 구성할 지 등 설정)
{% endstep %}

{% step %}
#### 쿠버네티스 배포

* 실제 애플리케이션 실행(컨테이너 시작 / 네트워크 연결 / 부하 분산 설정 등)
{% endstep %}

{% step %}
#### 서비스 노출

* 외부에서 접근할 수 있도록 설정
* 도메인 연결 / 보안 설정 / 트래픽 라우팅 등
{% endstep %}
{% endstepper %}
{% endstep %}
{% endstepper %}
