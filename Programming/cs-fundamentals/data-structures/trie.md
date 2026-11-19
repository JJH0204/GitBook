# [생성형 AI] 트라이 (Trie)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-013-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 문자열을 글자 단위 경로로 저장하는 트라이의 원리, 복잡도, C 구현을 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

트라이(trie, 접두사 트리)는 문자열의 글자를 간선으로 삼아 루트에서 내려가는 경로에 문자열을 저장하는 트리다. 같은 접두사를 가진 문자열은 경로의 앞부분을 공유한다. 문자열이 끝나는 노드에 끝 표시(`isEnd`)를 둔다.

## 2. 동작 원리

`car`, `card`, `cat`을 넣으면 `c - a`까지가 공유되고 그 아래에서 갈라진다.

```
root
 └ c
    └ a
       ├ r (끝)
       │  └ d (끝)
       └ t (끝)
```

| 연산 | 동작 | 시간 복잡도 |
|---|---|---|
| 삽입 | 글자를 따라 내려가며 없는 노드를 만든다 | O(L) |
| 탐색 | 글자를 따라 내려가 끝 표시를 확인한다 | O(L) |
| 접두사 검사 | 접두사 경로가 존재하는지만 확인한다 | O(L) |
| 공간 | 노드 수 × 자식 포인터 수(알파벳 크기) | 최악 O(N·L·A) |

L은 문자열 길이, N은 문자열 개수, A는 알파벳 크기(여기서는 26)다. 시간은 저장된 문자열 수 N과 무관하고 질의 문자열 길이에만 비례한다.

## 3. 예제 코드 (C, 소문자 a~z 트라이)

{% code title="trie.c" %}
```c
#include <stdio.h>
#include <stdlib.h>

typedef struct Node {
	struct Node *next[26];
	int isEnd;
} Node;

Node *newNode(void) {
	return calloc(1, sizeof(Node));          /* 포인터를 모두 NULL로 시작 */
}

void insert(Node *root, const char *s) {
	Node *cur = root;
	for (; *s; s++) {
		int i = *s - 'a';                     /* 소문자 a~z만 입력한다고 가정 */
		if (!cur->next[i]) cur->next[i] = newNode();
		cur = cur->next[i];
	}
	cur->isEnd = 1;
}

static Node *walk(Node *root, const char *s) {
	Node *cur = root;
	for (; *s && cur; s++) cur = cur->next[*s - 'a'];
	return cur;
}

int contains(Node *root, const char *s) {
	Node *n = walk(root, s);
	return n && n->isEnd;
}

int startsWith(Node *root, const char *prefix) {
	return walk(root, prefix) != NULL;
}

void freeTrie(Node *n) {
	if (!n) return;
	for (int i = 0; i < 26; i++) freeTrie(n->next[i]);
	free(n);
}

int main(void) {
	Node *root = newNode();
	insert(root, "car");
	insert(root, "card");
	insert(root, "cat");
	printf("contains car  : %d\n", contains(root, "car"));
	printf("contains ca   : %d\n", contains(root, "ca"));
	printf("contains cart : %d\n", contains(root, "cart"));
	printf("startsWith ca : %d\n", startsWith(root, "ca"));
	printf("startsWith do : %d\n", startsWith(root, "do"));
	freeTrie(root);
	return 0;
}
```
{% endcode %}

실행 결과:

```
contains car  : 1
contains ca   : 0
contains cart : 0
startsWith ca : 1
startsWith do : 0
```

| 위치 | 설명 |
|---|---|
| `calloc(1, sizeof(Node))` | 자식 포인터를 모두 NULL로, `isEnd`를 0으로 초기화한다 |
| `contains`와 `startsWith` | 같은 `walk`를 쓰되 `contains`만 `isEnd`를 확인한다. `ca`는 접두사이지만 저장된 단어는 아니다 |
| `freeTrie` | 후위 순서로 자식을 먼저 해제해 메모리 누수를 막는다 |

## 4. 한계와 주의

* 이 코드는 입력이 `a`~`z`라고 가정한다. 다른 글자가 들어오면 배열 범위를 벗어나므로 실제 사용 전에 입력을 검사하거나 알파벳 크기를 넓힌다.
* 노드마다 포인터 26개를 가져 메모리를 많이 쓴다. 알파벳이 크면 해시 맵이나 정렬된 자식 목록으로 자식을 저장한다.
* 자동 완성, 사전 검색, 접두사 개수 세기에 적합하다. 단순 포함 검사만 필요하면 [해시 테이블](hash-table.md)이 더 작고 빠르다.

## 관련 문서

* [이진 탐색 트리 (BST)](binary-search-tree.md)
* [해시 테이블 (Hash Table)](hash-table.md)
* [비선형 자료구조 (Non-linear)](non-linear-data-structure.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 트라이의 탐색 시간이 저장된 문자열 수와 무관한 이유를 설명한다.
- [ ] `contains("ca")`가 0이고 `startsWith("ca")`가 1인 이유를 적는다.
- [ ] 해시 테이블 대신 트라이를 쓰는 경우를 예로 든다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
