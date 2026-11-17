# 이진 트리 (Binary Tree)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-001-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 트리와 이진 트리의 용어, 종류, 포인터 구현(C), 순회(DFS, BFS)를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

트리(tree)는 계층 구조를 가지는 노드(node)와 간선(edge)의 집합이다. 이진 트리(binary tree)는 각 노드가 최대 2개의 자식(왼쪽 자식, 오른쪽 자식)을 갖는 트리다. 이진 트리는 K-ary 트리에서 K = 2인 특수한 경우이며, 이진 탐색 트리와 이진 힙을 구현하는 데 쓰인다.

트리의 특징은 다음과 같다.

* 데이터를 계층 구조(부모-자식 구조)로 저장한다.
* 노드는 여러 개의 다음 노드(자식)에 연결될 수 있지만 이전 노드(부모)는 하나뿐이다.
* 조직도처럼 현실의 계층 구조를 표현하기 좋다.
* 비선형(non-linear) 구조다.
* 노드가 n개이면 간선은 n − 1개다.

이진 트리의 일반 연산은 삽입, 삭제, 순회다. 이 연산의 난이도는 트리가 균형 잡혀 있는지, 대상 노드가 리프 노드인지 분기 노드인지에 따라 달라진다.

균형 트리(balanced tree)는 모든 노드에서 왼쪽 서브트리와 오른쪽 서브트리의 높이 차가 1 이하인 트리다. 균형 트리의 높이는 노드 수 n에 대해 O(log n)이다. 예를 들어 완전 이진 트리의 높이는 루트의 깊이를 0으로 세면 ⌊log₂ n⌋, 루트만 있는 트리의 높이를 1로 세면 ⌊log₂ n⌋ + 1이다.

```
    g                  s                  9
   / \                / \                / \
  b   m              f   u              5   13
 / \                    / \                /  \
c   d                  t   y              11  15
```

위 그림은 균형 이진 트리의 모양 예시다. 노드의 글자나 숫자는 탐색 트리 규칙과 무관하다.

## 2. 구성 요소

### 2-1. 용어

노드 종류(트리에서의 위치 기준)는 다음과 같다.

| 용어 | 내용 |
|---|---|
| 루트(root) 노드 | 트리의 첫 번째 노드 |
| 단말(leaf, terminal) 노드 | 자식 노드가 없는 노드 |
| 내부(internal) 노드 | 자식 노드가 있는 노드 |

노드 종류(노드 사이의 관계 기준)는 다음과 같다.

| 용어 | 내용 |
|---|---|
| 부모(parent) 노드 | 어떤 노드의 바로 위에 간선으로 연결된 노드 |
| 자식(child) 노드 | 어떤 노드의 바로 아래에 간선으로 연결된 노드 |
| 선조(ancestor) 노드 | 루트 노드부터 해당 노드의 부모까지 경로상에 있는 모든 노드 |
| 후손(descendant) 노드 | 특정 노드의 아래에 있는 모든 노드 |
| 형제(sibling) 노드 | 같은 부모 노드의 자식 노드 |

노드 속성은 다음과 같다.

| 용어 | 내용 |
|---|---|
| 레벨(level) | 루트 노드부터의 거리 |
| 높이(height) | 이 문서에서는 루트 노드에서 가장 먼 노드까지의 노드 수. 루트만 있는 트리의 높이는 1이다 |
| 차수(degree) | 한 노드가 가지는 자식 노드의 개수 |

{% hint style="info" %}
NOTE: 높이와 레벨의 기준은 교재마다 다르다. 루트의 깊이를 0으로 세고 간선 수로 높이를 재면 값이 1 작다. 이 문서의 노드 수 공식(2^h − 1)은 루트만 있는 트리의 높이를 1로 세는 기준이다. [비선형 자료구조 (Non-linear)](non-linear-data-structure.md)(PRG-DST-002-DO)는 간선 수 기준이다.
{% endhint %}

기타 용어는 다음과 같다.

| 용어 | 내용 |
|---|---|
| 서브트리(subtree) | 어떤 노드와 그 후손으로 이루어진 부분 트리 |
| 포리스트(forest) | 트리의 집합. 트리는 루트가 1개이고 포리스트는 루트가 n개다 |

### 2-2. 이진 트리의 종류

이진 트리는 모양에 따라 알고리즘 성능이 달라진다. 모양은 레벨과 노드 수에 따라 결정된다.

| 종류 | 정의 |
|---|---|
| 포화 이진 트리(Full/Perfect Binary Tree) | 모든 레벨이 노드로 가득 찬 트리 |
| 완전 이진 트리(Complete Binary Tree) | 마지막 레벨을 제외한 모든 레벨이 가득 차 있고, 마지막 레벨은 왼쪽부터 오른쪽으로 차례대로 채워진 트리 |
| 편향 이진 트리(Skewed Binary Tree) | 모든 노드가 한쪽 자식만 가진 트리 |
| 이진 검색 트리(Binary Search Tree, BST) | 모양이 아니라 키 값 조건으로 정의되는 이진 트리. 아래 참조 |

완전 이진 트리에 대한 보충이다.

* 마지막 바로 위 레벨의 노드는 자식이 0개, 1개, 2개일 수 있다. 다만 자식이 1개인 노드는 최대 1개이며 그 자식은 왼쪽 자식이다.
* 모든 레벨이 가득 찬 트리는 포화 이진 트리다. 포화 이진 트리는 완전 이진 트리의 특수한 경우다.
* 완전 이진 트리는 힙(heap) 구조와 힙 정렬에 쓴다.

이진 검색 트리(BST)에 대한 보충이다.

* 노드 N의 왼쪽 서브트리에는 N의 키보다 작은 키만, 오른쪽 서브트리에는 N의 키보다 큰 키만 있다. 이 문서는 키가 모두 다르다고 가정한다. 같은 키를 허용하는 구현은 한쪽에 몰아 두는 규칙이 따로 필요하다.
* 중위 순회를 하면 키가 오름차순으로 방문된다.
* 탐색, 삽입, 삭제는 높이에 비례하는 O(h)다. 균형이면 O(log n), 한쪽으로 치우치면 O(n)이다.

### 2-3. 노드 수의 범위

높이가 h인 이진 트리의 노드 수 n의 범위는 다음과 같다. 최솟값은 편향 이진 트리, 최댓값은 포화 이진 트리의 노드 수다.

| 항목 | 값 |
|---|---|
| 최소 노드 수 | h |
| 최대 노드 수 | 2^h − 1 |
| 범위 | h ≤ n ≤ 2^h − 1 |

### 2-4. 이진 트리의 추상 자료형(ADT)

| 이름 | 입력 | 출력 | 설명 |
|---|---|---|---|
| makeBinTree() | data | binTree | data를 갖는 rootNode로 구성된 binTree를 생성한다 |
| getRootNode() | binTree | rootNode | binTree의 rootNode를 반환한다 |
| addLeftChildNode() | parentNode, data | leftChildNode | parentNode의 leftChildNode를 추가한다 |
| addRightChildNode() | parentNode, data | rightChildNode | parentNode의 rightChildNode를 추가한다 |
| getLeftChildNode() | parentNode | leftChildNode | parentNode의 leftChildNode를 반환한다 |
| getRightChildNode() | parentNode | rightChildNode | parentNode의 rightChildNode를 반환한다 |
| getData() | node | data | node의 data를 반환한다 |
| deleteBinTree() | binTree | N/A | binTree의 모든 노드와 binTree를 `free`한다 |

### 2-5. 배열 이진 트리

완전 이진 트리는 노드를 레벨 순서(위에서 아래, 왼쪽에서 오른쪽)로 배열에 저장할 수 있다. 포인터가 필요 없고 부모와 자식을 인덱스 계산으로 찾는다.

| 인덱스 기준 | 부모 | 왼쪽 자식 | 오른쪽 자식 |
|---|---|---|---|
| 1부터 시작 | i / 2 (정수 나눗셈) | 2i | 2i + 1 |
| 0부터 시작 | (i − 1) / 2 | 2i + 1 | 2i + 2 |

완전 이진 트리가 아니면 빈 칸이 생겨 배열의 공간이 낭비된다. 높이가 h인 트리를 배열로 저장하려면 최대 2^h − 1칸이 필요하다.

### 2-6. 포인터 이진 트리

노드 사이의 간선(연결 정보)을 포인터로 구현한 이진 트리이며 연결 이진 트리(linked binary tree)라고도 한다.

* 노드 개수만큼만 메모리를 할당하므로 메모리 효율이 상대적으로 좋다.
* 노드의 탐색과 메모리 관리를 직접 해야 해서 구현이 어렵다.

## 3. 동작 원리와 예제 코드: 포인터 이진 트리 (C)

{% hint style="info" %}
NOTE: 이 절의 코드는 한 파일로 모아 `#include <stdio.h>`, `<stdlib.h>`, `<stdbool.h>`가 필요하다. 반환값이 `bool`인 함수는 `true`가 오류, `false`가 정상이다. 아래 코드가 쓰는 `ISNULL`, `ISNULL_ERROR` 매크로는 원본에 정의가 없어 3-1절에 추가했다.
{% endhint %}

### 3-1. 구조와 보조 정의

{% code title="구조 정의" %}
```c
typedef struct BinaryTreeNode
{
    char cData;
    
    struct BinaryTreeNode *pLeftChild;
    struct BinaryTreeNode *pRightChild;
} node;

typedef struct BinaryTree
{
    node *pRootNode;
} tree;
```
{% endcode %}

정정 내용은 다음과 같다. 원본의 멤버 타입은 `struct TreeNode *`였다. 이 이름의 구조체는 정의돼 있지 않아 `node`와 다른 타입이 되고 컴파일 오류 또는 호환되지 않는 포인터 경고가 난다. `struct BinaryTreeNode *`로 맞췄다.

{% code title="보조 매크로와 함수 선언 (원본에 없어 추가)" %}
```c
#define ISNULL(p)       ((p) == NULL)
#define ISNULL_ERROR(p) (((p) == NULL) ? (printf("error: NULL pointer\n"), true) : false)

node * createNodeBinTree(const char _cRootNodeData_);
bool deleteBinTreeNode(node * _pParent_);
```
{% endcode %}

`createBinTree`가 `createNodeBinTree`를 호출하므로 앞에 선언이 있어야 한다. 아래 순회 함수의 `...BinTreeNode` 보조 함수도 사용 전에 선언하거나 먼저 정의한다.

### 3-2. 생성

```c
tree * createBinTree(const char _cRootNodeData_)
{
    tree *pResult = NULL;
    pResult = (tree *)malloc(sizeof(tree));
    if (ISNULL(pResult))
        return NULL;
    
    pResult->pRootNode = createNodeBinTree(_cRootNodeData_);
    if (ISNULL(pResult->pRootNode))
    {
        free(pResult);
        return NULL;
    }
    return pResult;
}

node * createNodeBinTree(const char _cRootNodeData_)
{
    node * pResult = NULL;
    pResult = (node *)malloc(sizeof(node));
    if (ISNULL(pResult))
        return NULL;
    pResult->cData = _cRootNodeData_;
    pResult->pLeftChild = NULL;
    pResult->pRightChild = NULL;
    return pResult;
}
```

정정 내용은 다음과 같다. 원본은 루트 노드를 만든 뒤에도 `ISNULL(pResult)`를 한 번 더 검사했다. 이미 앞에서 검사한 값이라 항상 거짓이며, 루트 노드 생성 실패를 잡지 못했다. 루트 노드 생성이 실패하면 `pRootNode`가 `NULL`인 채로 `tree`가 반환돼 이후 순회에서 오류가 났다. `ISNULL(pResult->pRootNode)`로 정정했다.

### 3-3. 자식 노드 추가

```c
node * addLeftChildNode(node * _pParent_, const char _cData_)
{
    node *pResult = NULL;
    if (ISNULL(_pParent_))
        return pResult;
    if (ISNULL(_pParent_->pLeftChild))
    {
        pResult = createNodeBinTree(_cData_);
        _pParent_->pLeftChild = pResult;
    }
    else
        printf("error, The node already exists. addLeftChildNode()\n");
    return pResult;
}

node * addRightChildNode(node * _pParent_, const char _cData_)
{
    node *pResult = NULL;
    if (ISNULL(_pParent_))
        return pResult;
    if (ISNULL(_pParent_->pRightChild))
    {
        pResult = createNodeBinTree(_cData_);
        _pParent_->pRightChild = pResult;
    }
    else
        printf("error, The node already exists. addRightChildNode()\n");
    return pResult;
}
```

* 추가한 자식 노드를 `pResult`로 반환한다. 반환된 노드에 이어서 그 자식을 추가할 수 있어 새 노드를 다시 찾는 작업을 줄인다.
* 정정 내용: `addRightChildNode`의 오류 메시지가 `addLeftChildNode()`로 적혀 있어 `addRightChildNode()`로 고쳤다.
* 반환값이 `NULL`이면 부모가 `NULL`이거나 이미 자식이 있거나 메모리 할당에 실패한 것이다. 세 경우를 반환값만으로 구분할 수 없다.

### 3-4. 그 외 연산

```c
node * getRootNode(const tree * _pBinTree_)
{
    node *pResult = NULL;
    if (ISNULL(_pBinTree_))
        return NULL;
    pResult = _pBinTree_->pRootNode;
    return pResult;
}

bool deleteBinTree(tree * _pBinTree_)
{
    if (ISNULL(_pBinTree_))
        return true;
    deleteBinTreeNode(_pBinTree_->pRootNode);
    free(_pBinTree_);
    return false;
}

bool deleteBinTreeNode(node * _pParent_)
{
    if (ISNULL(_pParent_))
        return true;
    deleteBinTreeNode(_pParent_->pLeftChild);
    deleteBinTreeNode(_pParent_->pRightChild);
    free(_pParent_);
    return false;
}
```

| 함수 | 설명 |
|---|---|
| `getRootNode()` | 인자로 받은 트리의 루트 노드를 반환한다 |
| `deleteBinTree()` | 트리 전체를 메모리에서 해제한다. 루트 기준으로 모든 후손 노드를 먼저 해제한 뒤 트리를 해제하려고 `deleteBinTreeNode()`를 호출한다 |
| `deleteBinTreeNode()` | 재귀 함수다. 왼쪽, 오른쪽 서브트리를 해제한 뒤 자기 자신을 해제한다(후위 순회). 인자가 `NULL`이면 재귀를 끝낸다 |

`deleteBinTreeNode()`는 재귀의 바닥(`NULL`)에서도 `true`를 반환하지만 호출부가 반환값을 쓰지 않는다. 호출 깊이는 트리의 높이와 같아서 한쪽으로 치우친 큰 트리에서는 스택이 넘칠 수 있다.

### 3-5. main()

```c
int main (int argc, char * argv[])
{
    tree *pTree = NULL;
    node *pNodeA = NULL;
    node *pNodeB = NULL;
    node *pNodeC = NULL;
    node *pNodeD = NULL;
    node *pNodeE = NULL;
    node *pNodeF = NULL;

    pTree = createBinTree('A');
    if (!ISNULL(pTree))
    {
        pNodeA = getRootNode(pTree);
        pNodeB = addLeftChildNode(pNodeA, 'B');
        pNodeC = addRightChildNode(pNodeA, 'C');
    }

    if (!ISNULL(pNodeB))
    {
        pNodeD = addLeftChildNode(pNodeB, 'D');
    }

    if (!ISNULL(pNodeC))
    {
        pNodeE = addLeftChildNode(pNodeC, 'E');
        pNodeF = addRightChildNode(pNodeC, 'F');
    }
    
    deleteBinTree(pTree);
    
    return 0;
}
```

이 `main()`은 지금까지의 함수로 문자를 트리에 저장한다. 만들어지는 트리는 다음과 같다.

```
      A
     / \
    B   C
   /   / \
  D   E   F
```

저장에는 문제가 없지만 트리 내용을 출력하는 함수가 없어 모양을 볼 수 없다. 내용을 출력하려면 순회 순서를 정해야 한다. 순회 함수는 4절에 있다. 사용하지 않는 `pNodeD`, `pNodeE`, `pNodeF`는 컴파일러가 미사용 변수 경고를 낼 수 있다.

## 4. 순회(Traversal)와 탐색

트리를 만드는 것보다 쓰는 것이 중요하다. 쓰려면 모든 노드를 한 번씩 방문하는 로직이 필요하다. 이 순회는 트리 내용 출력, 노드 개수 구하기 등 많은 알고리즘의 기반이며 힙과 그래프에서도 쓴다.

### 4-0. 순회 결과 비교

3-5절의 트리(A, B, C, D, E, F)를 순회한 결과다.

| 순회 | 방문 순서 | 결과 |
|---|---|---|
| 전위(Pre-order) | 현재 노드, 왼쪽, 오른쪽 | A B D C E F |
| 중위(In-order) | 왼쪽, 현재 노드, 오른쪽 | D B A E C F |
| 후위(Post-order) | 왼쪽, 오른쪽, 현재 노드 | D B E F C A |
| 너비 우선(Level order) | 레벨 순, 같은 레벨은 왼쪽부터 | A B C D E F |

| 항목 | 값 |
|---|---|
| 시간 복잡도 | O(n). 모든 노드를 한 번씩 방문한다 |
| 재귀 방식의 호출 깊이 | 트리의 높이. 균형이면 O(log n), 편향이면 O(n) |
| 너비 우선의 큐 크기 | 가장 넓은 레벨의 노드 수. 최대 O(n) |

{% hint style="info" %}
NOTE: 아래 스택·큐 코드는 `stack_Create`, `stack_Push`, `stack_Pop`, `stack_Peek`, `stack_Delete`, `pStack->nCurrentCount`와 `queue_Create`, `queue_enqueue`, `queue_dequeue`, `queue_Delete`, `pQueue->nCurrentCount`를 쓴다. 이 함수들은 이 문서에 없다. [연결 스택 구현 (MyStack.c)](../../reference-and-snippets/c-snippets/mystack.c.md)와 이름이 달라 그대로는 연결되지 않으므로 같은 이름의 스택·큐를 따로 구현하거나 이름을 맞춰야 한다. 원본에서 `binTree`, `binTreeNode`로 적혀 있던 타입은 3절의 `tree`, `node`로 통일했다.
{% endhint %}

### 4-1. 깊이 우선 탐색(DFS)

DFS는 서브트리의 방문 순서가 핵심이며 한 방향의 끝(리프)까지 내려갔다가 되돌아와 다른 방향을 탐색한다. 대표 순서가 전위·중위·후위 순회다. DFS의 원리, 스택과 재귀 방식, 복잡도는 [깊이 우선 탐색 (DFS)](../algorithms/depthfirstsearch.md)(PRG-ALG-002-DO)를 참조한다.

#### 전위 순회(Pre-order)

* 현재 노드를 가장 먼저 방문해 처리한 뒤 왼쪽 서브트리, 오른쪽 서브트리 순으로 이동한다.
* 처리 내용은 목적에 따라 다르다. 트리 내용을 출력하려면 현재 노드 방문 시 출력한다.
* 왼쪽 서브트리를 모두 처리하고 나면 호출이 돌아와 오른쪽 서브트리를 처리한다.
* 노드를 방문한 직후 처리하므로 트리를 복사하거나 구조를 그대로 저장할 때 쓴다.

<details>

<summary>전위 순회 코드</summary>

```c
// Pre-Order Traversal Func
bool traversalPreorder(tree *_pTree_)
{
    if (ISNULL_ERROR(_pTree_))
        return true;
    traversalPreorderBinTreeNode(_pTree_->pRootNode);
    printf("\n");
    return false;
}

bool traversalPreorderBinTreeNode(node *_pRootNode_)
{
    if (_pRootNode_ == NULL)
        return true;
    printf("%c ", _pRootNode_->cData);
    traversalPreorderBinTreeNode(_pRootNode_->pLeftChild);
    traversalPreorderBinTreeNode(_pRootNode_->pRightChild);
    return false;
}
```

```c
// Use Stack
bool traversalPreorder(tree *_pTree_)
{
    node *pNode = NULL;
    stack *pStack = NULL;
    if (ISNULL_ERROR(_pTree_))
        return true;

    pNode = _pTree_->pRootNode;
    if (ISNULL_ERROR(pNode))
        return true;

    pStack = stack_Create();
    if (ISNULL_ERROR(pStack))
        return true;

    stack_Push(pStack, (node *)pNode);
    while (pStack->nCurrentCount > 0)
    {
        pNode = (node *)stack_Pop(pStack);
        printf("%c ", pNode->cData);
        if (pNode->pRightChild != NULL)
            stack_Push(pStack, (node *)pNode->pRightChild);
        if (pNode->pLeftChild != NULL)
            stack_Push(pStack, (node *)pNode->pLeftChild);
    }
    printf("\n");
    stack_Delete(pStack);
    return false;
}
```

두 `traversalPreorder`는 이름이 같아 한 파일에 함께 둘 수 없다. 둘 중 하나만 쓰거나 이름을 바꾼다. 스택 방식은 오른쪽 자식을 먼저 넣어야 왼쪽 자식이 먼저 나온다.

</details>

#### 중위 순회(In-order)

* 왼쪽 서브트리를 모두 처리한 뒤 현재 노드를 처리하고 오른쪽 서브트리로 이동한다.
* 핵심은 현재 노드를 처리하기 전에 왼쪽 서브트리가 모두 처리돼야 한다는 점이다.
* 왼쪽 자식이 있으면 더 이상 없을 때까지 왼쪽으로 내려간다. 가장 왼쪽 노드를 처리한 뒤 그 부모를 처리하고 오른쪽 서브트리로 이동한다.
* 이진 검색 트리에서 키를 오름차순으로 얻는다.

<details>

<summary>중위 순회 코드</summary>

```c
// In-Order Traversal Func
bool traversalInorder(tree *_pTree_)
{
    if (ISNULL_ERROR(_pTree_))
        return true;
    traversalInorderBinTreeNode(_pTree_->pRootNode);
    printf("\n");
    return false;
}

bool traversalInorderBinTreeNode(node *_pRootNode_)
{
    if (_pRootNode_ == NULL)
        return true;
    traversalInorderBinTreeNode(_pRootNode_->pLeftChild);
    printf("%c ", _pRootNode_->cData);
    traversalInorderBinTreeNode(_pRootNode_->pRightChild);
    return false;
}
```

```c
// use stack
bool traversalInorder(tree *_pTree_)
{
    node *pNode = NULL;
    stack *pStack = NULL;
    if (ISNULL_ERROR(_pTree_))
        return true;

    pNode = _pTree_->pRootNode;
    if (ISNULL_ERROR(pNode))
        return true;

    pStack = stack_Create();
    if (ISNULL_ERROR(pStack))
        return true;

    while (pNode != NULL || pStack->nCurrentCount > 0)
    {
        // 왼쪽 리프 노드를 향해 이동
        while (pNode != NULL)
        {
            stack_Push(pStack, (node *)pNode);
            pNode = pNode->pLeftChild;
        }

        // pNode가 NULL이면 stack에서 pop
        pNode = (node *)stack_Pop(pStack);
        printf("%c ", pNode->cData);

        // 오른쪽 서브 트리로 이동
        pNode = pNode->pRightChild;
    }
    stack_Delete(pStack);
    printf("\n");
    return false;
}
```

</details>

#### 후위 순회(Post-order)

* 왼쪽 서브트리, 오른쪽 서브트리를 모두 처리한 뒤 현재 노드를 마지막에 처리한다.
* 왼쪽으로 계속 내려가는 점은 중위 순회와 같다. 왼쪽을 처리한 뒤 곧바로 현재 노드를 처리하지 않고 오른쪽 서브트리를 먼저 처리하는 점이 다르다.
* 자식을 먼저 처리하므로 트리를 해제하거나 표현식 트리를 계산할 때 쓴다.

<details>

<summary>후위 순회 코드</summary>

```c
// Post-Order Traversal Func
bool traversalPostorder(tree *_pTree_)
{
    if (ISNULL_ERROR(_pTree_))
        return true;
    traversalPostorderBinTreeNode(_pTree_->pRootNode);
    printf("\n");
    return false;
}

bool traversalPostorderBinTreeNode(node *_pRootNode_)
{
    if (_pRootNode_ == NULL)
        return true;
    traversalPostorderBinTreeNode(_pRootNode_->pLeftChild);
    traversalPostorderBinTreeNode(_pRootNode_->pRightChild);
    printf("%c ", _pRootNode_->cData);
    return false;
}
```

```c
// use stack
bool traversalPostorder(tree *_pTree_)
{
    node *pNode = NULL;
    stack *pStack = NULL;
    if (ISNULL_ERROR(_pTree_))
        return true;

    pNode = _pTree_->pRootNode;
    if (ISNULL_ERROR(pNode))
        return true;

    pStack = stack_Create();
    if (ISNULL_ERROR(pStack))
        return true;

    while (pNode != NULL || pStack->nCurrentCount > 0)
    {
        if (pNode != NULL)
        {
            if (pNode->pRightChild != NULL)
                stack_Push(pStack, (node *)pNode->pRightChild);
            stack_Push(pStack, (node *)pNode);
            pNode = pNode->pLeftChild;
        }
        else
        {
            pNode = (node *)stack_Pop(pStack);
            if (pStack->nCurrentCount > 0 && pNode->pRightChild == (node *)stack_Peek(pStack))
            {
                stack_Pop(pStack);
                stack_Push(pStack, (node *)pNode);
                pNode = pNode->pRightChild;
            }
            else
            {
                printf("%c ", pNode->cData);
                pNode = NULL;
            }
        }
    }

    printf("\n");
    stack_Delete(pStack);
    return false;
}
```

</details>

### 4-2. 너비 우선 탐색(BFS, 레벨 순회)

너비 우선 탐색은 레벨 순서로 트리를 순회한다. 낮은 레벨(루트에 가까운 쪽)에서 높은 레벨 순으로, 같은 레벨에서는 왼쪽에서 오른쪽 순으로 처리한다. 방문 순서를 관리하려고 큐(queue)를 쓴다.

{% stepper %}
{% step %}
### 시작: 루트 노드를 큐에 삽입

탐색을 시작할 루트 노드를 큐에 삽입한다.
{% endstep %}

{% step %}
### 반복: 큐가 빌 때까지

큐가 비어 있지 않은 동안 다음을 반복한다.

* 큐에서 노드를 하나 꺼낸다.
* 꺼낸 노드를 처리한다(기능 수행).
* 그 노드의 왼쪽 자식과 오른쪽 자식이 있으면 차례로 큐에 삽입한다.
{% endstep %}
{% endstepper %}

```c
// breadth-first search (level traversal)
bool BreadthFirstSearch(tree *_pTree_)
{
    node *pCurrentNode = NULL;
    queue *pQueue = NULL;
    if (ISNULL_ERROR(_pTree_))
        return true;

    pCurrentNode = _pTree_->pRootNode;
    if (ISNULL_ERROR(pCurrentNode))
        return true;

    pQueue = queue_Create();
    if (ISNULL_ERROR(pQueue))
        return true;
    
    while (pCurrentNode != NULL || pQueue->nCurrentCount > 0)
    {
        if (pQueue->nCurrentCount > 0)
        {
            pCurrentNode = (node *)queue_dequeue(pQueue);
            printf("%c ", pCurrentNode->cData);
            if (pCurrentNode->pLeftChild != NULL)
                queue_enqueue(pQueue, (node *)pCurrentNode->pLeftChild);
            if (pCurrentNode->pRightChild != NULL)
                queue_enqueue(pQueue, (node *)pCurrentNode->pRightChild);
        }
        else
            queue_enqueue(pQueue, (node *)pCurrentNode);
        pCurrentNode = NULL;
    }
    printf("\n");
    queue_Delete(pQueue);
    return false;
}
```

반복문의 첫 회전에서는 큐가 비어 있어 `else` 가지로 루트를 큐에 넣는다. 이후에는 큐에서 꺼내 처리한다. 루트를 반복문 앞에서 큐에 먼저 넣으면 `else` 가지와 `pCurrentNode` 변수 갱신이 필요 없다.

## 5. 한계와 주의

* 이 구현은 반환값 `NULL`로 오류를 알리는 함수가 많아 오류 원인을 구분하기 어렵다.
* 재귀 순회와 재귀 해제는 높이가 큰 편향 트리에서 호출 스택을 넘칠 수 있다.
* 노드 데이터가 `char` 하나라 예제가 단순하다. 다른 타입으로 쓰려면 `cData` 타입과 출력 서식(`%c`)을 함께 바꾼다.
* BST의 균형이 깨지면 연산이 O(n)이 된다. 균형 유지는 AVL, 레드 블랙 트리가 맡는다.

## 6. 참조

* [CompleteBinaryTree](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/CompleteBinaryTree.c)
* [ExBinaryTrees](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExBinarytrees.c)

## 7. 약어·용어

| 용어 | 뜻 |
|---|---|
| DFS | Depth-First Search. 깊이 우선 탐색 |
| BFS | Breadth-First Search. 너비 우선 탐색 |
| BST | Binary Search Tree. 이진 검색 트리 |
| ADT | Abstract Data Type. 추상 자료형 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 완전 이진 트리와 포화 이진 트리의 차이를 노드 수 예로 설명한다.
- [ ] 전위·중위·후위 순회를 세 노드(루트, 왼쪽 자식, 오른쪽 자식)로 직접 손으로 따라가 결과를 적는다.
- [ ] 재귀 방식 순회 대신 스택을 써야 하는 경우가 언제인지 적는다.
