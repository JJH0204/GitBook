# GitBook 확장 문법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-DOC-002-REF |
| 유형 | REF (문법 표) |
| 목적 | 이 저장소의 문서에서 쓰는 GitBook 전용 블록 문법을 참조한다 |
| 확인 상태 | 미검증 (이 저장소의 기존 문서에서 쓰는 형식을 정리한 것이며 GitBook 화면에서 렌더링해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 원본에 없던 새 문서다. 기본 마크다운 문법은 DEV-DOC-001-REF를 따른다. GitBook 블록은 중괄호와 퍼센트 기호로 감싼 형식이며 GitBook에서만 렌더링된다. 다른 마크다운 뷰어에서는 글자 그대로 보인다.
{% endhint %}

## 1. 블록 표

각 블록은 여는 줄과 닫는 줄이 한 쌍이다. 아래 예는 코드 블록 안에 적었다.

| 블록 | 용도 |
|---|---|
| `hint` | 강조 상자. `style`은 `info`, `warning`, `danger` 중 하나다 |
| `stepper`, `step` | 번호 단계 묶음과 그 안의 한 단계 |
| `tabs`, `tab` | 환경별 탭 묶음과 그 안의 한 탭. 탭마다 `title`을 적는다 |
| `code` | 파일 이름(`title`)을 붙인 코드 블록. 여는 줄 `code title="파일명"`과 닫는 줄 `endcode` 사이에 일반 코드 블록을 둔다 |
| `embed` | 외부 영상·페이지 삽입. `url`을 적는다 |

### 입력 예

```
{% hint style="info" %}
NOTE: 보충 설명이다.
{% endhint %}

{% stepper %}
{% step %}
### 첫 번째 단계
설명
{% endstep %}
{% endstepper %}

{% tabs %}
{% tab title="Windows" %}
Windows 내용
{% endtab %}
{% tab title="macOS" %}
macOS 내용
{% endtab %}
{% endtabs %}

{% embed url="https://example.com" %}
```

## 2. 알림 종류

이 저장소는 알림 `style`을 3가지만 쓴다. 문구 첫 단어는 영문으로 고정한다.

| style | 문구 첫 단어 | 쓰는 곳 |
|---|---|---|
| `danger` | `WARNING:` | 데이터 손실, 보안 사고, 되돌릴 수 없는 작업 |
| `warning` | `CAUTION:` | 장비나 서비스 손상, 중단 가능성 |
| `info` | `NOTE:` | 보충 정보 |

예 (`warning`):

```
{% hint style="warning" %}
CAUTION: 기존 항목을 지우지 않는다.
{% endhint %}
```

## 3. 규칙

* 여는 블록과 닫는 블록은 짝을 맞춘다. 짝이 맞지 않으면 이후 내용이 깨진다.
* `step`은 반드시 `stepper` 안에, `tab`은 반드시 `tabs` 안에 쓴다.
* 블록 안에서 코드 블록을 쓸 수 있다.
* 한 문서의 첫 줄은 `# 제목`이다. 제목은 `SUMMARY.md`의 제목과 같게 쓴다.
* 새 문서를 만들면 `SUMMARY.md`에 줄을 추가한다. 목록에 없으면 목차에 나타나지 않는다.
* 이미지는 문서와 같은 저장소의 파일을 상대 경로로 가리킨다. 파일이 없으면 깨진 링크가 된다.

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [마크다운 문법 (Markdown Syntax)](markdownsyntax.md) | DEV-DOC-001-REF | 기본 마크다운 문법 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 새로 작성. 이 저장소에서 쓰는 GitBook 블록과 알림 규칙을 정리했다 |
