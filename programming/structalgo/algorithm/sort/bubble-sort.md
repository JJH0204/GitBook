# 버블 정렬 (Bubble Sort)

## 버블 정렬이란?

- 인접한 두 개의 원소를 비교하여 필요한 경우 자리를 교환하면서 정렬하는 비교 기반 정렬 알고리즘
- 가장 큰(또는 작은) 요소가 반복된 정렬의 끝으로 거품처럼 이동하는 방식이기 때문에 버블 정렬이라 불린다.

✔️ 시간 복잡도: **O(n²)** → 비효율적이지만 이해하기 쉬운 정렬 알고리즘

✔️ 제자리 정렬(In-place Sort) → 추가적인 메모리 공간이 필요 없음

✔️ 안정 정렬(Stable Sort) → 동일한 값을 가진 요소의 상대적 순서가 유지된다.

✔️ 거의 정렬된 배열에서는 개선된 버블 정렬(최적화 버블 정렬)을 활용하면 **O(n)** 성능 개선이 가능

---

## 버블 정렬 알고리즘 과정

1. 배열의 첫 번째 요소와 두 번째 요소를 비교하여 정렬 순서가 맞지 않으면 교환
2. 다음 요소로 이동하여 두 요소를 비교하고 필요하면 교환
3. 이 과정을 배열 끝까지 반복하면 가장 큰(또는 작은) 요소가 배열 끝에 배치된다.
4. 배열에서 가장 큰 요소가 정렬된 이후, 나머지 요소에 대해 동일한 과정 반복
5. 교환이 발생하지 않으면 정렬이 완료된 것으로 판단하고 종료

---

## 버블 정렬 예제

~~~c
#include <stdio.h>

void bubbleSort(int arr[], int n) {
	int i, j, temp;
	int swapped;

	for (i = 0; i < n - 1; i++) {
		swapped = 0;

		for (j = 0; j < n - i - 1; j++) {
			if (arr[j] > arr[j + 1]) {
				temp = arr[j];
				arr[j] = arr[j + 1];
				arr[j + 1] = temp;
				swapped = 1;
			}
		}

		if (swapped == 0) {
			break;
		}
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

	bubbleSort(arr, n);

	printf("post-sort: ");
	printArr(arr, n);
	return 0;
}
~~~

~~~
pre-sort: 64 25 12 22 11 
post-sort: 11 12 22 25 64 
~~~

---

## 버블 정렬의 시간 복잡도 분석

| 최선의 경우   | 평균적인 경우   | 최악의 경우    |
| :------- | --------- | --------- |
| **O(n)** | **O(n²)** | **O(n²)** |

- 최선의 경우 O(n): 배열이 이미 정렬된 경우, 한 번의 패스에서 교환이 발생하지 않아 즉시 종료된다.
- 평균 및 최악의 경우 O(n²): 모든 요소를 비교해야 하므로 O(n²) 성능을 가진다.

✔️ 일반적인 경우에 삽입 정렬, 퀵 정렬 등의 알고리즘이 더 빠르다.

---

## 버블 정렬 응용 (양방향 버블 정렬)

~~~c
void shakerSort(int arr[], int n) {
	int left = 0, right = n - 1;
	int swapped, temp;

	do {
		swapped = 0;

		for (int i = left; i < right; i++) {
			if (arr[i] > arr[i + 1]) {
				temp = arr[i];
				arr[i] = arr[i + 1];
				arr[i + 1] = temp;
				swapped = 1;
			}
		}
		right--;

		for (int i = right; i > left; i--) {
			if (arr[i] < arr[i - 1]) {
				temp = arr[i];
				arr[i] = arr[i - 1];
				arr[i - 1] = temp;
				swapped = 1;
			}
		}
		left++;
	} while (swapped);
}
~~~

✔️ shaker sort는 버블 정렬보다 비교 횟수를 줄일 수 있다.