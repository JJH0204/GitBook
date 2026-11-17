# BBCode 마크업 (BBCode)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WBB-007-DO |
| 유형 | D&O (개념) |
| 목적 | 게시판에서 쓰는 간이 마크업 BBCode를 설명한다 |
| 확인 상태 | 미검증 (원본과 일반 웹 지식을 정리했다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

BBCode(Bulletin Board Code)는 게시판에서 글 서식을 지정하는 간이 마크업 언어다. 웹 페이지를 구성하는 언어이며 HTML과 문법이 다르지만 유사하다. 게시판은 BBCode를 HTML로 변환해 출력한다.

## 2. 구성 요소

| 항목 | HTML | BBCode |
|---|---|---|
| 태그 표기 | `<b>텍스트</b>` | `[b]텍스트[/b]` |
| 괄호 | 꺾쇠 `<` `>` | 대괄호 `[` `]` |
| 목적 | 웹 문서 전체 구성 | 게시판 글 서식 |

## 3. 동작 원리

1. 작성자가 `[b]텍스트[/b]`처럼 BBCode로 글을 쓴다.
2. 게시판 서버가 BBCode를 해석한다.
3. 서버가 대응하는 HTML(`<b>텍스트</b>`)로 바꿔 출력한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| BBCode | Bulletin Board Code |
| 마크업 언어 | 태그로 문서 구조와 서식을 표시하는 언어 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [html.md](html.md) | PRG-WBB-006-DO | HTML 기초 |
| [a9-usingknownvulnerablecomponents.md](../../../../Security/bwapp/a9-usingknownvulnerablecomponents.md) | (없음) | A9 알려진 취약 컴포넌트 공격 (BBCode 언급) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 게시판이 HTML 대신 BBCode를 쓰는 이유를 내 말로 추측해 적는다.
- [ ] BBCode와 HTML의 같은 점과 다른 점을 한 줄씩 적는다.
