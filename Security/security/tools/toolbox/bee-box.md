# bee-box 환경 및 취약점 점검

## 목적

bee-box는 웹 취약점 실습용으로 만든 의도적 취약 가상 머신(VM)이다. 취약 웹 앱 bWAPP이 들어 있다. 이 문서는 bee-box의 용도, 점검 순서, VM 설정 팁을 정리한다.

{% hint style="danger" %}
WARNING: bee-box는 일부러 취약하게 만든 VM이다. 외부 네트워크에 노출하지 않는다. 호스트 전용(Host-only) 또는 내부 네트워크 같은 격리된 실습망에서만 실행한다. 점검 대상은 자신이 설치한 bee-box뿐이다.
{% endhint %}

{% hint style="info" %}
NOTE: 확인 상태: 미검증. 원본 페이지를 정리한 것이며 이 환경에서 실행해 확인하지 않았다.
{% endhint %}

## 구성 요소

| 구성 요소 | 역할 |
|---|---|
| bee-box VM | 취약한 서비스와 bWAPP을 실행하는 가상 머신이다 |
| bWAPP | 100개 이상의 웹 취약점을 담은 취약 웹 앱이다 |
| 점검 도구 | [Nmap](scaning-tool.md), [ZAP](zap.md) 등 이 그룹의 도구를 쓴다 |

## 설치

설치 방법은 외부 블로그를 참조한다. 이 문서는 설치 절차를 다시 쓰지 않는다.

* 참조: [bee-box setup (외부 블로그)](https://blog.naver.com/emmaeunji/221761093736)

## 점검 순서

2017년판 [OWASP](../../../owasp-top10/owasp.md) Top 10 순서대로 점검한다. 각 항목의 실습 기록은 아래 문서에 있다.

| OWASP 2017 항목 | 실습 문서 |
|---|---|
| A1 Injection | [A1-Injection](../../../bwapp/a1-injection.md) |
| A2 Broken Authentication | [A2-Broken\_Auth](../../../bwapp/a2-broken_auth.md) |
| A3 Cross-Site Scripting | [A3-Cross-Site Scripting](../../../bwapp/a3-cross-site-scripting.md) |
| A4 Insecure Direct Object References | [A4-Insecure\_DOR](../../../bwapp/a4-insecure_dor.md) |
| A8 CSRF | [A8-CSRF](../../../bwapp/a8-csrf.md) |
| A9 Using Components with Known Vulnerabilities | [A9-UsingKnownVulnerableComponents](../../../bwapp/a9-usingknownvulnerablecomponents.md) |
| A10 | 원본에 항목만 있고 문서가 없다 |

## 가상머신 설정 팁

{% hint style="info" %}
NOTE: 마우스 통합 설정을 끄면 VM 화면 조작이 원활하다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 키보드 또는 지역 설정에서 USA 배열이 적용되지 않으면 Korea(한글 키보드)로 바꾼다.
{% endhint %}

## 약어·용어

| 용어 | 뜻 |
|---|---|
| VM | Virtual Machine. 가상 머신 |
| bWAPP | buggy Web APPlication. 의도적 취약 웹 앱 |
| OWASP | Open Worldwide Application Security Project |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 의도적 취약 VM을 격리된 네트워크에서만 실행해야 하는 이유를 적는다.
- [ ] bee-box에서 점검해 본 취약점 하나와 그때 겪은 어려움을 적는다.
