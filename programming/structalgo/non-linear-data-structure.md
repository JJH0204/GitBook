# 비선형 자료 구조(Non-Linear Data Structure)

## **비선형 자료 구조(Non-Linear Data Structure)란?**

- **데이터가 순차적으로 저장되지 않고, 계층적 또는 네트워크 형태로 연결된 구조**
- **데이터 간의 관계가 단순한 선형이 아닌, 여러 방향으로 연결될 수 있는 구조**

✔ **데이터 간 관계가 복잡하며, 트리(Tree)와 그래프(Graph) 등이 대표적인 비선형 자료 구조**

✔ **데이터의 탐색 및 검색 속도가 효율적이며, 특정 연산에 강점이 있음**

✔ **연결 리스트(Linked List), 해시 테이블(Hash Table)도 일부 비선형적 특성을 가짐**

## **비선형 자료 구조의 종류**

| **자료 구조 유형**           | **설명**                | **특징**               |
| ---------------------- | --------------------- | -------------------- |
| **트리(Tree)**           | 계층적 구조를 가진 데이터 구조     | 부모-자식 관계, 계층적 탐색     |
| **그래프(Graph)**         | 노드와 엣지를 기반으로 한 데이터 구조 | 복잡한 관계 표현 가능         |
| **힙(Heap)**            | 우선순위를 가지는 이진 트리       | 최소/최대 값을 빠르게 찾을 수 있음 |
| **해시 테이블(Hash Table)** | 키-값 쌍으로 데이터를 저장하는 구조  | 빠른 검색 속도 (O(1))      |

✔ **트리는 부모-자식 관계를 기반으로 한 구조이며, 그래프는 더 자유로운 관계를 가질 수 있음**

✔ **비선형 자료 구조는 탐색, 검색, 정렬, 최단 경로 등의 다양한 연산에 강점이 있음**

---

## **트리(Tree)**

트리는 **계층적(Hierarchical) 구조를 가진 자료 구조**로,

각 노드(Node)가 **부모-자식 관계(Parent-Child Relationship)**를 가짐.

  

✔ **루트(Root) 노드에서 시작하여 계층적으로 연결됨**

✔ **사이클(Cycle)이 없는 그래프 형태**

✔ **DFS, BFS 탐색 알고리즘을 사용할 수 있음**

**트리(Tree)의 주요 용어**

| **용어**                   | **설명**               |
| ------------------------ | -------------------- |
| **루트 노드 (Root Node)**    | 트리의 최상위 노드           |
| **부모 노드 (Parent Node)**  | 특정 노드를 직접 연결하는 상위 노드 |
| **자식 노드 (Child Node)**   | 특정 노드에 연결된 하위 노드     |
| **형제 노드 (Sibling Node)** | 같은 부모를 가진 노드         |
| **잎 노드 (Leaf Node)**     | 자식이 없는 노드            |
| **깊이 (Depth)**           | 루트에서 특정 노드까지의 거리     |
| **높이 (Height)**          | 트리의 최대 깊이            |

**트리(Tree)의 종류**

|**트리 유형**|**설명**|
|---|---|
|**이진 트리(Binary Tree)**|각 노드가 최대 2개의 자식을 가질 수 있음|
|**이진 탐색 트리(BST, Binary Search Tree)**|왼쪽 자식은 부모보다 작고, 오른쪽 자식은 부모보다 큼|
|**AVL 트리(AVL Tree)**|BST의 균형을 유지하는 트리 (균형 트리)|
|**힙(Heap)**|최소값 또는 최대값을 빠르게 찾을 수 있는 이진 트리|
|**트라이(Trie)**|문자열 검색에 최적화된 트리 구조|

🔹 **이진 트리 예제 (C)**

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
    newNode->data = data;
    newNode->left = newNode->right = NULL;
    return newNode;
}

// 이진 트리 생성 예제
int main() {
    Node* root = createNode(10);
    root->left = createNode(5);
    root->right = createNode(15);

    printf("Root: %d\n", root->data);
    printf("Left Child: %d\n", root->left->data);
    printf("Right Child: %d\n", root->right->data);

    return 0;
}
```

✔ **이진 탐색 트리는 데이터 검색이 빠름 (O(log n))**

❌ **트리의 균형이 맞지 않으면 O(n)의 성능을 가질 수 있음**

---

## **그래프(Graph)**

**그래프(Graph) 개념**

그래프는 **노드(Node, Vertex)와 간선(Edge)으로 이루어진 자료 구조**로,

**복잡한 관계를 표현할 때 사용됨**.

✔ **선형 자료 구조보다 더 자유로운 데이터 관계 표현 가능**

✔ **DFS, BFS를 이용한 탐색 가능**

✔ _최단 경로 탐색 알고리즘 (다익스트라, A) 등에서 활용_*

**그래프의 주요 용어**

|**용어**|**설명**|
|---|---|
|**정점(Vertex, Node)**|그래프에서 데이터를 저장하는 요소|
|**간선(Edge)**|정점 간의 연결|
|**무방향 그래프(Undirected Graph)**|간선이 방향을 가지지 않는 그래프|
|**유방향 그래프(Directed Graph, DAG)**|간선이 특정 방향을 가지는 그래프|
|**가중 그래프(Weighted Graph)**|간선에 가중치(비용)가 있는 그래프|

**그래프의 표현 방법**

|**그래프 표현 방식**|**설명**|**공간 복잡도**|
|---|---|---|
|**인접 행렬(Adjacency Matrix)**|2차원 배열을 이용하여 연결 관계를 표현|**O(V²)**|
|**인접 리스트(Adjacency List)**|연결된 노드를 리스트로 저장|**O(V + E)**|

🔹 **그래프 인접 리스트 구현 (C)**

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

✔ **그래프는 네트워크, 소셜 네트워크, 경로 탐색 등에 많이 사용됨**

❌ **그래프의 복잡성이 증가할수록 탐색 속도가 느려질 수 있음**

---

## **비선형 자료 구조 비교**

| **자료 구조**              | **특징**            | **탐색 시간 복잡도**   |
| ---------------------- | ----------------- | --------------- |
| **트리(Tree)**           | 계층적 구조, 부모-자식 관계  | O(log n) ~ O(n) |
| **그래프(Graph)**         | 복잡한 연결 관계 표현 가능   | O(V + E)        |
| **힙(Heap)**            | 최소/최대 값을 빠르게 찾음   | O(log n)        |
| **해시 테이블(Hash Table)** | 키-값 매핑으로 빠른 검색 가능 | O(1)            |
