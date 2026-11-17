# 선형 자료구조 개요 (Linear)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DSA-003-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 배열, 연결 리스트, 스택, 큐, 덱의 구조와 연산별 시간 복잡도를 비교한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

선형 자료구조(linear data structure)는 요소가 일렬로 놓이고, 처음과 끝을 제외한 각 요소에 앞 요소와 뒤 요소가 하나씩 있는 구조다. 요소에 도달하는 방식은 구조마다 다르다.

* 배열은 인덱스로 임의 접근한다.
* 단일 연결 리스트는 머리에서 다음 포인터를 따라 한 방향으로만 이동한다.
* 이중 연결 리스트와 덱은 양방향으로 이동한다.

대표 구조는 배열, 연결 리스트, 스택, 큐, 덱이다. 스택과 큐는 배열 또는 연결 리스트로 구현한다.

## 2. 구성 요소

| 자료구조 | 설명 | 요소 접근 방식 |
|---|---|---|
| 배열 (Array) | 고정 크기의 연속된 메모리에 같은 자료형을 저장한다 | 인덱스로 임의 접근 O(1) |
| 연결 리스트 (Linked List) | 각 노드가 데이터와 다음 노드의 포인터를 가진다 | n번째 요소까지 순차 이동 O(n) |
| 스택 (Stack) | 후입선출(LIFO) 구조다 | 최상단(top) 접근 O(1) |
| 큐 (Queue) | 선입선출(FIFO) 구조다 | 맨 앞(front) 접근 O(1) |
| 덱 (Deque) | 양쪽 끝에서 삽입·삭제하는 구조다 | 양쪽 끝 접근 O(1) |

## 3. 연산별 복잡도

### 3-1. 배열

| 연산 | 시간 복잡도 | 비고 |
|---|---|---|
| 인덱스 접근 | O(1) | |
| 값 탐색 | O(n) | 정렬돼 있으면 이진 탐색 O(log n) |
| 삽입·삭제(중간·앞) | O(n) | 뒤 요소를 한 칸씩 이동한다 |
| 삽입·삭제(끝) | O(1) | 삽입은 남은 용량이 있을 때다 |

크기는 선언 시 고정된다. 크기를 자동으로 늘리는 동적 배열(C# `List<T>`, C++ `std::vector`)은 용량이 차면 더 큰 배열로 복사하므로, 끝 삽입이 분할상환(amortized) O(1)이다.

{% code title="C 예시" %}
```c
int arr[5] = {10, 20, 30, 40, 50};
printf("%d", arr[2]);  // 30 출력
```
{% endcode %}

### 3-2. 연결 리스트

| 연산 | 단일 연결 리스트 | 이중 연결 리스트 | 비고 |
|---|---|---|---|
| 탐색 | O(n) | O(n) | |
| 머리 삽입 | O(1) | O(1) | |
| 꼬리 삽입 | O(1) (tail 포인터가 있을 때), 없으면 O(n) | O(1) (tail 포인터가 있을 때) | tail 포인터는 마지막 노드를 가리키는 변수다 |
| 머리 삭제 | O(1) | O(1) | |
| 꼬리 삭제 | O(n) | O(1) (tail 포인터가 있을 때) | 단일 연결 리스트는 마지막 직전 노드를 찾아야 한다 |
| 노드 포인터를 이미 가진 삽입 | O(1) | O(1) | 위치를 찾는 비용은 별도다 |

배열보다 삽입·삭제가 빠른 경우는 위치를 이미 알고 있을 때다. 위치를 찾는 탐색은 O(n)이다. 노드마다 포인터 메모리를 추가로 쓴다.

{% code title="C 구조체 예시" %}
```c
typedef struct Node {
    int data;
    struct Node* next;
} Node;
```
{% endcode %}

### 3-3. 스택

| 연산 | 시간 복잡도 |
|---|---|
| push | O(1) |
| pop | O(1) |
| 최상단 접근(peek) | O(1) |
| 임의 요소 탐색 | O(n) |

{% code title="C 예시 (배열 기반, 경계 검사 포함)" %}
```c
#define SIZE 100
int stack[SIZE], top = -1;

int push(int value) {
    if (top == SIZE - 1) {
        return 0;               /* overflow: 가득 참 */
    }
    stack[++top] = value;
    return 1;
}

int pop(int *out) {
    if (top == -1) {
        return 0;               /* underflow: 비어 있음 */
    }
    *out = stack[top--];
    return 1;
}
```
{% endcode %}

원본 코드는 검사 없이 `stack[++top] = value;`와 `return stack[top--];`만 있었다. 가득 찬 스택에 push하거나 빈 스택에서 pop하면 배열 범위 밖을 읽거나 써서 정의되지 않은 동작(UB)이 된다. 위 코드는 성공이면 1, 실패이면 0을 반환한다. 상세 설명은 [스택 (Stack)](../../data-structures/stack.md)을 따른다.

### 3-4. 큐

| 연산 | 시간 복잡도 |
|---|---|
| enqueue | O(1) |
| dequeue | O(1) |
| 맨 앞 접근(front) | O(1) |
| 임의 요소 탐색 | O(n) |

{% code title="C 예시 (원형 큐, 경계 검사 포함)" %}
```c
#define SIZE 100
int queue[SIZE], front = 0, rear = 0, count = 0;

int enqueue(int value) {
    if (count == SIZE) {
        return 0;               /* overflow: 가득 참 */
    }
    queue[rear] = value;
    rear = (rear + 1) % SIZE;
    count++;
    return 1;
}

int dequeue(int *out) {
    if (count == 0) {
        return 0;               /* underflow: 비어 있음 */
    }
    *out = queue[front];
    front = (front + 1) % SIZE;
    count--;
    return 1;
}
```
{% endcode %}

원본 코드는 `queue[rear++] = value;`와 `return queue[front++];`였다. 이 구조는 두 가지 문제가 있다.

* `rear`가 `SIZE`에 도달한 뒤 enqueue하면 배열 범위를 벗어난다(UB).
* dequeue로 앞쪽 칸이 비어도 그 칸을 다시 쓰지 못한다. 처리한 요소 수만큼 용량이 줄어든다.

원형 큐는 `rear`와 `front`를 `% SIZE`로 되돌려 빈 칸을 재사용한다. `front == rear`만으로는 가득 참과 빔을 구별할 수 없으므로, 위 코드는 요소 수 `count`로 구별한다.

### 3-5. 덱

| 연산 | 시간 복잡도 | 비고 |
|---|---|---|
| 앞 삽입 (push front) | O(1) | |
| 뒤 삽입 (push back) | O(1) | |
| 앞 삭제 (pop front) | O(1) | |
| 뒤 삭제 (pop back) | O(1) | |
| 인덱스 접근 | 배열 기반 O(1), 연결 리스트 기반 O(n) | 배열 기반은 원형 버퍼로 구현한다 |

## 4. 비교표

| 자료구조 | 접근 | 탐색 | 삽입 | 삭제 | 특징 |
|---|---|---|---|---|---|
| 배열 | O(1) (인덱스) | O(n) | O(n) | O(n) | 고정 크기, 빠른 접근 |
| 단일 연결 리스트 | O(n) | O(n) | 머리 O(1) | 머리 O(1), 꼬리 O(n) | 동적 크기, 느린 탐색 |
| 스택 | 최상단 O(1) | O(n) | O(1) | O(1) | 후입선출(LIFO) |
| 큐 | 맨 앞 O(1) | O(n) | O(1) | O(1) | 선입선출(FIFO) |
| 덱 | 양쪽 끝 O(1) | O(n) | 양쪽 끝 O(1) | 양쪽 끝 O(1) | 양방향 큐. 배열 기반이면 인덱스 접근 O(1) |

접근은 "특정 위치의 요소에 도달하는 비용"이다. 스택·큐·덱은 정해진 끝에서만 접근하도록 제한한 구조이므로, 그 끝의 접근은 O(1)이다.

## 5. 한계·주의

* 배열은 크기를 선언 시 정해야 한다. 크기를 넘는 인덱스 접근은 UB다([배열 자료구조 (Array)](array.md)).
* 연결 리스트는 임의 접근이 불가능하고 노드마다 포인터 메모리가 든다.
* 배열 기반 스택·큐는 용량 초과(overflow)와 빈 구조에서의 삭제(underflow)를 반드시 검사한다.

## 6. 관련 문서

| 문서 | Task ID | 내용 |
|---|---|---|
| [배열 자료구조 (Array)](array.md) | PRG-DSA-004-DO | 배열의 메모리 배치와 경계 규칙 |
| [연결 리스트 상세 (Linked List)](../../data-structures/linkedlists_kr.md) | PRG-DST-005-DO | 연결 리스트 구현 |
| [스택 (Stack)](../../data-structures/stack.md) | PRG-DST-003-DO | 스택 정의와 구현 위치 |

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| LIFO, FIFO | 후입선출(Last-In First-Out), 선입선출(First-In First-Out) |
| overflow, underflow | 가득 찬 구조에 삽입, 빈 구조에서 삭제 |
| 분할상환(amortized) O(1) | 드물게 비싼 연산을 평균한 한 번당 비용이 O(1) |
| tail 포인터 | 연결 리스트의 마지막 노드를 가리키는 변수 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 단일 연결 리스트에서 머리 삭제는 O(1)인데 꼬리 삭제는 O(n)인 이유를 적는다.
- [ ] 크기 3인 원형 큐에서 enqueue, enqueue, dequeue, enqueue, enqueue를 차례로 했을 때 `front`, `rear`, `count`를 적는다.
- [ ] 스택과 큐 중 하나를 골라, 직접 쓴 프로그램에서 어디에 쓸 수 있을지 적는다.
