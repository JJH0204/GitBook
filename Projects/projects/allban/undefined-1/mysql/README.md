---
description: PC방 관리 프로그램(게토)의 로컬 루프백 트래픽에서 실시간 주문 데이터를 추출하는 것.
---

# 네트워크 패킷 분석 및 MySQL 프로토콜 디코딩 문제

> * 프로젝트 목적: PC방 관리 프로그램(게토)의 DB 트래픽을 가로채 실시간 주문 알림 시스템을 구현함.
> * 환경: Windows 10/11, MariaDB 10.0.16, Npcap Loopback Adapter.
> * 초기 문제: Wireshark에서는 패킷이 보이지만, 파이썬(Pyshark/Scapy) 스크립트에서는 주문 데이터(좌석 번호, 상품명 등)가 텍스트로 노출되지 않아 추출에 실패함.

**핵심 장애 요인 분석**

가. 프로토콜의 특성 (Binary Protocol)

* 대상 시스템은 일반적인 `COM_QUERY(0x03)`가 아닌, 성능 최적화를 위한 Prepared Statement 방식을 사용함.
* 데이터가 `COM_STMT_EXECUTE(0x17, Type 23)` 명령을 통해 전달되며, 이때 실제 값은 사람이 읽을 수 없는 바이너리(Binary) 형태로 인코딩되어 전달됨.

나. TCP 세그먼트 파편화 (Segmentation)

* 주문 데이터가 길어질 경우 하나의 MySQL 패킷이 여러 개의 TCP 세그먼트로 쪼개짐.
* 재조합(Reassembly) 과정 없이는 MySQL 레이어의 필드(stmt\_id, parameters)에 접근할 수 없는 현상이 발생함.

**단계별 해결 전략 및 구현 상세**

Step 1: Statement ID 추적 알고리즘 설계 바이너리 패킷에는 쿼리문(INSERT...)이 포함되지 않으므로, 서버와 클라이언트 간의 약속된 ID를 추적하는 로직을 도입함.

1. `COM_STMT_PREPARE(22)` 패킷 감시: 쿼리 문구 내 `tb_order` 등이 포함된 경우 해당 패킷의 `stmt_id`를 메모리(`dict`)에 캐싱.
2. `COM_STMT_EXECUTE(23)` 패킷 매칭: 수신된 패킷의 ID가 캐싱된 ID와 일치하면 주문 데이터로 간주.

Step 2: Pyshark 고도화 설정 파편화된 패킷을 온전히 읽기 위해 Tshark 엔진의 환경 설정을 강제 적용함.

* `tcp.desegment_tcp_streams`: TRUE (쪼개진 TCP 스트림 재조합)
* `mysql.desegment_buffers`: TRUE (MySQL 버퍼 재조합)
* `decode_as`: 특정 포트(3306)를 강제로 MySQL 프로토콜로 해석하도록 지정.

Step 3: 바이너리 파라미터 인덱스 추출 제공된 PDML(Packet Details Markup Language) 분석 결과에 근거하여, 바이너리 필드의 인덱스 기반으로 데이터를 특정함.

* Index 9: 좌석 번호 (Seat Number)
* Index 7: 결제 총액 (Total Price)
* `mysql.value.all_fields` 또는 `mysql.string.all_fields`를 리스트화하여 해당 위치의 값을 정밀하게 추출함.

**시행착오 및 디버깅 기록**

* 이슈: 인터페이스 경로 탐색 실패.
  * 원인: Windows 환경에서 Npcap의 루프백 어댑터명이 시스템마다 상이함 (`\Device\NPF_Loopback` 등).
  * 해결: [`get_tshark_interfaces()`](get_tshark_interfaces.md)를 사용하여 런타임에 "loopback" 키워드가 포함된 GUID를 자동 검색하는 로직 구현.
* 이슈: [실시간 로그 출력 지연](undefined.md).
  * 원인: 파이썬의 표준 출력 버퍼링과 Dart `Process.start` 간의 스트림 간섭.
  * 해결: 파이썬 실행 옵션에 `-u`(Unbuffered) 플래그를 추가하고, Dart에서 `LineSplitter`를 사용하여 줄 단위로 로그를 복원함.

**최종 성과 및 기술적 근거**

* MySQL Internals 명세 준수: Binary Protocol의 `Null Bitmap` 이후 데이터 배치 규칙을 적용하여 데이터 무결성 확보.
* 비동기 처리: 패킷 수집과 서버 전송을 분리하기 위해 `queue.Queue`와 `threading`을 도입, 유니티 서버급의 비동기 소켓 처리 흐름을 구현함.
