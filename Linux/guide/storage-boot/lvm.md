# [생성형 AI] 논리 볼륨 관리자 (LVM) 개념

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-010-DO |
| 유형 | D&O (개념) |
| 목적 | LVM의 구성 요소(PV, VG, LV)와 파티션 방식과의 차이, 기본 명령을 설명한다 |
| 확인 상태 | 미검증 (이 환경에 LVM 도구가 없어 실행하지 못했다. 공식 man 문서의 알려진 동작을 정리한 것이다) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

LVM(Logical Volume Manager)은 여러 물리 디스크나 파티션을 하나의 저장 공간 풀로 묶고, 그 안에서 크기를 바꿀 수 있는 논리 볼륨을 잘라 쓰게 해 준다. 고정된 파티션과 달리 서비스를 멈추지 않거나 짧은 중단으로 용량을 늘릴 수 있다.

## 2. 구성 요소

| 번호 | 구성 요소 | 약어 | 역할 | 조회 명령 |
|---|---|---|---|---|
| 1 | 물리 볼륨(Physical Volume) | PV | LVM이 쓰도록 초기화한 디스크 또는 파티션 | `pvs` |
| 2 | 볼륨 그룹(Volume Group) | VG | 하나 이상의 PV를 묶은 저장 공간 풀 | `vgs` |
| 3 | 논리 볼륨(Logical Volume) | LV | VG에서 잘라 낸 공간. 파일 시스템을 만들어 마운트한다 | `lvs` |

LV는 `/dev/<VG 이름>/<LV 이름>`(또는 `/dev/mapper/<VG>-<LV>`)로 접근한다.

## 3. 동작 원리

1. 디스크 또는 파티션을 PV로 초기화한다: `pvcreate <장치>`
2. PV를 묶어 VG를 만든다: `vgcreate <VG 이름> <장치>`
3. VG에서 LV를 만든다: `lvcreate -L <크기> -n <LV 이름> <VG 이름>`
4. LV에 파일 시스템을 만들고 마운트한다(LNX-STB-009-MP): `mkfs.xfs /dev/<VG 이름>/<LV 이름>`
5. 용량이 모자라면 VG에 여유가 있을 때 LV를 늘린다: `lvextend -r -L +<크기> /dev/<VG 이름>/<LV 이름>`. `-r`은 파일 시스템 크기도 함께 늘린다. VG에 여유가 없으면 먼저 `vgextend <VG 이름> <새 장치>`로 PV를 추가한다.

| 비교 | 파티션(fdisk) | LVM |
|---|---|---|
| 크기 변경 | 어렵다 | 비교적 쉽다 |
| 여러 디스크 묶기 | 불가능 | VG로 가능 |
| 구성 복잡도 | 낮다 | 계층이 늘어 높다 |

{% hint style="danger" %}
WARNING: `pvcreate`, `lvremove`, `vgremove`는 해당 장치의 데이터를 지우거나 접근할 수 없게 만든다. 장치 이름을 잘못 고르면 다른 디스크의 데이터가 사라진다. `lsblk`로 대상을 확인한 뒤 실습 디스크에서만 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: LV를 줄이는(`lvreduce`) 작업은 파일 시스템이 지원할 때만 가능하다. XFS는 줄일 수 없다. 늘리는 작업만 일반적으로 안전하다.
{% endhint %}

## 4. 관련 문서

| Task ID | 문서 | 용도 |
|---|---|---|
| LNX-LAS-002-REF | [fdisk 파티션 관리 유틸리티](../operations/linux_admin/system_mgmt/fdisk.md) | 파티션 방식과 비교한다 |
| LNX-STB-009-MP | [파일 시스템 마운트와 fstab 등록](mount-fstab.md) | LV를 마운트한다 |

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| PV, VG, LV | 물리 볼륨, 볼륨 그룹, 논리 볼륨 |
| LVM | Logical Volume Manager |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] PV, VG, LV의 관계를 내 말로 설명해 보자
- [ ] 디스크 용량이 부족했던 경험이 있다면 파티션과 LVM 중 무엇이 더 맞았을지 적어 보자
- [ ] LV를 늘리는 순서를 기억나는 대로 적어 보자
