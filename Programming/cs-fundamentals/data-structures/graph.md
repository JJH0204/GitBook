# [생성형 AI] 그래프 (Graph)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-009-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 그래프의 용어와 인접 행렬·인접 리스트 표현의 차이를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

그래프(graph)는 정점(vertex, node)과 정점을 잇는 간선(edge)의 집합으로 관계를 나타내는 비선형 자료구조다. 정점 수를 V, 간선 수를 E로 쓴다.

| 용어 | 뜻 |
|---|---|
| 무방향 그래프 | 간선에 방향이 없다. (u, v)와 (v, u)가 같다 |
| 방향 그래프 | 간선에 방향이 있다. u에서 v로만 갈 수 있다 |
| 가중치 그래프 | 간선에 비용(거리, 시간 등)이 붙는다 |
| 차수(degree) | 정점에 연결된 간선 수. 방향 그래프는 진입 차수와 진출 차수로 나눈다 |
| 경로 / 사이클 | 간선을 따라 이동하는 정점의 열 / 시작과 끝이 같은 경로 |
| 연결 그래프 | 모든 정점 쌍 사이에 경로가 있는 무방향 그래프 |

트리는 사이클이 없는 연결 무방향 그래프다. 즉 그래프의 특수한 경우다.

## 2. 표현 방법

| 항목 | 인접 행렬 | 인접 리스트 |
|---|---|---|
| 구조 | V x V 배열. `mat[u][v]`가 간선 유무(또는 가중치) | 정점마다 이웃 정점의 리스트 |
| 공간 | O(V^2) | O(V + E) |
| 간선 (u, v) 존재 확인 | O(1) | O(deg(u)) |
| 정점 u의 이웃 순회 | O(V) | O(deg(u)) |
| 적합한 경우 | 간선이 많은 밀집 그래프 | 간선이 적은 희소 그래프 |

간선이 적은 큰 그래프에서는 인접 행렬이 대부분 0으로 낭비된다. 이 문제는 [희소 행렬](set-sparse-matrix.md)과 같다.

## 3. 예제 코드 (C)

정점 0~4와 간선 (0,1) (0,2) (1,3) (2,3) (3,4)를 두 방식으로 저장한다.

{% code title="graph.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

#define N 5

typedef struct Edge { int to; struct Edge *next; } Edge;

static void addEdge(Edge *adj[], int u, int v) {   /* 무방향 */
	Edge *e = malloc(sizeof *e); e->to = v; e->next = adj[u]; adj[u] = e;
	e = malloc(sizeof *e);       e->to = u; e->next = adj[v]; adj[v] = e;
}

int main(void) {
	int mat[N][N] = {{0}};
	Edge *adj[N] = {0};
	int edges[][2] = {{0,1},{0,2},{1,3},{2,3},{3,4}};
	for (int i = 0; i < 5; i++) {
		int u = edges[i][0], v = edges[i][1];
		mat[u][v] = mat[v][u] = 1;
		addEdge(adj, u, v);
	}
	printf("adjacency matrix:\n");
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) printf("%d ", mat[i][j]);
		printf("\n");
	}
	printf("adjacency list:\n");
	for (int i = 0; i < N; i++) {
		printf("%d:", i);
		for (Edge *e = adj[i]; e; e = e->next) printf(" %d", e->to);
		printf("\n");
	}
	for (int i = 0; i < N; i++) {
		Edge *e = adj[i];
		while (e) { Edge *nx = e->next; free(e); e = nx; }
	}
	return 0;
}
```
{% endcode %}

실행 결과:

```
adjacency matrix:
0 1 1 0 0 
1 0 0 1 0 
1 0 0 1 0 
0 1 1 0 1 
0 0 0 1 0 
adjacency list:
0: 2 1
1: 3 0
2: 3 0
3: 4 2 1
4: 3
```

| 위치 | 설명 |
|---|---|
| `mat[u][v] = mat[v][u] = 1` | 무방향 그래프이므로 양쪽에 표시한다. 대칭 행렬이 된다 |
| `addEdge` | 새 노드를 리스트 앞에 붙이므로 이웃이 간선을 넣은 역순으로 나온다(O(1) 삽입). 이웃 순서는 알고리즘 결과에 영향을 줄 수 있다 |
| 마지막 `for`의 `free` | 리스트 노드를 모두 해제해 누수를 막는다 |

## 4. 탐색과의 연결

그래프를 다루는 기본 알고리즘은 탐색이다. [깊이 우선 탐색 (DFS)](../algorithms/depthfirstsearch.md)은 스택(또는 재귀)을, [너비 우선 탐색 (BFS)](../algorithms/breadth-first-search.md)은 [큐](queue.md)를 쓴다. 인접 리스트로 구현하면 둘 다 O(V + E)다. 가중치가 있는 최단 경로는 [다익스트라](../algorithms/dijkstra.md)로 푼다.

## 5. 한계와 주의

* 정점 번호가 0부터 연속된 정수가 아니면(문자열 등) 번호를 매기는 매핑이 따로 필요하다.
* 예제는 자기 자신으로 가는 간선(self-loop)과 중복 간선을 막지 않는다.
* 간선 (u, v)를 자주 확인하고 V가 작으면 인접 행렬이, 순회가 주 연산이면 인접 리스트가 낫다.

## 관련 문서

* [비선형 자료구조 (Non-linear)](non-linear-data-structure.md)
* [깊이 우선 탐색 (DFS)](../algorithms/depthfirstsearch.md)
* [너비 우선 탐색 (BFS)](../algorithms/breadth-first-search.md)
* [다익스트라 최단 경로 (Dijkstra)](../algorithms/dijkstra.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인접 행렬의 공간이 V^2인 이유를 쓰고, V가 10만이면 왜 문제가 되는지 계산한다.
- [ ] 방향 그래프로 바꾸면 `mat`과 `addEdge`가 어떻게 달라지는지 적는다.
- [ ] 트리가 그래프의 특수한 경우라는 말을 간선 수 E = V - 1 조건과 함께 설명한다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
