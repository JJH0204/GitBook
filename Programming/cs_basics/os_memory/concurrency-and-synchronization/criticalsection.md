# 임계 구역 (Critical Section)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CON-005-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 경쟁 상태가 생기는 과정과 임계 구역 문제의 해결 3요건, 해결 방법의 분류를 설명한다 |
| 확인 상태 | 미검증 (원본과 일반 지식을 정리한 것이며 코드를 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이전 정정(경쟁 상태에서는 load/add/store 사이에 끼어들어 2가 아니라 1만 증가할 수 있다, 해결 3요건은 상호 배제·진행·한정 대기)을 유지했다. 이번에 추가한 곳: 끼어들기 순서 표, 뮤텍스를 쓴 수정 예제, 해결 방법 설명, 3요건 설명의 표현 정리. 원본의 "**데이터 일관성**" 서식 오류도 고쳤다. [상호 배제](mutualexclusion.md)의 3요건 설명은 이 문서가 정본이다.
{% endhint %}

## 1. 목적

임계 구역(critical section)은 둘 이상의 프로세스나 스레드가 공유 자원(변수, 파일, 메모리 등)에 접근하는 코드 영역이다. 이 구역은 한 번에 하나의 실행 흐름만 실행해야 데이터 일관성(data consistency)이 유지된다.

## 2. 구성 요소

### 2.1 해결 3요건

임계 구역 문제를 해결하는 알고리즘은 아래 3가지를 모두 만족해야 한다.

| 요건 | 내용 |
|---|---|
| 상호 배제(Mutual Exclusion) | 임계 구역에는 한 번에 하나의 프로세스만 들어간다 |
| 진행(Progress) | 임계 구역이 비어 있고 들어가려는 프로세스가 있으면, 다음 진입자를 유한 시간 안에 정한다. 임계 구역 밖에서 실행 중인 프로세스는 이 결정에 관여하지 않는다 |
| 한정 대기(Bounded Waiting) | 진입을 요청한 프로세스는 다른 프로세스가 먼저 들어가는 횟수에 상한이 있어, 무한정 밀리지 않는다 |

{% hint style="warning" %}
CAUTION: 이 3요건은 교착 상태(deadlock)의 4가지 필요 조건(상호 배제, 점유 대기, 비선점, 순환 대기. Coffman 조건)과 다른 개념이다. 4조건은 [동기화 도구와 교착 상태](synchronization-primitives.md)에서 다룬다.
{% endhint %}

### 2.2 해결 방법의 분류

| 분류 | 방법 | 설명 |
|---|---|---|
| 알고리즘 | Peterson 알고리즘, Dekker 알고리즘 | 공유 변수(flag, turn)만으로 두 프로세스의 상호 배제를 구현한다. 현대 CPU는 메모리 접근 순서를 바꾸므로 메모리 장벽 없이 쓰면 깨질 수 있어 교육용 성격이 강하다 |
| 하드웨어 명령어 | Test-and-Set, Compare-and-Swap, Load-Link/Store-Conditional | 읽고 쓰는 동작을 쪼갤 수 없는 단일 원자적(atomic) 명령으로 수행한다. 잠금 구현의 바탕이다 |
| OS·언어 지원 | 뮤텍스, 세마포어, 모니터, 스핀락 | 운영체제나 언어가 제공하는 동기화 도구. [동기화 도구와 교착 상태](synchronization-primitives.md) 참조 |

### 2.3 발생 가능한 문제

| 문제 | 설명 |
|---|---|
| 경쟁 상태(Race Condition) | 둘 이상의 흐름이 공유 자원에 동시에 접근해 실행 순서에 따라 결과가 달라진다 |
| 교착 상태(Deadlock) | 서로가 가진 자원을 기다리며 무한 대기한다 |
| 기아 상태(Starvation) | 어떤 프로세스가 계속해서 임계 구역에 진입하지 못한다 |

## 3. 동작 원리

### 3.1 경쟁 상태

```c
// 공유 변수
int counter = 0;

// 임계 구역
counter = counter + 1;
```

`counter = counter + 1`은 기계어로 세 동작이다: 메모리에서 읽기(load), 1 더하기(add), 메모리에 쓰기(store). 두 프로세스가 동시에 실행할 때 중간에 끼어들면 2가 아니라 1만 증가할 수 있다.

| 순서 | 프로세스 1 | 프로세스 2 | counter(메모리) |
|---|---|---|---|
| 1 | load → 레지스터 = 0 | | 0 |
| 2 | | load → 레지스터 = 0 | 0 |
| 3 | add → 레지스터 = 1 | | 0 |
| 4 | | add → 레지스터 = 1 | 0 |
| 5 | store → 1 | | 1 |
| 6 | | store → 1 | 1 |

기대 값은 2이지만 결과는 1이다. 이런 예측하기 어려운 값 수정 때문에 값을 공유하는 프로세스들이 정상 동작하지 못할 수 있다.

## 4. 예제 코드

뮤텍스로 임계 구역을 보호하는 POSIX 스레드(pthreads) 예다(원본에 없던 코드, 컴파일·실행하지 않음). 두 스레드가 각각 1,000,000번 증가시키므로 결과는 2000000이어야 한다.

```c
#include <pthread.h>
#include <stdio.h>

static long counter = 0;
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

static void *worker(void *arg) {
    (void)arg;
    for (int i = 0; i < 1000000; i++) {
        pthread_mutex_lock(&lock);     // 임계 구역 진입
        counter = counter + 1;
        pthread_mutex_unlock(&lock);   // 임계 구역 탈출
    }
    return NULL;
}

int main(void) {
    pthread_t t1, t2;
    pthread_create(&t1, NULL, worker, NULL);
    pthread_create(&t2, NULL, worker, NULL);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    printf("%ld\n", counter);          // 2000000
    return 0;
}
```

### 4.1 코드 설명

| 줄 | 설명 |
|---|---|
| `static long counter` | 두 스레드가 공유하는 변수 |
| `pthread_mutex_lock` / `unlock` | 이 두 호출 사이가 임계 구역이다. 한 번에 한 스레드만 실행한다 |
| `pthread_join` | 두 스레드가 끝날 때까지 기다린 뒤 결과를 출력한다 |
| 빌드(참고) | `gcc counter.c -o counter -pthread` |

잠금 두 줄을 지우면 두 스레드가 `counter`를 동시에 읽고 쓰는 데이터 경쟁(data race)이 되어 C11 기준 정의되지 않은 동작이며, 보통 2000000보다 작은 값이 나온다.

## 5. 한계·주의

* 임계 구역은 짧게 유지한다. 잠금을 오래 쥐면 다른 스레드가 오래 기다린다.
* 잠금을 건 채 반환하거나 예외를 던지면 다른 스레드가 영원히 대기한다. 반드시 해제한다.
* 상호 배제만으로는 교착 상태와 기아를 막지 못한다.

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| 원자적(atomic) | 중간에 끼어들 수 없는 단일 동작 |
| 데이터 경쟁(data race) | 동기화 없이 둘 이상의 스레드가 같은 변수에 접근하고 하나 이상이 쓰는 상황 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `counter = counter + 1`이 한 줄인데도 안전하지 않은 이유를 내 말로 적어 본다.
- [ ] 상호 배제만 만족하고 진행이나 한정 대기를 만족하지 못하는 경우를 하나 상상해 적어 본다.
