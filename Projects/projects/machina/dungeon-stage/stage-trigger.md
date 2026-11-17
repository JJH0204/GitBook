# StageUpdateTrigger: 스테이지 전환 감지

## 무엇을 하는가

각 스테이지 씬의 출구에 `Collider`(Is Trigger)를 두고 `StageUpdateTrigger`를 붙인다. 플레이어가 트리거에 들어갔다가 앞쪽으로 빠져나가면 `DungeonManager.UpdatePlayerStageIndex(stageIndex + 1)`을 호출해 스테이지 전환을 시작한다. 같은 컴포넌트가 "이 스테이지에서 죽었을 때 돌아올 위치"(`respawnPosition`)도 `DungeonManager.RestartPosition`에 등록한다.

## 왜 이렇게 설계했나

- 커밋 `9ef994e7`(StageUpdateTrigger 추가)에서 처음 만들어졌고, 커밋 `e20761a7`에서 여러 스테이지의 Static 씬(변경 파일 목록에서 1~6번 스테이지 씬이 확인된다)에 트리거가 배치되었다.
- 스테이지 번호를 트리거가 직접 들고 있으므로 `DungeonManager`는 "어떤 트리거가 불렀는가"를 몰라도 된다. 씬 디자이너가 씬에 트리거를 놓고 번호만 입력하면 전환이 연결된다.
- 처음에는 `OnTriggerEnter`에서 곧바로 전환을 호출했다(코드에 주석으로 남아 있다). 지금은 Enter에서는 "들어온 순간의 스테이지 번호"만 저장하고, Exit에서 판단한다. 들어오는 즉시 로드하면 아직 문 앞에 서 있는 상태에서 스테이지가 바뀌기 때문으로 짐작된다(코드에는 이유가 적혀 있지 않다).

## 핵심 코드

{% code title="StageUpdateTrigger.cs" %}
```csharp
public class StageUpdateTrigger : MonoBehaviour
{
    [SerializeField] private int stageIndex;
    [SerializeField] private GameObject respawnPosition;

    private int _previousStageIndex;

    private void OnTriggerEnter(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        _previousStageIndex = DungeonManager.Instance.CurrentPlayerStageIndex;
    }

    private void OnTriggerExit(Collider other)
    {
        if (!other.CompareTag("Player")) return;

        if (_previousStageIndex > stageIndex)
        {
            // 뒤로 이동: 왔다갔다만 해도 갱신되는 문제 때문에 임시로 비활성화
            //DungeonManager.Instance.UpdatePlayerStageIndex(stageIndex);
        }
        else if (_previousStageIndex == stageIndex)
        {
            DungeonManager.Instance.UpdatePlayerStageIndex(stageIndex + 1);

            if (respawnPosition != null)
                DungeonManager.Instance.RestartPosition = respawnPosition.transform.position;
        }
    }
}
```
{% endcode %}

- `CompareTag("Player")`: 플레이어가 아닌 몬스터나 투사체가 지나가도 반응하지 않게 한다. 플레이어 프리팹의 태그가 `Player`여야 한다.
- `OnTriggerEnter`: 들어온 순간의 `CurrentPlayerStageIndex`를 기억한다.
- `OnTriggerExit`의 두 분기: `_previousStageIndex == stageIndex`이면 "내가 속한 스테이지에서 출구로 나갔다"는 뜻이므로 다음 번호로 전환한다. `_previousStageIndex > stageIndex`(뒤로 돌아가는 경우)는 주석 처리되어 아무 동작도 하지 않는다.
- `respawnPosition`: 전환과 함께 리스폰 위치를 갱신한다. 사망 후 부활(`ResetCurrentStage`)에서 `RestartPosition`으로 사용된다. 첫 스테이지의 값은 `Init1stGameScene`이 시작 위치로 미리 넣는다.

## 따라 만들기 단계

1. [DungeonManager 페이지](dungeon-manager.md)의 단계를 끝내 `UpdatePlayerStageIndex`가 동작하는 상태로 만든다.
2. 플레이어 오브젝트에 `Player` 태그를 지정하고 `Rigidbody` 또는 `CharacterController`가 있는지 확인한다. 트리거 콜백은 둘 중 하나가 있어야 한다.
   - 확인 방법: 아무 트리거에 들어가고 나올 때 로그가 찍힌다.
3. 각 스테이지 씬의 출구에 `BoxCollider`를 놓고 `Is Trigger`를 켠다. `StageUpdateTrigger`를 붙이고 `stageIndex`에 그 스테이지의 번호를 넣는다. 리스폰 위치로 쓸 빈 오브젝트를 만들어 `respawnPosition`에 연결한다.
   - 확인 방법: Scene 뷰에서 콜라이더가 출구를 막고 있다.
4. `DungeonManager`에 `RestartPosition`(`Vector3` 프로퍼티)을 추가한다.
5. 플레이하며 0번 스테이지의 출구를 지나간다.
   - 확인 방법: 출구를 빠져나가면 `Stage_2`가 올라오고 `Stage_0`이 내려간다. `CurrentPlayerStageIndex`가 1로 바뀐다(Inspector에서 `[SerializeField]` 필드로 보인다).
6. 같은 출구에서 들어갔다가 되돌아 나와 본다.
   - 확인 방법: `_previousStageIndex`와 `stageIndex`가 같으면 전환이 일어나고, 이미 지나간 뒤라면 아무 일도 없다. 뒤로 돌아가는 길이 없는 레벨이라면 문제없이 동작한다.

## 막히기 쉬운 곳과 한계

- **왕복 문제**: 코드 주석에 적힌 대로, 트리거를 왔다갔다하기만 해도 스테이지가 갱신되는 문제가 있어 뒤로 이동하는 로직은 꺼 두었다. 현재 게임은 이전 스테이지로 돌아가는 길을 막는 구조여서 이 한계가 드러나지 않는다. 되돌아가는 구조를 만들려면 방향 판정(들어온 위치와 나간 위치 비교)이 필요하다. 이는 코드 주석에서 읽은 설명이다.
- **같은 번호 판정의 의존성**: Enter 때 저장한 `_previousStageIndex`는 트리거 컴포넌트마다 따로 있다. 인덱스가 어긋나면(`UpdatePlayerStageIndex`가 진행 중이라 무시된 경우 등) 이후 트리거가 동작하지 않을 수 있다.
- **Enter 없이 Exit**: 플레이어가 트리거 안에서 순간이동으로 시작하거나 스테이지 로드로 트리거가 갑자기 켜지면 Exit만 발생할 수 있다. 이때 `_previousStageIndex`는 기본값 0이다. 이 시나리오가 실제로 발생하는지는 확인하지 못했다.
- **`RestartPosition` 갱신 순서**: 전환 호출 뒤에 리스폰 위치를 갱신한다. 전환이 가드(`_isUpdatingStage`)에 막혀 무시되어도 `RestartPosition`은 갱신된다는 점을 알아 둘 만하다.
- 이 영역과 연결된 상태 보관은 [오브젝트 상태 보관과 풀링](object-state-pooling.md)에서 다룬다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `OnTriggerEnter`가 아니라 `OnTriggerExit`에서 전환을 일으키도록 바꾼 이유가 무엇이라고 생각하는가?
- [ ] 트리거 이벤트(`OnTriggerEnter/Exit`)가 호출되려면 어떤 조건이 필요한지, 직접 테스트하며 알게 된 점을 적어 본다.
- [ ] 되돌아가는 길이 있는 레벨이라면 이 방식을 어떻게 바꿔야 할지 내 생각을 적어 본다.
