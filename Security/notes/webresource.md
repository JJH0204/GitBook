# 웹 리소스와 URI 개념

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-NOT-003-DO |
| 유형 | D&O (개념) |
| 목적 | 웹 리소스와 URI, 프론트엔드를 이루는 리소스를 설명한다 |
| 확인 상태 | 미검증 (원본을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

웹 리소스는 웹에 갖춰진 정보 자산이다. 모든 웹 리소스는 고유한 URI(Uniform Resource Identifier)를 가지며 URI로 식별한다.

예: `http://dreamhack.io/index.html`은 "dreamhack.io에 있는 `index.html` 리소스를 가져오라"는 뜻이다.

## 2. 구성 요소

### 2.1 프론트엔드 리소스

| 리소스 | 역할 |
|---|---|
| HTML (Hyper Text Markup Language) | 태그와 속성으로 구조화된 문서를 만든다 |
| CSS (Cascading Style Sheets) | 리소스를 어떻게 보여줄지 정하는 스타일 시트다 |
| JS (JavaScript) | 웹 문서의 동작을 정의한다. 클라이언트가 실행하므로 클라이언트 사이드 스크립트라고 부른다 |
| 기타 | 문서, 이미지, 동영상, 폰트 등 |

## 3. 동작 원리

1. 클라이언트가 URI로 리소스를 요청한다.
2. 서버가 해당 리소스를 응답한다.
3. 브라우저가 리소스 종류에 맞게 처리한다 ([SEC-NOT-005-DO](web_rendering.md)).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| URI | 리소스 식별자. URL은 위치를 나타내는 URI의 한 종류다 |
| 클라이언트 사이드 스크립트 | 이용자의 브라우저에서 실행되는 코드 |

## 참조

| 참조 문서 | 제목 |
|---|---|
| [html.md](../../Programming/cs_basics/web_technologies/web-basics/html.md) | HTML 기초 |
| [browserdevtools.md](../../Programming/cs_basics/web_technologies/browser-and-devtools/browserdevtools.md) | 브라우저 개발자 도구 (CSS 원본 링크 대상) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] URI와 URL은 어떻게 다른가? 내 말로 적어 본다.
- [ ] 브라우저 개발자 도구로 어떤 사이트의 리소스 목록을 본 경험을 적어 본다.
