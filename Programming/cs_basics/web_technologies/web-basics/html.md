# HTML 기초 (HTML)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WBB-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | HTML 문서의 기본 구조와 태그·속성을 설명한다 |
| 확인 상태 | 미검증 (원본과 일반 웹 지식을 정리했다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

HTML(HyperText Markup Language)은 웹 페이지의 구조와 내용을 정의하는 마크업 언어다. 브라우저는 HTML을 읽어 화면을 구성한다.

## 2. 구성 요소

### 2.1 기본 문서

{% code title="index.html" %}
```html
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Web Page!</title>
  </head>
  <body>
    <!-- 웹 페이지에 표시할 내용을 작성. -->
    <p>자기소개 페이지 작성하기</p>
  </body>
</html>
```
{% endcode %}

| 줄 | 설명 |
|---|---|
| `<!DOCTYPE html>` | 문서가 HTML5임을 선언한다 |
| `<html lang="ko">` | 루트 요소. `lang`은 문서 언어를 한국어로 지정한다 |
| `<head>` | 화면에 직접 표시되지 않는 문서 정보(메타데이터)를 담는다 |
| `<meta charset="UTF-8">` | 문자 인코딩을 UTF-8로 지정한다 |
| `<meta http-equiv="X-UA-Compatible" ...>` | 구형 Internet Explorer용 호환 설정이며 현재 브라우저에는 필요하지 않다 |
| `<meta name="viewport" ...>` | 모바일 화면 너비에 맞춰 표시하도록 지정한다 |
| `<title>` | 브라우저 탭에 표시되는 제목이다 |
| `<body>` | 화면에 표시할 내용을 담는다 |
| `<p>` | 문단 |

### 2.2 태그와 속성

| 구성 | 설명 |
|---|---|
| 태그 | 웹 페이지 구성 요소를 정의하며 HTML 문법의 가장 작은 단위다. `<` `>` 사이에 태그 이름을 넣는다(`<tag>`) |
| 속성 | 태그에 의미나 기능을 보충하는 옵션이다. 태그 없이 단독으로 쓸 수 없다. 속성 이름과 값으로 구성한다(`<tag 속성="값">`) |

속성 값이 여러 개이면 따옴표 안에 보통 공백으로 구분해 나열한다(예: `class="a b"`). 일부 속성은 쉼표를 쓴다.

### 2.3 요소의 종류

| 종류 | 설명 | 예 |
|---|---|---|
| 여는 태그와 닫는 태그가 있는 요소 | `<p>내용</p>` 형태 | `p`, `div`, `a` |
| void 요소 | 내용이 없어 닫는 태그를 쓰지 않는다 | `br`, `img`, `meta`, `input` |
| 시맨틱 태그 | 영역의 의미를 나타낸다 | `header`, `nav`, `main`, `article`, `section`, `footer` |

## 3. 동작 원리

1. 브라우저가 HTML 문서를 읽는다.
2. 브라우저가 태그를 계층 구조의 객체 트리(DOM, Document Object Model)로 만든다.
3. CSS와 JavaScript가 DOM을 바탕으로 모양과 동작을 더한다.
4. 브라우저가 DOM을 화면으로 그린다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| HTML | HyperText Markup Language |
| DOM | Document Object Model. 문서를 트리 구조 객체로 표현한 모델 |
| void 요소 | 닫는 태그가 없는 요소 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [웹 렌더링 엔진 원리](../../../../Security/notes/web_rendering.md) | SEC-NOT-005-DO | 렌더링 과정 |
| [webresource.md](../../../../Security/notes/webresource.md) | SEC-NOT-003-DO | 웹 리소스와 URI 개념 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 태그와 속성의 차이를 내 말로 설명한다.
- [ ] `<head>`와 `<body>`에 들어가는 내용의 차이를 적는다.
