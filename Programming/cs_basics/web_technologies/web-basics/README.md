---
description: 웹 개요, 프론트엔드, CGI, 웹 서버 구축, 워드프레스 배포, HTML, BBCode
---

# 웹 기초 (Web Basics)

웹의 통신 구조와 구성 요소, 웹 서버 구축 절차를 정리한다. 문서 번호(Task ID)는 `PRG-WBB-<번호>-<유형>` 형식이다.

{% hint style="info" %}
NOTE: 절차 문서(MP)는 모두 미검증이다. 웹 서버·방화벽 설정을 바꾸는 단계는 서비스 중단 위험이 있으므로 테스트 서버에서 먼저 수행한다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-WBB-001-DO | 개념 | [웹 개요 및 통신 구조 (Web)](weboverview.md) | 클라이언트와 서버의 통신 순서를 이해한다 |
| PRG-WBB-002-DO | 개념 | [프론트엔드 기초 (Front-end)](frontendbasics.md) | 프론트엔드와 백엔드의 구분을 이해한다 |
| PRG-WBB-003-DO | 개념 | [CGI 인터페이스 (CGI)](cgi.md) | 웹 서버가 외부 프로그램을 실행하는 방식을 이해한다 |
| PRG-WBB-004-MP | 절차 | [웹 서버 설정 및 명령어 (WebServer)](webserver.md) | Rocky Linux에 Apache(httpd)를 설치하고 페이지를 띄운다 |
| PRG-WBB-005-MP | 절차 | [Docker 워드프레스 배포 (Wordpress)](wordpress.md) | Docker 저장소를 등록한다(배포 단계는 미완성) |
| PRG-WBB-006-DO | 개념 | [HTML 기초 (HTML)](html.md) | HTML 문서 구조와 태그·속성을 이해한다 |
| PRG-WBB-007-DO | 개념 | [BBCode 마크업 (BBCode)](bbcode.md) | 게시판용 간이 마크업을 이해한다 |

## 읽는 순서

1. PRG-WBB-001-DO로 요청과 응답의 순서를 본다.
2. PRG-WBB-002-DO, 006-DO, 007-DO로 클라이언트 측 구성을 본다.
3. PRG-WBB-003-DO로 서버 측 동적 처리를 본다.
4. PRG-WBB-004-MP로 웹 서버를 직접 구축한다.
