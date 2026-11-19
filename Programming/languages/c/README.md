# [생성형 AI] C# 언어 (C#)

이 폴더는 C# 언어 노트의 그룹 소개다. 폴더 이름은 `c`이지만 내용은 C 언어가 아니라 C#이다. C 언어와 C++ 문서는 [C 및 C++ (C & C++)](../c-and-c++/README.md)에 있다.

{% hint style="info" %}
NOTE: 폴더 이름 `c`는 C#의 `#`를 경로에 쓸 수 없어 붙은 이름이다. C# 문서는 하위 폴더 `csharp/`에 있다.
{% endhint %}

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 그룹 README (안내) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (C# 컴파일러로 실행하지 않았다. 하위 문서를 요약했다) |

## 이 그룹은 무엇인가

C#은 .NET 플랫폼에서 쓰는 객체지향 언어이다. 이 폴더는 현재 상속과 다형성의 핵심인 `virtual`과 `abstract`를 다룬다. 읽는 순서는 [C# 핵심 개념 (C#)](csharp/README.md)의 목록을 따른다.

## 문서 목록

| 위치 | 문서 | 용도 |
|---|---|---|
| `csharp/` | [C# 핵심 개념 (C#)](csharp/README.md) | C# 핵심 개념 문서의 목록을 본다 |
| `csharp/` | [가상 메서드 (virtual)](csharp/virtual.md) | `virtual` 메서드를 확인한다 |
| `csharp/` | [추상 클래스 (Abstract Class)](csharp/abstractclasses.md) | 추상 클래스를 확인한다 |

## 핵심 용어

| 용어 | 뜻 |
|---|---|
| 상속 | 부모 클래스의 멤버를 자식 클래스가 물려받는 것 |
| 다형성 | 같은 호출이 객체의 실제 타입에 따라 다르게 동작하는 성질 |
| `override` | 부모의 `virtual`·`abstract` 멤버를 재정의하는 키워드 |
