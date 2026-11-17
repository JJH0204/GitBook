# 메모리 할당 유효성 검사

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-MEM-005-DO |
| 유형 | D&O + 예제 코드 |
| 목적 | `malloc` 실패를 검사하고 부분 할당을 정리하는 방법과 재시도(횟수·시간 제한) 변형을 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 정정한 것이며 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 무제한 재시도 예제는 두 가지 오류가 있어 정정했다. (1) `malloc`은 메모리를 0으로 초기화하지 않으므로 `pResult->pArray == NULL`을 할당 직후 읽으면 미초기화 읽기(UB)다. (2) 배열 할당 실패 후 `free(pResult); pResult = NULL;`을 하고도 바깥 루프가 아닌 안쪽 루프 조건 `pResult->pArray`를 다시 평가해 널 포인터를 역참조한다. 제한 시간 예제는 할당에 성공해도 시간 검사에서 `NULL`을 반환해 메모리가 누수되는 오류가 있어 고쳤다. 구조체 정의는 원본에 없어 예시용으로 추가했다.
{% endhint %}

## 1. 목적

`malloc`은 메모리가 부족하면 `NULL`을 반환한다. 반환값을 검사하지 않으면 `NULL` 역참조로 세그멘테이션 결함이 발생한다([PRG-MEM-004-TS](segmentationfault.md)). 이 문서는 구조체와 배열처럼 할당이 둘 이상일 때의 실패 처리를 다룬다.

## 2. 구성 요소

### 2.1 실패 처리 방식 비교

| 방식 | 동작 | 사용 시점 |
|---|---|---|
| 즉시 `NULL` 반환(권장) | 실패하면 정리하고 호출자에게 `NULL`을 반환한다 | 일반적인 경우. 표준 관행이다 |
| 횟수 제한 재시도 | 정해진 횟수까지 다시 할당한다 | 다른 스레드가 곧 메모리를 반환할 것으로 기대되는 경우 |
| 시간 제한 재시도 | 정해진 시간까지 다시 할당한다 | 위와 같음. 바쁜 대기이므로 CPU를 계속 쓴다 |

무제한 재시도는 메모리가 영영 확보되지 않으면 프로그램이 멈추므로 쓰지 않는다.

## 3. 동작 원리

두 번 할당할 때는 둘째 할당이 실패하면 첫째 할당을 반드시 해제해야 한다. 해제하지 않으면 메모리 누수가 생긴다.

1. 구조체를 `malloc`한다. 실패하면 `NULL`을 반환한다.
2. 구조체 필드를 초기화한다.
3. 배열을 `malloc`한다. 실패하면 구조체를 `free`하고 `NULL`을 반환한다.
4. 둘 다 성공하면 구조체 포인터를 반환한다.

## 4. 예제 코드

공통 정의다(원본에 없어 예시용으로 추가했다).

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct { int key; } heapNode;
typedef struct {
    int nMaxCount;
    int nCurrentCount;
    heapNode *pArray;
} arrayMaxHeap;
```

### 4.1 즉시 `NULL` 반환 (권장)

```c
arrayMaxHeap *createArrayHeap(const int _nMaxCount_) {
    if (_nMaxCount_ <= 0) { // 인자 유효성 점검
        printf("최대 원소 개수는 0보다 커야 한다.\n");
        return NULL; // 메모리 할당 시도 전에 반환
    }

    arrayMaxHeap *pResult = (arrayMaxHeap *)malloc(sizeof(arrayMaxHeap));
    if (pResult == NULL) return NULL;

    pResult->nMaxCount = _nMaxCount_; // 값 초기화
    pResult->nCurrentCount = 0;
    pResult->pArray = (heapNode *)malloc(sizeof(heapNode) * (_nMaxCount_ + 1));
    if (pResult->pArray == NULL) { // 배열 할당 실패 시
        free(pResult);             // 이미 할당한 구조체 해제
        return NULL;
    }
    return pResult;
}
```

### 4.2 시도 횟수 제한 (MAX_ATTEMPTS)

```c
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

### 4.3 제한 시간 적용 (TIMEOUT_SECONDS)

```c
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
        if (pResult != NULL) break; // 성공하면 시간 검사 없이 반환

        time(&now); // 현재 시간 측정
        if (difftime(now, start) > TIMEOUT_SECONDS) { // 제한 시간 초과 시
            printf("메모리 할당 시간이 초과되었습니다.\n");
            return NULL;
        }
    }
    return pResult;
}
```

## 5. 코드 설명

* 4.1: 인자 검사 후 할당하고, 둘째 할당 실패 시 `free(pResult)`로 첫째 할당을 정리한다. 반환값이 `NULL`이면 호출자가 실패를 처리한다.
* 4.2: 실패할 때마다 `attempts`를 늘려 최대 5번만 시도한다.
* 4.3: 성공하면 곧바로 루프를 빠져나온다. 실패했을 때만 경과 시간을 비교한다. 원본은 성공 직후에도 시간을 비교해 `NULL`을 반환하는 경로가 있었다.

## 6. 한계·주의

* 재시도 예제에는 재시도 사이의 지연(`sleep`)이나 지수 백오프가 없다. 재시도 사이에 지연이 없으면 CPU를 계속 쓴다.
* 실패가 계속될 수 있으므로 실패 시 호출자에게 오류를 반환하도록 설계한다.
* Linux 등 메모리 과다 할당(overcommit)을 허용하는 시스템에서는 `malloc`이 `NULL`을 반환하지 않고 나중에 프로세스가 강제 종료될 수 있다.
* `sizeof(heapNode) * (_nMaxCount_ + 1)`은 `_nMaxCount_`가 매우 크면 오버플로할 수 있다. 큰 값을 받을 때는 상한을 검사한다.
* 재시도 루프는 표준 관행이 아니다. 일반적으로 4.1을 쓴다.

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| 메모리 누수 | 할당했지만 해제하지 않아 쓸 수 없게 된 메모리 |
| 지수 백오프 | 재시도 간격을 2배씩 늘리는 방식 |
| overcommit | 실제 물리 메모리보다 많은 가상 메모리를 허용하는 정책 |

## 8. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [memorylayout.md](memorylayout.md) | PRG-MEM-002-DO | 메모리 레이아웃 (Layout) |
| [segmentationfault.md](segmentationfault.md) | PRG-MEM-004-TS | 세그멘테이션 결함 상세 (Segfault) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 둘째 `malloc`이 실패했을 때 첫째 할당을 `free`하지 않으면 어떻게 되는지 적어 본다.
- [ ] 재시도 방식이 도움이 되는 경우와 도움이 되지 않는 경우를 각각 적어 본다.
- [ ] 내 코드에서 할당 실패를 검사하지 않은 곳이 있는지 떠올려 적어 본다.
