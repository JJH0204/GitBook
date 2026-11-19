# [생성형 AI] 데이터 표현 (Data Repr)

컴퓨터가 숫자와 문자를 비트로 표현하는 방식을 다룬다. 문서 번호(Task ID)는 하위 그룹마다 `PRG-<그룹>-<번호>-<유형>` 형식이다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 그룹 README (안내) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (하위 문서 목록과 링크를 기준으로 작성했으며 본문 내용을 새로 검증하지 않았다) |

## 하위 그룹

| 그룹 | 폴더 | 다루는 내용 |
|---|---|---|
| 진법과 비트 (PRG-NUM) | [진법과 비트](number-systems-and-bits/README.md) | 비트와 바이트, 2진법, 2의 보수, 바이트 순서, 비트 연산 |
| 인코딩 및 형식 (PRG-ENC) | [인코딩 및 형식](encoding-and-formats/README.md) | ASCII, 유니코드, Base64, 개행 문자 |
| 해싱 및 체크섬 (PRG-HSH) | [해싱 및 체크섬](hashing-and-checksums/README.md) | 해시 함수, MD5, 체크섬 |

## 읽는 순서

1. 진법과 비트로 비트·바이트 표현을 익힌다.
2. 인코딩 및 형식에서 문자가 바이트가 되는 과정을 읽는다.
3. 해싱 및 체크섬을 읽는다.

## 이 영역이 다루는 것

컴퓨터는 모든 정보를 비트(0 또는 1)로 저장한다. 이 영역은 숫자가 비트로 바뀌는 규칙, 문자가 바이트로 바뀌는 규칙, 데이터를 고정 길이 값으로 요약하는 방법을 순서대로 다룬다. 프로그래밍 입문자와 보안·시스템 학습자가 메모리 덤프나 네트워크 패킷을 읽기 전에 읽는 것을 가정한다.

## 하위 문서 목록

| 그룹 | 문서 | 용도 |
|---|---|---|
| 진법과 비트 | [비트와 바이트](number-systems-and-bits/bit_byte.md) | 비트와 바이트 단위를 구분한다 |
| 진법과 비트 | [진법 체계](number-systems-and-bits/numbersystems.md) | 2·8·10·16진법을 서로 변환한다 |
| 진법과 비트 | [2진법과 2의 보수](number-systems-and-bits/binary.md) | 음수 표현을 이해한다 |
| 진법과 비트 | [최상위 및 최하위 비트](number-systems-and-bits/msb_n_lsb.md) | MSB와 LSB의 위치를 구분한다 |
| 진법과 비트 | [바이트 순서](number-systems-and-bits/byte_ordering.md) | 리틀 엔디언과 빅 엔디언을 구분한다 |
| 진법과 비트 | [비트 연산 및 시프트](number-systems-and-bits/bit_operation.md) | AND, OR, XOR, 시프트를 사용한다 |
| 진법과 비트 | [컴파일과 디스어셈블](number-systems-and-bits/compile-and-disassemble.md) | 코드가 기계어가 되는 과정을 확인한다 |
| 인코딩 및 형식 | [아스키 코드](encoding-and-formats/ascii.md) | 7비트 문자 코드를 확인한다 |
| 인코딩 및 형식 | [유니코드](encoding-and-formats/unicode.md) | 문자 집합과 인코딩 방식을 구분한다 |
| 인코딩 및 형식 | [인코딩과 디코딩](encoding-and-formats/encoding_decoding.md) | 두 용어의 방향을 구분한다 |
| 인코딩 및 형식 | [Base64 인코딩](encoding-and-formats/base64.md) | 바이너리를 텍스트로 바꾸는 방식을 이해한다 |
| 인코딩 및 형식 | [개행 문자](encoding-and-formats/crlf.md) | CR, LF, CRLF의 차이를 구분한다 |
| 해싱 및 체크섬 | [단방향 해싱](hashing-and-checksums/hashing.md) | 해시 함수의 성질을 이해한다 |
| 해싱 및 체크섬 | [MD5 해시 알고리즘](hashing-and-checksums/md5.md) | MD5의 구조와 한계를 확인한다 |

## 선수 지식과 핵심 용어

* 선수 지식: 10진수 계산. 프로그래밍 경험은 필수가 아니다.
* 비트(bit): 정보의 최소 단위. 바이트(byte)는 보통 8비트다.
* 진법: 수를 표현하는 자릿수 체계. 컴퓨터는 2진법, 사람은 보통 10진법과 16진법을 쓴다.
* 인코딩: 문자나 데이터를 정해진 규칙에 따라 바이트열로 바꾸는 것.
* 해시: 임의 길이 입력을 고정 길이 값으로 요약한 결과.
