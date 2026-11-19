# [생성형 AI] 해시 테이블 (Hash Table)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-007-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 해시 테이블의 원리, 충돌 처리, 복잡도를 체이닝 구현으로 설명한다 |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 검증(gcc로 실행). 아래 C 코드를 `gcc -Wall -Wextra -fsanitize=address,undefined`로 컴파일해 경고·오류 없이 실행했고 출력 예와 일치함을 확인했다. 복잡도·성질 설명은 일반 지식이다 |
| 개정 | R1 (2026-11-19) |

## 1. 정의

해시 테이블(hash table)은 키(key)를 해시 함수에 넣어 얻은 값으로 저장 위치(버킷)를 정하는 키-값 자료구조다. 키로 위치를 바로 계산하므로 평균적으로 삽입·검색·삭제가 O(1)이다.

## 2. 동작 원리

1. 해시 함수 `h(key)`가 키를 정수로 바꾼다.
2. `h(key) % 버킷 수`로 버킷 인덱스를 구한다.
3. 그 버킷에 키-값을 저장하거나 찾는다.

서로 다른 키가 같은 버킷에 배정되는 일을 **충돌(collision)**이라 한다. 버킷 수보다 키가 많으면 충돌은 피할 수 없다. 대표 처리 방식은 둘이다.

| 방식 | 내용 | 특징 |
|---|---|---|
| 체이닝(separate chaining) | 버킷마다 연결 리스트를 두고 충돌한 항목을 이어 붙인다 | 구현이 단순하고 삭제가 쉽다. 포인터 비용이 든다 |
| 개방 주소법(open addressing) | 충돌하면 다른 빈 버킷을 정해진 순서로 찾아 저장한다(선형 탐사 등) | 메모리가 연속이라 캐시에 유리하다. 삭제 처리가 까다롭고 가득 찰수록 느려진다 |

## 3. 복잡도

| 연산 | 평균 | 최악 | 비고 |
|---|---|---|---|
| 삽입 | O(1) | O(n) | 모든 키가 한 버킷에 몰리면 O(n) |
| 검색 | O(1) | O(n) | 같은 이유 |
| 삭제 | O(1) | O(n) | 같은 이유 |
| 공간 | O(n + 버킷 수) | | |

평균 O(1)은 해시 함수가 키를 고르게 퍼뜨린다는 가정에 기대며, 적재율(키 수 / 버킷 수)이 커지면 체인이 길어진다. 실제 라이브러리는 적재율이 기준을 넘으면 버킷 수를 늘리고 다시 배치(rehash)한다. 아래 예제는 이 확장을 구현하지 않았다.

## 4. 예제 코드 (C, 체이닝)

{% code title="hash.c" %}
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUCKETS 5

typedef struct Node {
	char *key;
	int value;
	struct Node *next;
} Node;

typedef struct { Node *bucket[BUCKETS]; } HashTable;

/* djb2 문자열 해시 */
static unsigned long hashStr(const char *s) {
	unsigned long h = 5381;
	for (; *s; s++) h = h * 33 + (unsigned char)*s;
	return h;
}

void put(HashTable *t, const char *key, int value) {
	unsigned long i = hashStr(key) % BUCKETS;
	for (Node *n = t->bucket[i]; n; n = n->next) {
		if (strcmp(n->key, key) == 0) { n->value = value; return; }
	}
	Node *n = malloc(sizeof *n);
	n->key = malloc(strlen(key) + 1);
	strcpy(n->key, key);
	n->value = value;
	n->next = t->bucket[i];
	t->bucket[i] = n;
}

int get(const HashTable *t, const char *key, int *out) {
	for (Node *n = t->bucket[hashStr(key) % BUCKETS]; n; n = n->next) {
		if (strcmp(n->key, key) == 0) { *out = n->value; return 1; }
	}
	return 0;
}

void freeTable(HashTable *t) {
	for (int i = 0; i < BUCKETS; i++) {
		Node *n = t->bucket[i];
		while (n) { Node *nx = n->next; free(n->key); free(n); n = nx; }
		t->bucket[i] = NULL;
	}
}

int main(void) {
	HashTable t = {0};
	const char *keys[] = {"apple", "banana", "cherry", "date", "elder", "fig", "grape"};
	for (int i = 0; i < 7; i++) put(&t, keys[i], i * 10);
	put(&t, "apple", 999);
	for (int i = 0; i < BUCKETS; i++) {
		printf("bucket %d:", i);
		for (Node *n = t.bucket[i]; n; n = n->next) printf(" (%s,%d)", n->key, n->value);
		printf("\n");
	}
	int v;
	printf("apple -> %d\n", get(&t, "apple", &v) ? v : -1);
	printf("kiwi -> %s\n", get(&t, "kiwi", &v) ? "found" : "none");
	freeTable(&t);
	return 0;
}
```
{% endcode %}

실행 결과:

```
bucket 0: (banana,10)
bucket 1: (cherry,20)
bucket 2: (elder,40) (apple,999)
bucket 3: (fig,50) (date,30)
bucket 4: (grape,60)
apple -> 999
kiwi -> none
```

버킷 5개에 키 7개를 넣어 충돌이 일어나고(버킷 2, 3), 같은 키 `apple`을 다시 넣으면 값만 갱신됨을 출력으로 확인할 수 있다.

| 위치 | 설명 |
|---|---|
| `hashStr` | djb2 문자열 해시(`h = h * 33 + c`, 초깃값 5381). 학습용으로 널리 알려진 간단한 함수이며 보안용이 아니다 |
| `put`의 앞쪽 `for` | 같은 키가 이미 있으면 값을 덮어쓴다 |
| `malloc`한 키 복사 | 호출자의 문자열 수명과 무관하게 키를 보관한다. `freeTable`에서 `key`와 노드를 모두 해제한다 |

## 5. 한계와 주의

* 키의 순서를 유지하지 않는다. 정렬된 순회나 범위 검색이 필요하면 [이진 탐색 트리](binary-search-tree.md) 같은 구조를 쓴다.
* 해시 함수가 나쁘면 한 버킷에 몰려 O(n)이 된다. 입력을 공격자가 고를 수 있는 환경에서는 충돌을 유도한 서비스 거부 사례가 알려져 있어, 언어 런타임은 무작위 시드를 쓰는 해시를 쓰기도 한다.
* 해시 테이블용 해시 함수와 암호학적 해시(무결성·비밀번호 저장용)는 목적이 다르다. 후자는 [해싱 (Hashing)](../../cs_basics/data_representation/hashing-and-checksums/hashing.md) 문서를 본다.
* 키로 쓰는 값은 저장 중에 바뀌면 안 된다. Python에서 리스트를 딕셔너리 키로 쓸 수 없는 이유다([Python 컬렉션](../../languages/python/python-collections.md) 참고).

## 관련 문서

* [비선형 자료구조 (Non-linear)](non-linear-data-structure.md): 해시 테이블의 분류
* [해싱 (Hashing)](../../cs_basics/data_representation/hashing-and-checksums/hashing.md)
* [Python 컬렉션 (Collections)](../../languages/python/python-collections.md): `dict`, `set`이 해시 테이블 기반

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 체이닝과 개방 주소법의 차이를 충돌이 일어난 상황을 그려 설명한다.
- [ ] 버킷 수를 5에서 7로 바꾸면 위 출력이 어떻게 달라지는지 예상한 뒤 실행해 비교한다.
- [ ] 평균 O(1)과 최악 O(n)이 갈리는 조건을 적는다.

## 개정 이력

| 개정 | 날짜 | 내용 |
|---|---|---|
| R1 | 2026-11-19 | 생성형 AI 초안 작성. 사람 검토 전 |
