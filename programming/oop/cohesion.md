# 응집도

모듈(또는 클래스, 함수) 내에 구성 요소들이 얼마나 밀접하게 연관되어 있는지를 나타내는 개념

"모듈 내부의 기능들이 얼나마 하나의 목적을 위해 집중되어 있는가?" 를 측정하는 지표

***

### 응집도의 중요성

* 높은 응집도: 모듈이 단일 책임 원칙(SRP)를 따르며, 유지보수가 쉽고 재사용성이 높다.
* 낮은 응집도: 여러 기능이 한 모듈에 섞여 있어, 변경시 다른 기능에 영향을 주기 쉽다.

따라서, **유지 보수/재사용성/가독성**을 위해 응집도를 높일 필요가 있다.

***

### 응집도의 종류

1. [우연적 응집도 - 가장 낮음](cohesion.md#undefined-2)
2. [논리적 응집도](cohesion.md#undefined-3)
3. [시간적 응집도](cohesion.md#undefined-4)
4. [절차적 응집도](cohesion.md#undefined-5)
5. [통신적 응집도](cohesion.md#undefined-6)
6. [순차적 응집도](cohesion.md#undefined-7)
7. [기능적 응집도 - 가장 높음](cohesion.md#undefined-8)

***

#### 우연적 응집도

* 모듈 내의 기능들이 아무 연관 없이 우연히 모여 있는 경우
* 여러 개의 무관한 기능을 하나의 모듈에 넣어둔 상태
* 최악의 응집도, 즉시 개선이 필요

```c
// 예제
void utilityFunction() {
    printReport();
    calculateTax();
    saveToDatabase();
}
```

* 보고서 출력, 세금 계산, 데이터 저장이 하나의 함수에 포함됨
* 서로 무관한 기능이 모여 있어 우연적 응집도 충족

***

#### 논리적 응집도

* 같은 범주의 작업을 수행하지만 각각의 기능이 논리적으로 다름
* 주어진 입력 값에 따라 다른 기능이 실행됨

```c
// 예제
void handleUserInput (int inputType) {
    if (inputType == 1) handleMouseInput();
    else if (inputType == 2) handleKeyboardInput();
}
```

* 마우스 입력과 키보드 입력이 같은 함수에서 처리된다.
* 기능 분리가 되어 있지 않는다.

***

#### 시간적 응집도

* 실행 시간이 비슷한 기능들을 묶어놓는 경우
* 예를 들어, 프로그램 초기화 작업을 한 모듈에 몰아넣는 경우

```c
// 예제
void initializeSystem() {
    loadConfig();
    initializeDatabase();
    setupUI();
}
```

* 실행 순서는 맞지만, 기능이 너무 광법위하다.
* 더 세분화하는 것이 좋다.

***

#### 절차적 응집도

* 특정 순서대로 실행되는 기능들을 모은 경우
* 시간적 응집도보다 더 구조화되었지만, 여전히 기능이 명확하게 나뉘지 않았다.

```c
// 예제
void processOrder() {
    validateOrder();
    calculatePrice();
    generateInvoice();
}
```

* 특정 절차를 따르긴 하지만, 각각의 기능이 다르다.
* 기능별로 나누는 것이 더 좋다.

***

#### 통신적 응집도

* 동일한 입력 데이터를 공유하여 서로 연관된 기능을 수행하는 경우
* 비교적 높은 응집도이지만, 하나의 모듈이 여러 역할을 할 가능성이 있다.

```c
// 예제
void processUserData(User user) {
    validateUser(user);
    saveUserToDatabase(user);
    sendWelcomeEmail(user);
}
```

* 같은 데이터를 사용하지만, 수행하는 작업이 다르다.
* 분리하는 것이 좋다.

***

#### 순차적 응집도

* 한 기능이 출력값이 다음 기능의 입력값으로 사용되는 경우
* 기능 간의 강한 연관성이 있다.

```c
// 예제
void analyzeText(String text) {
    TokenList tokens = tokenize(text);
    SyntaxTree tree = parse(tokens);
    generateCode(tree);
}
```

* tokenize>parse>generateCode 순서로 데이터가 흘러간다.

***

#### 기능적 응집도

* 모든 기능이 단 하나의 목적을 달성하기 위해 집중되어 있는 경우
* 이상적인 응집도
* 하나의 기능을 완벽하게 수행하는 모듈을 만들면 유지보수성이 높아진다.

```
// 예제
int calculateSum(int a, int b) {
    return a + b;
}
```

* 오직 덧셈만 수행하는 함수

***

### 응집도를 높이는 방법

* 하나의 모듈(클래스, 함수)은 하나의 역할만 수행하도록 설계한다.
* 관련된 기능들만 한 곳에 묶고, 연관이 없는 기능은 분리한다.
* SOLID 원칙 중 SRP(단일 책임 원칙)을 따르는 것이 중요하다.
