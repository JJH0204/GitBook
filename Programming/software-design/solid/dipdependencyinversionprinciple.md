# 의존관계 역전 원칙 (DIP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SLD-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 고수준 모듈이 저수준 구현이 아니라 추상에 의존하게 하는 방법을 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

{% hint style="info" %}
NOTE: 고수준 모듈은 저수준 모듈에 의존해서는 안 된다. 둘 다 추상에 의존해야 한다. 추상은 세부 구현에 의존해서는 안 되고, 세부 구현이 추상에 의존해야 한다.
{% endhint %}

고수준 모듈은 업무 규칙을 담은 모듈이고 저수준 모듈은 DB, 파일, 네트워크 같은 세부 구현이다. 소스 코드의 의존 방향이 "업무 규칙 → 세부 구현"에서 "세부 구현 → 추상 ← 업무 규칙"으로 바뀐다. 이 때문에 "역전"이라고 부른다.

## 2. 구성 요소

| 구성 요소 | 예제의 클래스 | 역할 |
|---|---|---|
| 고수준 모듈 | `OrderService` | 주문 처리 업무 규칙 |
| 추상 | `IOrderRepository` | 저장소가 제공해야 할 약속. 고수준 모듈 쪽에서 필요에 맞게 정의한다 |
| 저수준 모듈 | `SqlOrderRepository` | 추상을 구현하는 세부 구현 |

## 3. 동작 원리

의존 방향 비교다.

| 구조 | 의존 방향 |
|---|---|
| 위반 | `OrderService` → `SqlOrderRepository` |
| 준수 | `OrderService` → `IOrderRepository` ← `SqlOrderRepository` |

1. 고수준 모듈이 필요로 하는 기능을 인터페이스로 정의한다.
2. 고수준 모듈은 그 인터페이스만 사용한다.
3. 저수준 모듈이 그 인터페이스를 구현한다.
4. 구체 객체는 바깥(시작 지점)에서 만들어 넘긴다.

## 4. 예제 코드

위반 예제다. 고수준 클래스가 구체 클래스를 직접 만든다.

```csharp
class SqlOrderRepository
{
    public void Save(string order) { /* DB에 저장 */ }
}

class OrderService
{
    private readonly SqlOrderRepository _repo = new SqlOrderRepository();  // 구체 클래스에 의존

    public void Place(string order)
    {
        // 업무 규칙 ...
        _repo.Save(order);
    }
}
```

준수 예제다. 추상에 의존하고 구현은 생성자로 받는다.

```csharp
interface IOrderRepository
{
    void Save(string order);
}

class SqlOrderRepository : IOrderRepository
{
    public void Save(string order) { /* DB에 저장 */ }
}

class InMemoryOrderRepository : IOrderRepository
{
    public void Save(string order) { /* 메모리에 저장(테스트용) */ }
}

class OrderService
{
    private readonly IOrderRepository _repo;

    public OrderService(IOrderRepository repo)   // 생성자 주입
    {
        _repo = repo;
    }

    public void Place(string order)
    {
        // 업무 규칙 ...
        _repo.Save(order);
    }
}

class Program
{
    static void Main()
    {
        var service = new OrderService(new SqlOrderRepository());
        service.Place("주문 1");
    }
}
```

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `IOrderRepository` | `OrderService`가 필요로 하는 저장 기능의 약속이다 |
| `SqlOrderRepository` | 추상을 구현한다. 의존 화살표가 구현에서 추상으로 향한다 |
| `OrderService` 생성자 | 구현을 직접 만들지 않고 받는다 |
| `Main` | 구체 객체를 선택하고 조립한다. 테스트에서는 `InMemoryOrderRepository`를 넘긴다 |

## 6. 한계·주의

- DIP는 원칙이고 의존성 주입(DI, Dependency Injection)은 구현 기법이다. 둘은 같지 않다. 생성자 주입은 DIP를 지키는 한 가지 방법이다. 추상 없이 구체 클래스를 주입하면 DI를 써도 DIP는 지켜지지 않는다.
- 변하지 않는 안정된 클래스(표준 라이브러리의 `string` 등)까지 추상화할 필요는 없다.
- 인터페이스를 저수준 모듈 쪽에 두고 고수준 모듈이 그것을 가져다 쓰면 의존 방향이 역전되지 않는다. 추상은 고수준 모듈의 필요에 맞게 정의한다.

관련 문서: [SOLID 원칙 개요](solidprinciples.md), [결합도 (Coupling)](../oop/coupling.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내 코드에서 업무 규칙이 DB나 파일 클래스를 직접 `new`로 만드는 곳이 있는가?
- [ ] DIP와 DI의 차이를 내 말로 설명하라.
