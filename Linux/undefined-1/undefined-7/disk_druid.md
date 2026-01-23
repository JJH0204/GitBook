# Disk\_Druid

Disk Druid는 리눅스 시스템(특히 Red Hat과 Fedora)의 설치 과정에서 사용되는 GUI 기반 디스크 파티셔닝 도구입니다. 사용자가 하드 드라이브를 쉽게 파티셔닝하도록 도와주며, 파티션 추가·수정·삭제 등 주요 작업을 수행할 수 있습니다. 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/), [Fedora People](https://jsmith.fedorapeople.org/drafts/install-guide-en_US/sn-disk-druid.html).

## 주요 기능

* 파티션 생성 및 기존 파티션 크기 조정
* 파일 시스템 타입 변경
* LVM(Logical Volume Manager) 설정 지원
* 소프트웨어 RAID 구성 지원\
  이 도구는 확장성과 안정성을 고려한 데이터 저장 관리를 돕습니다. 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/), [Fedora People](https://jsmith.fedorapeople.org/drafts/install-guide-en_US/sn-disk-druid.html).

## 동작 방식

Disk Druid는 내부적으로 parted 유틸리티의 프런트 엔드(front-end)로 작동하여, 그래픽 인터페이스를 통해 파티션 관리를 쉽게 해줍니다. 출처: [MIT 문서](https://web.mit.edu/~linux/redhat/redhat-5.2/i386/doc/rhmanual/manual/doc033.htm).

{% stepper %}
{% step %}
### 파티션 추가

'Add' 버튼을 사용하여 새 파티션을 추가합니다. 새 파티션에 대한 세부 사항(파티션 타입, 크기, 마운트 포인트 등)을 입력할 수 있습니다. 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/).
{% endstep %}

{% step %}
### 파티션 수정

'Edit' 버튼을 사용하여 기존 파티션의 설정을 변경할 수 있습니다(크기 조정, 파일 시스템 변경 등). 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/).
{% endstep %}

{% step %}
### 파티션 삭제

'Delete' 버튼으로 선택한 파티션을 삭제할 수 있습니다. 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/).
{% endstep %}

{% step %}
### 변경사항 저장(Write) 또는 취소(Quit)

* 변경사항은 파티션 테이블에 즉시 적용되는 것이 아니라 메모리에만 저장됩니다.
* 디스크에 실제로 적용하려면 'Write' 버튼을 눌러야 합니다.
* 설정을 저장하지 않고 종료하려면 'Quit' 버튼을 사용하면 됩니다.\
  출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/).
{% endstep %}
{% endstepper %}

{% hint style="info" %}
Disk Druid는 설치 과정에서 주로 사용되며, GUI를 통해 리눅스 초보자도 파티션 작업을 비교적 쉽게 수행할 수 있도록 설계되어 있습니다. 출처: [Everything Linux 101 blog](https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/), [Fedora People](https://jsmith.fedorapeople.org/drafts/install-guide-en_US/sn-disk-druid.html).
{% endhint %}

## 참고 자료

* https://everything-linux-101.com/linux-fdisk-parted-and-disk-druid-hard-disk-partitioning-in-red-hat-linux-linux-commands-training/
* https://jsmith.fedorapeople.org/drafts/install-guide-en\_US/sn-disk-druid.html
* https://web.mit.edu/\~linux/redhat/redhat-5.2/i386/doc/rhmanual/manual/doc033.htm

더 자세한 사용법이나 추가 정보는 위의 링크들을 참고하세요.
