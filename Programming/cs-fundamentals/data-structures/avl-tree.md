# [생성형 AI] AVL 트리 (AVL Tree)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-014-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 높이 균형을 유지하는 AVL 트리의 회전 원리와 C 구현을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

AVL 트리는 모든 노드에서 왼쪽 서브트리와 오른쪽 서브트리의 높이 차(균형 계수)가 -1, 0, 1 중 하나가 되도록 유지하는 이진 탐색 트리다. [이진 탐색 트리](binary-search-tree.md)는 정렬된 순서로 넣으면 한쪽으로 치우쳐 높이가 n이 되지만, AVL 트리는 삽입 때마다 회전으로 균형을 되찾아 높이를 O(log n)으로 지킨다. 높이는 최대 약 1.44·log2(n + 2)이다.

## 2. 동작 원리

삽입 후 경로를 되짚으며 높이를 갱신하고, 균형 계수의 절댓값이 2가 되는 노드에서 회전한다.

| 경우 | 조건 | 처리 |
|---|---|---|
| LL | 왼쪽 자식의 왼쪽에 삽입 | 오른쪽 회전 1회 |
| RR | 오른쪽 자식의 오른쪽에 삽입 | 왼쪽 회전 1회 |
| LR | 왼쪽 자식의 오른쪽에 삽입 | 왼쪽 자식을 왼쪽 회전한 뒤 오른쪽 회전 |
| RL | 오른쪽 자식의 왼쪽에 삽입 | 오른쪽 자식을 오른쪽 회전한 뒤 왼쪽 회전 |

| 연산 | 시간 복잡도 |
|---|---|
| 탐색 | O(log n) |
| 삽입 | O(log n), 회전은 삽입당 최대 2번 |
| 삭제 | O(log n), 회전이 경로를 따라 여러 번 필요할 수 있다 |
| 공간 | O(n) |

## 3. 예제 코드 (C, 삽입만 구현)

1부터 7까지 오름차순으로 넣는다. 일반 BST라면 높이 7의 연결 리스트 모양이 된다.

{% code title="avl.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
	int key;
	int height;
	struct Node *left, *right;
} Node;

static int height(Node *n) { return n ? n->height : 0; }
static int max(int a, int b) { return a > b ? a : b; }
static void update(Node *n) { n->height = 1 + max(height(n->left), height(n->right)); }
static int balance(Node *n) { return height(n->left) - height(n->right); }

static Node *rotateRight(Node *y) {
	Node *x = y->left;
	y->left = x->right;
	x->right = y;
	update(y);
	update(x);
	return x;
}

static Node *rotateLeft(Node *x) {
	Node *y = x->right;
	x->right = y->left;
	y->left = x;
	update(x);
	update(y);
	return y;
}

Node *insert(Node *n, int key) {
	if (!n) {
		Node *t = malloc(sizeof(Node));
		t->key = key; t->height = 1; t->left = t->right = NULL;
		return t;
	}
	if (key < n->key) n->left = insert(n->left, key);
	else if (key > n->key) n->right = insert(n->right, key);
	else return n;                            /* 중복 키는 무시 */
	update(n);
	int b = balance(n);
	if (b > 1 && key < n->left->key) return rotateRight(n);             /* LL */
	if (b < -1 && key > n->right->key) return rotateLeft(n);            /* RR */
	if (b > 1) { n->left = rotateLeft(n->left); return rotateRight(n); }   /* LR */
	if (b < -1) { n->right = rotateRight(n->right); return rotateLeft(n); } /* RL */
	return n;
}

void preorder(Node *n) {
	if (!n) return;
	printf("%d ", n->key);
	preorder(n->left);
	preorder(n->right);
}

void freeTree(Node *n) {
	if (!n) return;
	freeTree(n->left);
	freeTree(n->right);
	free(n);
}

int main(void) {
	Node *root = NULL;
	for (int k = 1; k <= 7; k++) root = insert(root, k);   /* 오름차순 삽입 */
	printf("height = %d\n", height(root));
	printf("preorder: ");
	preorder(root);
	printf("\n");
	freeTree(root);
	return 0;
}
```
{% endcode %}

실행 결과:

```
height = 3
preorder: 4 2 1 3 6 5 7 
```

| 위치 | 설명 |
|---|---|
| `update`, `balance` | 노드 높이를 자식 높이로 다시 계산하고 `왼쪽 높이 - 오른쪽 높이`를 구한다 |
| `rotateRight`, `rotateLeft` | 포인터 세 개를 바꿔 서브트리 루트를 교체하고 새 루트를 돌려준다. 회전 후 아래쪽 노드(`y`/`x`)를 먼저 갱신한다 |
| 반환값 대입(`n->left = insert(...)`) | 회전으로 서브트리 루트가 바뀌므로 부모가 새 루트를 받아 연결한다 |
| 전위 순회 `4 2 1 3 6 5 7` | 루트가 4이고 높이가 3인 완전 이진 트리 모양이다 |

## 4. 한계와 주의

* 삭제는 이 예제에 없다. 삭제는 삽입보다 회전 분기가 많아 별도 구현이 필요하다.
* 각 노드가 높이를 저장하므로 BST보다 노드가 크고, 쓰기가 많으면 회전 비용이 든다. 레드-블랙 트리는 회전 수가 적어 삽입·삭제가 많은 라이브러리에서 쓰이지만 높이 제한은 느슨하다(최대 약 2·log2(n + 1)).
* 재귀 삽입은 스택 깊이가 높이만큼이므로 O(log n)이다.

## 관련 문서

* [이진 탐색 트리 (BST)](binary-search-tree.md)
* [이진 트리 (Binary Tree)](binarytrees_kr.md)
* [시간 복잡도와 빅오 표기법 (Big-O)](../overviews/big-o-notation.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] BST와 AVL 트리에서 1~7을 순서대로 넣었을 때 높이를 비교한다.
- [ ] LR 경우에 회전이 두 번 필요한 이유를 그림으로 설명한다.
- [ ] AVL 트리가 조회가 많은 작업에 맞는 이유를 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
