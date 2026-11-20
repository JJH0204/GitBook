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
| GMD-UNI-005-DO | D&O + 예제 | [\[생성형 AI\] 물리 질의와 충돌 이벤트](physics-queries.md) | `Raycast`, `OverlapSphere`, `OnCollision`, `OnTrigger`의 사용과 발생 조건을 이해한다 |
| GMD-UNI-006-DO | D&O + 예제 | [\[생성형 AI\] 시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md) | 프레임 독립 이동과 `timeScale`의 적용 범위를 이해한다 |
| GMD-UNI-007-DO | D&O + 예제 | [\[생성형 AI\] 새 Input System 기초](input-system.md) | 액션 기반 입력과 기존 Input Manager와의 차이를 이해한다 |
| GMD-UNI-008-DO | D&O + 예제 | [\[생성형 AI\] 프리팹과 Instantiate, Destroy](prefab-instantiate.md) | 프리팹 구조와 런타임 생성·삭제의 동작과 비용을 이해한다 |
| GMD-UNI-009-DO | D&O + 예제 | [\[생성형 AI\] 씬 로딩: SceneManager와 비동기 로드](scene-loading.md) | `SceneManager`의 동기·비동기·Additive 로드와 로딩 화면을 이해한다 |
| GMD-UNI-010-DO | D&O + 예제 | [\[생성형 AI\] 오디오 기초: AudioSource, AudioMixer](audio-basics.md) | `AudioSource`, `AudioMixer` 사용과 dB 환산을 이해한다 |
| GMD-UNI-011-DO | D&O + 예제 | [\[생성형 AI\] uGUI 기초: Canvas와 이벤트](ugui-basics.md) | Canvas, 앵커, `EventSystem`, 버튼 이벤트 연결을 이해한다 |
| GMD-UNI-012-DO | D&O + 예제 | [\[생성형 AI\] 고정 타임스텝 누산기와 보간](fixed-timestep-loop.md) | 누산기로 고정 간격 로직을 돌리고 렌더를 보간하는 구조를 이해한다 |
| GMD-UNI-013-DO | D&O + 예제 | [\[생성형 AI\] 쿨타임과 타이머 패턴](cooldown-timer.md) | 시각 비교와 카운트다운으로 쿨타임·타이머를 구현하는 패턴을 이해한다 |

## 읽는 순서

1. GMD-UNI-002-MP로 물리 기반 이동을 구현한다.
2. GMD-UNI-001-MP로 `CharacterController` 방식과 비교한다.
3. GMD-UNI-003-MP로 클릭 이동을 추가한다.
4. GMD-UNI-004-DO로 공격 설계를 본다.

{% hint style="info" %}
NOTE: 이 그룹의 코드는 기존 Input Manager(`Input.GetAxis`) 기준이다. Unity 6 기본 설정(새 Input System 전용)에서는 `Project Settings > Player > Active Input Handling`을 `Both`로 바꿔야 동작한다. 버전 확인 필요.
{% endhint %}
