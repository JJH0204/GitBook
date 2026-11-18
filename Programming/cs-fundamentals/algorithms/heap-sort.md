# [생성형 AI] 힙 정렬 (Heap Sort)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ALG-006-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 힙 정렬의 원리, 복잡도, 안정성과 C 구현을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra`로 컴파일해 경고 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 원리

힙 정렬은 배열을 최대 힙(max heap)으로 만든 뒤, 루트(최댓값)를 배열 끝으로 보내고 힙 크기를 줄여 가며 정렬하는 비교 기반 정렬이다.

최대 힙은 모든 부모가 자식보다 크거나 같은 완전 이진 트리다. 배열로 표현하면 인덱스 `i`의 왼쪽 자식은 `2i + 1`, 오른쪽 자식은 `2i + 2`다.

1. 마지막 부모(`n / 2 - 1`)부터 루트까지 거꾸로 `siftDown`을 적용해 배열을 최대 힙으로 만든다.
2. 루트 `arr[0]`(최댓값)과 힙의 마지막 요소를 교환한다. 마지막 요소는 확정된다.
3. 힙 크기를 1 줄이고 루트에 `siftDown`을 적용해 힙 성질을 복구한다.
4. 힙 크기가 1이 될 때까지 2~3을 반복한다.

`siftDown`은 부모를 자식 중 큰 쪽과 비교해 자식이 더 크면 교환하며 아래로 내려가는 연산이다.

## 2. 단계별 추적

`{4, 10, 3, 5, 1}`의 진행 과정이다. `|` 오른쪽이 확정된 구간이다.

| 단계 | 동작 | 배열 상태 |
|---|---|---|
| 힙 구성 | 인덱스 1은 10이 자식보다 커서 그대로 | `4 10 3 5 1` |
| 힙 구성 | 인덱스 0의 4를 10과 교환, 다시 5와 교환 | `10 5 3 4 1` |
| end=4 | 루트 10과 마지막 1 교환 후 복구 | `5 4 3 1 \| 10` |
| end=3 | 루트 5와 1 교환 후 복구 | `4 1 3 \| 5 10` |
| end=2 | 루트 4와 3 교환 후 복구 | `3 1 \| 4 5 10` |
| end=1 | 루트 3과 1 교환 | `1 \| 3 4 5 10` |

## 3. 예제 코드 (C)

{% code title="heap_sort.c" %}
```c
#include <stdio.h>

void swap(int *a, int *b) {
	int t = *a;
	*a = *b;
	*b = t;
}

/* 인덱스 i를 루트로 하는 서브트리를 최대 힙으로 만든다. 힙 크기는 n */
void siftDown(int arr[], int n, int i) {
	while (1) {
		int largest = i;
		int l = 2 * i + 1;
		int r = 2 * i + 2;

		if (l < n && arr[l] > arr[largest]) largest = l;
		if (r < n && arr[r] > arr[largest]) largest = r;
		if (largest == i) break;

		swap(&arr[i], &arr[largest]);
		i = largest;
	}
}

void heapSort(int arr[], int n) {
	for (int i = n / 2 - 1; i >= 0; i--) {
		siftDown(arr, n, i);
	}
	for (int end = n - 1; end > 0; end--) {
		swap(&arr[0], &arr[end]);
		siftDown(arr, end, 0);
	}
}

int main(void) {
	int arr[] = {4, 10, 3, 5, 1};
	int n = sizeof(arr) / sizeof(arr[0]);

	heapSort(arr, n);
	for (int i = 0; i < n; i++) {
		printf("%d ", arr[i]);
	}
	printf("\n");
	return 0;
}
```
{% endcode %}

출력 예:

```
1 3 4 5 10 
```

| 위치 | 설명 |
|---|---|
| `l = 2 * i + 1`, `r = 2 * i + 2` | 배열로 표현한 완전 이진 트리의 자식 인덱스 |
| `l < n && ...` | 자식이 힙 범위 안에 있을 때만 비교한다 |
| `largest == i` 이면 `break` | 부모가 이미 가장 크면 더 내려갈 필요가 없다 |
| `for (i = n / 2 - 1; i >= 0; i--)` | 잎 노드는 이미 힙이므로 마지막 부모부터 시작한다 |
| `siftDown(arr, end, 0)` | 힙 크기를 `end`로 줄여 확정된 뒤쪽 요소를 건드리지 않는다 |

## 4. 복잡도

| 항목 | 값 | 비고 |
|---|---|---|
| 힙 구성 | O(n) | |
| 시간(최선·평균·최악) | O(n log n) | 추출 n−1번에 각각 `siftDown` O(log n) |
| 공간 | O(1) | 제자리 정렬. 이 코드는 반복문으로 `siftDown`을 구현했다 |
| 안정성 | 불안정 | 루트와 끝 요소의 교환 때문이다 |

## 5. 안정성과 한계

* 최악에도 O(n log n)이고 추가 메모리가 O(1)이다.
* 불안정 정렬이다.
* 메모리를 넓게 건너뛰며 접근하므로 캐시 효율이 낮은 편이라, 같은 O(n log n)이어도 퀵 정렬보다 느린 경우가 많다고 알려져 있다.
* 같은 최대 힙 구조는 우선순위 큐의 구현에도 쓴다.

## 6. 관련 문서

* [퀵 정렬 (Quick Sort)](quick-sort.md)(PRG-ALG-005-DO)
* [이진 트리 (Binary Tree)](../data-structures/binarytrees_kr.md)(PRG-DST-001-DO): 완전 이진 트리의 구조
* [정렬 알고리즘 비교 (Sort)](../overviews/datastructuresalgorithms/sortalgorithmoverview.md)(PRG-DSA-001-DO): 정렬별 복잡도·안정성 비교표

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 배열로 표현한 힙에서 인덱스 `i`의 부모 인덱스를 구하는 식을 적고, 이유를 설명한다.
- [ ] 힙 구성이 O(n log n)이 아니라 O(n)이라고 알려진 이유를 찾아 자기 말로 적는다.
- [ ] 힙 정렬이 불안정한 입력 예를 하나 만들어 본다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
