# BlueIgloo Toon Shader

`com.blueigloo.shader` — URP 6000.3 툰 셰이더 UPM 패키지.

## 개요

세 모듈로 구성된다.

- **CharacterToon** — 캐릭터용 툰 셰이더. 램프/림/SDF 얼굴 그림자, 아웃라인, 전용 RendererFeature.
- **SceneToon** — 배경·지형·하늘용 툰 셰이더.
- **ToonShared** — 두 모듈이 공유하는 HLSL 라이브러리(램프, 밴드 섀도, 림).

이 저장소는 **패키지 그 자체**다. 저장소 루트가 곧 패키지 루트이므로 UPM URL에 `?path=`가 필요 없다.
바이너리 에셋과 Git LFS를 두지 않는 것이 규칙이며, 덕분에 clone이 400KB대로 끝난다.

## 설치

소비하는 프로젝트의 `Packages/manifest.json`에 다음 줄을 추가한다.

```json
"com.blueigloo.shader": "http://forge.tail025553.ts.net:3000/BlueIgloo/com.blueigloo.shader.git#v0.1.0"
```

UPM은 **프로젝트의 `manifest.json`에서만** git 의존성을 허용한다. 다른 패키지의
`package.json`에는 git URL을 적을 수 없으므로, `com.recombination.assets`를 쓰는
프로젝트라도 이 패키지를 자기 매니페스트에 직접 적어야 한다.

## 저작

시각 검증용 씬과 샘플 캐릭터는 저작 프로젝트 `BlueIgloo/unity-toonshader`에 있고,
이 저장소는 그 프로젝트의 `Packages/com.blueigloo.shader`에 **서브모듈**로 물려 있다.

```bash
git clone --recurse-submodules http://forge.tail025553.ts.net:3000/BlueIgloo/unity-toonshader.git
```

`Packages/` 아래에 있으므로 저작 중에도 소비자와 동일하게 **패키지 어셈블리로 컴파일**된다.
Assets에서만 통하고 패키지에서 깨지는 문제를 저작 단계에서 걸러내기 위한 배치다.

셰이더를 고칠 때는 서브모듈 안에서 커밋·푸시한 뒤, 저작 프로젝트에서 서브모듈 포인터를 갱신한다.

## 버전

1. `package.json`의 `version`을 올린다.
2. `CHANGELOG.md`에 항목을 추가한다.
3. 같은 번호로 `vX.Y.Z` 태그를 만들어 푸시한다.

소비자는 매니페스트에서 태그를 고정한다. 태그를 옮기면 이미 해석한 프로젝트가
조용히 다른 코드를 쓰게 되므로, 배포한 태그는 옮기지 말고 새 번호를 발행한다.

## 주의

패키지 코드는 **asmdef에 속해야만 컴파일된다.** 새 C# 폴더를 추가하면 asmdef를
같이 넣어라. Assets에서는 predefined 어셈블리가 주워 담아 주지만 패키지에서는 조용히 누락된다.
