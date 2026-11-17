# 형변환 (Type Cast)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CPP-002-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 암시적 형변환, C 스타일 형변환, C++ 캐스트 4종의 용도와 위험을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

형변환(type conversion)은 값을 다른 자료형으로 바꾸는 것이다. 컴파일러가 자동으로 하면 암시적 형변환, 프로그래머가 직접 지정하면 명시적 형변환이다.

## 2. 구성 요소

| 구분 | 문법 | 특징 |
|---|---|---|
| 암시적 | (없음) | 컴파일러가 자동 수행 |
| C 스타일 | `(new_type)expression` | C와 C++에서 모두 쓴다 |
| `static_cast` | `static_cast<T>(e)` | 관련 있는 타입 사이의 변환. 컴파일 타임 검사 |
| `dynamic_cast` | `dynamic_cast<T>(e)` | 다형 클래스의 포인터·참조 변환. 런타임 검사 |
| `const_cast` | `const_cast<T>(e)` | `const`/`volatile` 추가·제거 |
| `reinterpret_cast` | `reinterpret_cast<T>(e)` | 비트 패턴을 다른 타입으로 재해석 |

## 3. 동작 원리

### 3-1. 암시적 형변환

컴파일러가 자동으로 수행한다. 주로 기본 데이터 타입 사이에서 일어난다.

```cpp
int a = 10;
double b = a;  // int에서 double로 암시적 형변환
```

* 작은 범위의 타입에서 큰 범위의 타입으로 바뀐다(예: `int`에서 `double`).
* 작은 정수형 상수를 더 큰 정수형 변수에 대입할 수 있다(예: `char`에서 `int`).

{% hint style="warning" %}
CAUTION: 큰 타입에서 작은 타입으로도 암시적 변환이 일어난다(예: `double`에서 `int`로 소수부 버림). 값이 손실될 수 있다. 중괄호 초기화(`int x{3.5};`)는 이런 좁히기 변환(narrowing conversion)을 오류로 막는다.
{% endhint %}

### 3-2. C 스타일 형변환

```cpp
int a = 10;
double b = (double)a;  // C 스타일 형변환
```

C 스타일 형변환은 상황에 따라 `const_cast`, `static_cast`, `reinterpret_cast`에 해당하는 변환을 시도한다. 어느 변환이 일어나는지 코드에서 보이지 않아 위험하다.

### 3-3. C++ 스타일 형변환

C++는 더 안전하고 명확한 형변환을 위해 네 가지 연산자를 제공한다.

**static_cast**

* 기본 데이터 타입 사이의 변환이나 상속 관계의 포인터 변환에 쓴다.
* 안전을 보장하지는 않지만 컴파일 타임에 많은 오류를 잡는다. `const`를 제거할 수는 없다.

{% code title="예" %}
```cpp
int a = 10;
double b = static_cast<double>(a);
```
{% endcode %}

**dynamic_cast**

* 다형성(polymorphism)을 가진 클래스(가상 함수가 하나 이상 있는 클래스)의 포인터·참조에 쓰며 런타임에 타입을 검사한다.
* 포인터 변환이 실패하면 `nullptr`을 반환한다. 참조 변환이 실패하면 `std::bad_cast` 예외를 던진다.

{% code title="예" %}
```cpp
class Base {
public:
    virtual void foo() {}
    virtual ~Base() = default;
};
class Derived : public Base {};

Base* basePtr = new Derived;
Derived* derivedPtr = dynamic_cast<Derived*>(basePtr);
delete basePtr;
```
{% endcode %}

**const_cast**

* `const` 또는 `volatile` 속성을 추가하거나 제거한다.
* 객체의 원래 타입을 바꾸지 않는다.

{% code title="예" %}
```cpp
int x = 10;
const int* cp = &x;
int* p = const_cast<int*>(cp);
*p = 20;  // x가 const가 아니므로 정의된 동작
```
{% endcode %}

{% hint style="danger" %}
WARNING: 원래 `const`로 선언된 객체(`const int a = 10;`)를 `const_cast`로 `const`를 벗긴 포인터로 수정하면 정의되지 않은 동작(UB)이다. 원본 예제(`const int a = 10; int* b = const_cast<int*>(&a);`)는 변환 자체는 허용되지만 `*b`에 쓰면 UB다.
{% endhint %}

**reinterpret_cast**

* 주로 포인터 타입 사이의 변환에 쓰며 비트 단위로 객체를 재해석한다.
* 매우 위험하며 사용을 최소화한다.

{% code title="예" %}
```cpp
int a = 10;
int* ptr = &a;
char* charPtr = reinterpret_cast<char*>(ptr);
```
{% endcode %}

## 4. 정리

* 형변환이 필요한지, 안전한지 먼저 따진다.
* 암시적 형변환은 편리하지만 예상치 못한 결과를 낼 수 있다. 가능하면 명시적 형변환을 쓴다.
* `dynamic_cast`, `const_cast`, `reinterpret_cast`는 의도와 다른 문제를 만들 수 있으므로 주의해서 쓴다.

{% hint style="warning" %}
CAUTION: 명시적 형변환 중 `reinterpret_cast`와 `const_cast`는 위험할 수 있다. 필요한 경우에만 신중히 쓴다.
{% endhint %}

## 5. 정정 내용

* 코드 블록 언어 태그를 `c`에서 `cpp`로 바꿨다(`static_cast` 등은 C++ 문법이다).
* `dynamic_cast` 예제에 `public:`과 가상 소멸자(`virtual ~Base() = default;`)를 추가하고 `delete basePtr;`로 해제했다. 가상 소멸자 없이 기반 클래스 포인터로 `delete`하면 UB이고, 원본은 `new` 객체를 해제하지 않았다.
* `const_cast` 예제를 원래 `const`가 아닌 객체로 바꾸고 UB 경고를 추가했다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 암시적 형변환 때문에 값이 달라졌던 경험이 있는가? 어떤 코드였는가?
- [ ] `static_cast`와 `dynamic_cast`는 어떤 상황에서 각각 선택하는가?
- [ ] C 스타일 형변환 대신 C++ 캐스트를 쓰는 이유를 한 문장으로 적어 보자.
