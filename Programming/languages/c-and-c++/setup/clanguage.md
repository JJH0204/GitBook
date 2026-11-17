# C 언어 학습 로드맵 및 메모

잊고 살았던 코딩 실력을 다시 일깨우는 작업

{% stepper %}
{% step %}
### Learn-C.org

* C언어 문법 및 기본 문제 출제
* https://www.learn-c.org/
{% endstep %}

{% step %}
### VS Code로 C(C++) 개발하기

* C/C++ 개발 초기 환경 설정 방법
* VS Code 로 C(C++) 개발하기
{% endstep %}

{% step %}
### 조건부 컴파일

* https://www.tcpschool.com/c/c\_compile\_condCompile
{% endstep %}

{% step %}
### sizeof(dataType) 정리

* https://blog.naver.com/dnltjdghks1/221238594256
{% endstep %}

{% step %}
### 진법 변환기

* https://www.digikey.kr/ko/resources/conversion-calculators/conversion-calculator-number-conversion
{% endstep %}

{% step %}
### memset() 함수의 위험성

* memset() 함수의 위험성
{% endstep %}

{% step %}
### 세그멘테이션 오류

* [Segmentation Fault](../../../cs-basics/cs_basics/os_memory/memory-management/segmentationfault.md)
{% endstep %}

{% step %}
### 자료구조 및 알고리즘

* [Data Structures And Algorithms](../../../cs-fundamentals/overviews/datastructurealgorithmoverview.md)
{% endstep %}

{% step %}
### C 모듈화 에러

* C 모듈화 에러
{% endstep %}

{% step %}
### Xcode로 C언어 개발 환경설정

* https://nadocoding.tistory.com/94
{% endstep %}

{% step %}
### C 고급 문법

* [Bitmasks\_kr](../advanced-c/bitmasks_kr.md)
* [Unions\_kr](../data-structures-c/unions_kr.md)
* 함수 포인터
* [Pointer Arithmetics\_kr](../pointers-and-memory/pointer-arithmetics_kr.md)
* 제네릭 프로그래밍
* 메모리 할당 유효성 점검 방법
{% endstep %}

{% step %}
### C/C++ 은 왜 안전하지 않은 언어일까?

둘의 장점

* 가비지 콜랙터가 없다.

둘의 단점

* 가비지 콜랙터가 없다.
* 그럼 가비지 콜랙터가 뭐지?
{% endstep %}
{% endstepper %}

<details>

<summary>그럼 가비지 콜랙터가 뭐지?</summary>

가비지 콜렉터(garbage collector)는 런타임에서 더 이상 사용되지 않는 메모리를 자동으로 탐지하고 해제하는 시스템입니다. 가비지 콜렉터가 있으면 개발자가 직접 메모리 해제하는 부담이 줄어들고, 메모리 누수 같은 버그가 감소합니다. 반대로 가비지 콜렉터가 없으면 메모리 할당과 해제를 개발자가 직접 관리해야 하며, 이로 인해 메모리 누수, 이중 해제, 댕글링 포인터 등 안전성 문제들이 발생할 수 있습니다.

</details>
