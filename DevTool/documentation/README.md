---
description: GitBook/Markdown 작성 규칙과 편집 팁
---

# [생성형 AI] 문서 작성 가이드 (Documentation)

문서를 쓸 때 필요한 문법 규칙을 정리한다. 문서 번호(Task ID)는 `DEV-DOC-<번호>-<유형>` 형식이다. 유형은 REF(표)다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 그룹 안내 (번호 없음) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (이 환경에서 실행하지 않았고 링크된 문서의 존재만 확인했다) |
| 개정 | R2 (2026-11-19) |

## 이 영역의 소개

이 레포의 문서를 쓰거나 고칠 때 문법을 찾는 참조 그룹이다. 문서를 처음 쓰는 사람은 기본 마크다운 문법을 먼저 확인하고, 그다음 GitBook 전용 블록을 확인한다.

## 핵심 용어

- Markdown: 제목, 목록, 표, 코드 블록 등을 일반 텍스트로 쓰는 표기법
- hint: GitBook의 알림 블록(info, warning, danger)
- stepper, tabs: GitBook의 단계 및 탭 블록
- SUMMARY.md: GitBook의 목차 파일. 새 문서는 여기에 추가해야 목차에 나타난다
- H1: 문서 첫 줄의 제목. SUMMARY의 제목과 일치시킨다

## 선수 지식

텍스트 편집기 사용법, Git 저장소의 기본 구조.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-DOC-001-REF | 표 | [마크다운 문법 (Markdown Syntax)](markdownsyntax.md) | 기본 마크다운 문법을 참조한다 |
| DEV-DOC-002-REF | 표 | [GitBook 확장 문법](gitbooksyntax.md) | `hint`, `stepper`, `tabs` 등 GitBook 블록을 참조한다 |

## 읽는 순서

1. DEV-DOC-001-REF로 기본 문법을 확인한다.
2. DEV-DOC-002-REF로 GitBook 블록과 알림 규칙을 확인한다.
