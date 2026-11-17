# 파일 시스템 마운트 (mount)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-008-REF |
| 유형 | REF (명령 표) |
| 목적 | `mount`, `umount`의 형식과 옵션, `/etc/fstab` 필드를 찾아본다 |
| 확인 상태 | 미검증 (원본 페이지와 util-linux `mount`의 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

마운트는 저장 장치나 파일 시스템을 특정 디렉터리에 연결해 그 내용을 쓸 수 있게 하는 과정이다. 실제 작업 순서는 [파일 시스템 마운트와 fstab 등록](mount-fstab.md)(LNX-STB-009-MP)을 따른다.

{% hint style="danger" %}
WARNING: `/etc/fstab`을 잘못 고치면 다음 부팅에서 시스템이 멈추거나 비상 모드로 들어갈 수 있다. 편집은 LNX-STB-009-MP의 안전 사항과 절차를 따른다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 "마운트해도 기존 파일이 삭제되지 않는다"고 적었다. 장치 안의 파일은 유지된다. 그러나 내용이 있는 디렉터리 위에 마운트하면 마운트를 해제하기 전까지 그 디렉터리의 기존 파일이 가려져 보이지 않는다. 비어 있는 디렉터리를 마운트 지점으로 쓴다.
{% endhint %}

## 1. 기본 형식

| 동작 | 명령 |
|---|---|
| 마운트 | `mount <장치> <마운트 지점>` |
| 해제 | `umount <장치 또는 마운트 지점>` |
| 현재 마운트 목록 | `mount` |
| 특정 형식만 목록 | `mount -t ext4` |

해제는 마운트 지점 안이 아닌 밖의 디렉터리에서 실행한다. 마운트 지점 안에서 작업 중이면 `target is busy` 오류가 나온다.

## 2. mount 옵션

| 옵션 | 동작 | 예 |
|---|---|---|
| `-t <형식>` | 파일 시스템 형식을 지정한다 (ext4, nfs, iso9660 등) | `mount -t ext4 /dev/sda1 /mnt` |
| `-o <옵션>` | 쉼표로 구분한 마운트 옵션을 지정한다 | `mount -o ro /dev/sda1 /mnt` |
| `-a` | `/etc/fstab`에 적힌 모든 파일 시스템을 마운트한다 | `mount -a` |
| `-r` | 읽기 전용으로 마운트한다 (`-o ro`와 같다) | `mount -r /dev/sda1 /mnt` |
| `-n` | `/etc/mtab`을 갱신하지 않는다 | `mount -n /dev/sda1 /mnt` |
| `-v` | 상세 정보를 출력한다 | `mount -v /dev/sda1 /mnt` |
| `-L <라벨>` | 볼륨 라벨로 장치를 지정한다 | `mount -L <라벨> /mnt` |

## 3. -o 옵션 값

| 값 | 동작 | 예 |
|---|---|---|
| `ro` | 읽기 전용 | `mount -o ro /dev/sda1 /mnt` |
| `rw` | 읽기·쓰기 | `mount -o rw /dev/sda1 /mnt` |
| `noatime` | 파일 접근 시간을 갱신하지 않는다 (쓰기 감소) | `mount -o noatime /dev/sda1 /mnt` |
| `async` | 비동기 쓰기 | `mount -o async /dev/sda1 /mnt` |
| `sync` | 동기 쓰기 | `mount -o sync /dev/sda1 /mnt` |
| `remount` | 이미 마운트된 파일 시스템의 옵션을 바꾼다 | `mount -o remount,rw /mnt` |
| `loop` | ISO 같은 이미지 파일을 마운트한다 | `mount -o loop image.iso /mnt` |
| `defaults` | 기본 옵션 묶음(rw, suid, dev, exec, auto, nouser, async) | `/etc/fstab`에서 주로 쓴다 |

## 4. 마운트 예

| 대상 | 명령 |
|---|---|
| 장치 | `sudo mount /dev/sdb1 /mnt/media` |
| USB | `sudo mount /dev/<장치>1 /mnt/usb` |
| 옵션 지정 USB | `sudo mount -o rw,async /dev/sdb1 /mnt/usb` |
| NFS 공유 | `sudo mount -t nfs <서버>:/<공유 경로> /mnt/nfs` |
| NFS 버전 지정 | `sudo mount -t nfs -o rw,vers=4 <서버>:/<공유 경로> /mnt/nfs` |
| tmpfs(메모리 디스크) | `sudo mount -t tmpfs tmpfs /mnt/ramdisk` |
| ISO 파일 | `sudo mount -o loop image.iso /mnt/iso` |
| DVD | `mount /dev/cdrom /mnt/dvd` |

## 5. umount 오류

| 증상 | 원인 | 조치 |
|---|---|---|
| `target is busy` | 마운트 지점을 쓰는 프로세스나 셸이 있다 | 마운트 지점 밖으로 `cd`하고, `fuser -mv <마운트 지점>` 또는 `lsof +f -- <마운트 지점>`으로 사용 중인 프로세스를 확인해 종료한 뒤 다시 `umount`한다 |
| `not mounted` | 이미 해제됐거나 이름이 틀렸다 | `mount` 목록으로 정확한 이름을 확인한다 |

## 6. /etc/fstab 필드

`/etc/fstab`은 부팅 때 자동 마운트할 파일 시스템과 옵션을 적는 파일이다. 한 줄에 6개 필드를 공백으로 구분해 쓴다.

```
<장치> <마운트 지점> <형식> <옵션> <dump> <pass>
```

| 번호 | 필드 | 뜻 |
|---|---|---|
| 1 | 장치 | 장치 이름(`/dev/sdb1`), `UUID=<UUID>`, `LABEL=<라벨>` 중 하나 |
| 2 | 마운트 지점 | 연결할 디렉터리 |
| 3 | 형식 | 파일 시스템 형식. 예: `ext4`, `xfs`, `nfs` |
| 4 | 옵션 | 쉼표로 구분한 마운트 옵션. 예: `defaults` |
| 5 | dump | `dump` 백업 대상 여부. `0` 또는 `1` |
| 6 | pass | 부팅 때 `fsck` 검사 순서. `/`는 `1`, 다른 파일 시스템은 `2`, 검사 안 함은 `0` |

예시 줄(원본):

```
/dev/sdb1 /mnt/media ext4 defaults 0 0
```

UUID로 쓴 줄:

```
UUID=<UUID> /mnt/media ext4 defaults 0 0
```

## 7. 장치 찾기

| 명령 | 용도 |
|---|---|
| `fdisk -l` | 연결된 저장 장치와 파티션을 나열한다 (root 필요) |
| `lsblk` | 디스크와 파티션을 트리로 본다 |
| `blkid` | 장치의 UUID, 형식, 라벨을 본다 |

## 8. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [파일 시스템 마운트와 fstab 등록](mount-fstab.md) | LNX-STB-009-MP | 작업 절차 |
| [fdisk 파티션 관리 유틸리티](../operations/linux_admin/system_mgmt/fdisk.md) | LNX-LAS-002-REF | `fdisk -l` |
