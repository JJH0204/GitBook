# 내 훈련 기록

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-DOC-005-REF |
| 유형 | REF (규칙표와 양식) |
| 목적 | 훈련 기록 페이지의 제목 규칙, 진도표, 주간 회고 양식을 제공한다 |
| 확인 상태 | 미검증 (사용자가 쓰는 양식의 구조를 보존하고 형식만 정돈했다) |
| 개정 | R1 (2026-11-18) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [03-documentation-habits/README.md](../03-documentation-habits/README.md) | GMD-DOC-001-DO | '질문받는 기획자'가 되기 위한 문서화 습관 |

이 페이지가 훈련장의 본체다. 템플릿을 복사해서 이 페이지 아래에 새 페이지로 쓴다.

## 페이지 제목 규칙

```
YYYY-MM-DD <종류> <주제>
```

| 종류 | 의미 | 템플릿 |
|---|---|---|
| `rd` | 역기획 1장 | [reverse-design-template](../01-system-design/reverse-design-template.md) |
| `bal` | 밸런스 실습 (시트 링크 + 의도 문장) | [balance-drills](../01-system-design/balance-drills.md) |
| `dc` | 결정 카드 | [decision-card-template](../02-portfolio/decision-card-template.md) |
| `pf` | 포트폴리오 문서 | [02-portfolio](../02-portfolio/README.md) |
| `pfr` | 문제 정의서 | [problem-framing-template](../03-documentation-habits/problem-framing-template.md) |
| `pt` | 플레이테스트 로그 | [playtest-log-template](../03-documentation-habits/playtest-log-template.md) |
| `wk` | 주간 회고 | 아래 양식 |

예: `2026-11-18 rd 젠레스 존 제로 그로기`, `2026-11-19 bal B1 데미지 공식`

## 진도표

> 매주 토요일 회고 때 한 줄씩 추가한다. A, B, AI 보완율은 [GMD-DOC-001-DO 성장 지표](../03-documentation-habits/README.md#성장-지표-ai-의존도가-줄고-있는가) 참고.

| 주 | 역기획 | 밸런스 | 결정 카드 | 포트폴리오 | 플테 로그 | A | B | AI 보완율 | 한 줄 메모 |
|---|---|---|---|---|---|---|---|---|---|
| 1주 (__/__) | /2 | /1 | /2 | — | — | | | | |
| 2주 | /2 | /1 | /4 | — | — | | | | |
| 3주 | /2 | /2 | /4 | /1 | — | | | | |
| 4주 | /1 | — | /4 | /2 | /1 | | | | |

## 주간 회고 양식

`practice/YYYY/MM-DD-wk.md`로 저장한다.

```markdown
# N주차 회고 (MM-DD ~ MM-DD)

## 한 것
- 

## 가장 자주 놓친 것 ([AI] 태그 항목에서)
- 

## 30분 안에 못 끝낸 칸 (반복되는 빈칸)
- 

## 다음 주에 바꿀 것 하나
- 
```
