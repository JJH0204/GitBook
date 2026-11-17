# 내비메시 에이전트 클릭 이동

CharacterController 와 함께 NavMeshAgent를 사용하면 마우스 클릭으로 캐릭터 제어가 가능하도록 만들 수 있다.

NavMesh 기능은 Unity에서 제공하는 AI 기능으로 사용하기전 패키지를 설치해야 한다.

설치하면 아래와 같이 사용가능하다

NavMeshAgent 의 설정

???

NavMesh를 생성할 대상설정

생성할 NavMesh의 Bake 시에 적용할 설정을 조절 할 수 있다.

Bake 버튼으로 NavMesh를 생성할 수 있다.

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

^IQu2OSvS

초기 값 설정

마우스 좌 클릭 입력 확인

마우스 입력이 있었던 위치를 Ray를 이용해 스크린 좌표에서 월드 좌표로 변환\
변환 과정에서 RayCast를 활용해 지면과 충돌했는지 검사

마우스로 클릭한 지점을 목적지로 NavMesh 설정

목적지로 이동

목적지 도착여부 확인

이동 정지

캐릭터의 이동 위치를 마지막에 보정

이거 때문에 Scene 실행하면 캐릭터가 바닥에 박힌체로 시작하는 것 같은데 플레이어의 초기 위치를 따로 설정해 줘야겠다.

바닥에 붙여 놓은 체로 LastUpdate() 메서드는 주석 처리했다.
