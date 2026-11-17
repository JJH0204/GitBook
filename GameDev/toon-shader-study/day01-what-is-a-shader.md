# Day 01. 셰이더가 뭐예요?

> ⏱ **약 1시간** — 읽기 25분 · 소스 둘러보기 20분 · 해보기 15분
> 🧸 **오늘의 비유**: 셰이더는 **GPU 공장의 작업 지시서**예요.

## 오늘 배울 것

- [ ] 셰이더가 하는 일을 한 문장으로 말할 수 있다
- [ ] "버텍스 셰이더"와 "프래그먼트 셰이더"의 차이를 안다
- [ ] 툰 셰이더가 일반(실사) 셰이더와 무엇이 다른지 안다
- [ ] 이 셰이더 패키지의 `source/` 폴더에서 어디에 무엇이 있는지 안다

---

## 1. 요리사 한 명 vs 아르바이트 수천 명

컴퓨터에는 일하는 머리가 두 개 있어요.

| | CPU | GPU |
|---|---|---|
| 비유 | 아주 똑똑한 **요리사 한 명** | 간단한 일만 하는 **아르바이트생 수천 명** |
| 잘하는 일 | 복잡한 일을 순서대로 | 똑같은 일을 동시에 엄청 많이 |
| 게임에서 | 캐릭터 이동, AI, 물리 | 화면의 점(픽셀) 수백만 개 칠하기 |

화면은 가로 1920 × 세로 1080 = 약 **200만 개의 점**이에요. 1초에 60번 다시 그리니까 1초에 1억 2천만 번 색을 정해야 해요. 요리사 한 명으로는 불가능하죠. 그래서 아르바이트생 수천 명(GPU)에게 **똑같은 지시서 한 장**을 나눠 주고 "각자 맡은 점 하나씩 칠해!"라고 시켜요.

{% hint style="success" %}
**셰이더(Shader) = 그 지시서**예요. "이 점은 무슨 색으로 칠할지"를 계산하는 아주 작은 프로그램이에요. 모든 아르바이트생이 같은 지시서를 읽지만, 각자 맡은 점의 위치·방향이 다르니까 결과 색이 달라져요.
{% endhint %}

## 2. GPU 공장의 작업 순서 (렌더링 파이프라인)

![GPU 공장의 작업 순서](../.gitbook/assets/concept-pipeline.png)

1. **메시 데이터 (재료 창고)** — 3D 모델은 사실 **점(정점, vertex)** 들과 그 점을 이은 **삼각형**으로 되어 있어요. 점마다 위치, 바라보는 방향(노멀), 그림 좌표(UV)가 적혀 있어요.
2. **버텍스 셰이더 (점 옮기기 담당)** — 점 하나마다 한 번씩 실행돼요. "이 점이 화면 어디에 찍혀야 하나?"를 계산해요. (Day 02에서 자세히!)
3. **래스터라이저 (쪼개기 담당)** — GPU가 알아서 해요. 화면에 놓인 삼각형을 **픽셀 크기로 잘게 쪼개요**.
4. **프래그먼트 셰이더 (색칠 담당)** — 쪼개진 픽셀 하나마다 한 번씩 실행돼요. "이 픽셀은 무슨 색?"을 계산해요. **툰 셰이더의 마법은 대부분 여기서 일어나요.**
5. **화면** — 앞에 있는 것이 뒤에 있는 것을 가리는지 확인(깊이 테스트)하고, 투명하면 섞어서(블렌딩) 완성해요.

{% hint style="info" %}
우리가 직접 쓰는 건 **2번(버텍스)** 과 **4번(프래그먼트)** 두 가지예요. 나머지는 GPU가 정해진 대로 해 줘요.
{% endhint %}

## 3. 툰 셰이더는 뭐가 달라요?

실사 게임의 셰이더는 빛을 **미끄럼틀처럼** 부드럽게 표현해요. 밝은 곳에서 어두운 곳까지 수천 단계로 서서히 변해요.

만화(애니메이션) 그림은 달라요. 그림자를 **계단처럼** 딱 2~3칸으로만 칠하고, 테두리에 **검은 외곽선**을 그려요. 툰 셰이더는 이걸 흉내 내요.

![샘플 머티리얼 4종](../.gitbook/assets/day01-sample-spheres.png)

위 사진은 이 셰이더 패키지의 셰이더로 그린 구체들이에요. 빛이 닿는 쪽과 그림자 쪽이 **뚜렷한 경계**로 나뉘고, 가장자리에 **외곽선**이 있죠. 앞으로 22일 동안 이 그림이 어떻게 만들어지는지 한 줄씩 뜯어볼 거예요.

툰 셰이더가 하는 일을 크게 나누면 이래요.

| 기능 | 하는 일 | 배우는 날 |
|---|---|---|
| 셀(Cel) 음영 | 빛을 2~3단 계단으로 나누기 | Day 06–07 |
| 그림자·여러 빛 | 드리운 그림자, 보조 조명 | Day 08–10 |
| 림 라이트 | 가장자리가 빛나는 효과 | Day 11 |
| 외곽선 | 검은 테두리 | Day 12–14 |
| 얼굴 그림자 | 얼굴 전용 깔끔한 그림자 | Day 15 |
| 반짝임 | 하이라이트, 머리카락 천사 고리, MatCap | Day 16–17 |

## 4. 셰이더 vs 머티리얼

헷갈리기 쉬운 두 단어예요.

- **셰이더** = **레시피** ("김치볶음밥 만드는 법")
- **머티리얼** = 레시피에 **재료 양을 정해 둔 한 접시** ("김치 많이, 밥 조금, 계란 1개 올린 김치볶음밥")

같은 셰이더로 머티리얼을 여러 개 만들 수 있어요. 피부용 머티리얼, 머리카락용 머티리얼, 옷용 머티리얼이 모두 같은 `CharacterToon` 셰이더를 쓰지만 색과 슬라이더 값이 달라요.

## 5. 이 셰이더 패키지의 지도

`source/` 폴더는 실제 게임 프로젝트에서 쓰는 툰 셰이더 패키지(`com.blueigloo.shader` v0.2.0)를 그대로 복사한 거예요.

```
source/
├── CharacterToon/          ← 캐릭터용 (사람, 몬스터)
│   ├── Shaders/            ← .shader  = 지시서 본체
│   ├── ShaderLibrary/      ← .hlsl    = 여러 지시서가 나눠 쓰는 공구함
│   ├── Runtime/            ← .cs      = 게임 실행 중 셰이더에 값을 넣어 주는 스크립트
│   └── Editor/             ← .cs      = Unity 에디터 도구 (인스펙터 화면, 빌드 정리)
├── SceneToon/              ← 배경용 (건물, 나무, 지형, 하늘)
│   ├── Shaders/
│   ├── ShaderLibrary/
│   └── Editor/
└── ToonShared/             ← 배경 셰이더들이 같이 쓰는 공구함
    └── ShaderLibrary/
```

셰이더 파일은 6개예요.

| 파일 | 무엇을 그리나 | 크기 |
|---|---|---|
| [CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader) | 캐릭터 (모든 기능) | 947줄 — **주인공** |
| [CharacterToon_Unlit.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon_Unlit.shader) | 빛 계산 없는 가벼운 캐릭터 | 298줄 |
| [ScreenSpaceOutline.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/ScreenSpaceOutline.shader) | 화면 전체에 외곽선 덧그리기 | 69줄 |
| [SceneToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader) | 배경 물체 | 531줄 |
| [SceneToon_Terrain.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Terrain.shader) | 지형 | 310줄 |
| [SceneToon_Sky.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Sky.shader) | 하늘 | 70줄 — **가장 쉬움** (Day 03에서 통째로 읽어요) |

{% hint style="success" %}
각 파일이 무슨 일을 하는지 한눈에 보고 싶으면 [SOURCE-MAP.md](source-map.md)를 열어 보세요.
{% endhint %}

## 6. 해보기 (15분)

1. **이름 찾기** — [CharacterToon.shader 1줄](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L1)을 열어 보세요. `Shader "com.blueigloo/CharacterToon/Character"` 가 보이죠? 이게 Unity 머티리얼의 셰이더 드롭다운에 나오는 이름이에요.
2. **재료 목록 찾기** — 같은 파일 [18–19줄](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L18-L19)에서 `_BaseMap`과 `_BaseColor`를 찾아보세요. 머티리얼 인스펙터의 "Base Map", "Base Color" 칸이 바로 이 두 줄이에요.
3. **색칠 담당 찾기** — [285줄](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285)의 `half4 frag(...)`가 프래그먼트 셰이더예요. [665줄](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L665)의 `return half4(shaded, baseColor.a);` 가 "이 색으로 칠해!"라는 마지막 한 줄이에요. 그 사이 380줄이 모두 "무슨 색으로 칠할지" 계산이에요.
4. **(Unity가 있다면)** 부모 프로젝트(`unity-toonshader`)에서 `Assets/Sample/Material`의 머티리얼 하나를 골라 Base Color를 바꿔 보세요. 셰이더 코드는 그대로인데 색만 바뀌죠? 그게 "머티리얼 = 재료 양"이에요.
5. **종이에 그리기** — 위의 공장 그림을 보지 않고 5칸을 그려 보세요.

## 7. 오늘의 액기스

👉 [ESSENCE.md — Day 01](essence.md#day-01)

## 더 읽을거리

- [The Book of Shaders (한국어)](https://thebookofshaders.com/?lan=kr) — 셰이더를 처음 배우는 사람을 위한 그림책 같은 사이트. 1~3장만 먼저 읽어 보세요.
- [LearnOpenGL — Hello Triangle](https://learnopengl.com/Getting-started/Hello-Triangle) — 렌더링 파이프라인 그림이 아주 잘 되어 있어요. (영어)
- [Wikipedia — Graphics pipeline](https://en.wikipedia.org/wiki/Graphics_pipeline) (영어) / [위키백과 — 셰이더](https://ko.wikipedia.org/wiki/%EC%85%B0%EC%9D%B4%EB%8D%94)
- [위키백과 — 셀 셰이딩](https://ko.wikipedia.org/wiki/%EC%85%80_%EC%85%B0%EC%9D%B4%EB%94%A9) — 툰 셰이딩의 다른 이름

---

[목차](README.md) · [다음: Day 02 →](day02-coordinate-spaces.md)
