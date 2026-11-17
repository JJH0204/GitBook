# 디스크 드루이드 파티셔닝 도구

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-001-DO |
| 유형 | D&O (개념·구조) |
| 목적 | 설치 과정에서 쓰이는 GUI 파티셔닝 도구 Disk Druid의 기능과 동작을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 참조 문서를 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: Disk Druid는 옛 Red Hat 계열 설치 프로그램의 도구다. 현재 RHEL 계열 설치 프로그램(Anaconda)은 `설치 대상` 화면의 사용자 지정 파티션 기능으로 같은 작업을 한다. 이 대응 관계는 일반 지식이며 미검증이다.
{% endhint %}

## 1. 목적

Disk Druid는 리눅스 설치 중에 하드 드라이브를 GUI로 파티셔닝하는 도구다. 파티션 추가·수정·삭제를 마우스로 한다. 실제 명령줄 파티셔닝은 [fdisk 파티션 관리 유틸리티](../operations/linux_admin/system_mgmt/fdisk.md)(LNX-LAS-002-REF)를 쓴다.

## 2. 구성 요소

| 번호 | 버튼·기능 | 역할 |
|---|---|---|
| 1 | Add | 새 파티션을 추가한다. 파티션 타입, 크기, 마운트 포인트를 입력한다 |
| 2 | Edit | 기존 파티션의 설정(크기, 파일 시스템)을 바꾼다 |
| 3 | Delete | 선택한 파티션을 삭제한다 |
| 4 | Write | 메모리에 있는 변경을 디스크의 파티션 테이블에 기록한다 |
| 5 | Quit | 변경을 저장하지 않고 종료한다 |

그 밖의 지원 기능은 다음과 같다.

* LVM(Logical Volume Manager) 설정
* 소프트웨어 RAID 구성
* 파일 시스템 타입 변경

## 3. 동작 원리

1. 사용자가 Add, Edit, Delete로 파티션 구성을 바꾼다.
2. 변경은 파티션 테이블에 즉시 적용되지 않고 메모리에만 저장된다.
3. 사용자가 Write를 누르면 변경이 디스크에 기록된다.
4. Quit을 누르면 기록 없이 종료한다.

원본 출처는 Disk Druid가 내부적으로 `parted` 유틸리티의 프런트 엔드로 동작한다고 설명한다. 이 설명은 미검증이다.

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 파티션(partition) | 디스크를 나눈 논리적 영역 |
| 마운트 포인트(mount point) | 파티션을 연결하는 디렉터리. 예: `/`, `/boot` |
| LVM | Logical Volume Manager. 여러 디스크를 묶어 크기를 유연하게 쓰는 방식 |
| RAID | 여러 디스크를 묶어 속도나 안정성을 높이는 방식 |

## 5. 참조

* [Everything Linux 101: fdisk, parted, Disk Druid](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/)
* [Fedora Install Guide draft: Disk Druid](https://jsmith.fedorapeople.org/drafts/install-guide-en_US/sn-disk-druid.html)
* [Red Hat 5.2 설치 매뉴얼](https://web.mit.edu/~linux/redhat/redhat-5.2/i386/doc/rhmanual/manual/doc033.htm)
* [fdisk 파티션 생성과 삭제](../operations/linux_admin/system_mgmt/fdisk-partition.md) (LNX-LAS-003-MP)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 변경이 Write를 누르기 전까지 디스크에 기록되지 않는 방식은 어떤 점에서 안전한가?
- [ ] 마운트 포인트를 `/`와 `/boot`로 나누는 이유를 내 말로 설명해 보자.
- [ ] 설치 프로그램의 GUI 파티셔닝과 `fdisk` 명령을 써 본 경험이 있다면 차이를 적어 보자.
