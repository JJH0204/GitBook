# [생성형 AI] 큐 (Queue)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-006-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 큐의 선입선출 원리, 연산 복잡도, 원형 배열 구현을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

큐(queue)는 한쪽 끝(rear)에서 삽입하고 반대쪽 끝(front)에서 삭제하는 선형 자료구조다. 먼저 넣은 요소가 먼저 나오므로 선입선출(FIFO, First-In First-Out)이라 한다. 삽입 연산을 enqueue, 삭제 연산을 dequeue라 한다.

## 2. 동작 원리

| 연산 | 동작 | 시간 복잡도 |
|---|---|---|
| enqueue | rear에 요소를 넣는다 | O(1) |
| dequeue | front의 요소를 꺼내 제거한다 | O(1) |
| peek(front) | front의 요소를 제거하지 않고 읽는다 | O(1) |
| 임의 요소 탐색 | front부터 차례로 확인한다 | O(n) |

배열로 구현할 때 front 인덱스를 하나씩 올리기만 하면 앞쪽 칸이 다시 쓰이지 않는다. 그래서 인덱스를 용량으로 나눈 나머지로 돌려 쓰는 **원형 큐(circular queue)**를 쓴다. 연결 리스트로 구현하면 head에서 삭제, tail에 삽입하므로 용량 제한이 없다.

용량 4인 원형 큐에서 1~4를 넣고 둘을 꺼낸 뒤 6, 7을 넣는 과정이다.

| 단계 | head | size | 배열 상태(인덱스 0~3) |
|---|---|---|---|
| 1~4 enqueue | 0 | 4 | 1 2 3 4 |
| 5 enqueue 시도 | 0 | 4 | 가득 차서 실패 |
| dequeue 2회(1, 2) | 2 | 2 | - - 3 4 |
| 6 enqueue | 2 | 3 | 6은 인덱스 (2+2)%4 = 0 |
| 7 enqueue | 2 | 4 | 7은 인덱스 (2+3)%4 = 1 |

## 3. 예제 코드 (C, 원형 배열 큐)

{% code title="queue.c" %}
```c
#include <stdio.h>

#define CAP 4

typedef struct {
	int data[CAP];
	int head;   /* 다음에 꺼낼 요소의 인덱스 */
	int size;   /* 현재 요소 수 */
} Queue;

void qInit(Queue *q) { q->head = 0; q->size = 0; }

int enqueue(Queue *q, int v) {
	if (q->size == CAP) return 0;                 /* 가득 참 */
	q->data[(q->head + q->size) % CAP] = v;       /* 끝 위치는 head + size */
	q->size++;
	return 1;
}

int dequeue(Queue *q, int *out) {
	if (q->size == 0) return 0;                   /* 비어 있음 */
	*out = q->data[q->head];
	q->head = (q->head + 1) % CAP;
	q->size--;
	return 1;
}

int main(void) {
	Queue q;
	int v;
	qInit(&q);
	for (int i = 1; i <= 5; i++)
		printf("enqueue %d -> %s\n", i, enqueue(&q, i) ? "ok" : "full");
	dequeue(&q, &v); printf("dequeue -> %d\n", v);
	dequeue(&q, &v); printf("dequeue -> %d\n", v);
	printf("enqueue 6 -> %s\n", enqueue(&q, 6) ? "ok" : "full");
	printf("enqueue 7 -> %s\n", enqueue(&q, 7) ? "ok" : "full");
	while (dequeue(&q, &v)) printf("dequeue -> %d\n", v);
	printf("dequeue on empty -> %s\n", dequeue(&q, &v) ? "ok" : "empty");
	return 0;
}
```
{% endcode %}

실행 결과:

```
enqueue 1 -> ok
enqueue 2 -> ok
enqueue 3 -> ok
enqueue 4 -> ok
enqueue 5 -> full
dequeue -> 1
dequeue -> 2
enqueue 6 -> ok
enqueue 7 -> ok
dequeue -> 3
dequeue -> 4
dequeue -> 6
dequeue -> 7
dequeue on empty -> empty
```

| 위치 | 설명 |
|---|---|
| `head`, `size` 두 변수 | 비었는지와 가득 찼는지를 `size`로 구분한다. `head`와 `tail`만 쓰면 두 상태가 같은 값이 되어 칸 하나를 비워 두어야 한다 |
| `(q->head + q->size) % CAP` | 다음에 넣을 위치. 끝에 닿으면 0으로 돌아간다 |
| 반환값 0/1 | 가득 찬 큐에 넣거나 빈 큐에서 꺼내는 경우(overflow, underflow)를 호출자가 확인하게 한다 |

## 4. 용도와 한계

* 너비 우선 탐색(BFS), 작업 대기열, 프로세스 스케줄링의 준비 큐, 버퍼에 쓴다.
* 양쪽 끝에서 모두 삽입·삭제해야 하면 덱(deque)을 쓴다. 우선순위로 꺼내야 하면 [힙](heap.md)으로 만든 우선순위 큐를 쓴다.
* 고정 크기 배열 큐는 용량을 넘으면 거부해야 하므로 최대 개수를 미리 정할 수 없을 때는 연결 리스트 구현이나 동적 배열을 쓴다.

## 관련 문서

* [스택 (Stack)](stack.md)
* [선형 자료구조 개요 (Linear)](../overviews/datastructuresalgorithms/lineardatastructureoverview.md): 배열, 연결 리스트, 스택, 큐, 덱 비교
* [너비 우선 탐색 (BFS)](../algorithms/breadth-first-search.md): 큐를 쓰는 대표 알고리즘

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 원형 큐에서 `head`와 `tail`만 쓰면 빈 상태와 가득 찬 상태를 어떻게 구분해야 하는지 설명한다.
- [ ] 스택과 큐가 각각 어떤 문제에 맞는지 예를 하나씩 든다.
- [ ] `CAP`을 3으로 바꾸고 위 시나리오를 손으로 추적한다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
