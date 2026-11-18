# Bada 렌더링 후처리: 저해상도·툰·외곽선

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-BDA-104-DO |
| 유형 | D&O (렌더링 설계와 구현 현황) |
| 목적 | 로우폴리 3D를 저해상도 픽셀 아트로 바꾸는 후처리의 설계와, 사본에 구현된 범위를 구분해 설명한다 |
| 대상 | `Docs/Porting/PORTING.md` §7, `Docs/Porting/WORKSTREAMS.md` WS4, `Tools/blender/make_assets.py`, `Assets/Scripts/Game/BadaGame.cs` |
| 확인 상태 | 미검증 (문서와 코드를 읽고 썼으며 Unity에서 화면을 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 비공개 레포, 접근 권한 필요: [JJH0204/Bada](https://github.com/JJH0204/Bada)
{% endhint %}

{% hint style="warning" %}
CAUTION: 사본에는 저해상도, 툰 라이팅, 외곽선 패스를 구현한 셰이더나 렌더러 피처가 없다. 사본의 Unity 슬라이스는 URP 기본 설정 위에서 `Universal Render Pipeline/Lit`와 `Unlit` 셰이더를 쓰고, 에셋은 플랫 셰이딩 로우폴리다. 후처리는 `PORTING.md` §7의 목표 사양이며, 개요 페이지가 말한 Godot 판의 구현은 사본에 없다. 이 문서는 "설계 목표"와 "사본의 구현"을 나누어 적는다.
{% endhint %}

## 1. 목적

모델링 부담을 줄이려고 복셀 대신 로우폴리 3D를 쓰고, 화면에서 픽셀 아트 느낌을 내는 방법을 정리한다. 목업(three.js)이 먼저 이 룩을 구현했고, Unity 이식은 같은 룩을 URP로 다시 만드는 것이 목표다.

## 2. 구성 요소

| 구분 | 요소 | 위치 | 상태 |
|---|---|---|---|
| 구현 | Blender 에셋 스크립트 | `Tools/blender/make_assets.py` | 사본에 있음 |
| 구현 | FBX 모델 8개 | `Assets/Models/*.fbx` | 사본에 있음 |
| 구현 | 바다 평면과 URP Lit 머티리얼 | `BadaGame.Start` | 사본에 있음 (`Plane`, 색 `(.11, .33, .44)`, 매끄러움 .85) |
| 구현 | IMGUI HUD | `BadaGame.OnGUI` | 사본에 있음 |
| 설정 | URP 에셋 PC·Mobile, 렌더러에 `ScreenSpaceAmbientOcclusion` 피처 | `Assets/Settings/` | 템플릿 기본으로 보임. 확인 필요 |
| 설계 | 저해상도 정수 배 확대 | `PORTING.md` §7 | 사본에 구현 없음 |
| 설계 | 3밴드 툰 라이팅 | 같은 문서 | 사본에 구현 없음 |
| 설계 | ID·법선 패스와 외곽선 패스 | 같은 문서 | 사본에 구현 없음 |
| 설계 | 하늘·바다 셰이더, 디더링, 날씨 효과 | 같은 문서 | 사본에 구현 없음 |

## 3. 데이터 흐름

설계안의 한 프레임은 다음 순서다.

```
 3D 씬(로우폴리, 플랫 셰이딩)
   │  renderScale = 1/k 로 내부 해상도에 그림 (k = max(2, round(화면폭 / 590)))
   ▼
 툰 라이팅: 직사광 5단 양자화 + 3밴드 램프
   │
   ├─▶ ID 패스: 객체 ID, 재질 ID, 뷰 공간 법선, 깊이 (같은 내부 해상도)
   ▼
 외곽선 패스: 이웃 4픽셀 비교 → 1픽셀 선 (객체 경계 > 깊이 단차 > 재질 경계)
   │
   ▼
 디더링(하늘·바다만) → Point 확대(FinalPost) → 레터박스
```

## 4. 핵심 코드 해설

### 4.1 구현된 부분: 로우폴리 에셋

{% code title="Tools/blender/make_assets.py (mesh, 발췌)" %}
```python
def mesh(name, vertices, faces, materials, indexes=None):
    data = bpy.data.meshes.new(name)
    UNITY_VERTICES[data.name] = vertices
    data.from_pydata([(-x, -z, y) for x, y, z in vertices], [], faces)
    ...
    for poly, index in zip(data.polygons, indexes or [0] * len(faces)):
        poly.material_index = index
        poly.use_smooth = False
```
{% endcode %}

* 정점을 Unity 좌표로 적고 Blender 좌표 `(-x, -z, y)`로 바꿔 넣는다. 개요 페이지의 "왼손 좌표계 때문에 화면이 뒤집혀 보인 문제"와 같은 맥락의 처리다.
* `use_smooth = False`로 면마다 평평하게 음영을 준다. 로우폴리 룩과 설계안의 "flat shading"에 맞는다.
* 재질은 `HullWhite`, `Deck`, `ChairRed` 같은 단색 12개이며 텍스처가 없다.

{% code title="Assets/Scripts/Game/BadaGame.cs (ShowCatch, 발췌)" %}
```csharp
var mpb = new MaterialPropertyBlock();
...
for (int i = 0; i < 2; i++) {
    ColorUtility.TryParseHtmlString(sp.Colors[i], out var col);
    mpb.SetColor("_BaseColor", col);
    rend.SetPropertyBlock(mpb, i);
}
```
{% endcode %}

* 물고기 메시는 5가지 형태(round, flat, torpedo, long, squid)뿐이고, 어종별 차이는 등과 배 색 두 가지를 `MaterialPropertyBlock`으로 칠해 만든다. 머티리얼 인스턴스를 늘리지 않는다.
* 색은 `FishingData.Species[i].Colors`(JSON의 `c`)에서 온다.

### 4.2 설계 부분: 후처리 수치

`PORTING.md` §7이 정한 값 중 따라 만들 때 필요한 것만 옮긴다.

| 항목 | 값 |
|---|---|
| 내부 해상도 | `k = max(2, round(화면폭/590))`, 내부 크기 `ceil(화면/k)`, Point 확대, FXAA 끔 |
| 램프 | 32칸 텍스처: 0~16 → 0, 17~23 → 150, 24~31 → 255 |
| 직사광 | `floor(m·5 + .5)/5`로 5단 양자화 |
| 그림자 | 하드, 맵 1024, 배를 따라가는 ±14m 직교 상자, bias -.004, normal bias .14 |
| 외곽선 색 | 조명 받은 기본색 × .43 |
| 디더링 | 4×4 Bayer, 8단계, 진폭 .45, 하늘과 바다 픽셀에만 |
| 움직임 | 물·배 흔들림 등 월드 애니메이션은 15fps로 양자화, 카메라만 매 프레임 |

* 목업은 객체·재질 ID를 8비트로 RGBA8에 넣었고 255개를 넘으면 충돌한다. 설계안은 Unity에서 `R16G16_UInt` 타깃과 별도 법선 타깃을 쓰라고 한다(`PORTING.md` §7, §11).
* 이소메트릭 프로젝트용 요소(스프라이트 정렬, 이중 깊이, 직교 카메라)는 Bada가 원근 카메라를 쓰므로 필요 없다고 적혀 있다.

## 5. 따라 만들기

확인 상태: 미검증. 1~3은 사본에 있는 구현, 4~8은 설계안이다.

1. 정점을 코드로 적는 Blender 스크립트로 로우폴리 모델을 만들고 FBX로 내보낸다. 면은 `use_smooth = False`로 둔다. → 결과: `Assets/Models/`에 FBX가 생긴다.
2. FBX를 프리팹으로 쓰고 색은 `MaterialPropertyBlock`으로 바꾼다. → 결과: 같은 메시로 어종별 색이 나온다.
3. 바다는 `Plane`에 URP Lit 머티리얼을 입힌다. → 결과: 푸른 수면이 보인다.
4. 픽셀 아트 전용 URP 렌더러 에셋을 만들고 `renderScale = 1/k`, 업스케일 Point로 둔다. → 결과: 화면이 정수 배로 큰 픽셀로 보인다.
5. 툰 라이팅 셰이더로 직사광을 5단으로 자르고 3밴드 램프를 적용한다. → 결과: 면의 음영이 계단으로 나뉜다.
6. 렌더 그래프 패스로 객체 ID, 재질 ID, 법선, 깊이를 내부 해상도로 기록한다. → 결과: ID 버퍼를 확인할 수 있다.
7. 외곽선 패스에서 이웃 4픽셀을 비교해 1픽셀 선을 그린다. → 결과: 물체 경계에 1픽셀 선이 생기고 수면과 선체가 만나는 곳에 점선 물결선이 뜬다.
8. 하늘과 바다에만 4×4 Bayer 디더링을 더한다. → 결과: 수평선이 돌릴 때 자글거리지 않는다(`ACCEPTANCE.md` A18의 기준).

## 6. 알려진 한계와 주의

* 사본의 화면은 외곽선·저해상도 없이 URP 기본 룩이다. 개요 페이지의 "저해상도로 그려 정수 배로 키우는 후처리"는 설계와 목업 쪽 설명이며 사본의 Unity 코드에서 확인하지 못했다. 확인 필요.
* 사본의 UI는 IMGUI(`OnGUI`)이고 한글은 OS 글꼴 `Malgun Gothic`에 의존한다. 다른 OS에서는 글꼴이 없을 수 있다(코드 읽기).
* 렌더링 확인은 화면을 눈으로 보는 수동 기준(A18)이다. 수평선 자글거림, 1픽셀 선, 물선은 스크린샷으로 확인하도록 적혀 있다.

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| 로우폴리 | 면 수가 적은 3D 모델 |
| 툰 밴드 | 빛의 세기를 몇 단계로 잘라 만화 같은 음영을 내는 방식 |
| ID 패스 | 객체·재질 번호를 화면에 기록해 경계를 찾는 데 쓰는 렌더 단계 |
| 디더링 | 규칙 무늬 잡음으로 색 단계 사이를 부드럽게 보이게 하는 방법 |

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 (소스 사본 읽기 기준) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 복셀 대신 로우폴리와 후처리를 고른 이유를 내 말로 적으면?
- [ ] 화면을 눈으로 비교해 목업과 맞춘 경험에서 가장 어긋났던 부분은 무엇이었는가?
