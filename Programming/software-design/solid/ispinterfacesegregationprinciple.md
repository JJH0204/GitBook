# 인터페이스 분리 원칙 (ISP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-SLD-005-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 큰 인터페이스를 클라이언트별로 나누는 이유와 방법을 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

{% hint style="info" %}
NOTE: 클라이언트는 자신이 사용하지 않는 메서드에 의존하지 않아야 한다.
{% endhint %}

하나의 범용 인터페이스보다 클라이언트별로 좁은 여러 인터페이스가 낫다. 클라이언트가 쓰지 않는 메서드가 바뀌어도 그 클라이언트가 다시 컴파일되거나 영향을 받는 일이 없어진다.

## 2. 구성 요소

| 구성 요소 | 위반 예제 | 준수 예제 |
|---|---|---|
| 인터페이스 | `IMachine` (인쇄, 스캔, 팩스) | `IPrinter`, `IScanner`, `IFax` |
| 구현 클래스 | `BasicPrinter` (인쇄만 가능) | `BasicPrinter : IPrinter` |
| 클라이언트 | 인쇄만 필요한데 `IMachine` 전체에 의존 | 필요한 인터페이스에만 의존 |

## 3. 동작 원리

1. 인터페이스를 사용하는 클라이언트를 나열한다.
2. 클라이언트별로 실제 호출하는 메서드를 정리한다.
3. 호출 집합이 다르면 인터페이스를 그 단위로 나눈다.
4. 여러 기능을 가진 클래스는 인터페이스를 여러 개 구현한다.

## 4. 예제 코드

위반 예제다. 인쇄만 하는 기기가 쓰지 않는 메서드를 구현해야 한다.

```csharp
using System;

interface IMachine
{
    void Print(string doc);
    void Scan(string doc);
    void Fax(string doc);
}

class BasicPrinter : IMachine
{
    public void Print(string doc) => Console.WriteLine("인쇄: " + doc);
    public void Scan(string doc) => throw new NotSupportedException();
    public void Fax(string doc) => throw new NotSupportedException();
}
```

준수 예제다. 기능별로 인터페이스를 나눈다.

```csharp
using System;

interface IPrinter { void Print(string doc); }
interface IScanner { void Scan(string doc); }
interface IFax     { void Fax(string doc); }

class BasicPrinter : IPrinter
{
    public void Print(string doc) => Console.WriteLine("인쇄: " + doc);
}

class MultiFunctionDevice : IPrinter, IScanner, IFax
{
    public void Print(string doc) => Console.WriteLine("인쇄: " + doc);
    public void Scan(string doc)  => Console.WriteLine("스캔: " + doc);
    public void Fax(string doc)   => Console.WriteLine("팩스: " + doc);
}

class Report
{
    // 인쇄만 필요하므로 IPrinter에만 의존한다
    public void Output(IPrinter printer) => printer.Print("월간 보고서");
}
```

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `BasicPrinter`(위반) | `Scan`, `Fax`가 예외를 던진다. 호출자는 인터페이스만 보고 호출할 수 있다고 믿으므로 LSP도 어긴다 |
| `IPrinter`, `IScanner`, `IFax` | 클라이언트가 필요한 만큼만 의존하게 한다 |
| `MultiFunctionDevice` | 여러 인터페이스를 구현해 모든 기능을 제공한다 |
| `Report.Output` | `IPrinter`만 받으므로 스캔·팩스 변경에 영향을 받지 않는다 |

## 6. 한계·주의

- 인터페이스를 너무 잘게 쪼개면 타입이 많아진다. 실제 클라이언트의 사용 패턴 기준으로 나눈다.
- 빈 메서드나 예외만 던지는 메서드가 있으면 ISP 위반을 의심한다.
- ISP는 인터페이스의 응집도를 높이는 방법이기도 하다. 자세한 내용은 [응집도 (Cohesion)](../oop/cohesion.md)를 본다.

관련 문서: [SOLID 원칙 개요](solidprinciples.md), [리스코프 치환 원칙 (LSP)](lspliskovsubstitutionprinciple.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내가 쓰는 인터페이스나 라이브러리 중 일부 메서드만 쓰는 것은 무엇인가?
- [ ] 인터페이스를 분리하면 어떤 변경이 쉬워지는가?
