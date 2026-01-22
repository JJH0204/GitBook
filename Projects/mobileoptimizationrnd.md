# MobileOptimizationRnD

{% hint style="warning" %}
⚠ Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. You can decompress Drawing data with the command palette: "Decompress current Excalidraw file". For more info check plugin settings under "Saving".
{% endhint %}

## Code Block

```csharp
using UnityEngine;
using UnityEngine.AddressableAssets; // 핵심 기능
using UnityEngine.ResourceManagement.AsyncOperations; // 비동기 핸들(AsyncOperationHandle) 사용 시 필요
```

## Code Block 1

```csharp
using Managers;
using System;
using UnityEngine;
using UnityEngine.AddressableAssets;
// using UnityEngine.ResourceManagement.AsyncOperations;
// using UnityEngine.ResourceManagement.ResourceProviders;
// using UnityEngine.SceneManagement;

public class InitManager : Singleton<InitManager>
{
    [SerializeField] private string persistentSceneAddress = "Scene_Persistent";
    
    private void Start()
    {
        Debug.Log("[InitManager] 시스템 초기화 시작...");

        // 1. 필요한 초기 설정 (예: 프레임 레이트, 로깅 설정)
        Init();
        
        // 2. Persistent 씬 로드
        LoadPersistentScene();
    }

    private static void Init()
    {
        Application.targetFrameRate = 60;
    }

    private async void LoadPersistentScene()
    {
        try
        {
            Debug.Log("[InitManager] Persistent 씬 로딩 중...");
        
            await Addressables.LoadSceneAsync(persistentSceneAddress).Task; // await Addressables.LoadSceneAsync(persistentSceneAddress, LoadSceneMode.Single).Task; 과 동일
        
            Debug.Log("[InitManager] 역할 종료. 제어권은 Game Manager로 넘어감.");
        }
        catch (Exception e)
        {
            Debug.LogError($"[InitManager] Persistent 씬 로드 실패: {e.Message}");
        }
    }
}
```

## Excalidraw Data

Addressables 시스템 도입: 에셋 번들의 상위 레벨 추상화 시스템

* Resources 폴더 사용은 지양: Resources 폴더에 있는 모든 에셋은 앱 시작 시 인덱싱 되므로, 앱의 Startup Time을 늦추고 메모리 관리를 어렵게 만듬
* 로컬/원격 로딩 경로를 코드 수정 없이 변경 가능
* 종속성 자동 관리
* 메모리 로드/언로드 추적 용이
* 자주 업데이트되는 콘텐츠는 원격(CDN)으로, 기본 콘텐츠는 로컬로 분류하여 그룹화 ^geuXA4Ml

텍스처 압축

* ios/Android 공통: ASTC 사용 (4x4 \~12x12 사이에서 조절, 보통 6x6 또는 8x8 추천)
* 대부분 기기에서 ASTC 지원 (구형은 ETC2, ios는 PVRTC) ^4vdOdpi2

오디오 설정

* BGM은 스트리밍
* SFX: 메모리에 풀어서 사용(Decompress on Load)또는 Compressed in Memory
* Force to Mono를 체크하여 메모리를 절반으로 줄이는 것이 효율적 ^zQTFaqkq

로딩 패턴 및 메모리 관리

* 비동기 로딩: 메인 스레드를 차단하지 않도록 모든 리소스 로딩은 Async 방식을 사용
* 오브젝트 풀링: 자주 인스턴스 되고 디스트로이되는 객체는 풀링으로 관리 (이미 적용됨)
* 거대 힙(Large Heap) 방지 및 언로드: 씬 전환 시 Resources.UnloadUnusedAssets() 또는 Addressables의 레퍼런스 카운트가 0이 될 때 즉시 메모리에서 해제되도록 설계 ^iG30UdZP

씬 관리 및 번들 전략

* Additive Scene Loading: 거대한 하나의 씬을 로드하는 대신, 베이스 씬 위에 환경, UI, 캐릭터 씬을 LoadSceneMode.Additive로 겹쳐서 로드 (메모리 피크 분산)
*   번들 중복 문제: 서로 다른 번들이 동일한 텍스처나 쉐이더를 참조할 경우 메모리에 두 번 로드될 수 있다.

    > Addressables의 Analyze 툴을 사용해 중복 종속성을 찾고, 공통 의존성 번들로 분리 ^E3Dwsfoe

그 외

* 셰이더 컴파일
* 코루틴, 비동기 작업의 부하 분산 ^57XBFlg9

Bootstrap Pattern: 절대 파괴되지 않는 관리자 씬을 하나 두고 그 위에 씬을 적층하여 관리

A. 부트스트랩 씬(Bootstrap / Entry Scene)

* 가장 먼저 로드되는 씬
* 게임 플레이 요소는 없음
* 필요한 경우 시스템 초기화 담당 (서버 설정, 버전 체크, 마스터 데이터 로드)
* DontDestoryOnLoad로 지정된 싱글톤 매니저들 포함

B. 씬 컨텍스트 분리

* 이전 씬을 완전히 날리고 새 씬을 로드하는 LoadSceneMode.Single방식은 메모리 단편화를 유발하고 로딩 스파크를 만듬
* 이를 방지하기 위해 씬을 기능별로 쪼개서 Additive(가산) 방식으로 로드

Persistent Scene(영구 씬): 매니저, 공용 카메라, 오디오 리스너 등 항상 존재해야 하는 것\
UI Scene: 캔버스, 팝업, HUD. (별도로 로드, 카메라 설정과 무관하게 렌더링)\
Environment Scene (Static): 지형, 라이트맵, 정적 오브젝트. (플레이 공간이 바뀔 때만 교체)\
Gameplay Scene (콘텐츠 씬): 스포너, 게임 룰, 동적 객체. ^YJFYNIPJ

Bootstrap Scene(Entry) ^hcCR390C

필수 객체 로드 (매니저, 카메라, 오디오 리스너 등) ^3Ly3nefr

Persistent Scene ^Ny4qgtKk

Game Manager ^BzV1ApvX

Scene Manager ^H8bbaxPP

Data Manager ^h1nuJpOx

Init Manager ^fx5Ucd6R

Event bus ^cgOqbjk9

UI Scene ^YcBXcMAP

UI Manager ^K18Vj1pX

Sound Manager ^WjxLivpJ

Map Manager ^4nUUGzcn

Player Prefab ^tsJJBQcK

Canvas ^dHAF810K

Environment Scene (Static) ^iNjrqpSW

Gameplay Scene (Dynamic) ^0MhRZyVu

동적으로 생성되는 게임 오브젝트들은 명시적으로 Dynamic Scene에서 생성되고 관리될 수 있도록 코드에서 정의 ^0t2LF9yc

Main Camera ^QIIionW6

Audio Listener ^NXVxPecW

Addressables.LoadSceneAsync 과 SceneManager.LoadScene 의 차이 ^mno88XDw

* SceneManager.LoadScene을 Addressables 시스템으로 감싼 메서드
* 해당 씬이 참조하는 에셋들을 다운로드 > 메모리에 로드 > 씬 활성화 > 레퍼런스 카운트 증가 복합적인 과정을 수행
* 씬 적층에 보다 효과적 ^mXBadkqb

### Addressables 사용법

{% stepper %}
{% step %}
#### 설치

* Package Manager > Unity Registry > Addressables 설치
{% endstep %}

{% step %}
#### 코드 선언

* using UnityEngine.AddressableAssets; 등 필요한 선언 추가
{% endstep %}

{% step %}
#### 초기 설정 (Addressable Groups)

* Window > Asset Management > Addressables > Groups
* Create Addressables Settings > AddressableAssetsData 폴더 생성 ^fgdWicq2

`AddressableAssetsData` 폴더는 어드레서블 시스템의 컨트롤 타워(설정 저장소)입니다. 이 폴더를 삭제하면 어떤 에셋을 번들로 묶을지, 빌드 방식, 서버 주소 등 모든 정보가 손실됩니다.

폴더 안의 핵심 파일들:

* AddressableAssetSettings: 프로젝트 전체 어드레서블 설정(카탈로그 빌드, 해시, 빌드 스크립트 등)
* AssetGroups: Groups 창에서 보이는 그룹 정보(.asset 파일)
* Schemas: 각 그룹에 적용되는 세부 옵션(압축 방식, 저장 위치, 로딩 방식 등)
{% endstep %}

{% step %}
#### 실무 팁 / 협업 주의사항

* `Assets/AddressableAssetsData` 폴더는 반드시 버전 관리(SVN 등)에 커밋해야 함
  * 공유되지 않으면 설정이 팀원에게 반영되지 않아 빌드 에러가 발생함
* Profiles: 개발/배포 프로필을 나누어 로컬/원격 주소를 분리
* 번들 모드와 Schema를 그룹별로 조정하여 모바일 최적화 수행
{% endstep %}

{% step %}
#### 씬 등록

* 씬 선택 후 'Addressable' 체크박스 활성화
* Address 필드에 코드에서 부를 식별 가능한 이름 입력 ^6Sa1LxFJ
{% endstep %}

{% step %}
#### 스크립트 활용 예제 / 적용

* Addressables.LoadSceneAsync, Addressables.LoadAssetAsync 등 활용
* 각 씬별 Init 객체 배치하여 로드시 우선순위 초기화 작업 수행
{% endstep %}
{% endstepper %}

`AddressableAssetsData` 폴더는 한마디로 \*\*"어드레서블 시스템의 컨트롤 타워(설정 저장소)"\*\*입니다.

***

#### 1. 폴더 안의 핵심 파일들과 역할 (요약)

① AddressableAssetSettings (메인 관리자 파일)

* 역할: 카탈로그 생성, 해시 관리, 빌드 스크립트 정의

② AssetGroups

* 역할: Groups 창에서 보이는 그룹들의 실제 파일 저장소

③ Schemas

* 역할: 각 그룹의 세부 옵션(압축 방식, 저장 위치, 로딩 방식 등)

***

#### 2. 협업 시 주의사항 (SVN 사용 시)

* `Assets/AddressableAssetsData` 폴더는 반드시 버전 관리에 커밋해야 함
* 공유되지 않으면 팀원 간 설정 불일치, 빌드 실패 발생

#### 3. 모바일 최적화 관점에서의 활용

* Profiles 설정으로 development/production 분리
* 그룹별 Schema로 압축/로딩 방식 튜닝 (예: 몬스터 그룹: 압축 해제; 배경 음악: 스트리밍)

***

#### 로드할 씬을 Addressables 시스템에 등록 ^ibmAg5Mw

* 씬 선택 후 'Addressable' 체크박스 활성화
* Address 필드에 코드에서 부를 이름 간단하게 입력 (가능한 식별이 쉽고 간단하게) ^6Sa1LxFJ

5. 활용 스크립트 예제 ^3HJs0ufO

Pool Manager ^xoB9WVT3

풀 메니저랑 UI 메니저를 어떻게 사용하면 좋을까 ^ipw8Ue2z

각 씬 별로 Init 객체를 배치해서 씬 별로 로드시 필요한 가장 우선순위가 높은 초기화 작업을 진행한다. ex) 생성한 객체를 상위 씬의 매니저에 등록, 플레이어 스폰 등등 ^TftSUcSH

게임 전체에 적용될 기본 설정 ^QpBJ0Yku

게임 실행 중에는 절대 사라질 일 없는 객체(매니저 등) ^8Gxf5s6N

Bootstrap 씬 초기화 후 Persistent 씬 로드 (single 방식) ^y36ZLxfv

Persistent 씬 로드 시 Init 객체 동작

> 생성 예정된 매니저 객체들 생성 (주의! 이때 객체들의 Awake, Start 구문의 실행으로 인해 의도하지 않은 null 에러 발생할 수 있음) ^PIAD4WzZ

각 매니저 스크립트에 예외 처리 추가 ^kSHe9bv5

1. 게임 매니저(Game Manager): 게임의 전체 상태를 관리 ^puk7mQR0

Game Manager ^Nkh7q4lg

영구씬 로드 시 가장 먼저 로드 ^c98yxCwo

게임의 상태를 enum 형태로 가짐 ^hqDcNe0j

Environment Scene (Static) ^BUT8BoNd

Game Manager ^sbjI1cbv

Scene Manager ^pOMAae2L

Dungeon Manager ^A3gpKuqz

player ^ljv7i82B

Gameplay Scene (Dynamic) ^rLpcWIJd

아이템 획득처 -> 상자

* 힐팩
* 진윤씨의 관리 이슈(휴먼에러) 통제가 불가능 함 ^KGnq6BC8

동일한 아이템의 중복 획득에 대한 예외처리 -> 수용씨를 통해 확인

* 버그에 가까운데 허용할 것인지 / 시스템화 하는 것이 맞는가 (유효성 점검 필요) ^NRX5ZXro

비휘발 ^kb1kwskP 휘발 ^iKbgmzRB

중첩 씬(로그 또는 기타 시스템에서 관리하는 관리자를 배치) ^lHnNJ9eV

Event Scene (AddOn) ^yZiNNG7f

플레이어의 사용 여부를 SO로 관리해서 영구 씬의 매니저에서 SO를 구독하고 오브젝트의 로드 여부를 결정 ^6YX7vUqH

Scene Manager ^d8koh1Ov

게임 매니저 생성 여부를 확인하고 없으면 아무 동작하지 않음 ^pCp3GcWY

Data Manager ^KRSGmGsA

Environment Scene (Static) ^hDGhGsoe

Gameplay Scene (Dynamic) ^Bj8LeULJ

UI Scene ^mM8cbjpO

Canvas ^VTE2olYt

Player Scene ^OhxpD9qf

Player\_URA ^mxPB3PiW

Persistent Scene ^rQP4nxzp

필수 객체 로드 (매니저, 카메라, 오디오 리스너 등) ^n5xrbakh

Game Manager ^a2eXIBfq

Scene Manager ^GGJD3r6p

Data Manager ^o0zJFNl8

UI Manager ^m2ooBjJh

Sound Manager ^dMgZiYDo

Map Manager ^eqrJFCx2

Main Camera ^EXAORIuZ

Audio Listener ^E1fX2jEZ

Pool Manager ^BzjAn8hw

Event Manager ^n4I3iQ9L

UI Manager ^aPurDhrU

영구 씬이 로드되고 모든 객체가 생성되었을 때 Init 객체가 GameManager에 플레그를 남김 ^ERPIqTHP

GameManager객체가 생성되고 Init 플레그가 활성화 되면 필요한 하위 씬을 Addtive로 로드 ^W0dBM1rh

Loading Scene ^gTHYpaxr

Title Scene ^bVvF8fs0

부트스트랩 씬에서 영구 씬을 Addtive로 로드 ^EwJsk7Wp

영구 씬의 Init 객체가 동작 ^pUd6TuTq

게임 진행에 필요한 매니저 객체 생성 ^gnPcDwrk

영구 씬의 가장 최상의 매니저(GameManager)의 상태를 다른 매니저들이 스스로 동작 여부를 판단 ^oBJQ5neK

게임 시작 ^9mwnYy9O

부트스트랩 ^Otddj9MG

영구 ^SnZg0ykW

언로드 ^O7ko5KQT

게임 전체에 적용되는 초기 설정을 적용 ^ln8kGUnI

필수 매니저 객체 일괄 생성 ^798U7408

UI Scene ^OX6i8SmH

기본으로 Loding Canvas를 활성화 해둔 상태로 씬을 저장

* 필요한 UI 리소스 + 영구 씬의 로드가 완료되면 Loding Canvas를 비활성화
* Title Canvas 활성화 ^pK4av6rp

GameScene ^7jXdGfj5

Title UI 에서 클릭 이벤트에 의해 GameManager의 상태 변경 -> SceneManager에 의해 다음 씬 로드 ^YfK2loo9

PlayerScene ^D5HLVDLr

GameScene과 PlayerScene이 준비될 때까지 다시 UI Manager 에 의해 Loading Canvas 활성화 ^sABswBK7

영구 ^XYuVmHNf

게임 종료 시 씬은 생성의 역순으로 언로드하여 운영체제에 안전하게 메모리 반환 ^twX1eAJt

이제와서 "이벤트 버스"를 적용하기에는 "모바일 최적화"를 하다가 초가삼가 다태우는 꼴이 될 것 같다.

* 지금 시스템(코드)을 가능한 수정하지 않고 모바일에 최적화 할 수 있는 방안을 생각해야 한다. ^5i4GOIq4

지금 가장 문제는 기존 게임 씬에 배치되었던 UI Manager ^BHfixPOE

* UI Manager 라고 하지만 Game Scene에서만 정상적으로 동작함으로 Manager 급으로 활용하면 안된다 판단됨 ^ajum0CJZ
* UI Manager의 코드는 가능한 수정하지 않고 게임 오브젝트 그대로 급만 격하시키면 될 것 같은데 ^1mZX3PFg
* 클래스 이름을 어떻게 수정하지 + 싱글톤으로 구현되어 있어서 내가 알지 못하는 다른 코드에서 싱글톤으로 접근하고 있을 수 있다. ^qbYVPlhQ
* GameUIController 로 클래스 이름을 바꾸고 싱글톤을 상속받지 않고 모노비헤이비어로 상속 받도록 수정하면 컴파일 에러가 발생하는 스크립트가 있을 것 ^FoYqf5rK
* 그러면 해당 스크립트를 새로 만들 UI Manager를 싱글톤으로 구현하고 새로운 UI Manager가 GameUIController(기존 UIManager)를 가지고 있으면 ^uBxLAtrM
* 에러가 발생하는 스크립트에서 UI Manager를 통해 Public으로 접근하여 사용하도록만 수정하면 간단하게 문제가 해결될 것 같다. ^PLoBvfuO

플레이어 씬을 로드하면 Init 객체가 동작해 이전에 미리 등록해둔 프리팹들이 동시에 인스턴스된다.

* 이때 초기화가 필요한 경우: 기능이 동작하는데 필요한 컴포넌트 등록을 의미 ^b2boEMIk
* 플레이어를 프리팹으로 불러올때 매시가 비활성화 된 상태로 로드된다. + 이동이 안됨 ^SlutQdtp

중간 보고 ^p1zubMON

오디오 리스너를 Player 씬에서 생성하는 바람에 타이틀 씬에서 BGM을 들을 리스너가 없다는 알림이 발생한다.(실제로 BGM이 들리지 않음)

* SoundManager의 하위에 리스너를 생성하고 플레이어가 생성되면 팔로우 리스너 객체를 생성해 리스너가 플레이어를 따라 다니도록 만들자 ^YEVC09WG

영상 리소스 불러오는 과정에서 무슨 문제가 있는 것 같다. > 이미지 소스를 웹 최적화 버전으로 다시 인코딩 했다.(문제 해결) ^VxdN9nXp

프롤로그 재생 중 플레이어 캐릭터를 조작할 수 있다. (프롤로그 종료 후 플레이어를 조작할 수 있도록 수정) ^4JiimiRH

플레이어를 프리팹으로 인스턴스 하면서 인풋 시스템에서 발생하는 문제( 이것 때문에 마우스 회전이 적용안되는 것 같음) ^qgguG20D

비활성화 된 객체의 컴포넌트에 접근하여 발생하는 경고 메시지 ^b3jsJlXy

동적 로딩을 위한 트리거 설치 및 오류 수정 완료 -> TODO: PC 브랜치와 병합 준비 ^QZY3zTXH

PC와 모바일 빌드 머지가 성공적으로 마무리 되었다. -> Main 브랜치에서 작업 지속할 예정 ^nuaag54M

모바일 특화 생명주기 처리 (OnApplicationPause)

* 필수 구현: OnApplicationPause(bool isPaused)를 구현하여 백그라운드 진입 시 불필요한 연산(타이머, 물리 연산)을 멈추고, 중요 데이터(인벤토리 등)를 즉시 로컬에 저장(Save)하는 로직이 다이어그램의 DataManager 흐름에 포함되어야 함 ^jax0280f

### Element Links

* gnj2aene: [모바일 최적화 방안 RnD#Code Block](/broken/pages/e1a7dfacbe29f3f58ff7d4bccc9f1786d168f4c9)
* eYmrEeOZ: [모바일 최적화 방안 RnD#Code Block 1](/broken/pages/ddaae7eff0e3a55b3504d0a4e0fa6fcef3f611c7)
* ER1JFiZP: https://youtu.be/\_s2V5qODbgs

### Embedded Files

* a2d98640b9d2014bdc5a203b4bdf97908f477dc3: \[\[topics/assets/images/스크린샷 2025-11-20 10.12.07.png]]
* d4a03056bfd10fc8c04b4f13634119630ca7bec8: \[\[topics/assets/images/스크린샷 2025-11-25 09.59.39.png]]
* 2c78522de1f10bb618b78f0415736b3418d6ac0b: \[\[topics/assets/images/스크린샷 2025-11-25 10.18.43.png]]
* a9d6f84e8229f12637e04f8ce858917440ec65e6: \[\[topics/assets/images/스크린샷 2025-11-26 11.12.29.png]]
* 5df2efe0877cf0ba3411f01a1415055d2a179660: \[\[topics/assets/images/스크린샷 2025-11-26 11.18.30.png]]
* 00dbad1768948218048aa4dcdbadba08abf6be1e: \[\[topics/assets/images/스크린샷 2025-11-26 11.18.57.png]]
* bd3016757def6ee14dc5d83c167eacefe838651: \[\[topics/assets/images/스크린샷 2025-12-02 22.35.35.png]]
* e30209ab6d4a2d53fa34a0585cefcc4ae1d65b98: \[\[topics/assets/images/스크린샷 2025-12-03 13.44.08.png]]
* c81d7c148d411867bf47f289a9295ccb98b5e8dd: \[\[topics/assets/images/스크린샷 2025-12-09 16.16.30.png]]
* e049f3205d4a5048dfe1b58bf37ca5262d9dc568: \[\[topics/assets/images/스크린샷 2025-12-09 19.41.24.png]]
* 236e3f7596bb845d882007d401a913d405675535: \[\[topics/assets/images/스크린샷 2025-12-09 20.24.16.png]]
* c9fa4412df51eb584f0862709c1beec34ea924e7: \[\[topics/assets/images/스크린샷 2025-12-09 20.26.48.png]]
* 350dd257ba8d8d2a0c3ab1611bad920a91379b05: \[\[topics/assets/images/스크린샷 2025-12-11 13.45.50.png]]

***

### Drawing

```compressed-json
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

... (Drawing compressed JSON continued)
```
