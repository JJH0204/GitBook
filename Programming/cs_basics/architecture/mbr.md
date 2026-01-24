# MBR

Master Boot Record (MBR)는 하드 드라이브나 다른 저장 장치에 위치한 특별한 부트 섹터로, 컴퓨터 부팅 과정을 시작하는 데 필요한 코드를 포함하고 있습니다. MBR은 특히 IBM PC 호환 시스템에서 사용되며, 1983년 PC DOS 2.0과 함께 처음 소개되었습니다 ([Wikipedia](https://en.wikipedia.org/wiki/Master_boot_record)).

#### MBR의 위치 및 구조

MBR은 하드 드라이브의 첫 번째 섹터(섹터 0)에 위치하며, 이 위치는 어떠한 파티션에도 속하지 않습니다. 이로 인해 파티션을 삭제하더라도 MBR 코드는 여전히 남아 있습니다 ([EaseUS](https://www.easeus.com/diskmanager/master-boot-record.html)). MBR은 다음 세 부분으로 구성됩니다:

* 부트스트랩 코드 영역: 부트 로더의 실제 코드가 들어 있는 곳으로, 설치된 운영 체제를 로드하는 기능을 수행합니다.
* 파티션 테이블: 저장 장치의 파티션에 대한 정보를 포함하며, 시작 위치, 크기 및 사용된 파일 시스템 유형 등의 데이터를 포함합니다.
* MBR 시그니처: MBR 코드가 유효한지를 확인하는데 사용되는 작은 코드 조각입니다.

#### MBR의 한계

MBR은 2TB 이상의 드라이브를 지원하지 않으며, 최대 4개의 주 파티션만을 지원합니다. 이러한 제한 때문에 더 크고 복잡한 스토리지 요구 사항을 가진 시스템에서는 점차 GPT(GUID Partition Table) 방식으로 대체되고 있습니다 ([MiniTool](https://www.minitool.com/lib/mbr-master-boot-record.html)).

MBR은 컴퓨터가 켜질 때 BIOS에 의해 먼저 읽혀지며, 운영 체제의 로딩을 시작하는 기능을 담당합니다. 이 과정에서 BIOS는 하드웨어 장치를 검사하고, MBR을 메모리로 읽어들여 실행합니다 ([EaseUS](https://www.easeus.com/diskmanager/master-boot-record.html)).

MBR은 시스템의 중요한 부분이므로, MBR에 문제가 발생했을 경우 부팅 자체가 불가능해질 수 있습니다. 따라서 MBR을 관리하고 필요한 경우 복구하는 방법을 알고 있어야 합니다.

더 자세한 정보는 다음 링크를 참고하세요:

* https://en.wikipedia.org/wiki/Master\_boot\_record
* https://www.easeus.com/diskmanager/master-boot-record.html
* https://www.minitool.com/lib/mbr-master-boot-record.html
