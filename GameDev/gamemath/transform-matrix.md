# [생성형 AI] 좌표 변환과 행렬(TRS)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-MTH-005-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | 로컬 좌표와 월드 좌표의 관계, `Transform`의 변환 함수 차이, TRS 행렬을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다. 예제 수치는 손으로 계산했다) |
| 개정 | R1 (2026-11-19) |

## 1. 정의

모든 `Transform`은 위치(Translation), 회전(Rotation), 크기(Scale)를 가진다. 이 셋을 합친 변환을 TRS라 부르며, 4x4 행렬 하나로 나타낼 수 있다. 부모가 있으면 오브젝트의 월드 변환은 부모의 월드 변환에 자신의 로컬 변환을 곱한 것이다.

```
월드 변환 = 부모 월드 변환 × 로컬 변환
점의 월드 좌표 = 월드 변환 × 점의 로컬 좌표
```

Unity는 열 벡터 규약을 쓴다. 변환은 `M * v` 순서로 쓰고, 여러 변환은 오른쪽부터 먼저 적용된다. TRS 행렬에서는 크기, 회전, 이동 순서로 적용된다.

## 2. 구성 요소

| 목적 | API | 이동 | 회전 | 크기 |
|---|---|---|---|---|
| 로컬 점 → 월드 점 | `transform.TransformPoint(p)` | O | O | O |
| 로컬 방향 → 월드 방향 | `transform.TransformDirection(d)` | X | O | X |
| 로컬 벡터 → 월드 벡터 | `transform.TransformVector(v)` | X | O | O |
| 월드 점 → 로컬 점 | `transform.InverseTransformPoint(p)` | O | O | O (역) |
| 월드 방향 → 로컬 방향 | `transform.InverseTransformDirection(d)` | X | O (역) | X |
| TRS 행렬 만들기 | `Matrix4x4.TRS(pos, rot, scale)` | | | |
| 로컬 → 월드 행렬 | `transform.localToWorldMatrix` | | | |
| 월드 → 로컬 행렬 | `transform.worldToLocalMatrix` | | | |
| 행렬로 점 변환 | `m.MultiplyPoint(p)`, `m.MultiplyPoint3x4(p)` | O | O | O |
| 행렬로 방향 변환 | `m.MultiplyVector(v)` | X | O | O |

## 3. 동작 원리

### 3.1 계산 예

오브젝트가 위치 (1, 2, 3), Y축 90° 회전, 크기 (2, 2, 2)이고 부모가 없다. 로컬 점 (0, 0, 1)의 월드 좌표를 구한다.

| 단계 | 연산 | 결과 |
|---|---|---|
| 1 | 크기 적용 | (0, 0, 2) |
| 2 | Y축 90° 회전 (+Z → +X) | (2, 0, 0) |
| 3 | 위치 더하기 | (3, 2, 3) |

`transform.TransformPoint(new Vector3(0, 0, 1))`이 같은 값(3, 2, 3)을 돌려준다.

### 3.2 같은 동작인데 결과가 다른 이유

| 상황 | 올바른 선택 |
|---|---|
| 총구 위치(캐릭터 앞 0.5m)를 월드 좌표로 구한다 | `TransformPoint`. 위치이므로 이동이 포함되어야 한다 |
| "캐릭터 앞쪽"을 방향으로 쓴다 | `transform.forward` 또는 `TransformDirection`. 크기가 반영되지 않는다 |
| 부모가 (2, 2, 2) 크기일 때 방향 벡터 길이를 유지한다 | `TransformDirection`. `TransformVector`는 길이를 크기만큼 늘린다 |

### 3.3 동차 좌표

4x4 행렬로 이동까지 표현하려고 점을 (x, y, z, 1), 방향을 (x, y, z, 0)로 쓴다. w가 0이면 이동 열이 곱해지지 않아 이동이 무시된다. 위 표에서 점과 방향의 차이가 여기서 나온다.

### 3.4 `lossyScale`

부모가 회전한 상태에서 비균등 크기(예: 부모 (1, 2, 1))를 쓰면 자식이 기울어진 상태에서 찌그러진다. 이 경우 `transform.lossyScale`은 근삿값이다. 비균등 크기를 부모에 쓰는 구성은 피한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| TRS | Translation, Rotation, Scale |
| 로컬 / 월드 | 부모 기준 좌표 / 씬 전체 기준 좌표 |
| 동차 좌표 | 점 w=1, 방향 w=0으로 확장한 4차원 표현 |

## 5. 더 보기

* [벡터 기초와 연산 (Vector)](vector.md)
* [쿼터니언과 회전](quaternion.md)
* [3D 게임 그래픽스 기초](../gameplayprogrammer/3dgamedev/gamegraphics.md): 월드, 뷰, 클립 공간
* [툰 셰이더 공부 노트 Day 02 · 좌표 공간 여행](../toon-shader-study/day02-coordinate-spaces.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 캐릭터의 손 위치에 무기를 붙일 때 로컬 좌표와 월드 좌표 중 어느 쪽으로 계산했는지, 이유와 함께 쓴다.
- [ ] 방향과 위치를 구분하지 않아 생긴 버그가 있으면 증상과 원인을 적는다.
