# Kubernetes 환경의 WAF 구성

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-010-MP |
| 목적 | Nginx 인그레스 컨트롤러에 ModSecurity와 OWASP CRS를 켜서 클러스터로 들어오는 웹 요청을 검사한다 |
| 적용 대상 | Kubernetes 클러스터(실습 또는 스테이징), `kubectl`·`helm` 사용 가능, 클러스터 관리자 권한 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 ConfigMap 이름 `nginx-configuration`은 Helm으로 설치한 ingress-nginx의 기본 ConfigMap 이름(보통 `ingress-nginx-controller`)과 다를 수 있다. 5-B-01에서 실제 이름을 확인한다(확인 필요).
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [웹 애플리케이션 방화벽 (WAF)](waf.md) | SEC-DEF-009-MP | 서버 단독 환경의 ModSecurity |
| Tigera: Kubernetes WAF 가이드 | - | https://www.tigera.io/learn/guides/kubernetes-security/kubernetes-waf/ |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Kubernetes 클러스터 | 실습·스테이징 | 운영 클러스터는 쓰지 않는다 |
| 2 | `kubectl`, `helm` | 클러스터에 접속된 상태 | |
| 3 | 시험 대상 서비스 | 예: `<서비스 이름>` (원본은 Django 웹 서버) | 포트 80 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 5-B-02의 인그레스 컨트롤러 재시작과 규칙 변경은 외부에서 들어오는 요청에 일시적 중단 또는 오차단을 일으킬 수 있다. 실서비스가 아닌 스테이징 환경에서 먼저 수행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-D의 시험은 공격 요청을 보내 WAF의 차단 동작을 확인하는 것이다. 자신이 관리하는 시험 서비스에만 보낸다. 다른 시스템에 보내지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클러스터에 접속한다: `kubectl get nodes` | 노드가 `Ready`로 나온다 |
| 2 | `helm`이 설치돼 있다: `helm version` | 버전이 출력된다 |
| 3 | 시험 서비스가 있다: `kubectl get svc -n <네임스페이스>` | 대상 서비스가 보인다 |

## 5. 절차

### A. 인그레스 컨트롤러 설치

1. (5-A-01) 저장소를 추가한다: `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx` → 결과: 저장소가 추가됐다는 메시지가 출력된다.
2. (5-A-02) 설치한다: `helm install ingress-nginx ingress-nginx/ingress-nginx` → 결과: `STATUS: deployed`가 출력된다.
3. (5-A-03) 동작을 확인한다: `kubectl get pods -n ingress-nginx` (Helm 기본 설치 시 네임스페이스는 설치 때 지정한 값이며, 지정하지 않았다면 `default`다. `-n`을 실제 값으로 바꾼다) → 결과: 컨트롤러 파드가 `Running`이다.

### B. ModSecurity 활성화

1. (5-B-01) ConfigMap 이름을 확인한다: `kubectl get configmap -n <네임스페이스>` → 결과: 컨트롤러 ConfigMap 이름(예: `ingress-nginx-controller`)을 얻는다.
2. (5-B-02) ConfigMap에 아래 값을 추가한다. `metadata.name`은 5-B-01의 실제 이름으로 바꾼다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <ConfigMap 이름>
  namespace: <네임스페이스>
data:
  enable-modsecurity: "true"
  enable-owasp-modsecurity-crs: "true"
```

3. (5-B-03) 적용한다: `kubectl apply -f <파일 이름>.yaml` → 결과: `configured`가 출력된다.
4. (5-B-04) 컨트롤러를 재시작한다: `kubectl rollout restart deployment ingress-nginx-controller -n <네임스페이스>` → 결과: `restarted`가 출력된다.
5. (5-B-05) 재시작이 끝났는지 확인한다: `kubectl rollout status deployment ingress-nginx-controller -n <네임스페이스>` → 결과: `successfully rolled out`이 출력된다.

### C. 인그레스 리소스 생성

1. (5-C-01) 아래 내용으로 인그레스 파일을 만든다. 도메인, 네임스페이스, 서비스 이름은 환경에 맞게 바꾼다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <인그레스 이름>
  namespace: <네임스페이스>
  annotations:
    nginx.ingress.kubernetes.io/enable-modsecurity: "true"
    nginx.ingress.kubernetes.io/enable-owasp-modsecurity-crs: "true"
spec:
  rules:
    - host: <도메인>
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: <서비스 이름>
                port:
                  number: 80
```

2. (5-C-02) 적용한다: `kubectl apply -f <파일 이름>.yaml` → 결과: `created`가 출력된다.
3. (5-C-03) 확인한다: `kubectl get ingress -n <네임스페이스>` → 결과: 인그레스가 목록에 보인다.

### D. 규칙 구성과 시험

1. (5-D-01) 추가 규칙이 필요하면 ConfigMap에 정의하거나 규칙 파일을 ConfigMap으로 만들어 인그레스 컨트롤러에 마운트한다. 비즈니스 특성에 맞는 예외·허용 규칙은 OWASP CRS와 별도로 적용한다.
2. (5-D-02) 시험 요청을 시험 서비스에 보낸다. 예: 주소에 `<script>` 문자열이 포함된 요청 → 결과: WAF가 요청을 차단하고 `403` 응답을 준다(ModSecurity의 기본 차단 응답 코드. 확인 필요).
3. (5-D-03) 컨트롤러 로그를 확인한다: `kubectl logs -n <네임스페이스> deployment/ingress-nginx-controller` → 결과: ModSecurity가 차단한 요청의 기록이 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 정상 요청: `curl -i http://<도메인>/` | 서비스가 응답한다 | 응답 코드 `200` |
| 2 | 시험 요청(5-D-02) | WAF가 차단한다 | 응답 코드 `403` |
| 3 | 컨트롤러 로그 | 차단 기록이 있다 | ModSecurity 관련 항목 1건 이상 |

## 7. 복구

1. (7-01) ConfigMap의 `enable-modsecurity`와 `enable-owasp-modsecurity-crs` 값을 `"false"`로 바꾸고 `kubectl apply -f`로 적용한다 → 결과: `configured`가 출력된다.
2. (7-02) 컨트롤러를 재시작한다: `kubectl rollout restart deployment ingress-nginx-controller -n <네임스페이스>`
3. (7-03) 인그레스의 ModSecurity 주석을 제거하거나 인그레스를 삭제한다: `kubectl delete ingress <인그레스 이름> -n <네임스페이스>`
4. (7-04) 컨트롤러를 제거하려면 `helm uninstall ingress-nginx`를 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 스테이징 환경 CAUTION, 기능 확인, 복구 절을 추가했다. ConfigMap 이름 확인 단계를 보충했다. 윈도우 컨테이너 문서를 가리키던 참고 링크 2건은 WAF와 관련이 없어 삭제했다 |
