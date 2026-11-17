# 웹 해킹 개요 (Web Hacking)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-NOT-004-DO |
| 유형 | D&O (개념) |
| 목적 | 웹 해킹의 범위를 정의하고 관련 문서를 안내한다 |
| 확인 상태 | 미검증 (원본 두 문장을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

웹 해킹은 웹을 대상으로 하는 해킹과 그 기술을 가리킨다. 웹 서버와 클라이언트에서 발생하는 취약점과 이를 공격하는 기법을 포함한다.

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 공격 기법을 시도하는 것은 불법이다. 자신이 소유·관리하는 격리된 실습 환경이나 의도적 취약 앱에서만 실습한다.
{% endhint %}

## 2. 구성 요소

| 영역 | 설명 |
|---|---|
| 서버 측 | 웹 서버와 애플리케이션, 데이터베이스에서 생기는 취약점 |
| 클라이언트 측 | 브라우저에서 실행되는 스크립트, 세션 처리에서 생기는 취약점 |

## 3. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [web_rendering.md](web_rendering.md) | SEC-NOT-005-DO | 웹 렌더링 엔진 원리 |
| [webresource.md](webresource.md) | SEC-NOT-003-DO | 웹 리소스와 URI 개념 |
| [webbrowser.md](../../Programming/cs_basics/web_technologies/browser-and-devtools/webbrowser.md) | | 웹 브라우저 |

{% hint style="info" %}
NOTE: 원본의 `Web Reversing` 소제목은 내용이 없어 제거했고, 원본의 카드 링크 `web.md`는 대상 파일이 없어 삭제했다. 확인 필요.
{% endhint %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 서버 측 취약점과 클라이언트 측 취약점의 차이를 내 말로 적어 본다.
- [ ] 실습 환경을 따로 두어야 하는 이유를 적어 본다.
