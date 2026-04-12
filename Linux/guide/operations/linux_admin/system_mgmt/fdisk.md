# FDISK

FDISK는 리눅스 시스템에서 하드 디스크 파티션을 관리하는 명령줄 유틸리티로, 사용자가 디스크 파티션 테이블을 생성·수정·삭제할 수 있게 해줍니다. 이 도구는 특히 MBR(Master Boot Record) 파티션 테이블을 지원하지만, GPT(GUID Partition Table)는 지원하지 않습니다. ([LFCS Certification Prep](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/))

## 주요 명령어

* `n`: 새 파티션을 추가합니다.
* `d`: 기존 파티션을 삭제합니다.
* `p`: 파티션 테이블을 표시합니다.
* `q`: 변경사항을 저장하지 않고 종료합니다.
* `w`: 변경사항을 디스크에 쓰고 종료합니다.\
  (출처: [LFCS Certification Prep](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/))

## 파티션 제한 및 확장 파티션

* 기본적으로 최대 네 개의 기본 파티션을 만들 수 있습니다.
* 더 많은 파티션이 필요한 경우, 하나의 기본 파티션을 확장 파티션으로 설정하고 그 안에 여러 개의 논리 파티션을 포함시킬 수 있습니다. ([Linuxize](https://linuxize.com/post/fdisk-command-in-linux/))

{% hint style="danger" %}
FDISK는 파티션을 조정할 때 주의를 요구하는 도구입니다. 잘못된 사용은 데이터 손실로 이어질 수 있으므로, 변경 사항을 적용하기 전에 항상 현재의 파티션 구성을 검토하고, 필요한 경우 데이터를 백업하세요.\
(출처: [Linuxize](https://linuxize.com/post/fdisk-command-in-linux/), [LFCS Certification Prep](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/))
{% endhint %}

## 참고 자료

* Linuxize - Fdisk Command in Linux: https://linuxize.com/post/fdisk-command-in-linux/
* Tecmint - 10 fdisk Commands: https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/
