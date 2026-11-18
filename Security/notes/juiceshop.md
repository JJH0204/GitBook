# OWASP Juice Shop 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-NOT-006-DO |
| 유형 | D&O (개념) |
| 목적 | 실습용 취약 웹 앱 Juice Shop을 소개하고 안전한 실행 방법을 안내한다 |
| 확인 상태 | 미검증 (원본은 링크 표뿐이었다. 개요와 실행 안내는 일반 지식으로 보충했다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

OWASP Juice Shop은 OWASP 프로젝트가 만든 의도적 취약 웹 애플리케이션이다. 웹 취약점을 합법적으로 실습하는 데 쓴다. 취약점을 풀면 점수판(Score Board)에서 진행 상황을 확인할 수 있다.

## 2. 구성 요소

| 항목 | 설명 |
|---|---|
| 서버 | Node.js 기반 웹 앱이다 |
| 기본 포트 | TCP 3000 |
| 점수판 | `/#/score-board` 경로 (실습 풀이 문서에서 확인한 경로) |

## 3. 실행 환경

{% hint style="danger" %}
WARNING: 이 앱은 일부러 취약하게 만들었다. 인터넷에 공개된 서버나 업무망에 두지 않는다. 자신의 PC나 격리된 VM·컨테이너에서만 실행하고, 실습망 밖에서 접근할 수 없게 한다. 허가받지 않은 시스템을 대상으로 공격 기법을 쓰는 것은 불법이다.
{% endhint %}

컨테이너 실행 예 (공식 이미지, 미검증):

```
docker run -d -p 127.0.0.1:3000:3000 bkimminich/juice-shop
```

접속 주소는 `http://127.0.0.1:3000`이다. `127.0.0.1`로 바인딩하면 같은 PC에서만 접근한다.

## 4. 참조

| 참조 문서 | 제목 |
|---|---|
| [juiceshop_walkthrough.md](juiceshop_walkthrough.md) | OWASP Juice Shop 실습 풀이 |
| [Juice Shop 풀이 모음 (GitHub, 외부)](https://github.com/bsqrl/juice-shop-walkthrough) | 외부 자료 |
| [OWASP Juice Shop 프로젝트 (외부)](https://owasp.org/www-project-juice-shop/) | 외부 자료 |

{% hint style="info" %}
NOTE: 원본 표의 `Juiceshop_main.js` 행은 링크가 비어 있어 삭제했다. 확인 필요.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 의도적 취약 앱을 인터넷에 공개하면 안 되는 이유를 적어 본다.
- [ ] 실습 환경을 격리하기 위해 내가 쓸 방법을 적어 본다.
