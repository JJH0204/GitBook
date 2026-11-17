# 툰 셰이더 패키지 설치와 버전 관리 (README)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSR-001-MP |
| 목적 | 툰 셰이더 UPM 패키지(`com.blueigloo.shader`)를 프로젝트에 설치하고, 저작 프로젝트를 받고, 새 버전을 발행한다 |
| 적용 대상 | Unity 6000.3, URP 17.3.0, Git 2.x |
| 소요 시간 | 설치 약 5분, 저작 환경 약 10분, 버전 발행 약 10분 |
| 확인 상태 | 미검증 (패키지의 README를 정리했으며 설치와 발행을 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 학습용으로 복사한 소스 패키지 `source/`의 안내서다. 파일 목록은 [소스 지도](../source-map.md)(GMD-TSS-025-REF), 버전별 변경은 [변경 이력](CHANGELOG.md)(GMD-TSR-002-REF)에 있다. 이 환경에서는 설치하지 않았다. 저장소 주소는 개인 서버 주소여서 `<저장소 주소>`로 바꿔 적었다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [CHANGELOG.md](CHANGELOG.md) | GMD-TSR-002-REF | 툰 셰이더 패키지 변경 이력 (CHANGELOG) |
| [../source-map.md](../source-map.md) | GMD-TSS-025-REF | 소스 지도 |

### 1.1 패키지 구성

| 모듈 | 내용 |
|---|---|
| `CharacterToon` | 캐릭터용 툰 셰이더. 램프, 림, SDF 얼굴 그림자, 아웃라인, 전용 RendererFeature |
| `SceneToon` | 배경, 지형, 하늘용 툰 셰이더 |
| `ToonShared` | 두 모듈이 공유하는 HLSL 라이브러리(램프, 밴드 섀도, 림) |

이 저장소는 패키지 그 자체다. 저장소 루트가 패키지 루트이므로 UPM URL에 `?path=`가 필요 없다. 바이너리 에셋과 Git LFS를 두지 않는 것이 규칙이어서 clone이 400KB대다.

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity Editor | 6000.3 | |
| 2 | URP | `com.unity.render-pipelines.universal` 17.3.0 | 패키지 의존성 |
| 3 | Git | 2.x | UPM이 git 의존성을 받는 데 필요 |
| 4 | 패키지 저장소 접근 권한 | | `<저장소 주소>` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 이미 발행한 태그(`v<버전>`)를 옮기지 않는다. 태그를 옮기면 이미 해석한 프로젝트가 조용히 다른 코드를 쓰게 된다. 수정은 새 버전 번호로 발행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 패키지 코드는 asmdef에 속해야만 컴파일된다. 새 C# 폴더를 추가하면 asmdef를 함께 넣는다. `Assets/`에서는 predefined 어셈블리가 받아 주지만 패키지에서는 조용히 누락된다.
{% endhint %}

{% hint style="info" %}
NOTE: UPM은 프로젝트의 `manifest.json`에서만 git 의존성을 허용한다. 다른 패키지의 `package.json`에는 git URL을 적을 수 없다. `com.recombination.assets`를 쓰는 프로젝트라도 이 패키지를 자기 `manifest.json`에 직접 적는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Unity 프로젝트가 URP 17.3.0 이상을 쓰는지 확인한다 | `Window > Package Manager`에서 `Universal RP` 버전을 본다 |
| 2 | `Packages/manifest.json`을 백업한다 | 복사본이 있다 |
| 3 | 사용할 태그를 정한다 | 저장소 태그 목록에 `v<버전>`이 있다 |

## 5. 절차

### A. 패키지 설치

1. (5-A-01) 소비하는 프로젝트의 `Packages/manifest.json`을 연다.
2. (5-A-02) `dependencies`에 다음 줄을 추가한다. → 결과: JSON 문법 오류가 없다(앞 줄 끝에 쉼표가 있다).
3. (5-A-03) Unity Editor로 돌아간다. → 결과: Package Manager가 패키지를 받는다. `Console`에 오류가 없다.

```json
"com.blueigloo.shader": "<저장소 주소>/BlueIgloo/com.blueigloo.shader.git#v<버전>"
```

### B. 저작 프로젝트 받기

시각 검증용 씬과 샘플 캐릭터는 저작 프로젝트에 있다. 이 패키지 저장소는 저작 프로젝트의 `Packages/com.blueigloo.shader`에 서브모듈로 연결되어 있다. `Packages/` 아래에 있으므로 저작 중에도 소비자와 같이 패키지 어셈블리로 컴파일된다. Assets에서만 통하고 패키지에서 깨지는 문제를 저작 단계에서 거른다.

1. (5-B-01) 서브모듈과 함께 clone한다. → 결과: `Packages/com.blueigloo.shader` 폴더에 패키지 파일이 있다.

```bash
git clone --recurse-submodules <저장소 주소>/BlueIgloo/unity-toonshader.git
```

2. (5-B-02) 셰이더를 고치면 서브모듈 안에서 커밋하고 푸시한다.
3. (5-B-03) 저작 프로젝트에서 서브모듈 포인터를 갱신한다. → 결과: `git status`에 서브모듈 변경이 보인다.

### C. 새 버전 발행

1. (5-C-01) `package.json`의 `version`을 올린다.
2. (5-C-02) `CHANGELOG.md`에 항목을 추가한다.
3. (5-C-03) 같은 번호로 `vX.Y.Z` 태그를 만들어 푸시한다. → 결과: 저장소 태그 목록에 새 태그가 보인다.

소비하는 프로젝트는 `manifest.json`에서 태그를 고정한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `Window > Package Manager`의 `In Project` 목록을 본다 | `BlueIgloo Toon Shader`가 있다 | 버전이 `manifest.json`의 태그와 같다 |
| 2 | `Console`을 확인한다 | 컴파일 오류가 없다 | 오류 0개 |
| 3 | 머티리얼의 셰이더 목록을 연다 | `CharacterToon`, `SceneToon` 계열 셰이더가 보인다 | 셰이더가 목록에 있다 |

## 7. 복구

1. (7-01) `Packages/manifest.json`에서 `com.blueigloo.shader` 줄을 삭제하거나 4번 준비에서 백업한 파일로 되돌린다.
2. (7-02) 잘못 발행한 태그는 옮기지 않는다. 새 버전 번호를 발행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 개인 서버 주소를 `<저장소 주소>`로 일반화, 예시 태그를 `v<버전>`으로 일반화 |
