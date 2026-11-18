# Allban 패킷 분석: MySQL 바이너리 프로토콜 해석

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-102-DO |
| 유형 | D&O (구조 해체) + 따라 만들기 |
| 목적 | 스니퍼 두 개(`main.py`, `scapy_main.py`)가 MySQL Prepared Statement 트래픽에서 값을 꺼내는 구조를 해체한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="warning" %}
CAUTION: 이 문서는 같은 PC 안의 루프백 트래픽을 관찰하는 구조를 방어·구조 관점에서 설명한다. 대상 시스템의 이용 약관과 계약상 허용 여부는 원본에 없다. 쿼리·테이블·컬럼 이름과 접속 정보는 적지 않았다(`<값 생략>`). 같은 방식을 쓰기 전에 허용 범위를 확인한다. 또한 이 구조는 평문 통신을 관찰하므로, 자기 시스템의 DB 통신이 같은 PC의 다른 프로그램에 읽힐 수 있다는 점은 방어 쪽에서도 의미가 있다(통신 암호화, 접근 권한 분리).
{% endhint %}

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [queue-sync.md](queue-sync.md) | PRJ-ALB-101-DO | Allban 큐 동기화와 프로세스 관리 |
| [네트워크 패킷 분석 및 MySQL 디코딩](../dev-and-deploy/mysql/README.md) | PRJ-ALB-007-DO | 분석 회고 |
| [루프백 어댑터 자동 탐색 구현 (Npcap)](../dev-and-deploy/mysql/get_tshark_interfaces.md) | PRJ-ALB-008-REF | 어댑터 탐색 코드 |

## 이 영역이 하는 일

MySQL 클라이언트와 서버 사이의 TCP 바이트를 읽어 "어떤 쿼리가, 어떤 값으로 실행됐는가"를 복원한다. 레포에는 같은 목표의 구현이 두 갈래 있다.

| 구분 | `main.py` | `scapy_main.py` |
|---|---|---|
| 캡처·해석 | `pyshark`(tshark가 MySQL 해석, 재조합) | Scapy가 패킷만 주고, MySQL 해석은 직접 구현 |
| 외부 의존 | tshark(Wireshark), Npcap | Npcap만 |
| 주목하는 명령 | PREPARE(22), EXECUTE(23) | QUERY(3), PREPARE(0x16), EXECUTE(0x17), CLOSE(0x19) |
| 출력 | 큐 → 서버 POST | 콘솔과 JSONL 로그 파일 세 종류 |
| 배포 | 관리 프로그램이 실행 | `run_scapy_sniffer.bat`로 단독 실행 |

## 구성 요소

| 구성 요소 | 파일·심볼 | 역할 |
|---|---|---|
| 문장 캐시 | `prepared_statements`(`main.py`), `stmt_map`(`scapy_main.py`) | 문장 ID → 쿼리 틀(과 파라미터 수) |
| 세션 상태기계 | `MySQLSession`, `session_map` | 클라이언트 주소·포트별로 응답 해석 단계 추적 |
| 길이 인코딩 읽기 | `read_lenenc_int`, `read_lenenc_str` | MySQL 가변 길이 정수·문자열 |
| 바이너리 값 읽기 | `parse_binary_values` | Null 비트맵 + 타입별 값 |
| 로깅 큐 | `log_queue`, `logging_worker` | JSONL 파일 기록을 별도 스레드로 |
| 어댑터 탐색 | `find_loopback_adapter` | 루프백 어댑터 이름 찾기 |
| 패킷 진입점 | `packet_callback` → `parse_mysql_payload` | 포트 3306 방향으로 서버행/클라이언트행 구분 |

## 데이터 흐름

```
 [pyshark 경로: main.py]
   LiveCapture(display_filter = mysql.command 22 또는 23, 재조합 옵션 TRUE)
     -> command 22 + 주문 테이블 포함 쿼리 -> prepared_statements 에 저장
     -> command 23 -> 파라미터 목록 -> 인덱스 9(좌석), 7(총액) -> 큐

 [Scapy 경로: scapy_main.py]
   sniff(iface=루프백, filter="tcp port 3306")
     -> packet_callback: 목적지 포트 3306 = 서버행, 출발지 포트 3306 = 응답
        서버행:  [3바이트 길이][1바이트 순번][명령 1바이트][본문]
          03 QUERY   -> 쿼리 문자열 로그
          16 PREPARE -> pending_prepares[클라이언트] = 쿼리
          17 EXECUTE -> stmt_id 로 stmt_map 조회 -> 바이너리 파라미터 해석
          19 CLOSE   -> stmt_map 에서 제거
        응답행:  상태기계 AWAITING_RESULTSET -> READING_COLUMNS -> READING_ROWS
          PREPARE 응답(0x00, 9바이트 이상) -> stmt_id, 파라미터 수 -> stmt_map 저장
```

## 핵심 코드 해설

### 1. MySQL 패킷 헤더 자르기

`scapy_main.py`의 `parse_mysql_payload()`는 한 TCP 페이로드에 MySQL 패킷이 여러 개 이어질 수 있다고 보고 반복문으로 자른다.

```python
pkt_len = struct.unpack('<I', payload[offset:offset+3] + b'\x00')[0]
seq_id = payload[offset+3]
mysql_data = payload[offset+4 : offset+4+pkt_len]
offset += 4 + pkt_len
```

앞 3바이트가 본문 길이(리틀 엔디언), 다음 1바이트가 순번이다. 본문의 첫 바이트가 서버행에서는 명령 코드다.

### 2. EXECUTE 패킷에서 값 꺼내기

EXECUTE 본문은 `명령(1) + 문장 ID(4) + 플래그(1) + 반복 횟수(4)` 다음에 `Null 비트맵 → new-params-bound 플래그 → (타입 2바이트 × 파라미터 수) → 값들` 순서다. 코드는 파라미터 시작을 `offset=10`으로 잡고 `parse_binary_values()`를 부른다.

```python
null_bitmap_len = (num_params + 7) // 8
...
new_params_bound = data[offset]; offset += 1
if new_params_bound:
    # 파라미터마다 2바이트 타입을 읽는다 (하위 1바이트만 사용)
```

값은 타입 코드로 갈린다: TINY(1바이트)·SHORT·LONG·LONGLONG·FLOAT·DOUBLE은 고정 길이로 `struct.unpack`, 문자열·BLOB 계열은 길이 인코딩 문자열이다.

### 3. 문장 ID는 응답에서 받는다

MySQL에서 문장 ID는 서버가 PREPARE에 응답할 때 준다. `scapy_main.py`는 이 순서를 따른다. PREPARE 요청 때 쿼리를 `pending_prepares`에 보관하고, 응답 패킷(`0x00`, 9바이트 이상)에서 ID(`[1:5]`)와 파라미터 수(`[7:9]`)를 꺼내 `stmt_map`에 저장한다. 반면 `main.py`는 PREPARE 요청 패킷에서 `stmt_id`를 읽으려 한다(`getattr(mysql_layer, 'stmt_id', None)`). 요청에는 이 값이 없어 `None`이 될 수 있다. 이는 기존 회고의 "확인 필요"에 대한 소스 쪽 단서다(실행하지 않아 확정은 아니다).

### 4. 비동기 로깅

`scapy_main.py`는 로그를 `log_queue`에 넣고 별도 스레드가 JSONL 세 파일(SQL, 결과 행, 주문)에 추가 기록한다. 터미널 출력은 콘솔에 바로 하고 파일 쓰기만 큐로 미룬다. [큐 동기화](queue-sync.md)와 같은 프로듀서-컨슈머 구조다.

## 따라 만들기

`확인 상태: 미검증`

| 단계 | 할 일 | 기대 결과 |
|---|---|---|
| 1 | Npcap을 설치하고 파이썬에서 루프백 어댑터 이름을 찾는다(`scapy.arch.windows.get_windows_if_list`로 설명에 `Loopback`이 든 항목) | 어댑터 이름이 하나 나온다 |
| 2 | `sniff(iface=..., filter="tcp port 3306", prn=콜백, store=0)`을 건다 | 콜백이 TCP 페이로드마다 호출된다 |
| 3 | 목적지 포트가 3306이면 서버행, 출발지 포트면 응답으로 나눈다 | 방향별로 다른 해석기가 불린다 |
| 4 | 페이로드를 4바이트 헤더 단위로 자르고 서버행은 첫 바이트를 명령 코드로 읽는다 | QUERY·PREPARE·EXECUTE가 구분된다 |
| 5 | PREPARE 응답에서 문장 ID와 파라미터 수를 읽어 캐시에 저장한다 | 이후 EXECUTE를 쿼리 틀과 연결할 수 있다 |
| 6 | EXECUTE에서 Null 비트맵과 타입 목록을 읽고 타입별로 값을 꺼낸다 | 파라미터 목록이 나온다 |
| 7 | 실제 값은 대상 시스템에서 위치(인덱스)를 확인해 매핑한다(이 소스는 좌석 9, 총액 7이라고 적었다) | 필요한 필드가 값으로 나온다 |
| 8 | 결과를 큐에 넣고 전송·기록은 워커에게 맡긴다 | 캡처 루프가 느려지지 않는다 |

## 알려진 한계·주의

{% hint style="info" %}
NOTE: 아래는 코드를 읽고 판단한 것이며 실행으로 확인하지 않았다.
{% endhint %}

| 번호 | 내용 | 위치 |
|---|---|---|
| 1 | PREPARE 응답 처리의 조건이 `src_info in pending_prepares`인데, 키는 요청 때 클라이언트 주소로 저장했고 응답에서는 `src_info`가 서버 주소다. 키가 달라 `stmt_map`에 저장되지 않을 가능성이 있다. 그러면 EXECUTE는 "Unknown Execute ID"로 남는다 | `scapy_main.py` `parse_mysql_payload` 끝부분 |
| 2 | 결과 행의 바이너리 형식(`0x00` 시작)을 `parse_binary_values(..., offset=1, ...)`로 읽는다. 이 함수는 EXECUTE 요청용(`new-params-bound` 플래그 포함)이라 행 파싱과 형식이 다르다. 행의 Null 비트맵은 앞 2비트를 건너뛰는 별도 규칙이 있다(소스 주석도 같은 의문을 적었다) | `scapy_main.py` |
| 3 | `log_event("ORDER", ...)`를 호출하는 곳이 없다. 주문 추적 로그 파일은 정의만 있고 쓰이지 않는다 | `scapy_main.py` |
| 4 | `packet_callback`이 모든 예외를 삼킨다(`except Exception: pass`). 해석 오류가 로그에 남지 않는다 | `scapy_main.py` |
| 5 | 스트림 재조합이 없다. 페이로드가 여러 TCP 세그먼트로 쪼개지면 `scapy_main.py`는 중간에서 잘린 패킷을 해석한다. 그래서 `main.py`는 tshark의 재조합 옵션을 쓴다 | 두 파일 |
| 6 | 파라미터 인덱스(9, 7)는 대상 시스템 한 버전의 분석 결과를 하드코딩한 것이다. 대상이 바뀌면 깨진다 | `main.py` |
| 7 | `main.py`가 가져오는 PREPARE 쿼리 필터는 쿼리 텍스트에 특정 문자열이 든 경우만 캐시한다(문자열은 `<값 생략>`) | `main.py` |
| 8 | `requirements.txt`는 UTF-16으로 저장돼 `scapy`만 적혀 있다. `main.py`는 `pyshark`·`requests`가 필요하다 | `python_packetSnip/requirements.txt` |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] tshark를 쓰는 방식과 Scapy로 직접 해석하는 방식을 어떻게 비교했는지 내 말로 적어 보자.
- [ ] 바이너리 프로토콜 해석에서 가장 헷갈렸던 규칙은 무엇이었는가?
- [ ] 이 분석 방식이 막혀 있는 환경에서는 어떤 대안을 쓰겠는가?
