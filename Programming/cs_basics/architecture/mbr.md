# 마스터 부트 레코드 (MBR)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARC-009-DO |
| 유형 | D&O (개념) |
| 목적 | MBR의 위치, 구조(446 + 64 + 2바이트), 시그니처, 한계를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 부팅 자료 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 AI 문체와 본문 속 인용 표기(`([Wikipedia])` 등)는 평서체로 정리하고 링크는 참조 절로 옮겼다. MBR 시그니처는 코드가 아니라 값이라는 정정은 유지했다. 바이트 구성 표(446 / 64 / 2)는 원본에 없어 추가했다.
{% endhint %}

## 1. 목적

마스터 부트 레코드(Master Boot Record, MBR)는 저장 장치(하드 드라이브 등)의 첫 번째 섹터(섹터 0)에 있는 특별한 부트 섹터다. 컴퓨터 부팅 과정을 시작하는 데 필요한 코드를 담는다. IBM PC 호환 시스템에서 쓰이며, 1983년 PC DOS 2.0과 함께 처음 도입되었다(원본 기술. 확인 필요).

## 2. 구성 요소

MBR은 512바이트 섹터 1개이며 어떤 파티션에도 속하지 않는다. 그래서 파티션을 삭제해도 MBR 코드는 남는다.

| 오프셋 | 크기 | 구성 | 설명 |
|---|---|---|---|
| 0 ~ 445 | 446바이트 | 부트스트랩 코드 영역 | 부트 로더의 코드가 들어 있다. 설치된 운영체제를 로드한다 |
| 446 ~ 509 | 64바이트 | 파티션 테이블 | 파티션 항목 4개(각 16바이트). 시작 위치, 크기, 파티션 종류 등을 담는다 |
| 510 ~ 511 | 2바이트 | MBR 시그니처 | 값 0x55AA. MBR이 유효한지 확인하는 데 쓴다. 코드가 아니라 값이다 |

{% hint style="info" %}
NOTE: 시그니처의 바이트 순서는 오프셋 510이 0x55, 오프셋 511이 0xAA다. 16비트 리틀 엔디언 값으로 읽으면 0xAA55다.
{% endhint %}

## 3. 동작 원리

1. 컴퓨터가 켜지면 BIOS가 하드웨어를 검사한다.
2. BIOS가 부팅 장치의 섹터 0을 메모리로 읽고, 시그니처(55 AA)가 유효하면 그 코드를 실행한다.
3. 부트스트랩 코드가 파티션 테이블에서 부팅할 파티션을 찾아 운영체제 로드를 시작한다.

MBR에 문제가 생기면 부팅이 불가능할 수 있다.

### 3.1 한계

| 한계 | 설명 |
|---|---|
| 디스크 용량 | 섹터 주소가 32비트라 512바이트 섹터 기준 2 TiB(약 2TB)까지만 다룬다 |
| 파티션 수 | 주(primary) 파티션이 최대 4개다 |

이 한계 때문에 더 크고 복잡한 저장 장치에는 GPT(GUID Partition Table) 방식이 쓰인다. GPT는 UEFI 부팅과 함께 쓰는 것이 일반적이다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| MBR | Master Boot Record |
| BIOS | Basic Input/Output System. 펌웨어 |
| GPT | GUID Partition Table |
| UEFI | Unified Extensible Firmware Interface |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Master boot record (Wikipedia)](https://en.wikipedia.org/wiki/Master_boot_record) | | 외부 문서 |
| [Master Boot Record (EaseUS)](https://www.easeus.com/diskmanager/master-boot-record.html) | | 외부 문서 |
| [MBR (MiniTool)](https://www.minitool.com/lib/mbr-master-boot-record.html) | | 외부 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 파티션을 모두 지워도 MBR 코드가 남는 이유를 내 말로 설명해 본다.
- [ ] MBR 디스크와 GPT 디스크 중 내 PC는 어느 쪽인지 확인한 방법을 적어 본다.
