---
description: URL 구조, URL 인코딩, HTTP 쿠키, HTTP 상태 코드 요약
---

# HTTP 및 URL (HTTP & URLs)

웹 주소(URL)의 구조와 인코딩, 쿠키, 상태 코드를 정리한다. 문서 번호(Task ID)는 `PRG-HTU-<번호>-<유형>` 형식이다. HTTP 프로토콜 자체와 상태 코드 전체 표는 Network 스페이스가 정본이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-HTU-001-DO | 개념 | [URL 구조 및 분석 (URL)](url.md) | URL을 구성 요소로 나눠 읽는다 |
| PRG-HTU-002-DO | 개념 | [URL 인코딩 (URL Encoding)](url_encoding.md) | 예약 문자와 `%XX` 인코딩 규칙을 이해한다 |
| PRG-HTU-003-DO | 개념 | [HTTP 쿠키 및 속성 (Cookie)](cookie.md) | 쿠키 교환 방식과 보안 속성을 이해한다 |
| PRG-HTU-004-REF | 표 | [HTTP 상태 코드](rfc_2616_code.md) | 상태 코드 다섯 분류와 대표 코드를 찾는다 |

## 읽는 순서

1. PRG-HTU-001-DO로 URL의 구성 요소를 본다.
2. PRG-HTU-002-DO로 URL에 쓸 수 없는 문자의 처리를 본다.
3. PRG-HTU-003-DO로 요청 사이에 상태를 유지하는 방법을 본다.
4. 응답 결과를 읽을 때 PRG-HTU-004-REF를 연다.
