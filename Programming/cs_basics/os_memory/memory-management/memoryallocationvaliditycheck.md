# MemoryAllocationValidityCheck

함수 내에서 `malloc` 호출이 실패할 때 즉시 종료되지 않고 재시도하도록 수정한 예시와, 무한 재시도를 방지하기 위해 시도 횟수 또는 제한 시간을 둔 예제를 정리합니다.

다음은 원래 제시한, 두 번의 할당(구조체와 배열)에 대해 성공할 때까지 재시도하는 기본 예시입니다:

```c
arrayMaxHeap *createArrayHeap(const int _nMaxCount_) {
    arrayMaxHeap *pResult = NULL;
    if (_nMaxCount_ <= 0) { // 인자 유효성 점검
        printf("최대 원소 개수는 0보다 커야 한다.\n");
        return NULL; // 메모리 할당 시도 전에 반환
    }
    
    while (pResult == NULL) {
        pResult = (arrayMaxHeap *)malloc(sizeof(arrayMaxHeap)); // 메모리 할당 시도
        if (pResult != NULL) { // 메모리 할당 성공 시
            pResult->nMaxCount = _nMaxCount_; // 값 초기화
            pResult->nCurrentCount = 0;
            while (pResult->pArray == NULL) {
                pResult->pArray = (heapNode *)malloc(sizeof(heapNode) * (_nMaxCount_ + 1)); // 메모리 할당 시도
                if (pResult->pArray == NULL) { // 배열 메모리 할당 실패 시
                    free(pResult); // 할당된 메모리 해제
                    pResult = NULL; // 다시 시도하도록 설정
                }
            }
        }
        // 선택적: 메모리 할당 시도에 대한 제한 시간 또는 시도 횟수를 설정할 수 있습니다.
    }
    return pResult; // 메모리 할당 성공한 객체 반환
}
```

아래는 재시도에 시도 횟수 제한과 시간 제한을 적용한 예제입니다. 탭으로 접근 방식별 코드를 분리했습니다.

{% tabs %}
{% tab title="시도 횟수 제한 (MAX_ATTEMPTS)" %}
```c
#include <stdio.h>
#include <stdlib.h>

#define MAX_ATTEMPTS 5 // 최대 시도 횟수

arrayMaxHeap *createArrayHeapWithAttempts(const int _nMaxCount_) {
    arrayMaxHeap *pResult = NULL;
    int attempts = 0; // 시도 횟수 카운터

    if (_nMaxCount_ <= 0) {
        printf("최대 원소 개수는 0보다 커야 합니다.\n");
        return NULL;
    }

    while (pResult == NULL && attempts < MAX_ATTEMPTS) {
        pResult = (arrayMaxHeap *)malloc(sizeof(arrayMaxHeap));
        if (pResult != NULL) {
            pResult->nMaxCount = _nMaxCount_;
            pResult->nCurrentCount = 0;
            pResult->pArray = (heapNode *)malloc(sizeof(heapNode) * (_nMaxCount_ + 1));
            if (pResult->pArray == NULL) {
                free(pResult);
                pResult = NULL;
            }
        }
        attempts++; // 시도 횟수 증가
    }

    if (pResult == NULL) {
        printf("메모리 할당에 실패했습니다. (시도 횟수 초과)\n");
        return NULL;
    }

    return pResult;
}
```
{% endtab %}

{% tab title="제한 시간 적용 (TIMEOUT_SECONDS)" %}
```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TIMEOUT_SECONDS 5 // 최대 대기 시간 (초)

arrayMaxHeap *createArrayHeapWithTimeout(const int _nMaxCount_) {
    arrayMaxHeap *pResult = NULL;
    time_t start, now;

    if (_nMaxCount_ <= 0) {
        printf("최대 원소 개수는 0보다 커야 합니다.\n");
        return NULL;
    }

    time(&start); // 시작 시간 측정

    while (pResult == NULL) {
        pResult = (arrayMaxHeap *)malloc(sizeof(arrayMaxHeap));
        if (pResult != NULL) {
            pResult->nMaxCount = _nMaxCount_;
            pResult->nCurrentCount = 0;
            pResult->pArray = (heapNode *)malloc(sizeof(heapNode) * (_nMaxCount_ + 1));
            if (pResult->pArray == NULL) {
                free(pResult);
                pResult = NULL;
            }
        }

        time(&now); // 현재 시간 측정
        if (difftime(now, start) > TIMEOUT_SECONDS) { // 제한 시간 초과 시
            printf("메모리 할당 시간이 초과되었습니다.\n");
            return NULL;
        }
    }

    return pResult;
}
```
{% endtab %}
{% endtabs %}

주의사항

* 위 예제들은 재시도 로직만 추가한 것이며, 실제 환경에서는 재시도 간 지연(sleep)이나 지수 백오프 같은 전략을 고려하는 것이 일반적입니다. (본문의 예제들에는 지연 로직은 포함되어 있지 않습니다.)
* 반복 시도 중에도 시스템 상태에 따라 실패가 계속될 수 있으므로, 실패 시 호출자에게 적절한 오류 정보를 반환하도록 설계해야 합니다.
