# 입력 시스템 에러 해결 (Input System)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-MOP-001-TS |
| 유형 | TS (문제 해결 기록) |
| 목적 | 프로젝트를 다시 열었을 때 Input System 패키지에서 컴파일 오류가 난 증상, 시도한 방법, 해결을 기록한다 |
| 확인 상태 | 미검증 (작성자의 기록을 정리한 것이며 이 환경에서 재현하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 증상

프로젝트 진행을 1~2개월 멈췄다가 마무리 작업을 위해 에디터로 열었을 때 아래 컴파일 오류가 나왔다.

```text
Library/PackageCache/com.unity.inputsystem@1.14.2/InputSystem/Actions/InputActionState.cs(50,46): error CS0246: The type or namespace name 'IInputStateChangeMonitor' could not be found (are you missing a using directive or an assembly reference?)
```

- 오류는 프로젝트 코드가 아니라 패키지 캐시(`Library/PackageCache`)의 `com.unity.inputsystem@1.14.2` 안에서 났다.
- 패키지 버전이 `1.14.2`로 올라가 있었다. 언제 올라갔는지는 원본에 없다.

## 2. 가능 원인

| 번호 | 원인 | 판단 근거 | 상태 |
|---|---|---|---|
| 1 | 패키지 버전과 에디터 버전의 불일치 | 패키지를 `1.10.0`으로 내리자 해결됨 | 가장 유력, 정확한 원인은 미확인 |
| 2 | `Library` 폴더 또는 패키지 캐시 손상 | `Library` 삭제 후에도 해결되지 않음 | 배제 |
| 3 | Player 설정(Active Input Handling) 문제 | 설정을 바꿔도 해결되지 않음 | 배제 |

{% hint style="info" %}
NOTE: 원본은 "1.14.2는 유니티 6에서 원활하게 동작한다"고 적었다. 원본 스크린샷의 `manifest.json`에는 `com.unity.render-pipelines.universal` 14.0.12가 있었다. 이 URP 버전은 Unity 2022.3 계열과 짝이므로, 프로젝트의 에디터는 Unity 6가 아니었을 가능성이 있다. 에디터 버전과 Input System 1.14.x의 지원 범위는 이 환경에서 확인하지 못했다. 버전 확인 필요.
{% endhint %}

## 3. 격리 절차

원본에서 시도한 순서다.

1. 기존 `Library` 폴더를 삭제한다. → 결과: 오류가 그대로 남았다.
2. 유니티 캐시를 삭제한다. → 결과: 오류가 그대로 남았다.
3. Player 설정을 수정한다. → 결과: 오류가 그대로 남았다.
4. `Packages/manifest.json`에서 `com.unity.inputsystem` 버전을 낮춘다. → 결과: 에디터가 정상 실행되었다.

## 4. 시정 조치

`Packages/manifest.json`의 `dependencies`에서 아래 줄의 버전을 `1.10.0`으로 내렸다.

```json
"com.unity.inputsystem": "1.10.0",
```

{% hint style="warning" %}
CAUTION: 낮춘 버전에서 새 버전의 Input System 기능이나 `.inputactions` 에셋 형식을 쓰고 있었다면 다른 오류가 날 수 있다. 낮춘 뒤 입력 동작을 한 번 확인한다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본의 스크린샷은 `manifest.json` 편집 화면이었다. 화면에 로컬 경로와 계정 이름이 보여 공개 저장소에서는 삭제하고 위 코드 줄로 대체했다. 같은 파일에 외부 에셋 패키지의 Git 주소(비공개 레포일 수 있음, 접근 권한 필요)도 들어 있다.
{% endhint %}

## 5. 배운 점

- 패키지 버전을 관리해야 한다. 확인 없이 누른 패키지 업데이트가 2시간을 소모했다.
- 프로젝트를 한동안 쉬었다 열 때는 `Packages/manifest.json`과 `Packages/packages-lock.json`이 바뀌었는지 먼저 확인한다. 팀 프로젝트에서는 이 두 파일을 버전 관리에 포함해 의도하지 않은 업데이트를 막는다.

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM TS 형식으로 재작성, 스크린샷을 텍스트로 대체 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 패키지 캐시 안의 오류를 보고 프로젝트 코드가 아니라 패키지 버전을 의심한 이유는 무엇인가?
- [ ] 같은 일을 겪지 않도록 팀에서 패키지 버전을 어떻게 관리하겠는가?
