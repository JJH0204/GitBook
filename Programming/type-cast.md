# Type Cast

{% stepper %}
{% step %}
### 1. 암시적 형변환 (Implicit Type Conversion)

* 컴파일러가 자동으로 수행하는 형변환입니다.
* 주로 기본 데이터 타입 간의 형변환에서 많이 발생합니다.

```c
int a = 10;
double b = a;  // int에서 double로 암시적 형변환
```

* 작은 범위의 타입에서 큰 범위의 타입으로 변환 (예: int에서 double로)
* 상수 표현식을 더 큰 타입의 변수에 대입 (예: char에서 int로)
* 위 조건은 아래 명시적 형변환에서도 유지된다.
{% endstep %}

{% step %}
### 2. 명시적 형변환 (Explicit Type Conversion)

* 프로그래머가 직접 형변환을 지정하는 방식입니다.
* 명시적 형변환에는 C 스타일 형변환과 C++ 스타일 형변환이 있습니다.

#### C 스타일 형변환 (C-Style Cast)

* C에서 사용하던 형변환 방식으로, C++에서도 사용할 수 있습니다.
* 문법은 (new\_type)expression입니다.

```c
int a = 10;
double b = (double)a;  // C 스타일 형변환
```

#### C++ 스타일 형변환 (C++ Style Cast)

* C++에서는 보다 안전하고 명확한 형변환을 위해 네 가지의 형변환 연산자를 제공합니다.
* static\_cast
  * 주로 기본 데이터 타입 간의 형변환이나 포인터 타입 간의 형변환에 사용됩니다.
  * 안전성을 보장하지 않지만, 컴파일 타임에 많은 오류를 잡아줍니다.

{% code title="예" %}
```c
int a = 10;
double b = static_cast<double>(a);
```
{% endcode %}

* dynamic\_cast
  * 주로 다형성(pointers to base class)의 객체에 사용되며, 런타임에 타입을 체크합니다.
  * 실패하면 nullptr을 반환합니다.

{% code title="예" %}
```c
class Base { virtual void foo() {} };
class Derived : public Base {};
Base* basePtr = new Derived;
Derived* derivedPtr = dynamic_cast<Derived*>(basePtr);
```
{% endcode %}

* const\_cast
  * const 또는 volatile 속성을 추가하거나 제거할 때 사용됩니다.
  * 객체의 원래 타입을 변경하지 않습니다.

{% code title="예" %}
```c
const int a = 10;
int* b = const_cast<int*>(&a);
```
{% endcode %}

* reinterpret\_cast
  * 주로 포인터 타입 간의 형변환에 사용되며, 비트 단위로 객체를 재해석합니다.
  * 매우 위험하며, 사용을 최소화해야 합니다.

{% code title="예" %}
```c
int a = 10;
int* ptr = &a;
char* charPtr = reinterpret_cast<char*>(ptr);
```
{% endcode %}
{% endstep %}

{% step %}
### 3. 정리

* 형변환을 사용할 때는 항상 해당 형변환이 필요한지, 그리고 안전한지 고려해야 합니다.
* 암시적 형변환은 편리하지만, 예상치 못한 결과를 초래할 수 있기 때문에 주의가 필요합니다.\
  (가능한 명시적인 방법으로 형변환 시도)
* 명시적인 방법 중에서도 dynamic\_cast, const\_cast, reinterpret\_cast는 코드를 작성한 프로그래머의 의도와 다른 문제를 만들 수 있기에 주의해서 사용해야 한다.
{% endstep %}
{% endstepper %}

{% hint style="warning" %}
명시적 형변환 중 특히 reinterpret\_cast와 const\_cast는 위험할 수 있으니 필요한 경우에만 신중히 사용하세요.
{% endhint %}
