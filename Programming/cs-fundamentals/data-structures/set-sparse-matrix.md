# 희소 행렬 (Sparse Matrix)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-004-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 희소 행렬의 두 가지 저장 방식과 전치(transpose) 구현을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

희소 행렬(sparse matrix)은 대부분의 항이 0인 행렬이다. 0을 모두 저장하면 메모리가 낭비되므로 0이 아닌 항만 저장하는 방식을 쓴다.

## 2. 저장 방식 비교

| 방식 | 저장 내용 | 장점 | 단점 |
|---|---|---|---|
| 2차원 배열 | 모든 항 | 행렬 연산 구현이 단순하다. 임의 항 접근이 O(1)이다 | 0이 대부분이면 메모리를 낭비한다 |
| 삼원소(triplet, COO) | 0이 아닌 항의 (행, 열, 값) | 0이 많을수록 메모리를 절약한다 | 항 접근과 연산 구현이 복잡하다 |

삼원소 외에 행 단위로 압축하는 CSR(Compressed Sparse Row) 등의 방식도 있다. 이 문서는 삼원소 방식만 다룬다.

## 3. 방식 1: 2차원 배열 전체 저장

{% code title="matrix_full.c" %}
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
	MatrixPrint(matrix);
	MatrixPrint(matrix2);
	return 0;
}
```
{% endcode %}

* 전치는 `result[j][i] = matrix[i][j]`로 행과 열을 맞바꾼다. 시간 O(ROWS × COLS).
* 이 예제는 `ROWS == COLS`라서 `matrix2`를 같은 크기로 선언할 수 있다. 정방행렬이 아니면 `result`는 `[COLS][ROWS]`로 선언한다.
* 예상 출력은 원본 행렬 `1 2 3 / 4 5 6 / 7 8 9`와 전치 행렬 `1 4 7 / 2 5 8 / 3 6 9`다.

## 4. 방식 2: 0이 아닌 항만 저장(삼원소)

{% hint style="warning" %}
CAUTION: 원본 코드는 행·열 번호를 1부터 넣었고 0인 항 8개도 함께 저장했다(`terms`는 1). 전치 루프는 열 번호를 0부터 비교하므로 두 규칙이 충돌한다. 원본은 비영 항이 열 1에 있어 우연히 맞았지만, 열 번호가 `cols`와 같은 항(1-based의 마지막 열)은 `c < a.cols` 조건에서 빠진다. 아래 코드는 인덱스를 0부터로 통일하고 0이 아닌 항만 저장하도록 정정했다.
{% endhint %}

{% code title="sparse_matrix.c" %}
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
	/* 3x3 행렬, 0이 아닌 항은 (행 0, 열 2, 값 3) 하나다. 인덱스는 0부터 센다. */
	SparseMatrix a = {
		{
			{0, 2, 3}
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
{% endcode %}

예상 출력은 `2 0 3`이다. 항 (0, 2)가 전치되어 (2, 0)이 된다.

### 코드 설명

| 위치 | 설명 |
|---|---|
| `element` | 0이 아닌 항 하나(행, 열, 값) |
| `SparseMatrix` | 항 배열 `data`, 행 수 `rows`, 열 수 `cols`, 항 개수 `terms`. 항은 최대 101개까지 저장한다 |
| `b.rows = a.cols; b.cols = a.rows;` | 전치하면 행과 열의 크기가 바뀐다 |
| 바깥 `for (c ...)` | 원본의 열 번호 순으로 훑는다. 전치 결과가 행 우선 정렬 상태가 되게 한다 |
| 안쪽 `for (i ...)` | 열 번호가 `c`인 항을 찾아 행·열을 맞바꿔 `b`에 넣는다 |

### 복잡도

| 방식 | 시간 | 비고 |
|---|---|---|
| 위 단순 전치 | O(cols × terms) | 열마다 모든 항을 훑는다. 항이 많으면 2차원 배열 전치 O(rows × cols)보다 느려질 수 있다 |
| 빠른 전치(fast transpose) | O(cols + terms) | 열별 항 개수와 시작 위치 배열을 먼저 계산해 한 번에 배치한다. 이 문서에는 코드가 없다 |

## 5. 한계와 주의

* `data[101]` 고정 배열이라 `terms`가 101을 넘으면 범위를 벗어난다. 입력을 받는 코드에는 `terms <= 101` 검사가 필요하다.
* 행렬을 값으로 전달·반환하므로 구조체 전체가 복사된다. 항이 많으면 포인터 전달이 낫다.
* `matrixPrint`는 항 목록만 출력하며 0인 항은 나타내지 않는다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| 전치(transpose) | 행과 열을 맞바꾼 행렬. (i, j) 항이 (j, i)로 간다 |
| COO | Coordinate list. (행, 열, 값) 삼원소 목록 |
| CSR | Compressed Sparse Row. 행 단위 압축 저장 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 0이 아닌 항의 비율이 얼마 이하일 때 삼원소 방식이 이득인지 항당 저장 크기로 따져 본다.
- [ ] 단순 전치가 O(cols × terms)인 이유를 두 개의 반복문으로 설명한다.
- [ ] 인덱스를 0부터 세는지 1부터 세는지 정해 두지 않으면 어떤 문제가 생기는지 적는다.
