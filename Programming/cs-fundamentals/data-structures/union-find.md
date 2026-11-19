# [생성형 AI] 유니온 파인드 (Union-Find)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-011-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 서로소 집합 자료구조의 find·union 연산, 경로 압축, 랭크 기반 합치기를 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

유니온 파인드(union-find), 또는 서로소 집합(disjoint set) 자료구조는 겹치지 않는 집합들을 관리하며 다음 두 연산을 제공한다.

| 연산 | 동작 |
|---|---|
| find(x) | x가 속한 집합의 대표 원소(루트)를 반환한다 |
| union(a, b) | a와 b가 속한 두 집합을 하나로 합친다 |

두 원소가 같은 집합인지는 `find(a) == find(b)`로 확인한다. 그래프에서 연결 여부 판단, 사이클 검출, 크루스칼 최소 신장 트리 알고리즘에 쓴다.

## 2. 동작 원리

각 집합을 트리로 표현하고 `parent[i]`에 부모를 저장한다. 루트는 `parent[i] == i`다.

* find는 부모를 따라 루트까지 올라간다. 트리가 길면 느리다.
* **경로 압축(path compression)**: find 중에 지나친 모든 노드를 루트에 직접 연결해 다음 find를 짧게 만든다.
* **랭크 기반 합치기(union by rank)**: 합칠 때 높이가 낮은 트리를 높은 트리 아래에 붙여 높이 증가를 막는다.

두 기법을 함께 쓰면 연산 한 번의 분할상환 시간이 O(α(n))이다. α는 역아커만 함수로 현실적인 모든 n에서 5 이하라서 사실상 상수로 본다. 어느 하나만 써도 평균적으로 충분히 빠르다.

## 3. 예제 코드 (C)

{% code title="union_find.c" %}
```c
#include <stdio.h>

#define N 8
static int parent[N], rnk[N];

void init(void) { for (int i = 0; i < N; i++) { parent[i] = i; rnk[i] = 0; } }

int find(int x) {
	if (parent[x] != x) parent[x] = find(parent[x]);   /* 경로 압축 */
	return parent[x];
}

int unite(int a, int b) {
	int ra = find(a), rb = find(b);
	if (ra == rb) return 0;                            /* 이미 같은 집합 */
	if (rnk[ra] < rnk[rb]) { int t = ra; ra = rb; rb = t; }
	parent[rb] = ra;                                   /* 랭크가 작은 쪽을 아래로 */
	if (rnk[ra] == rnk[rb]) rnk[ra]++;
	return 1;
}

int main(void) {
	init();
	printf("unite(0,1)=%d\n", unite(0, 1));
	printf("unite(2,3)=%d\n", unite(2, 3));
	printf("unite(1,3)=%d\n", unite(1, 3));
	printf("unite(0,2)=%d\n", unite(0, 2));
	printf("same(0,3)=%d same(0,4)=%d\n", find(0) == find(3), find(0) == find(4));
	return 0;
}
```
{% endcode %}

실행 결과:

```
unite(0,1)=1
unite(2,3)=1
unite(1,3)=1
unite(0,2)=0
same(0,3)=1 same(0,4)=0
```

| 위치 | 설명 |
|---|---|
| `parent[x] = find(parent[x])` | 재귀로 루트를 찾아 오는 길의 모든 노드를 루트에 직접 연결한다(경로 압축) |
| `rnk` | 트리 높이의 상한 추정치다. 경로 압축 후에는 실제 높이와 다를 수 있다 |
| `unite`의 반환값 | 이미 같은 집합이면 0이다. `unite(0,2)`는 앞선 합치기로 이미 연결돼 0을 반환한다 |
| 별도 `printf` 4줄 | 함수 인자와 `printf` 인자의 평가 순서는 C에서 규정되지 않으므로, 부작용이 있는 `unite`를 한 문장에 여러 번 쓰지 않고 줄마다 호출한다 |

## 4. 한계와 주의

* 집합을 합치기만 한다. 한 원소를 집합에서 빼는 연산은 지원하지 않는다.
* 재귀 find는 경로 압축 없이 한 줄로 늘어난 트리에서 호출 깊이가 클 수 있다. 랭크로 합치면 높이가 O(log n)으로 제한되어 문제가 되지 않는다.
* 원소는 0부터 시작하는 정수 번호여야 한다.

## 관련 문서

* [그래프 (Graph)](graph.md)
* [탐욕법 (Greedy)](../algorithms/greedy.md): 크루스칼 알고리즘이 탐욕 선택을 쓴다
* [비선형 자료구조 (Non-linear)](non-linear-data-structure.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 경로 압축 없이 find만 쓰면 최악에 왜 O(n)이 되는지 예를 든다.
- [ ] 원소 6개에서 `unite(0,1)`, `unite(2,3)`, `unite(0,2)` 후 `parent` 배열을 손으로 추적한다.
- [ ] 무방향 그래프의 사이클을 유니온 파인드로 검출하는 방법을 말로 설명한다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
