# 비선형 자료구조 (Non-linear)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-002-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 비선형 자료구조(트리, 그래프, 힙)의 정의, 표현 방법, 복잡도를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

비선형 자료구조(non-linear data structure)는 데이터가 한 줄로 순서대로 놓이지 않고 계층적 또는 망(network) 형태로 연결된 구조다. 한 요소가 여러 요소와 연결될 수 있다.

* 대표 구조는 트리(Tree)와 그래프(Graph)다.
* 연결 리스트(Linked List)는 요소가 한 줄로 이어지므로 선형 구조다.
* 해시 테이블(Hash Table)은 키로 위치를 계산하는 구조이며 선형·비선형 어느 쪽에도 속하지 않는 별도 분류로 보는 것이 일반적이다. 이 문서에서는 비교 목적으로만 표에 포함한다.

## 2. 구성 요소

| 자료구조 | 설명 | 특징 |
|---|---|---|
| 트리(Tree) | 계층적 구조를 가진 데이터 구조 | 부모-자식 관계, 사이클 없음 |
| 그래프(Graph) | 정점과 간선으로 이루어진 구조 | 복잡한 관계를 표현한다 |
| 힙(Heap) | 완전 이진 트리이면서 힙 속성(부모가 자식보다 크거나 같음, 또는 작거나 같음)을 만족하는 구조 | 최솟값 또는 최댓값을 O(1)에 조회한다 |
| 해시 테이블(Hash Table) | 키-값 쌍을 저장하고 해시 함수로 위치를 계산하는 구조 | 평균 O(1) 검색. 별도 분류 |

## 3. 트리(Tree)

트리는 루트에서 시작해 각 노드(Node)가 부모-자식 관계로 이어진 계층 구조다. 사이클이 없는 연결 그래프이며 DFS, BFS로 탐색한다.

### 3-1. 주요 용어

| 용어 | 설명 |
|---|---|
| 루트 노드 (Root Node) | 트리의 최상위 노드 |
| 부모 노드 (Parent Node) | 특정 노드를 직접 연결하는 상위 노드 |
| 자식 노드 (Child Node) | 특정 노드에 연결된 하위 노드 |
| 형제 노드 (Sibling Node) | 같은 부모를 가진 노드 |
| 잎 노드 (Leaf Node) | 자식이 없는 노드 |
| 깊이 (Depth) | 루트에서 특정 노드까지의 거리(간선 수) |
| 높이 (Height) | 트리의 최대 깊이 |

{% hint style="info" %}
NOTE: 높이의 기준은 문서마다 다르다. 이 문서는 루트의 깊이를 0으로 보는 간선 수 기준이다. [이진 트리 (Binary Tree)](binarytrees_kr.md)(PRG-DST-001-DO)는 루트 하나만 있는 트리의 높이를 1로 센다. 노드 수 범위 공식을 쓸 때는 기준을 확인한다.
{% endhint %}

### 3-2. 트리의 종류

| 트리 유형 | 설명 |
|---|---|
| 이진 트리(Binary Tree) | 각 노드가 최대 2개의 자식을 가진다 |
| 이진 탐색 트리(BST) | 왼쪽 서브트리의 모든 키는 노드보다 작고, 오른쪽 서브트리의 모든 키는 노드보다 크다 |
| AVL 트리 | 높이 균형을 유지하는 BST |
| 힙(Heap) | 완전 이진 트리 + 힙 속성 |
| 트라이(Trie) | 문자열 검색에 최적화된 트리 |

### 3-3. 이진 트리 예제 (C)

{% code title="binary_tree.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

// 노드 구조체 정의
typedef struct Node {
    int data;
    struct Node* left;
    struct Node* right;
} Node;

// 새 노드 생성 함수
Node* createNode(int data) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    if (newNode == NULL)
        return NULL;
    newNode->data = data;
    newNode->left = newNode->right = NULL;
    return newNode;
}

// 이진 트리 생성 예제
int main() {
    Node* root = createNode(10);
    if (root == NULL)
        return 1;
    root->left = createNode(5);
    root->right = createNode(15);

    printf("Root: %d\n", root->data);
    printf("Left Child: %d\n", root->left->data);
    printf("Right Child: %d\n", root->right->data);

    free(root->left);
    free(root->right);
    free(root);
    return 0;
}
```
{% endcode %}

정정 내용은 다음과 같다. 원본에는 `malloc` 반환값 검사와 `free`가 없었다. `createNode`의 NULL 검사와 `main` 끝의 `free` 3줄을 추가했다. 이 예제는 자식 `createNode`의 반환값을 검사하지 않으므로, 메모리가 부족하면 `root->left->data`에서 NULL을 역참조할 수 있다. 실제 코드에서는 자식 생성 후에도 검사한다.

BST 탐색은 평균 O(log n)이다. 입력이 정렬된 순서로 삽입되는 등 트리가 한쪽으로 치우치면 O(n)이 된다. AVL 같은 균형 트리는 O(log n)을 보장한다.

## 4. 그래프(Graph)

그래프는 정점(Vertex, Node)과 간선(Edge)으로 이루어진 구조다. 선형 구조보다 자유로운 관계를 표현한다. DFS, BFS로 탐색하고, 최단 경로 알고리즘(다익스트라, A\*)에 쓴다.

### 4-1. 주요 용어

| 용어 | 설명 |
|---|---|
| 정점(Vertex, Node) | 그래프에서 데이터를 저장하는 요소 |
| 간선(Edge) | 정점 간의 연결 |
| 무방향 그래프(Undirected Graph) | 간선이 방향을 가지지 않는 그래프 |
| 방향 그래프(Directed Graph) | 간선이 특정 방향을 가지는 그래프 |
| 방향 비순환 그래프(DAG, Directed Acyclic Graph) | 방향 그래프 중 사이클이 없는 그래프. 방향 그래프와 같은 말이 아니다 |
| 가중 그래프(Weighted Graph) | 간선에 가중치(비용)가 있는 그래프 |

### 4-2. 표현 방법

| 표현 방식 | 설명 | 공간 복잡도 | 알맞은 경우 |
|---|---|---|---|
| 인접 행렬(Adjacency Matrix) | 2차원 배열로 연결 관계를 표현한다 | O(V²) | 간선이 많은 밀집 그래프, 두 정점의 연결을 O(1)에 확인할 때 |
| 인접 리스트(Adjacency List) | 정점마다 이웃을 리스트로 저장한다 | O(V + E) | 간선이 적은 희소 그래프 |

### 4-3. 인접 행렬 구현 (C)

{% code title="graph_adjmatrix.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

// 정점 개수
#define V 5

// 그래프 구조체 정의
typedef struct Graph {
    int adjMatrix[V][V];
} Graph;

// 그래프 초기화
void initGraph(Graph* g) {
    for (int i = 0; i < V; i++)
        for (int j = 0; j < V; j++)
            g->adjMatrix[i][j] = 0;
}

// 간선 추가 함수
void addEdge(Graph* g, int src, int dest) {
    if (src < 0 || src >= V || dest < 0 || dest >= V)
        return;
    g->adjMatrix[src][dest] = 1;
    g->adjMatrix[dest][src] = 1;  // 무방향 그래프
}

// 그래프 출력 함수
void printGraph(Graph* g) {
    for (int i = 0; i < V; i++) {
        for (int j = 0; j < V; j++) {
            printf("%d ", g->adjMatrix[i][j]);
        }
        printf("\n");
    }
}

// 메인 함수
int main() {
    Graph g;
    initGraph(&g);
    addEdge(&g, 0, 1);
    addEdge(&g, 1, 2);
    addEdge(&g, 2, 3);

    printGraph(&g);
    return 0;
}
```
{% endcode %}

* 정정 내용: `addEdge`에 정점 번호 범위 검사를 추가했다. 범위 검사가 없으면 배열 밖에 쓰는 정의되지 않은 동작(UB)이 된다.
* 이 예제의 간선은 `0-1`, `1-2`, `2-3`이며 정점 4는 연결되지 않는다.
* 이 문서에는 인접 리스트 코드가 없다.

## 5. 비교

| 자료구조 | 특징 | 탐색 시간 복잡도 |
|---|---|---|
| 일반 트리 | 계층 구조, 부모-자식 관계 | 임의 값 찾기 O(n) |
| 이진 탐색 트리 | 정렬된 계층 구조 | 평균 O(log n), 치우치면 O(n). 균형 트리는 O(log n) 보장 |
| 그래프 | 복잡한 연결 관계 | 전체 순회 O(V + E) (인접 리스트) |
| 힙 | 최솟값 또는 최댓값을 루트에 둔다 | 최솟값(최댓값) 조회 O(1), 삽입·삭제 O(log n), 임의 값 찾기 O(n) |
| 해시 테이블 | 키-값 매핑 | 평균 O(1), 최악 O(n) |

{% hint style="info" %}
NOTE: 힙은 우선순위 큐 구현에 쓴다. 완전 이진 트리이므로 배열로 저장할 수 있다.
{% endhint %}

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| V, E | 정점 수, 간선 수 |
| DAG | 방향 비순환 그래프 |
| BST | 이진 탐색 트리 |
| UB | 정의되지 않은 동작(undefined behavior) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 트리를 그래프의 특수한 경우라고 부르는 이유를 적는다.
- [ ] 인접 행렬과 인접 리스트 중 어느 쪽을 쓸지 정했던 경험이나 상황을 하나 적는다.
- [ ] BST가 한쪽으로 치우치면 왜 O(n)이 되는지 설명한다.
