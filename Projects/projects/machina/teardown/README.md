# Machina R&D 해체 분석 (Teardown)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MCH-001-DO |
| 유형 | D&O (개요) |
| 목적 | Machina R&D 중 오브젝트 풀링·모바일 최적화, 오브젝트 파괴 감지, UI 옵서버 패턴 해체 문서의 범위를 정리한다 |
| 확인 상태 | 미검증 (소스를 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
WARNING: 이 팀 레포는 비공개 레포, 접근 권한 필요. 구조·설계 중심으로 쓰며 밸런스 수치, 기획 원문, 에셋 경로, 팀원 실명은 싣지 않는다. 공개 범위는 사용자 결정 전이다.
{% endhint %}

{% hint style="info" %}
NOTE: 로컬 소스(`25Machina`)의 작업 트리에는 C# 파일이 없어, 코드는 소스 레포의 git 오브젝트에서 읽기 전용으로 읽었다. 컴파일·실행은 하지 않았다.
{% endhint %}

## 이 문서의 구성

| 문서 | Task ID | 내용 |
|---|---|---|
| [오브젝트 풀링·모바일 최적화](pooling-optimization.md) | PRJ-MCH-101 | `PoolManager`, 몬스터 재사용, Addressables 그룹, URP 품질 에셋 |
| [오브젝트 파괴 감지](destruction-detection.md) | PRJ-MCH-102 | `GlobalGameObject` 이벤트, `IsDestroy`/`IsDisable` 입력 노드 |
| [UI 옵서버 패턴](ui-observer.md) | PRJ-MCH-103 | 시스템 메시지 버스, `EventManager` |

## 기존 문서와의 관계

기존 R&D 문서(`rnd/`)는 조사 당시의 코드와 메모를 정리한 기록이다. 이 폴더는 현재 소스를 다시 읽어, 조사 기록과 달라진 점(키 선택 결과, 목록·카운터 구조, 정적 이벤트 버스)을 중심으로 쓴다. 풀링은 [오브젝트 풀링 조사](../rnd/objectpoolingresearch.md), 던전 쪽 풀링은 [오브젝트 상태 보관과 풀링](../dungeon-stage/object-state-pooling.md)을 먼저 읽는다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 풀링, 파괴 감지, 옵서버 중 내가 가장 직접 구현한 것은 무엇이고 이유는 무엇인가?
- [ ] 세 기법은 서로 어떻게 맞물리는가(예: 풀로 돌려보낼 때도 파괴 이벤트를 쓰는가)?
