# [생성형 AI] 오디오 기초: AudioSource, AudioMixer

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UNI-010-DO |
| 유형 | D&O (개념) + 예제 |
| 목적 | `AudioSource`, `AudioListener`, `AudioMixer`의 역할과 효과음·배경음 재생 방식을 이해한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (Unity에서 실행하지 않았다). 데시벨 환산식은 Python으로 확인했다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

Unity의 소리는 세 가지로 나뉜다. `AudioClip`은 소리 데이터, `AudioSource`는 그것을 재생하는 컴포넌트, `AudioListener`는 소리를 듣는 귀다. 한 씬에는 활성 `AudioListener`가 하나만 있어야 한다(보통 메인 카메라에 붙어 있다).

## 2. 구성 요소

| 요소 | 역할 |
|---|---|
| `AudioClip` | 소리 에셋. 임포트 설정(Load Type 등)이 메모리와 CPU를 정한다 |
| `AudioSource` | 재생 컴포넌트. `Play`, `Stop`, `volume`, `loop`, `spatialBlend` |
| `AudioListener` | 청취 지점 |
| `AudioMixer` | 소리를 그룹(BGM, SFX 등)으로 묶어 볼륨과 효과를 조절하는 에셋 |
| Exposed Parameter | 스크립트에서 값을 바꿀 수 있게 믹서에서 노출한 매개변수 |

| `AudioSource` 속성 | 의미 |
|---|---|
| `Play On Awake` | 켜져 있으면 오브젝트가 활성화될 때 자동 재생 |
| `Loop` | 반복 재생 |
| `Spatial Blend` | 0이면 2D(거리 무관), 1이면 3D(거리·방향 반영) |
| `Output` | 연결할 믹서 그룹 |

## 3. 동작 원리

### 3.1 효과음과 배경음

```csharp
[RequireComponent(typeof(AudioSource))]
public class SfxPlayer : MonoBehaviour
{
    [SerializeField] AudioClip hitClip;
    AudioSource source;

    void Awake() => source = GetComponent<AudioSource>();

    public void PlayHit() => source.PlayOneShot(hitClip, 0.8f);   // 0.8: 볼륨 배율
}
```

| 메서드 | 특징 |
|---|---|
| `Play()` | 하나의 클립을 재생한다. 호출하면 이전 재생이 끊기고 처음부터 다시 재생된다 |
| `PlayOneShot(clip, scale)` | 같은 소스에서 여러 효과음이 겹쳐 재생된다. 효과음에 쓴다 |
| `AudioSource.PlayClipAtPoint(clip, pos)` | 임시 오브젝트를 만들어 재생한다. 편하지만 호출이 잦으면 할당이 늘어난다 |

### 3.2 믹서로 볼륨 슬라이더

믹서의 볼륨은 데시벨(dB)이다. 슬라이더(0~1 선형 값)를 dB로 바꿔 넣는다. `dB = 20 × log10(선형값)`이다.

| 선형 값 | dB (Python으로 확인) |
|---|---|
| 1.0 | 0 |
| 0.5 | -6.02 |
| 0.0001 | -80 |

```csharp
using UnityEngine.Audio;

public class VolumeSetting : MonoBehaviour
{
    [SerializeField] AudioMixer mixer;   // Exposed Parameter 이름: "MusicVol"

    public void SetMusic(float linear)   // 슬라이더 0~1
    {
        float db = Mathf.Log10(Mathf.Max(linear, 0.0001f)) * 20f;   // 0이면 log가 -무한대라 하한을 둔다
        mixer.SetFloat("MusicVol", db);
    }
}
```

믹서에서 그룹의 Volume 항목을 우클릭해 `Expose ... to script`를 선택한 뒤 매개변수 이름을 바꿔야 `SetFloat`로 접근할 수 있다. 이름이 다르면 `SetFloat`는 false를 돌려준다.

### 3.3 임포트 설정

| Load Type | 특징 | 쓰임새 |
|---|---|---|
| Decompress On Load | 로드 시 풀어 메모리에 둔다. 재생 CPU가 낮다 | 짧은 효과음 |
| Compressed In Memory | 압축한 채 두고 재생 때 푼다 | 중간 길이 |
| Streaming | 디스크에서 읽으며 재생한다. 메모리가 적다 | 긴 배경음 |

정확한 기준은 플랫폼과 클립 길이에 따라 다르므로 프로파일러로 확인한다.

{% hint style="warning" %}
CAUTION: 브라우저(WebGL)와 일부 모바일 환경은 사용자 입력 전 자동 재생을 막는다. 첫 터치 이후에 재생하는지 대상 플랫폼에서 확인한다.
{% endhint %}

{% hint style="info" %}
NOTE: 에셋 스토어의 효과음과 음악은 라이선스 조건(재배포·크레딧)이 있다. 출시 전 확인한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| dB(데시벨) | 소리 크기의 로그 단위. 0이 기준이고 음수는 감쇠 |
| 2D/3D 소리 | 거리 감쇠 없음 / 있음 |
| 믹서 그룹 | 소리를 묶어 함께 조절하는 단위 |

## 5. 더 보기

* [시간: deltaTime, fixedDeltaTime, timeScale](time-deltatime.md)
* [Unity Manual: Audio](https://docs.unity3d.com/Manual/Audio.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 효과음과 배경음의 `Load Type`을 다르게 두는 이유를 자신의 말로 설명한다.
- [ ] 게임에서 소리가 연출에 가장 크게 기여할 장면을 하나 쓴다.
