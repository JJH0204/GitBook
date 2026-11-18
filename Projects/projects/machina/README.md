---
description: 25년 SBS 대구게임아카데미 팀 프로젝트반(팀 재조합) 작업 결과 및 과정 기록
---

# 마키나 프로젝트 (Machina)

25년 SBS 대구게임아카데미 팀 프로젝트반(팀 재조합)에서 진행한 프로젝트 "마키나"의 작업 결과와 과정을 기록한다. 이 페이지는 그룹 README이며 문서 번호(Task ID)는 `PRJ-MCH-<번호>-<유형>` 형식이다.

## 결과 영상

{% embed url="https://youtu.be/-IaZPr1fBW8" %}

## 하위 기록

| 주제 | 문서 |
|---|---|
| 몬스터 AI | [몬스터 AI (Monster AI)](monsterai/README.md) |
| 최적화 | [최적화 (Optimization)](optimization/README.md) |
| 셰이더 | [셰이더 (Shader)](shader/README.md) |
| 연구 개발 | [연구 개발 (R&D)](rnd/README.md) |

## 해체 분석 (내가 작성한 코드)

팀 레포의 내 커밋을 영역별로 해체해, 따라 만들 수 있게 정리했다. 코드는 공개 레포 `2025_Project_ProjectRecombination`에서 읽었다.

* [던전·스테이지·씬 관리](dungeon-stage/README.md)
* [UI·사운드·이벤트·입력·Android 빌드](ui-audio-input/README.md)
* [보스 스킬과 테스트 도구](boss-skills/README.md)
* [비주얼 스크립팅 노드 체계](visual-scripting/README.md)

개인 레포로 만든 도구도 있다.

* [GOS](../gos/README.md): 코드 없이 기믹을 만드는 노드 플러그인(다른 강사가 수업에서 사용)
* [MonsterAI](../monster-ai/README.md): Behavior Tree와 그래프 뷰 에디터
* [Unity 우선순위 큐](../unity-priority-queue/README.md): MonsterAI의 초기 실험
