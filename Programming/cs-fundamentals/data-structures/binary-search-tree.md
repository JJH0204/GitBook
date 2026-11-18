# [생성형 AI] 이진 탐색 트리 (BST)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-010-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 이진 탐색 트리의 규칙, 삽입·탐색 원리, 치우침에 따른 복잡도 변화를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

이진 탐색 트리(BST, Binary Search Tree)는 모든 노드에 대해 **왼쪽 서브트리의 모든 키는 노드보다 작고, 오른쪽 서브트리의 모든 키는 노드보다 크다**는 규칙을 만족하는 이진 트리다. 이 책의 예제는 같은 키를 중복해서 넣지 않는 것으로 정한다(구현에 따라 중복을 허용하는 방식도 있다).

중위 순회(왼쪽, 자신, 오른쪽)로 방문하면 키가 오름차순으로 나온다. 트리의 용어와 순회는 [이진 트리](binarytrees_kr.md)에서 다룬다.

## 2. 동작 원리

* **탐색**: 루트에서 시작해 찾는 키가 노드보다 작으면 왼쪽, 크면 오른쪽으로 내려간다. 같으면 찾은 것이고, 빈 자리(NULL)에 닿으면 없는 것이다. 한 번 비교할 때마다 절반 정도를 버리는 [이진 탐색](../algorithms/binary-search.md)과 같은 원리다.
* **삽입**: 탐색과 같은 경로로 내려가 NULL을 만난 자리에 새 노드를 단다.
* **삭제**: 자식이 없으면 그냥 제거, 자식이 하나면 자식으로 대체, 자식이 둘이면 오른쪽 서브트리의 최솟값(또는 왼쪽의 최댓값)으로 값을 대체한 뒤 그 노드를 제거한다. 아래 예제는 삭제를 구현하지 않았다.

## 3. 복잡도

| 연산 | 평균(균형에 가까울 때) | 최악(한쪽으로 치우칠 때) |
|---|---|---|
| 탐색 | O(log n) | O(n) |
| 삽입 | O(log n) | O(n) |
| 삭제 | O(log n) | O(n) |
| 중위 순회 | O(n) | O(n) |
| 공간 | O(n) | O(n) |

연산 시간은 트리 높이 h에 비례(O(h))한다. 이미 정렬된 키를 차례로 넣으면 한 줄로 늘어선 사실상의 연결 리스트가 되어 높이가 n이다. 높이를 O(log n)으로 보장하려고 스스로 균형을 맞추는 트리(AVL 트리, 레드-블랙 트리 등)를 쓴다.

## 4. 예제 코드 (C)

{% code title="bst.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

typedef struct Node { int key; struct Node *left, *right; } Node;

Node *insert(Node *root, int key) {
	if (!root) {
		Node *n = malloc(sizeof *n);
		n->key = key; n->left = n->right = NULL;
		return n;
	}
	if (key < root->key) root->left = insert(root->left, key);
	else if (key > root->key) root->right = insert(root->right, key);
	return root;                                   /* 같은 키는 무시 */
}

int contains(const Node *root, int key) {
	while (root) {
		if (key == root->key) return 1;
		root = key < root->key ? root->left : root->right;
	}
	return 0;
}

void inorder(const Node *root) {
	if (!root) return;
	inorder(root->left);
	printf("%d ", root->key);
	inorder(root->right);
}

int height(const Node *root) {
	if (!root) return 0;
	int l = height(root->left), r = height(root->right);
	return 1 + (l > r ? l : r);
}

void freeTree(Node *root) {
	if (!root) return;
	freeTree(root->left); freeTree(root->right); free(root);
}

int main(void) {
	int in[] = {50, 30, 70, 20, 40, 60, 80, 40};
	Node *root = NULL;
	for (int i = 0; i < 8; i++) root = insert(root, in[i]);
	printf("inorder: "); inorder(root); printf("\n");
	printf("contains 60: %d, contains 65: %d\n", contains(root, 60), contains(root, 65));
	printf("height: %d\n", height(root));
	freeTree(root);

	Node *skew = NULL;                             /* 정렬된 입력 */
	for (int k = 1; k <= 6; k++) skew = insert(skew, k);
	printf("sorted input height: %d\n", height(skew));
	freeTree(skew);
	return 0;
}
```
{% endcode %}

실행 결과:

```
inorder: 20 30 40 50 60 70 80 
contains 60: 1, contains 65: 0
height: 3
sorted input height: 6
```

| 위치 | 설명 |
|---|---|
| `insert` | 재귀로 내려가 NULL 자리에 노드를 만들고, 갱신된 자식 포인터를 `root->left`/`root->right`에 다시 대입한다 |
| `else if (key > root->key)` | 같은 키(마지막 입력 40)는 아무 일도 하지 않고 무시한다 |
| `contains` | 재귀 없이 반복문으로 내려간다 |
| 두 번째 트리 | 1~6을 오름차순으로 넣으면 높이가 6이 되어 치우침을 확인할 수 있다 |

## 5. 한계와 주의

* 균형이 깨지면 O(n)까지 느려진다. 입력 순서에 민감하다.
* 재귀 깊이가 트리 높이와 같으므로 치우친 큰 트리에서는 호출 스택이 깊어진다.
* 키 순서가 필요 없다면 [해시 테이블](hash-table.md)이 평균 O(1)로 더 빠르다. BST는 정렬 순회, 최솟값·최댓값, 범위 질의가 필요할 때 이점이 있다.

## 관련 문서

* [이진 트리 (Binary Tree)](binarytrees_kr.md)
* [이진 탐색 (Binary Search)](../algorithms/binary-search.md)
* [해시 테이블 (Hash Table)](hash-table.md)
* [비선형 자료구조 (Non-linear)](non-linear-data-structure.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] BST와 일반 이진 트리의 차이를 한 문장으로 쓴다.
- [ ] 20, 10, 30, 5, 15 순서로 넣은 BST를 그리고 중위 순회 결과를 쓴다.
- [ ] 삭제 대상 노드의 자식이 둘일 때 왜 오른쪽 서브트리의 최솟값을 쓰는지 설명한다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
