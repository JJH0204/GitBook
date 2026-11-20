# [생성형 AI] 덱 (Deque)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-012-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 양쪽 끝에서 삽입·삭제하는 덱의 원리와 원형 배열 구현을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

덱(deque, double-ended queue)은 앞과 뒤 양쪽에서 삽입과 삭제가 모두 가능한 선형 자료구조다. 앞에서만 넣고 빼면 스택, 뒤에서 넣고 앞에서 빼면 [큐](queue.md)로 동작하므로 둘을 일반화한 구조다.

## 2. 동작 원리

| 연산 | 동작 | 시간 복잡도(원형 배열) |
|---|---|---|
| pushFront | 앞에 요소를 넣는다 | O(1) |
| pushBack | 뒤에 요소를 넣는다 | O(1) |
| popFront | 앞 요소를 꺼낸다 | O(1) |
| popBack | 뒤 요소를 꺼낸다 | O(1) |
| 임의 위치 접근 | `(head + i) % CAP` 위치를 읽는다 | O(1) |

원형 큐와 같이 인덱스를 용량으로 나눈 나머지로 돌려 쓴다. 앞쪽 삽입은 `head`를 한 칸 뒤로 물려야 하는데 `head - 1`은 0일 때 음수가 되므로 `(head + CAP - 1) % CAP`로 계산한다.

## 3. 예제 코드 (C, 원형 배열 덱)

{% code title="deque.c" %}
```c
#include <stdio.h>

#define CAP 4

typedef struct {
	int data[CAP];
	int head;   /* 앞쪽 요소의 인덱스 */
	int size;
} Deque;

void dInit(Deque *d) { d->head = 0; d->size = 0; }

int pushBack(Deque *d, int v) {
	if (d->size == CAP) return 0;
	d->data[(d->head + d->size) % CAP] = v;
	d->size++;
	return 1;
}

int pushFront(Deque *d, int v) {
	if (d->size == CAP) return 0;
	d->head = (d->head + CAP - 1) % CAP;      /* 뒤로 한 칸: 음수가 되지 않게 CAP을 더한다 */
	d->data[d->head] = v;
	d->size++;
	return 1;
}

int popFront(Deque *d, int *out) {
	if (d->size == 0) return 0;
	*out = d->data[d->head];
	d->head = (d->head + 1) % CAP;
	d->size--;
	return 1;
}

int popBack(Deque *d, int *out) {
	if (d->size == 0) return 0;
	*out = d->data[(d->head + d->size - 1) % CAP];
	d->size--;
	return 1;
}

int main(void) {
	Deque d;
	int v;
	dInit(&d);
	pushBack(&d, 2);
	pushBack(&d, 3);
	pushFront(&d, 1);
	pushFront(&d, 0);
	printf("pushBack 9 -> %s\n", pushBack(&d, 9) ? "ok" : "full");
	popFront(&d, &v); printf("popFront -> %d\n", v);
	popBack(&d, &v);  printf("popBack -> %d\n", v);
	popBack(&d, &v);  printf("popBack -> %d\n", v);
	popFront(&d, &v); printf("popFront -> %d\n", v);
	printf("popFront on empty -> %s\n", popFront(&d, &v) ? "ok" : "empty");
	return 0;
}
```
{% endcode %}

실행 결과:

```
pushBack 9 -> full
popFront -> 0
popBack -> 3
popBack -> 2
popFront -> 1
popFront on empty -> empty
```

| 위치 | 설명 |
|---|---|
| `(d->head + CAP - 1) % CAP` | `head`가 0일 때 CAP-1로 돌아간다. C에서 음수의 `%`는 음수 결과가 나올 수 있어 CAP을 먼저 더한다 |
| `(d->head + d->size - 1) % CAP` | `popBack`이 읽는 마지막 요소의 위치다 |
| 반환값 0/1 | 가득 참 또는 빔을 호출자가 확인하게 한다 |

추적: 2, 3을 뒤에 넣고 1, 0을 앞에 넣으면 논리 순서는 0 1 2 3이다. `popFront`는 0, `popBack`은 3, 다시 `popBack`은 2, `popFront`는 1을 돌려준다.

## 4. 용도와 한계

* 슬라이딩 윈도 최댓값, 회문 검사, 0-1 BFS, 작업 훔치기(work stealing) 대기열에 쓴다.
* 고정 크기 배열 덱은 용량을 넘으면 거부한다. 크기를 모르면 연결 리스트(이중 연결)나 동적 배열 기반 구현을 쓴다.
* Python의 `collections.deque`는 양끝 연산이 O(1)이고, 리스트의 `pop(0)`은 O(n)이다.

## 관련 문서

* [큐 (Queue)](queue.md)
* [스택 (Stack)](stack.md)
* [선형 자료구조 개요 (Linear)](../overviews/datastructuresalgorithms/lineardatastructureoverview.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 덱으로 스택과 큐를 각각 흉내 내는 방법을 설명한다.
- [ ] `head`가 0일 때 `pushFront`가 어느 인덱스에 쓰는지 손으로 추적한다.
- [ ] 덱이 큐보다 적합한 문제를 하나 찾아 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
