# 단일 책임 원칙 (SRP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SLD-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 클래스를 변경 이유 기준으로 나누는 방법을 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

{% hint style="info" %}
NOTE: 한 클래스는 하나의 책임만 가져야 한다. 클래스를 변경하는 이유는 오직 하나여야 한다.
{% endhint %}

여기서 책임은 "기능 하나"가 아니라 "변경 이유 하나"다. 계산 규칙을 바꾸려는 사람과 저장 형식을 바꾸려는 사람이 다르면 책임이 둘이다.

## 2. 구성 요소

| 구분 | 위반 예제의 클래스 | 준수 예제의 클래스 | 변경 이유 |
|---|---|---|---|
| 계산 | `Invoice` | `Invoice` | 금액 계산 규칙이 바뀐다 |
| 저장 | `Invoice` | `InvoiceRepository` | 저장 방식(파일, DB)이 바뀐다 |
| 출력 | `Invoice` | `InvoicePrinter` | 출력 형식이 바뀐다 |

## 3. 동작 원리

1. 클래스의 메서드를 나열한다.
2. 각 메서드가 바뀌는 이유를 적는다.
3. 이유가 둘 이상이면 이유별로 클래스를 나눈다.
4. 나뉜 클래스는 필요한 쪽에서 조합해 쓴다.

## 4. 예제 코드

위반 예제다. 한 클래스가 계산, 저장, 출력을 모두 맡는다.

```csharp
using System;
using System.IO;

class Invoice
{
    public decimal Amount { get; set; }

    public decimal CalculateTotal() => Amount * 1.1m;      // 계산 규칙(세율)

    public void SaveToFile(string path)                     // 저장 방식
    {
        File.WriteAllText(path, CalculateTotal().ToString());
    }

    public void Print()                                     // 출력 형식
    {
        Console.WriteLine($"합계: {CalculateTotal()}");
    }
}
```

준수 예제다. 변경 이유별로 클래스를 나눴다.

```csharp
using System;
using System.IO;

class Invoice
{
    public decimal Amount { get; set; }
    public decimal CalculateTotal() => Amount * 1.1m;
}

class InvoiceRepository
{
    public void Save(Invoice invoice, string path)
    {
        File.WriteAllText(path, invoice.CalculateTotal().ToString());
    }
}

class InvoicePrinter
{
    public void Print(Invoice invoice)
    {
        Console.WriteLine($"합계: {invoice.CalculateTotal()}");
    }
}
```

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| 위반 `Invoice` | 세율, 저장 경로 형식, 출력 문구가 바뀔 때마다 같은 클래스를 고친다 |
| 준수 `Invoice` | 계산 규칙만 담는다. 세율이 바뀔 때만 수정한다 |
| `InvoiceRepository` | 저장 방식만 담는다. DB로 바꿔도 `Invoice`는 수정하지 않는다 |
| `InvoicePrinter` | 출력 형식만 담는다 |

## 6. 한계·주의

- 책임을 지나치게 잘게 나누면 클래스가 늘고 흐름을 따라가기 어렵다. 실제로 서로 다른 이유로 바뀌는 경우에 나눈다.
- 아직 한 번도 따로 바뀐 적 없는 부분을 미리 나누지 않는다. 두 번째 변경 이유가 생길 때 나눠도 늦지 않다.
- SRP는 응집도와 관련이 깊다. 한 클래스의 구성 요소가 한 목적에 모이면(높은 응집도) SRP를 지킨 상태에 가깝다. 자세한 내용은 [응집도 (Cohesion)](../oop/cohesion.md)를 본다.

관련 문서: [SOLID 원칙 개요](solidprinciples.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내가 만든 클래스 하나를 골라 변경 이유가 몇 개인지 적어 보라.
- [ ] "책임이 하나"와 "메서드가 하나"는 어떻게 다른가?
