# CLanguage

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
* [VS Code 로 C(C++) 개발하기](/broken/pages/7efc3b62a49becb94261f05d723f3b153de3faa9)
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

* [memset() 함수의 위험성](/broken/pages/d211162b82519e5cbde3744c2fc163cd96ae02b0)
{% endstep %}

{% step %}
### 세그멘테이션 오류

* [Segmentation Fault](file:///4766478/cs_basics/SegmentationFault.md)
{% endstep %}

{% step %}
### 자료구조 및 알고리즘

* [Data Structures And Algorithms](/broken/pages/13850983e411159352b3feb173687bfb26ea5f66)
{% endstep %}

{% step %}
### C 모듈화 에러

* [C 모듈화 에러](/broken/pages/3c78ac1c484f5e3dac2209d62760b5d70b3f546e)
{% endstep %}

{% step %}
### Xcode로 C언어 개발 환경설정

* https://nadocoding.tistory.com/94
{% endstep %}

{% step %}
### C 고급 문법

* [Bitmasks\_kr](file:///4766478/cs_basics/Bitmasks_kr.md)
* [Unions\_kr](file:///4766478/cs_basics/Unions_kr.md)
* [함수 포인터](/broken/pages/483d19201f67796ee20673b9787ef0aedef51565)
* [Pointer Arithmetics\_kr](/broken/pages/f5055a9c417d71f9ed7c6a96399cdea03b095471)
* [제네릭 프로그래밍](/broken/pages/3cf9debe464919c7f521e25486d0246379463ee4)
* [메모리 할당 유효성 점검 방법](/broken/pages/5d8892e490a9dd50a9d6e5718960a61770f426e5)
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
