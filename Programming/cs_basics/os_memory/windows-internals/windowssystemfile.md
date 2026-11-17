# 가상 메모리 시스템 파일

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WIN-002-REF |
| 유형 | REF (표) |
| 목적 | Windows가 가상 메모리와 절전에 쓰는 시스템 파일의 용도를 구분한다 |
| 확인 상태 | 미검증 (일반 Windows 지식을 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 정정: 오타 "pageing"을 고쳤다. `swapfile.sys`를 "보조 저장 장치에 저장"이라 적었으나 실제로는 UWP(스토어) 앱의 중단된 메모리를 보관하는 파일이며 `pagefile.sys`와 별개다. `hiberfile.sys` 설명은 RAM 내용 저장으로 구체화했다. 합치기 대상이었던 [Windows PE 메모리 레이아웃](windowsmemorylayout.md)과는 주제가 달라 별도 파일로 유지했다.
{% endhint %}

## 파일 표

| 파일 | 용도 | 생성 조건 |
|---|---|---|
| `pagefile.sys` | 가상 메모리(페이징)용 파일. 물리 메모리가 부족할 때 페이지를 내보낸다 | 기본으로 생성된다(시스템 관리 크기) |
| `hiberfile.sys` | 최대 절전 모드와 빠른 시작에서 RAM 내용을 저장한다 | 최대 절전 모드가 활성화돼 있을 때 |
| `swapfile.sys` | UWP(스토어) 앱의 중단된 메모리를 보관한다. `pagefile.sys`와 별개다 | 시스템이 필요로 할 때 |

* 이 파일들은 보통 시스템 드라이브 루트(`C:\`)에 숨김 시스템 파일로 있다.
* 이 파일에는 메모리 내용 조각이 남을 수 있어 포렌식 분석 대상이 되기도 한다. 분석 시 증거 보존 규칙을 따른다([PRG-MEM-007-MP](../memory-management/memorycheck.md)).

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [virtualmemory.md](../memory-management/virtualmemory.md) | PRG-MEM-008-DO | 가상 메모리와 페이징 |
| [windowsmemorylayout.md](windowsmemorylayout.md) | PRG-WIN-001-DO | Windows PE 메모리 레이아웃 |
