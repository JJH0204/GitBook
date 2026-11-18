# memset 함수 안전성 (memset)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ADC-004-TS |
| 유형 | TS (문제 해결) |
| 목적 | 정적 분석기의 `memset` 보안 경고의 의미를 설명하고 조치 방법을 정리한다 |
| 확인 상태 | 미검증 (원본을 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

`#c` `#Coding` `#개발`

## 1. 증상

정적 분석기가 `memset` 호출에 다음 경고를 낸다.

**메시지 원문**

> Call to function 'memset' is insecure as it does not provide security checks introduced in the C11 standard. Replace with analogous functions that support length arguments or provides boundary checks such as 'memset\_s' in case of C11

**메시지 번역**

> 함수 'memset'에 대한 호출은 C11 표준에 도입된 보안 검사를 제공하지 않으므로 안전하지 않습니다. C11의 경우 length 인수를 지원하거나 'memset\_s'와 같은 경계 검사를 제공하는 유사한 함수로 대체합니다

## 2. 가능 원인

| 원인 | 설명 |
|---|---|
| 분석기의 일반 규칙 | 분석기가 `memset`을 경계 검사가 없는 함수로 분류해 대체를 권고한다. 코드에 결함이 있다는 뜻이 아니다 |
| `memset_s`는 C11 Annex K(선택 기능) | 이 경고가 권하는 `memset_s`는 C11 부속서 K(Annex K, 경계 검사 인터페이스)에 있다. 선택 기능이라 구현이 지원할 의무가 없다. glibc는 Annex K를 지원하지 않는다 |
| 크기 인자 오류 | 크기에 실제 객체보다 큰 값을 주면 버퍼 오버플로가 난다 |

## 3. 격리 절차

1. 경고가 가리키는 `memset` 호출의 첫 인자(대상)와 세 번째 인자(크기)를 확인한다.
2. 크기가 대상 객체의 크기를 넘지 않는지 확인한다.
3. 대상이 구조체이면 `sizeof *p`(`p`는 대상 포인터)로 크기를 계산한다.

## 4. 시정 조치

원본은 "memset을 대체할 함수를 찾아야 한다"로 끝났고 찾지 못했다고 적었다. 대신 아래 코드는 `memset`을 쓰지 않고 구조체 멤버를 직접 초기화하는 방식으로 경고를 피했다.

| 방법 | 코드 | 비고 |
|---|---|---|
| 멤버를 직접 대입 | `p->a = 0; p->b = 0;` | 아래 `initNode`가 이 방식이다. 이식성이 좋고 경고가 없다 |
| 초기화자로 0 채움 | `Node n = {0};` | 선언 시점에 쓴다. 객체 전체를 0으로 만든다 |
| `memset` 유지 | `memset(p, 0, sizeof *p);` | 크기를 `sizeof *p`로 계산한다. 경고는 분석기 설정에서 해당 규칙을 끄거나 해당 줄만 예외 처리한다 |
| `memset_s` | `memset_s(p, sizeof *p, 0, sizeof *p);` | C11 Annex K 선택 기능이다. glibc에서는 사용할 수 없다 |

{% hint style="info" %}
NOTE: 구조체에 포인터나 부동 소수점 멤버가 있으면 모든 비트가 0인 값이 `NULL`이나 0.0과 같다고 표준이 보장하지 않는다. 대부분의 플랫폼에서는 같다. 이식성이 중요하면 멤버를 직접 대입한다.
{% endhint %}

아래는 `memset`을 쓰지 않고 멤버를 직접 초기화하도록 바꾼 코드다(원본 보존).

<details>

<summary>코드: initList</summary>

```c
int initList(polyList *_pList_)
{
	if (_pList_ == NULL)
	{
		printf("Error attempting to initialize unallocated memory: initList()\n");
		return -1;
	}
	_pList_->nCurrentCount = 0;
	initNode(&(_pList_->headerNode));
	return 0;
}
```

</details>

<details>

<summary>코드: initNode</summary>

```c
int initNode(node *_pNode_)
{
    if (_pNode_ == NULL)
    {
        printf("Error attempting to initialize unallocated memory: initNode()\n");
        return -1;
    }
    _pNode_->pNext = NULL;
    _pNode_->tData.coefficient = 0;
    _pNode_->tData.degree = 0;
    return 0;
}
```

</details>

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 정적 분석 경고가 나왔을 때 코드를 바꿀지 경고를 끌지 무엇으로 판단하는가?
- [ ] 구조체를 0으로 초기화하는 방법 두 가지를 내 말로 비교하면?
