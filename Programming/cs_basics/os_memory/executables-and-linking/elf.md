# ELF 바이너리 형식 (ELF)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-EXL-002-DO |
| 유형 | D&O (개념) |
| 목적 | Linux 실행 파일 형식인 ELF의 구조와 Windows PE 형식과의 차이를 설명한다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 `readelf` 등을 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 "Linux 실행 파일 형식"이라는 한 줄과 외부 링크뿐이었다. 원본의 설명을 유지하고 링크는 5절 참조로 옮겼다. 구조, 종류, 섹션 표, PE 비교는 모두 추가했다.
{% endhint %}

## 1. 목적

ELF(Executable and Linkable Format)는 Linux와 대부분의 Unix 계열이 쓰는 실행 파일, 오브젝트 파일, 공유 라이브러리의 표준 파일 형식이다. 이 문서는 ELF의 구조와 PE 형식과의 차이를 정리한다.

## 2. 구성 요소

### 2.1 ELF 파일의 종류

| 종류(`e_type`) | 설명 | 예 |
|---|---|---|
| ET_REL | 재배치 가능한 오브젝트 파일 | `add.o` |
| ET_EXEC | 고정 주소에 올리는 실행 파일 | 비-PIE 실행 파일 |
| ET_DYN | 공유 객체 또는 위치 독립 실행 파일(PIE) | `libc.so`, 현대 배포판의 기본 실행 파일 |
| ET_CORE | 비정상 종료 시 메모리 덤프 | `core` 파일 |

실행 파일은 보통 확장자가 없다. `.bin`은 설치 스크립트 관례일 뿐 ELF의 필수 확장자가 아니다.

### 2.2 구조

| 구성 | 역할 |
|---|---|
| ELF 헤더 | 파일 맨 앞. 매직 넘버 `7f 45 4c 46`(`\x7fELF`), 32/64비트, 엔디안, 대상 아키텍처, 진입점 주소, 헤더 테이블 위치 |
| 프로그램 헤더 테이블 | 실행에 필요한 세그먼트 목록. 로더가 읽는다 |
| 섹션 헤더 테이블 | 섹션 목록. 링커와 분석 도구가 읽는다 |
| 섹션, 세그먼트 | 실제 내용 |

링커는 섹션을, 로더는 세그먼트를 본다. 세그먼트 하나가 여러 섹션을 묶는다.

### 2.3 주요 섹션

| 섹션 | 내용 |
|---|---|
| `.text` | 실행 코드 |
| `.rodata` | 읽기 전용 데이터(문자열 상수 등) |
| `.data` | 초기값이 있는 전역·정적 변수 |
| `.bss` | 초기값이 없는(0으로 초기화되는) 전역·정적 변수. 파일에는 크기만 기록한다 |
| `.symtab`, `.strtab` | 심볼 테이블, 문자열 테이블 |
| `.rela.text` 등 | 재배치 정보 |
| `.dynamic`, `.dynsym` | 동적 링크 정보와 동적 심볼 |
| `.plt`, `.got` | 동적 링크된 함수 호출을 위한 점프 테이블과 주소 테이블 |

### 2.4 ELF와 PE 비교

| 항목 | ELF (Linux) | PE (Windows) |
|---|---|---|
| 확장자 | 없음(공유 객체는 `.so`) | `.exe`, `.dll` |
| 시작 표식 | `7f 45 4c 46` | `MZ`(DOS 헤더), 이후 `PE\0\0` |
| 코드·데이터 섹션 | `.text`, `.rodata`, `.data`, `.bss` | `.text`, `.rdata`, `.data`, `.idata`(임포트), `.reloc`, `.rsrc` |
| 동적 링크 | `.dynamic`, GOT/PLT | 임포트 테이블(IAT) |
| macOS 형식 | Mach-O (별도 형식) | |

PE의 메모리 배치는 [Windows PE 메모리 레이아웃](../windows-internals/windowsmemorylayout.md)에서 다룬다.

## 3. 동작 원리

실행 파일의 확인 명령은 아래와 같다(이 환경에서는 실행하지 않았다, 미검증).

| 목적 | 명령 |
|---|---|
| ELF 헤더 보기 | `readelf -h <파일>` |
| 섹션 목록 | `readelf -S <파일>` |
| 세그먼트 목록 | `readelf -l <파일>` |
| 심볼 목록 | `nm <파일>` |
| 필요한 공유 라이브러리 | `ldd <파일>` |
| 파일 종류 | `file <파일>` |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ELF | Executable and Linkable Format |
| PE | Portable Executable. Windows 실행 파일 형식 |
| PIE | Position-Independent Executable. 위치 독립 실행 파일 |
| GOT/PLT | Global Offset Table / Procedure Linkage Table |

## 5. 참조

| 참조 | 비고 |
|---|---|
| [Linux Basic](https://krjaeh0.gitbook.io/j-log/cloud/linux-basics/linux-basic) | 원본이 가리킨 외부 문서(실행 파일 형식) |
| [링커와 로더](linking-and-loading.md) | PRG-EXL-003-DO |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 섹션과 세그먼트를 나누어 보는 이유를 링커와 로더의 역할로 적어 본다.
- [ ] `.bss`가 파일에서 크기만 차지하는 이유를 내 말로 적어 본다.
