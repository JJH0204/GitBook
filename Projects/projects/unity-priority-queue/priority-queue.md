# 이진 힙 우선순위 큐 해체

## 무엇을 하는가

우선순위 큐는 "넣은 순서와 상관없이, 가장 우선순위가 높은 것부터 꺼내는" 큐다. 레포의 `PriorityQueue<TElement>`는 배열(`List`) 기반 이진 힙으로 이를 구현한다. 요소와 정수 우선순위를 한 쌍으로 저장하고, 비교 방식은 생성자에 델리게이트로 받는다.

## 자료구조: 배열 기반 이진 힙

이진 힙은 완전 이진 트리를 배열에 층 순서대로 담은 구조다. 부모는 자식보다 항상 우선이다(최소 힙이면 부모 값이 자식 값보다 작거나 같다). 형제끼리는 순서 규칙이 없다.

0부터 시작하는 인덱스 `i`에서 다음 식이 성립한다.

| 관계 | 식 |
|---|---|
| 부모 | `(i - 1) / 2` (정수 나눗셈) |
| 왼쪽 자식 | `2i + 1` |
| 오른쪽 자식 | `2i + 2` |

```text
인덱스:  0   1   2   3   4   5
값   :  [1] [3] [2] [7] [4] [5]

        1
      /   \
     3     2
    / \   /
   7   4 5
```

핵심 연산은 두 가지다.

- **삽입 시 위로 올리기(sift-up):** 배열 끝에 넣고, 부모보다 우선이면 부모와 자리를 바꾸며 위로 올라간다.
- **삭제 시 아래로 내리기(sift-down):** 루트를 꺼내고, 마지막 요소를 루트에 올린 뒤 더 우선인 자식과 자리를 바꾸며 내려간다.

| 연산 | 시간 복잡도 | 이유 |
|---|---|---|
| 삽입 (`Enqueue`) | O(log n) | 트리 높이만큼 위로 올림 |
| 삭제 (`Dequeue`) | O(log n) | 트리 높이만큼 아래로 내림 |
| 조회 (`Peek`) | O(1) | 루트는 항상 `[0]` |

높이가 log n인 이유는 완전 이진 트리라서 층마다 노드 수가 두 배가 되기 때문이다.

## 왜 이렇게 설계했나

- **비교 델리게이트.** 최소 힙과 최대 힙을 같은 코드로 처리하려고 `Comparison<(TElement item, int priority)>`를 생성자로 받는다. 비교 결과가 `< 0`이면 앞쪽(루트 쪽)에 둔다.
- **팩토리 메서드.** `CreateMinPriorityQueue()`, `CreateMaxPriorityQueue()`가 흔한 두 경우의 델리게이트를 만들어 준다.
- **튜플 저장.** 요소와 우선순위를 `(item, priority)` 튜플로 묶어 `List`에 저장한다. 요소 타입이 우선순위를 알 필요가 없다.

## 레포 구현은 최소 힙인가 최대 힙인가

둘 다 만들 수 있게 되어 있고, 기본 동작은 비교자가 정한다.

- `CreateMinPriorityQueue()`: `a.priority.CompareTo(b.priority)`. 숫자가 작을수록 먼저 나온다(최소 힙).
- `CreateMaxPriorityQueue()`: `b.priority.CompareTo(a.priority)`. 숫자가 클수록 먼저 나온다(최대 힙).
- 몬스터 AI(`AI.cs`)는 최소 힙을 만들고, 넣을 때 `-action.Priority`를 우선순위로 써서 "큰 Priority 값이 먼저"가 되게 한다. 최대 힙 팩토리를 쓰지 않은 점은 코드에서 확인되는 사실이고, 이유는 코드에 없다.

## 동일 우선순위의 순서(안정성)

코드로 확인한 결과, **안정(stable)하지 않다.** 먼저 넣은 것이 먼저 나온다는 보장이 없다.

- 비교는 엄격한 `< 0`이라 같은 우선순위끼리는 올리지도 내리지도 않는다.
- 그러나 `Dequeue`가 마지막 요소를 루트로 옮기므로, 같은 우선순위 사이의 순서가 뒤섞인다.
- 순서를 기록하는 필드(삽입 번호 등)는 없다.

같은 우선순위 `A, B, C, D`를 차례로 넣고 꺼낼 때, 레포와 같은 알고리즘을 Python으로 옮겨 돌려 보면 `A, D, C, B` 순서가 나온다(레포의 C# 코드를 직접 실행한 것이 아니므로 unverified). 또 `(a,5) (b,3) (c,8) (d,1) (e,3)`을 넣으면 `d, e, b, a, c`가 나와, 우선순위 3인 `b`(먼저 삽입)보다 `e`가 먼저 나온다. 안정성이 필요하면 `(priority, 삽입 번호)`를 비교 키로 쓰는 방식이 흔하다.

## 핵심 코드 발췌

{% code title="PriorityQueue.cs" %}
```csharp
public void Enqueue(TElement item, int priority)
{
    _heap.Add((item, priority));
    HeapifyUp(_heap.Count - 1);
}

public TElement Dequeue()
{
    if (_heap.Count == 0)
        throw new InvalidOperationException("PriorityQueue is empty.");

    var topItem = _heap[0].item;
    int lastIndex = _heap.Count - 1;
    _heap[0] = _heap[lastIndex];
    _heap.RemoveAt(lastIndex);

    if (_heap.Count > 0)
        HeapifyDown(0);
    return topItem;
}

private void HeapifyUp(int index)
{
    int parentIndex = (index - 1) / 2;
    while (index > 0 && _comparer(_heap[index], _heap[parentIndex]) < 0)
    {
        Swap(index, parentIndex);
        index = parentIndex;
        parentIndex = (index - 1) / 2;
    }
}

private void HeapifyDown(int index)
{
    int leftChild = 2 * index + 1;
    int rightChild = 2 * index + 2;
    int targetIndex = index;

    if (leftChild < _heap.Count && _comparer(_heap[leftChild], _heap[targetIndex]) < 0)
        targetIndex = leftChild;
    if (rightChild < _heap.Count && _comparer(_heap[rightChild], _heap[targetIndex]) < 0)
        targetIndex = rightChild;

    if (targetIndex != index)
    {
        Swap(index, targetIndex);
        HeapifyDown(targetIndex);
    }
}
```
{% endcode %}

(발췌에서 주석과 빈 줄은 줄였다.)

줄 단위 설명은 다음과 같다.

- `Enqueue`: 배열 끝에 추가한 뒤 마지막 인덱스에서 `HeapifyUp`을 호출한다.
- `Dequeue`: 루트 요소를 저장해 두고, 마지막 요소를 루트 자리에 덮어쓴 뒤 마지막 칸을 지운다. 남은 요소가 있을 때만 `HeapifyDown(0)`을 부른다. 요소가 1개였다면 덮어쓰기와 삭제가 같은 칸이라 문제없이 비게 된다.
- `HeapifyUp`: `index > 0` 조건으로 루트에서 멈춘다. 부모가 더 우선이면(비교 결과 `< 0`이 아니면) 멈춘다. 루트(인덱스 0)의 부모 식 `(0-1)/2`는 C# 정수 나눗셈으로 0이 되지만 `index > 0`이 먼저 걸러 준다.
- `HeapifyDown`: 현재, 왼쪽, 오른쪽 중 가장 우선인 인덱스를 고른다. 같은 우선순위면 현재 위치를 유지하므로 불필요한 교환이 없다. 교환이 있으면 내려간 자리에서 재귀 호출한다. 재귀 깊이는 트리 높이(log n)라 부담이 없다.
- 주석의 "가장 작은 요소"라는 표현은 최소 힙 기준이다. 비교자가 바뀌면 "가장 우선인 요소"로 읽어야 한다.

## 따라 만들기 단계

빈 Unity 프로젝트(레포는 2022.3 기준)에서 시작한다.

1. **폴더와 파일 만들기.** `Assets/Scripts/CustomCollections/PriorityQueue.cs`를 만들고 `Script.CustomCollections` 네임스페이스, `using System; using System.Collections.Generic;`을 적는다.
   - 확인 방법: 에디터가 컴파일 에러 없이 끝난다(콘솔이 비어 있다).
2. **저장소와 비교자 필드.** `List<(TElement item, int priority)> _heap`과 `Comparison<(TElement item, int priority)> _comparer`를 선언하고 `Count => _heap.Count`를 둔다.
   - 확인 방법: 컴파일이 통과한다.
3. **생성자와 팩토리.** 비교자를 받는 생성자(null이면 `ArgumentNullException`), 그리고 최소/최대 힙 팩토리를 만든다.
   - 확인 방법: 임시 스크립트에서 `PriorityQueue<string>.CreateMinPriorityQueue().Count`가 0으로 출력된다.
4. **`Swap` 구현.** 튜플 교환 `(_heap[i], _heap[j]) = (_heap[j], _heap[i]);`
   - 확인 방법: 컴파일 통과. 다음 단계에서 간접 확인한다.
5. **`HeapifyUp`, `Enqueue`, `Peek`.** 위의 부모 식 `(index - 1) / 2`로 부모와 비교하며 올린다. `Peek`은 빈 큐에서 `InvalidOperationException`을 던지고 아니면 `_heap[0].item`을 반환한다.
   - 확인 방법: 5, 3, 8을 우선순위로 넣은 뒤 `Peek()`가 우선순위 3인 요소를 반환한다.
6. **`Dequeue`(HeapifyDown 전 단계).** 빈 큐에서 예외를 던지고, 루트를 저장한 뒤 마지막 요소를 루트로 옮기고 마지막 칸을 지운다. `HeapifyDown` 호출은 다음 단계에서 붙인다.
   - 확인 방법: 빈 큐에서 `Dequeue()`를 호출하면 예외가 난다.
7. **`HeapifyDown`.** 자식 인덱스 `2i+1`, `2i+2`를 범위 검사(`< Count`) 후 비교한다.
   - 확인 방법: 1~10을 섞어 넣고 모두 꺼냈을 때 오름차순으로 나온다.
8. **`Clear`와 검증 스크립트.** 아래 테스트를 실행한다.
   - 확인 방법: 콘솔에 `PASS`가 출력된다.

## 테스트 코드 예시

가장 단순한 방법은 빈 오브젝트에 붙이는 `MonoBehaviour`로 `Debug` 검증을 하는 것이다. 어셈블리 정의(asmdef)가 필요 없다.

```csharp
using UnityEngine;
using Script.CustomCollections;

public class PriorityQueueCheck : MonoBehaviour
{
    private void Start()
    {
        var min = PriorityQueue<string>.CreateMinPriorityQueue();
        min.Enqueue("e", 3); min.Enqueue("a", 5); min.Enqueue("c", 8);
        min.Enqueue("d", 1); min.Enqueue("b", 3);

        // 우선순위 오름차순이어야 한다 (같은 3의 순서는 보장되지 않음)
        int prev = int.MinValue;
        var order = new System.Collections.Generic.Dictionary<string, int>
            { {"e",3},{"a",5},{"c",8},{"d",1},{"b",3} };
        while (min.Count > 0)
        {
            var item = min.Dequeue();
            Debug.Assert(order[item] >= prev, $"order broken at {item}");
            prev = order[item];
        }

        var max = PriorityQueue<int>.CreateMaxPriorityQueue();
        foreach (var p in new[] { 2, 9, 4 }) max.Enqueue(p, p);
        Debug.Assert(max.Peek() == 9, "max heap top");

        Debug.Log("PASS");
    }
}
```

NUnit을 쓰려면 Test Framework 패키지(`com.unity.test-framework`)와 테스트용 asmdef가 필요하다. 이 레포의 `manifest.json`에는 해당 패키지가 직접 선언되어 있지 않다. NUnit 형태의 같은 검증은 다음과 같다(미실행).

```csharp
[Test]
public void MinHeap_DequeuesInAscendingOrder()
{
    var q = PriorityQueue<int>.CreateMinPriorityQueue();
    foreach (var p in new[] { 5, 3, 8, 1, 9, 2 }) q.Enqueue(p, p);
    var result = new List<int>();
    while (q.Count > 0) result.Add(q.Dequeue());
    CollectionAssert.AreEqual(new[] { 1, 2, 3, 5, 8, 9 }, result);
}

[Test]
public void EmptyQueue_Dequeue_Throws()
{
    Assert.Throws<InvalidOperationException>(() =>
        PriorityQueue<int>.CreateMinPriorityQueue().Dequeue());
}
```

## 막히기 쉬운 곳과 한계

- **같은 우선순위의 순서가 보장되지 않는다.** 위의 안정성 절 참고.
- **우선순위 변경과 삭제를 지원하지 않는다.** `Contains`, `Remove`, 우선순위 갱신이 없다. 그래서 이 레포의 AI는 큐를 오래 쓰지 않고 매 프레임 비운다([몬스터 AI 실험 해체](monster-ai-experiment.md) 참고).
- **우선순위는 `int`로 고정이다.** 음수 처리(`-priority`)를 호출 쪽에서 하는데, `int.MinValue`를 부정하면 오버플로가 나서 값이 그대로 남는다(경계값, 코드 기준 추정).
- **비교자가 일관되지 않으면 힙이 깨진다.** 델리게이트를 받으므로 호출자가 책임진다.
- **.NET 6 이상에는 `System.Collections.Generic.PriorityQueue<TElement,TPriority>`가 있다.** Unity 2022.3은 .NET Standard 2.1 프로필이라 기본 제공되지 않아 직접 구현할 이유가 있다(Unity 버전별 지원은 확인 필요).
- **네임스페이스가 `Script.CustomCollections`.** 폴더명이 아니라 코드의 네임스페이스를 기준으로 `using`해야 한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 배열로 표현한 힙에서 부모와 자식의 인덱스를 구하는 식이 왜 그렇게 되는지 내 말로 설명해 본다.
- [ ] 같은 우선순위의 요소가 들어오는 순서대로 나오지 않는 상황을 직접 만들어 본 경험이 있는가? 있다면 어떻게 확인했는가?
- [ ] 직접 구현해 본 뒤, 표준 라이브러리의 우선순위 큐와 비교해 무엇이 다르다고 느꼈는가?
