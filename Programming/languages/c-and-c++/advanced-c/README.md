# C 언어 고급 (Advanced C)

C 언어의 고급 주제(함수 포인터, 제네릭 프로그래밍, 비트마스크, `memset` 정적 분석 경고)를 정리한 그룹이다. 문서 번호(Task ID)는 `PRG-ADC-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-ADC-001-DO | D&O + 예제 | [함수 포인터 (Function Pointer)](function-pointers.md) | 함수 포인터 선언, 호출, `qsort` 콜백을 이해한다 |
| PRG-ADC-002-DO | D&O + 예제 | [제네릭 프로그래밍 (Generics)](genericprogramming.md) | `void *` 기반 스택으로 C의 제네릭 구현을 이해한다 |
| PRG-ADC-003-DO | D&O + 예제 | [비트마스크 상세 (Bitmasks)](bitmasks_kr.md) | 비트 설정, 해제, 토글, 검사를 이해한다 |
| PRG-ADC-004-TS | TS | [memset 함수 안전성 (memset)](memset.md) | `memset` 보안 경고의 원인과 조치를 확인한다 |

## 읽는 순서

1. PRG-ADC-001-DO로 함수 포인터를 익힌다.
2. PRG-ADC-002-DO에서 함수 포인터(콜백)와 `void *`를 함께 쓰는 방법을 본다.
3. PRG-ADC-003-DO와 PRG-ADC-004-TS는 순서와 무관하게 읽는다.
