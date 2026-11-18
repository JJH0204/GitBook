# NodePort 공개 실습

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-011-MP |
| 목적 | Service 타입을 NodePort로 바꿔 `port-forward` 없이 `localhost:8080`으로 접속하고, 열려 있는 문을 센다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), 포트 매핑 설정(8080에서 30080)으로 만든 kind 클러스터 `student`, `mysite` Deployment가 떠 있는 상태 |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 클러스터에서 실행해 확인하지 않았다. NodePort와 `extraPortMappings`로 `curl`이 열리는지는 원본에서도 교실 리허설 대상으로 남아 있다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N2-16-003-DO | 밖으로 여는 법 |
| [lesson-0-lab.md](lesson-0-lab.md) | LEC-N2-16-008-MP | 클러스터 재생성 실습 |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-N2-16-009-MP | 내 이미지 올리기 실습 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 한 개 |
| 2 | 브라우저 | Windows | 5-A-05에서 사용 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: NodePort는 밖에 문을 여는 일이다. 열 Service는 웹(`mysite`)뿐이다. DB를 올린다면 그 Service는 NodePort로 열지 않고 ClusterIP로 둔다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 클러스터를 포트 매핑 없이 만들었다면 이 실습은 동작하지 않는다. 먼저 [클러스터 재생성 실습](lesson-0-lab.md)을 수행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 포트 매핑이 있다 | `docker ps`에 `0.0.0.0:8080->30080/tcp`가 보인다 |
| 2 | `mysite` Pod가 떠 있다 | `kubectl get pods`에서 `Running`이다 |

## 5. 절차

### A. NodePort로 연다

1. (5-A-01) `nano ~/myweb/k8s/service.yaml`로 파일을 연다.
2. (5-A-02) 아래 내용을 입력하고 저장한다(`Ctrl+O`, Enter, `Ctrl+X`).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysite
spec:
  type: NodePort
  selector:
    app: mysite
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

3. (5-A-03) 적용한다: `kubectl apply -f ~/myweb/k8s/service.yaml` → 결과: `service/mysite created`.
4. (5-A-04) Service를 확인한다: `kubectl get svc mysite` → 결과: TYPE이 `NodePort`이고 PORT(S)가 `80:30080/TCP`이다.
5. (5-A-05) 접속한다: `curl http://localhost:8080`. Windows 브라우저에서 `http://localhost:8080`도 연다. → 결과: `port-forward` 없이 내 포트폴리오가 열린다.

### B. 열린 문을 센다(11일차 회수)

1. (5-B-01) Service 목록을 본다: `kubectl get svc` → 결과: TYPE이 `NodePort`인 줄의 개수가 밖에 열린 문의 수이다.
2. (5-B-02) 호스트 쪽 수신 포트를 확인한다: `sudo ss -tulnp | grep 8080` → 결과: 8080을 수신하는 줄이 보인다.
3. (5-B-03) 질문에 답한다: DB를 올린다면 그 Service는 어떤 타입이어야 하는가? → 결과: `ClusterIP`(기본값)이다.

### C. Ingress 시연(강사)

1. (5-C-01) 강사가 [3. 밖으로 여는 법](lesson-3.md)의 Ingress 매니페스트와 그림을 보여 준다. → 결과: 학생은 문 하나에서 이름과 경로로 나눠 보내는 구조를 말한다.
2. (5-C-02) 12일차 `squid`(포워드 프록시)의 방향을 뒤집은 것이 리버스 프록시임을 짚는다.

{% hint style="info" %}
NOTE: Ingress 컨트롤러 설치까지 가지 않는다. 학생은 매니페스트를 `apply`하지 않는다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get svc mysite` | TYPE `NodePort` | `80:30080/TCP`가 보인다 |
| 2 | `curl http://localhost:8080` | 내 포트폴리오의 HTML | 기본 nginx 화면이 아니다 |
| 3 | 켜 둔 `port-forward`가 없는 상태 | 접속된다 | 터미널을 점유하는 명령이 없다 |

## 7. 복구

1. (7-01) Service를 ClusterIP로 되돌리려면 Service를 지운다: `kubectl delete service mysite` → 결과: `service "mysite" deleted`. 이후 접속은 `kubectl port-forward deployment/mysite 8081:80`으로 한다.
2. (7-02) 다시 열려면 5-A-03을 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-3.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. 복구 절을 추가했다 |
