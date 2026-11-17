# C 언어 학습 로드맵 및 메모

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CST-002-REF |
| 유형 | REF (학습 주제 순서와 문서 위치 표) |
| 목적 | C 언어를 다시 학습할 때 거치는 주제의 순서와, 주제별 문서·외부 자료 위치를 한눈에 찾게 한다 |
| 확인 상태 | 미검증 (원본 목록을 표로 정리했다. 외부 링크의 현재 접속 여부는 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 순서

| 순서 | 주제 | 이 저장소의 문서 | 외부 자료 |
|---|---|---|---|
| 1 | C 문법과 기본 문제 풀이 | [C 언어 기초](../c-fundamentals/README.md) | [Learn-C.org](https://www.learn-c.org/) |
| 2 | 개발 환경 | [VS Code C/C++ 환경 설정](intro.md) | Xcode 사용 시: [Xcode로 C 개발 환경 설정](https://nadocoding.tistory.com/94) |
| 3 | 조건부 컴파일 | [전처리 과정](../build-and-tooling/preprocessing.md) | [TCP School: 조건부 컴파일](https://www.tcpschool.com/c/c_compile_condCompile) |
| 4 | `sizeof`와 자료형 크기 | [변수와 자료형](../c-fundamentals/variables-and-types.md) | [sizeof(dataType) 정리](https://blog.naver.com/dnltjdghks1/221238594256) |
| 5 | 진법 변환 | [진법과 비트](../../../cs_basics/data_representation/number-systems-and-bits/README.md) | [DigiKey 진법 변환기](https://www.digikey.kr/ko/resources/conversion-calculators/conversion-calculator-number-conversion) |
| 6 | `memset()` 함수의 위험성 | [memset 함수 안전성](../advanced-c/memset.md) | |
| 7 | 세그멘테이션 오류 | [Segmentation Fault](../../../cs_basics/os_memory/memory-management/segmentationfault.md) | |
| 8 | 자료구조와 알고리즘 | [Data Structures And Algorithms](../../../cs-fundamentals/overviews/datastructurealgorithmoverview.md) | |
| 9 | C 모듈화 에러 | [C 모듈화 에러 해결](../build-and-tooling/cmodularizationerror.md) | |
| 10 | C 고급 문법 | 아래 2절 | |
| 11 | C/C++가 안전하지 않은 이유 | 아래 3절 | |

## 2. C 고급 문법 문서

| 주제 | 문서 |
|---|---|
| 비트마스크 | [비트마스크 상세](../advanced-c/bitmasks_kr.md) |
| 공용체 | [공용체 상세](../data-structures-c/unions_kr.md) |
| 함수 포인터 | [함수 포인터](../advanced-c/function-pointers.md) |
| 포인터 연산 | [포인터 연산 상세](../pointers-and-memory/pointer-arithmetics_kr.md) |
| 제네릭 프로그래밍 | [제네릭 프로그래밍](../advanced-c/genericprogramming.md) |
| 메모리 할당 유효성 점검 | [메모리 할당 유효성 점검](../../../cs_basics/os_memory/memory-management/memoryallocationvaliditycheck.md) |

## 3. C/C++가 안전하지 않은 이유 (메모)

C와 C++는 표준 언어 차원의 가비지 컬렉터(garbage collector, GC)가 없다. 이 점은 장점이자 단점이다.

| 구분 | 내용 |
|---|---|
| 장점 | GC가 실행 중에 끼어들지 않아 메모리 사용 시점과 해제 시점을 프로그래머가 정확히 통제한다 |
| 단점 | 메모리 할당과 해제를 프로그래머가 직접 관리해야 한다 |
| 단점에서 생기는 문제 | 메모리 누수, 이중 해제(double free), 해제 후 사용(use after free, 댕글링 포인터), 범위 밖 접근 |

용어:

* 가비지 컬렉터: 실행 중 더 이상 쓰이지 않는 메모리를 자동으로 찾아 해제하는 시스템이다. GC가 있으면 직접 해제하는 부담과 누수 버그가 줄어든다.
* 메모리 누수와 이중 해제의 구분: 해제하지 않은 메모리는 프로그램이 계속 점유하는 버그다. 이미 해제한 메모리를 다시 `free()`하거나 해제 후 접근하는 것은 정의되지 않은 동작(UB)이다. 자세한 코드는 [동적 메모리 할당](../pointers-and-memory/dynamic-allocation.md)을 본다.

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지(단계 목록 + 접기 블록)를 표 형식 REF로 재작성. 링크 없던 항목에 저장소 내부 링크를 연결. GC 설명을 3절 표로 옮기고 안전성 문제(누수, 이중 해제, 해제 후 사용)를 UB와 버그로 구분해 추가 |
