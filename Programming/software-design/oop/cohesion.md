# 응집도 (Cohesion)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-OOP-004-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 모듈 응집도의 정의와 일곱 단계를 예제와 함께 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

응집도(cohesion)는 모듈(클래스, 함수) 안의 구성 요소가 서로 얼마나 밀접하게 연관돼 있는지를 나타낸다. "모듈 내부의 기능이 하나의 목적에 얼마나 집중돼 있는가"를 재는 척도다.

| 수준 | 특징 |
|---|---|
| 높은 응집도 | 모듈이 하나의 목적에 집중한다. 단일 책임 원칙([SRP](../solid/srpsingleresponsibilityprinciple.md))에 가깝고 유지보수와 재사용이 쉽다 |
| 낮은 응집도 | 여러 기능이 섞여 있어 한 기능을 바꿀 때 다른 기능이 영향받기 쉽다 |

{% hint style="info" %}
NOTE: 응집도는 높게, 결합도는 낮게 만든다. 결합도는 [결합도 (Coupling)](coupling.md)를 본다.
{% endhint %}

## 2. 구성 요소

| 순서 | 유형 | 특징 | 수준 |
|---|---|---|---|
| 1 | 우연적 응집도 (Coincidental) | 기능이 아무 연관 없이 모여 있다 | 가장 낮다 |
| 2 | 논리적 응집도 (Logical) | 같은 범주의 기능이지만 입력값에 따라 다른 기능이 실행된다 | 낮다 |
| 3 | 시간적 응집도 (Temporal) | 실행 시점이 같은 기능을 묶는다 | 낮다 |
| 4 | 절차적 응집도 (Procedural) | 정해진 순서로 실행되는 기능을 묶는다 | 중간이다 |
| 5 | 통신적 응집도 (Communicational) | 같은 입력 데이터를 공유하는 기능을 묶는다 | 중간 이상이다 |
| 6 | 순차적 응집도 (Sequential) | 한 기능의 출력이 다음 기능의 입력이다 | 높다 |
| 7 | 기능적 응집도 (Functional) | 모든 요소가 단 하나의 목적을 위해 존재한다 | 가장 높다 |

## 3. 동작 원리

아래 예제는 C 문법으로 쓴 설명용 코드이며 호출하는 함수의 정의는 생략했다. 문자열은 `const char *`, 나머지 타입은 불투명 포인터로 표현한다.

### 3.1 우연적 응집도 (가장 낮음)

서로 무관한 기능이 한 함수에 있다. 즉시 분리해야 한다.

```c
void utilityFunction(void) {
    printReport();
    calculateTax();
    saveToDatabase();
}
```

보고서 출력, 세금 계산, 데이터 저장이 연관 없이 모였다.

### 3.2 논리적 응집도

입력값에 따라 서로 다른 기능이 실행된다. 마우스와 키보드 입력 처리가 한 함수에 섞여 있다.

```c
void handleUserInput(int inputType) {
    if (inputType == 1) handleMouseInput();
    else if (inputType == 2) handleKeyboardInput();
}
```

### 3.3 시간적 응집도

실행 시점이 같다는 이유만으로 묶었다. 초기화 작업을 한 곳에 모은 경우가 대표적이다.

```c
void initializeSystem(void) {
    loadConfig();
    initializeDatabase();
    setupUI();
}
```

실행 순서는 맞지만 기능 범위가 넓다. 더 세분화하는 편이 좋다.

### 3.4 절차적 응집도

정해진 순서로 실행되지만 각 단계가 서로 다른 기능이다.

```c
void processOrder(void) {
    validateOrder();
    calculatePrice();
    generateInvoice();
}
```

### 3.5 통신적 응집도

같은 데이터를 쓰는 기능이지만 하는 일이 다르다.

```c
void processUserData(User *user) {
    validateUser(user);
    saveUserToDatabase(user);
    sendWelcomeEmail(user);
}
```

### 3.6 순차적 응집도

앞 단계의 출력이 뒷 단계의 입력으로 이어진다. `tokenize → parse → generateCode` 순서로 데이터가 흐른다.

```c
void analyzeText(const char *text) {
    TokenList *tokens = tokenize(text);
    SyntaxTree *tree = parse(tokens);
    generateCode(tree);
}
```

### 3.7 기능적 응집도 (가장 높음)

하나의 목적만 수행한다. 이상적인 응집도다.

```c
int calculateSum(int a, int b) {
    return a + b;
}
```

## 4. 응집도를 높이는 방법

1. 모듈(클래스, 함수) 하나에 역할 하나만 맡긴다.
2. 관련된 기능만 한 곳에 묶고 연관 없는 기능은 분리한다.
3. 단일 책임 원칙([SRP](../solid/srpsingleresponsibilityprinciple.md))에 맞춰 변경 이유별로 나눈다.

{% hint style="info" %}
NOTE: 순차적·통신적 응집도처럼 중간 단계도 실무에서 자주 쓴다. 모든 함수를 기능적 응집도로 만들 필요는 없다. 우연적·논리적 응집도를 먼저 없애는 것이 우선이다.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| 모듈 | 함수, 클래스, 파일처럼 독립적으로 다루는 단위 |
| 응집도 | 모듈 내부 요소 사이의 연관 정도. 높을수록 좋다 |
| 책임 | 변경이 필요해지는 이유 하나 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 내 코드에서 "utils", "manager"처럼 여러 일을 하는 모듈이 있는가? 어떤 유형의 응집도인가?
- [ ] 응집도와 단일 책임 원칙은 어떤 관계인가?
