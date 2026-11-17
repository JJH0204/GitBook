# 내비메시 에이전트 클릭 이동

CharacterController 와 함께 NavMeshAgent를 사용하면 마우스 클릭으로 캐릭터 제어가 가능하도록 만들 수 있다.

## 준비

NavMesh는 Unity가 제공하는 길찾기(AI) 기능이다. Unity 2022.2부터는 **AI Navigation** 패키지(`com.unity.ai.navigation`)를 Package Manager에서 설치해서 쓴다.

1. 바닥(또는 바닥들의 부모)에 **NavMeshSurface** 컴포넌트를 붙인다.
2. NavMesh를 만들 대상을 정한다. Collect Objects(전체 / 볼륨 안 / 이 오브젝트의 자식), Include Layers, Use Geometry(렌더 메시 / 물리 콜라이더)
3. **Bake** 버튼으로 NavMesh를 굽는다. 걸을 수 있는 영역이 파랗게 표시된다.
4. 캐릭터에 **NavMeshAgent**를 붙인다.

| NavMeshAgent 설정 | 뜻 |
|---|---|
| Agent Type | 반지름·높이·오를 수 있는 경사/턱. NavMeshSurface와 같은 타입이어야 한다 |
| Base Offset | 에이전트 기준점과 오브젝트 피벗 사이의 높이 차이 |
| Speed / Angular Speed / Acceleration | 최고 속도, 회전 속도, 가속도 |
| Stopping Distance | 목적지에서 이만큼 떨어지면 멈춘다 |
| Auto Braking | 목적지 근처에서 감속한다 |
| Obstacle Avoidance | 다른 에이전트를 피하는 품질과 우선순위(Priority) |
| Area Mask | 지나갈 수 있는 영역 종류 |

* 움직이는 장애물은 **NavMeshObstacle**(Carve를 켜면 NavMesh에 구멍을 낸다), 떨어진 발판 사이 점프는 **NavMeshLink**로 만든다.

## 코드

```csharp
private void Awake()
{
    characterController = GetComponent<CharacterController>();
    navMeshAgent = GetComponent<NavMeshAgent>();
    navMeshAgent.updatePosition = false;
    navMeshAgent.updateRotation = true;
    
    cam = Camera.main;
}

private void Update()
{
    if (Input.GetMouseButton(0))
    {
        // 카메라 피킹으로 이동할 위치 계산
        var ray = cam.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, 100f, groundLayerMask))
        {
            // NavMeshAgent를 사용하여 이동
            navMeshAgent.SetDestination(hit.point);
        }
    }

    if (navMeshAgent.remainingDistance > navMeshAgent.stoppingDistance)
        characterController.Move(navMeshAgent.velocity * Time.deltaTime);
    else
        characterController.Move(Vector3.zero);
}

private void LateUpdate()
{
    transform.position = navMeshAgent.nextPosition;
}
```

코드 흐름

1. 초기 값 설정: 에이전트가 위치는 직접 옮기지 않게(`updatePosition = false`) 하고 회전만 맡긴다.
2. 마우스 좌클릭 입력 확인
3. 클릭한 스크린 좌표를 Ray로 바꾸고, Raycast로 지면과 충돌했는지 검사
4. 충돌한 지점을 목적지로 설정 (`SetDestination`)
5. 남은 거리가 멈춤 거리보다 크면 에이전트가 계산한 속도로 CharacterController를 이동, 아니면 정지
6. `LateUpdate`에서 캐릭터 위치를 에이전트 위치(`nextPosition`)로 보정

이거 때문에 Scene 실행하면 캐릭터가 바닥에 박힌체로 시작하는 것 같은데 플레이어의 초기 위치를 따로 설정해 줘야겠다.

바닥에 붙여 놓은 체로 LateUpdate() 메서드는 주석 처리했다.

* `remainingDistance`는 경로 계산이 끝나기 전(`pathPending`이 true일 때)에는 정확하지 않다.
* `updatePosition = false`로 직접 옮길 때는 `navMeshAgent.nextPosition`과 실제 위치가 어긋나지 않게 맞춰 줘야 한다.

## 더 보기

* [AI Navigation 패키지 문서](https://docs.unity3d.com/Packages/com.unity.ai.navigation@latest)
* [Unity ScriptReference — NavMeshAgent.nextPosition](https://docs.unity3d.com/ScriptReference/AI.NavMeshAgent-nextPosition.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 캐릭터가 바닥에 박혀서 시작하는 원인을 찾는다. 힌트: `nextPosition`이 가리키는 높이와 캐릭터 피벗(CharacterController의 중심)의 높이를 비교해 본다. 찾았으면 `LateUpdate`를 되살려 고친다.
- [ ] NavMeshAgent가 직접 위치를 옮기게(`updatePosition = true`) 하는 방식과 이 페이지 방식의 차이를 쓴다. 언제 어느 쪽을 쓰는지도 적는다.
- [ ] 클릭 이동 중 문이 닫혀 길이 막히면 어떻게 처리할지 설계해 본다 (NavMeshObstacle, `CalculatePath`).
