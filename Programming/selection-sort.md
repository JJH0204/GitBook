# selection sort

## 선택 정렬이란?

* 배열(리스트)에서 가장 작은(또는 가장 큰) 요소를 선택하여 정렬하는 비교 기반 정렬 알고리즘
* 배열에서 최소값을 찾아 맨 앞 요소와 교환하는 방식을 반복하면서 정렬을 수행한다.

{% hint style="info" %}
✔️ 시간 복잡도: **O(n²)** → 비효율적이지만 구현은 간단

✔️ 제자리 정렬(In-place Sort) → 추가적인 메모리 공간 필요 없음

✔️ 안정 정렬(Unstable Sort) → 동일한 값을 가진 요소의 상대적 순서가 유지되지 않을 수 있음

✔️ 배열이 거의 정렬된 경우에도 성능 향상이 없음
{% endhint %}

***

## 선택 정렬 알고리즘 과정

{% stepper %}
{% step %}
### 배열의 최소값을 찾는다.

현재 위치부터 끝까지 탐색하여 최소값의 인덱스를 찾는다.
{% endstep %}

{% step %}
### 최소값을 배열의 첫 번째 요소와 교환한다.

찾은 최소값을 현재 위치(예: 첫 번째 요소)와 교환한다.
{% endstep %}

{% step %}
### 나머지 배열에서 최소값을 찾고 교환한다.

다음 위치로 이동하여 같은 과정을 반복한다(두 번째 요소부터).
{% endstep %}

{% step %}
### 전체 배열이 정렬될 때까지 반복한다.

위 과정을 반복하면 배열 전체가 오름차순(또는 내림차순)으로 정렬된다.
{% endstep %}
{% endstepper %}

***

## 오름차순 정렬 예제 (C)

{% code title="selection_sort.c" %}
```c
#include <stdio.h>

void selectionSort(int arr[], int n) {
	int i, j, minIdx, temp;

	for (i = 0; i < n - 1; i++) {
		minIdx = i;

		for (j = i + 1; j < n; j++) {
			if (arr[j] < arr[minIdx]) {
				minIdx = j;
			}
		}

		temp = arr[i];
		arr[i] = arr[minIdx];
		arr[minIdx] = temp;
	}
}

void printArr(int arr[], int n) {
	for (int i = 0; i < n; i++) {
		printf("%d ", arr[i]);
	}
	printf("\n");
}

int main() {
	int arr[] = {64, 25, 12, 22, 11};
	int n = sizeof(arr) / sizeof(arr[0]);

	printf("pre-sort: ");
	printArr(arr, n);

	selectionSort(arr, n);

	printf("post-sort: ");
	printArr(arr, n);
	return 0;
}
```
{% endcode %}

출력 예:

```
pre-sort: 64 25 12 22 11 
post-sort: 11 12 22 25 64 
```

***

## 선택 정렬의 시간 복잡도 분석

| 최선의 경우    | 평균적인 경우   | 최악의 경우    |
| --------- | --------- | --------- |
| **O(n²)** | **O(n²)** | **O(n²)** |

* 비교 횟수: (n-1) + (n-2) + … + 2 + 1 = **n(n-1)/2** ≈ **O(n²)**
* 교환 횟수: 최악의 경우 **n-1번** 교환 수행
* 이미 정렬된 배열에서도 **O(n²)** 시간이 소요된다. → 데이터 정렬 여부를 고려하지 않는다.

***

## 선택 정렬의 응용

* 내림차순 정렬

{% code title="내림차순으로 바꾸는 조건" %}
```c
if (arr[j] > arr[maxIdx]) {
	maxIdx = j;
}
```
{% endcode %}

* 양방향 선택 정렬 (Double Selection Sort)\
  한 번 탐색에서 최소값과 최대값을 동시에 찾아 양쪽 끝에 배치\
  → 시간 복잡도는 여전히 **O(n²)** 이지만, 일반적인 선택 정렬보다 실제 비교/교환 횟수를 줄일 수 있다.
