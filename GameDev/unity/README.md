---
description: CharacterController, Rigidbody, NavMeshAgent 이동 구현과 투사체 전투 설계
---

# 유니티 (Unity)

Unity 컴포넌트로 캐릭터 이동과 공격을 구현한 노트를 모은 그룹이다. 문서 번호(Task ID)는 `GMD-UNI-<번호>-<유형>` 형식이다. 모든 코드는 실행해 확인하지 않았다(미검증).

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| GMD-UNI-001-MP | MP + 참조 표 | [캐릭터 컨트롤러 이동 구현](charactercontroller.md) | `CharacterController.Move`로 이동, 점프, 대시, 중력을 구현한다 |
| GMD-UNI-002-MP | MP + 참조 표 | [리지드바디 캐릭터 이동 구현](rigidbody.md) | `Rigidbody`로 이동, 점프, 대시를 구현한다 |
| GMD-UNI-003-MP | MP + 참조 표 | [내비메시 에이전트 클릭 이동](navmeshagent.md) | `NavMeshAgent`로 마우스 클릭 이동을 구현한다 |
| GMD-UNI-004-DO | D&O | [전투 시스템 투사체 발사 설계](battlesystemdesign.md) | 대상 지정, 발사, 사거리 제한의 설계 의도를 확인한다 |

## 읽는 순서

1. GMD-UNI-002-MP로 물리 기반 이동을 구현한다.
2. GMD-UNI-001-MP로 `CharacterController` 방식과 비교한다.
3. GMD-UNI-003-MP로 클릭 이동을 추가한다.
4. GMD-UNI-004-DO로 공격 설계를 본다.

{% hint style="info" %}
NOTE: 이 그룹의 코드는 기존 Input Manager(`Input.GetAxis`) 기준이다. Unity 6 기본 설정(새 Input System 전용)에서는 `Project Settings > Player > Active Input Handling`을 `Both`로 바꿔야 동작한다. 버전 확인 필요.
{% endhint %}
