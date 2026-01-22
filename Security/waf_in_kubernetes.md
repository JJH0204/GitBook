# WAF\_in\_Kubernetes

{% stepper %}
{% step %}
### 인그레스 컨트롤러(Ingress Controller) 설정

쿠버네티스에서 인그레스는 클러스터 외부에서 내부 서비스로의 HTTP/HTTPS 경로를 관리하는 리소스입니다. 인그레스 컨트롤러는 이러한 인그레스 리소스를 처리하는 컴포넌트로, Nginx 인그레스 컨트롤러가 널리 사용됩니다.

* Nginx 인그레스 컨트롤러 설치 (Helm 사용 예):

{% code title="설치 (Helm)" %}
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx
```
{% endcode %}

* 설치 후 동작 확인:

```bash
kubectl get pods -n ingress-nginx
```
{% endstep %}

{% step %}
### ModSecurity를 통한 WAF 설정

Nginx 인그레스 컨트롤러는 ModSecurity를 통합하여 WAF 기능을 제공할 수 있습니다.

* 인그레스 컨트롤러의 ConfigMap을 수정하여 ModSecurity 활성화 예:

{% code title="ConfigMap 예시 (nginx-configuration)" %}
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
data:
  enable-modsecurity: "true"
  enable-owasp-modsecurity-crs: "true"
```
{% endcode %}

* 설정 적용 후 인그레스 컨트롤러 재시작:

```bash
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```
{% endstep %}

{% step %}
### 인그레스 리소스 생성 및 Django 서비스 연결

Django 웹 서버를 외부에 노출하기 위해 인그레스 리소스를 생성하고, 이를 통해 트래픽을 관리합니다.

* 인그레스 리소스 예시:

{% code title="Ingress 리소스 예시" %}
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: django-ingress
  namespace: your-namespace
  annotations:
    nginx.ingress.kubernetes.io/enable-modsecurity: "true"
    nginx.ingress.kubernetes.io/enable-owasp-modsecurity-crs: "true"
spec:
  rules:
    - host: your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: django-service
                port:
                  number: 80
```
{% endcode %}

{% hint style="info" %}
`your-namespace`, `your-domain.com`, `django-service` 등은 환경에 맞게 변경하세요.
{% endhint %}
{% endstep %}

{% step %}
### WAF 규칙 구성 및 테스트

ModSecurity는 OWASP Core Rule Set(CRS)을 기본으로 제공하지만, 필요에 따라 사용자 정의 규칙을 추가할 수 있습니다.

* 규칙 구성 방법:
  * ConfigMap에 추가 규칙을 정의하거나, 별도의 규칙 파일을 생성하여 인그레스 컨트롤러에 마운트(예: ConfigMap → volume)할 수 있습니다.
  * OWASP CRS 외에 비즈니스 특성에 맞는 예외/허용 규칙을 적용하세요.
* 테스트:
  * 다양한 공격 시나리오(예: SQL 인젝션, XSS 등)를 시뮬레이션하여 WAF가 차단하는지 확인합니다.
  * 인그레스 컨트롤러와 ModSecurity 로그를 확인하여 차단/허용 로그를 검토하세요.

{% hint style="warning" %}
테스트는 실제 서비스에 영향을 줄 수 있으므로, 가능하면 스테이징 환경에서 먼저 수행하세요.
{% endhint %}
{% endstep %}
{% endstepper %}

### 참고 자료

* https://kubernetes.io/ko/docs/concepts/windows/user-guide/
* https://k8s-docs.netlify.app/ko/docs/setup/production-environment/windows/user-guide-windows-containers/
* https://www.tigera.io/learn/guides/kubernetes-security/kubernetes-waf/
