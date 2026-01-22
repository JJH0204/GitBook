# 집합, 희소 행렬 (Set, Sparse Matrix)

* 희소 행렬: 대부분의 항들이 '0'인 배열
* 배열을 이용한 행렬(Matrix)을 표현

### 1) 2차원 배열을 이용하여 배열의 전체 요소를 저장

* 장점: 행렬 연산을 간단하게 구현가능
* 단점: 대부분의 항이 0인 희소 행렬의 경우 많은 메모리 공간을 낭비하게 된다.

![](<../../../.gitbook/assets/스크린샷 2025-03-21 18.40.34.png>)

```c
#include <stdio.h>

#define ROWS 3
#define COLS 3

void MatrixTranspose(int matrix[ROWS][COLS], int result[COLS][ROWS])
{
	for (int i = 0; i < ROWS; i++)
	{
		for (int j = 0; j < COLS; j++)
		{
			result[j][i] = matrix[i][j];
		}
	}
}

void MatrixPrint(int matrix[ROWS][COLS])
{
	for (int i = 0; i < ROWS; i++)
	{
		for (int j = 0; j < COLS; j++)
		{
			printf("%d ", matrix[i][j]);
		}
		printf("\n");
	}
}

int main()
{
	int matrix[ROWS][COLS] = {
		{1, 2, 3},
		{4, 5, 6},
		{7, 8, 9}
	};
	int matrix2[ROWS][COLS];
	
	MatrixTranspose(matrix, matrix2);
	MatrixPrint(matrix1);
	MatrixPrint(matrix2);
	return 0;
}
```

### 2) '0'이 아닌 요소들만 저장

* 장점: 희소 행렬의 경우, 메모리 공간 절약
* 단점: 각종 행렬 연산들의 구현이 복잡해진다.

![](<../../../.gitbook/assets/스크린샷 2025-03-21 18.41.06.png>)

```c
#include <stdio.h>

typedef struct {
	int row;
	int col;
	int value;
} element;

typedef struct {
	element data[101];
	int rows;
	int cols;
	int terms;
} SparseMatrix;

SparseMatrix MatrixTranspose(SparseMatrix a)
{
	SparseMatrix b;
	int bindex;
	b.rows = a.cols;
	b.cols = a.rows;
	b.terms = a.terms;
	
	if (a.terms > 0) {
		bindex = 0;
		for (int c = 0; c < a.cols; c++) {
			for (int i = 0; i < a.terms; i++) {
				if (a.data[i].col == c) {
					b.data[bindex].row = a.data[i].col;
					b.data[bindex].col = a.data[i].row;
					b.data[bindex].value = a.data[i].value;
					bindex++;
				}
			}
		}
	}
	return b;
}

  

void matrixPrint(SparseMatrix a)
{
	for (int i = 0; i < a.terms; i++) {
		printf("%d %d %d\n", a.data[i].row, a.data[i].col, a.data[i].value);
	}
}

  

int main()
{
	SparseMatrix a = {
		{
			{1, 1, 3},
			{1, 2, 0},
			{1, 3, 0},
			{2, 1, 0},
			{2, 2, 0},
			{2, 3, 0},
			{3, 1, 0},
			{3, 2, 0},
			{3, 3, 0}
		},
		3,
		3,
		1
	};
	
	SparseMatrix result;
	result = MatrixTranspose(a);
	matrixPrint(result);
	return 0;
}
```
