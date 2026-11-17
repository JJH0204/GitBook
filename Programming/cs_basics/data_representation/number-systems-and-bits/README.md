# 진법과 비트 (Number & Bits)

2진수·16진수 표기, 비트와 바이트, 2의 보수, 바이트 순서, 비트 연산을 정리한다. 문서 번호(Task ID)는 `PRG-NUM-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-NUM-001-DO | 개념 | [비트와 바이트](bit_byte.md) | 비트, 니블, 바이트, KB/KiB를 구분한다 |
| PRG-NUM-002-DO | 개념 | [진법 체계](numbersystems.md) | 2·8·10·16진법과 변환 방법을 이해한다 |
| PRG-NUM-003-DO | 개념 | [최상위 및 최하위 비트](msb_n_lsb.md) | MSB, LSB, 부호 비트를 이해한다 |
| PRG-NUM-004-DO | 개념 | [2진법과 2의 보수](binary.md) | 부호 있는 정수의 범위와 부동소수점 구조를 이해한다 |
| PRG-NUM-005-DO | 개념 | [바이트 순서](byte_ordering.md) | 빅/리틀 엔디안과 네트워크 바이트 순서를 이해한다 |
| PRG-NUM-006-DO | 개념 | [비트 연산 및 시프트](bit_operation.md) | 논리·비트·시프트 연산과 마스킹을 이해한다 |
| PRG-NUM-007-DO | 개념 | [컴파일과 디스어셈블](compile-and-disassemble.md) | 컴파일 4단계와 디스어셈블·디컴파일을 구분한다 |

## 읽는 순서

1. PRG-NUM-001-DO, PRG-NUM-002-DO, PRG-NUM-003-DO 순서로 비트와 진법의 기본을 읽는다.
2. PRG-NUM-004-DO로 정수와 실수가 비트로 저장되는 방식을 읽는다.
3. PRG-NUM-005-DO, PRG-NUM-006-DO를 읽는다.
4. 바이너리 분석에 관심이 있으면 PRG-NUM-007-DO를 읽는다.
