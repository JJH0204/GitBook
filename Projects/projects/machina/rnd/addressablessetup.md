# Addressables 설정과 씬 로드

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MRD-004-MP |
| 목적 | Addressables 패키지를 설치하고 씬을 Addressable로 등록해 코드로 로드한다 |
| 적용 대상 | Unity 프로젝트, Addressables 패키지(`com.unity.addressables`). 원본 스크린샷의 버전은 1.22.3이다 |
| 소요 시간 | 약 20분 (추정) |
| 확인 상태 | 미검증 (원본 메모를 절차로 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mobileoptimizationrnd.md](mobileoptimizationrnd.md) | PRJ-MRD-003-DO | 모바일 최적화 연구 개발 (R&D) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity 에디터 | 프로젝트에 쓰는 버전 | 버전 확인 필요 |
| 2 | Addressables 패키지 | `com.unity.addressables` | Unity Registry |
| 3 | 버전 관리 도구 | 원본은 SVN을 언급했다 | Git 등도 같은 원칙 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `Assets/AddressableAssetsData` 폴더를 삭제하면 어떤 에셋을 번들로 묶을지, 빌드 방식, 서버 주소 등 설정이 모두 사라진다. 삭제 전에 버전 관리에 커밋한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `AddressableAssetsData` 폴더를 버전 관리에 커밋하지 않으면 팀원에게 설정이 전달되지 않아 빌드 오류가 난다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 씬 변경 내용을 저장하고 버전 관리에 커밋한다 | 작업 트리가 깨끗하다 |
| 2 | 로드할 씬의 이름과 코드에서 부를 주소를 정한다 | 예: `Scene_Persistent` |

## 5. 절차

### A. 설치

1. (5-A-01) `Window > Package Manager`를 연다.
2. (5-A-02) `Unity Registry`를 선택하고 `Addressables`를 설치한다. → 결과: 패키지 목록에 Addressables가 나타난다.

### B. 초기 설정

1. (5-B-01) `Window > Asset Management > Addressables > Groups`를 연다.
2. (5-B-02) `Create Addressables Settings`를 누른다. → 결과: `Assets/AddressableAssetsData` 폴더가 생긴다.
3. (5-B-03) `AddressableAssetsData` 폴더를 버전 관리에 커밋한다.

폴더의 핵심 파일은 다음과 같다.

| 항목 | 역할 |
|---|---|
| `AddressableAssetSettings` | 프로젝트 전체 설정(카탈로그 빌드, 해시, 빌드 스크립트) |
| `AssetGroups` | Groups 창에 보이는 그룹 정보(`.asset` 파일) |
| `Schemas` | 그룹별 세부 옵션(압축 방식, 저장 위치, 로딩 방식) |

### C. 프로필과 그룹 조정

1. (5-C-01) Profiles에서 개발용과 배포용 프로필을 나눠 로컬 주소와 원격 주소를 분리한다.
2. (5-C-02) 그룹마다 번들 모드와 Schema를 조정한다. → 결과: 원본 예시는 몬스터 그룹은 압축 해제, 배경 음악은 스트리밍이다.

### D. 씬 등록

1. (5-D-01) Project 창에서 로드할 씬 에셋을 선택한다.
2. (5-D-02) Inspector에서 `Addressable`을 체크한다.
3. (5-D-03) `Address` 필드에 코드에서 부를 이름을 입력한다. 식별하기 쉽고 짧게 짓는다. → 결과: Groups 창에 씬이 나타난다.

### E. 코드에서 로드

1. (5-E-01) 스크립트 위쪽에 `using UnityEngine.AddressableAssets;`를 추가한다.
2. (5-E-02) `Addressables.LoadSceneAsync(<주소>)` 또는 `Addressables.LoadAssetAsync<T>(<주소>)`를 호출한다. 예시는 [모바일 최적화 연구 개발 (R&D)](mobileoptimizationrnd.md)의 `InitManager`다.
3. (5-E-03) 각 씬에 Init 객체를 두어 로드 시 우선하는 초기화(매니저 등록, 플레이어 스폰)를 수행하게 한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Groups 창을 연다 | 등록한 씬이 보인다 | Address가 입력한 이름과 같다 |
| 2 | 플레이 모드에서 로드 코드를 실행한다 | 씬이 로드된다 | 오류 로그가 없다 |
| 3 | `Window > Asset Management > Addressables > Analyze`를 실행한다 | 중복 종속성이 있으면 목록에 나온다 | 중복 번들 종속성 0건 |

{% hint style="info" %}
NOTE: Groups 창의 `Play Mode Script` 설정에 따라 번들을 빌드하지 않고도 에디터에서 로드되는 경우가 있다. 실제 기기 빌드 전에는 `Build > New Build`로 번들을 만들어 확인해야 한다. 버전 확인 필요.
{% endhint %}

## 7. 복구

1. (7-01) 설정을 잘못 바꿨다면 `AddressableAssetsData` 폴더를 마지막 커밋 상태로 되돌린다.
2. (7-02) 씬 등록을 취소하려면 씬 Inspector에서 `Addressable` 체크를 해제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `mobileoptimizationrnd.md`의 "Addressables 사용법"을 AMM MP 형식으로 분리·재작성. 중복된 `AddressableAssetsData` 설명을 통합 |
