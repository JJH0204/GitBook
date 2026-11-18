# Allban 큐 동기화와 프로세스 관리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-101-DO |
| 유형 | D&O (구조 해체) + 따라 만들기 |
| 목적 | 스니퍼가 수집한 주문을 큐와 워커 스레드로 서버에 전하는 경로, 서버의 수신부, 스니퍼 프로세스의 생성·종료를 해체한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | PRJ-ALB-100-DO | Allban 해체 분석 |
| [packet-sniffer.md](packet-sniffer.md) | PRJ-ALB-102-DO | Allban 패킷 분석 |
| [kds-protocol.md](kds-protocol.md) | PRJ-ALB-104-REF | Allban KDS 통신 규약 |
| [큐 기반 비동기 데이터 동기화 (Queue)](../dev-and-deploy/queue.md) | PRJ-ALB-005-DO | 큐를 도입한 배경과 모의 예제 |
| [프로세스 통합 및 생명주기 관리 (Dart-Python)](../dev-and-deploy/dart-python.md) | PRJ-ALB-011-DO | 트리 종료 설계 회고 |

## 이 영역이 하는 일

기존 회고 문서는 "왜 큐를 썼는가"를 모의 예제로 설명한다. 이 페이지는 레포의 실제 코드가 어떻게 생겼는지를 본다. 세 부분이다.

1. 스니퍼 쪽: 패킷 분석 결과를 `queue.Queue`에 넣고, 워커 스레드가 HTTP로 서버에 보낸다(`python_packetSnip/main.py`).
2. 서버 쪽: `/api/external_order`로 받는다(`admin_console/lib/services/server_service.dart`).
3. 프로세스: 서버가 스니퍼를 자식 프로세스로 띄우고, 로그를 받고, 종료한다(같은 파일).

## 구성 요소

| 구성 요소 | 파일·심볼 | 역할 |
|---|---|---|
| 큐 | `main.py`의 `data_queue` | 스레드 간 완충 버퍼. 크기 제한 없음 |
| 프로듀서 | `process_mysql_packet()` | 주문으로 판단한 패킷을 `data_queue.put()` |
| 컨슈머 | `send_worker()` | 큐에서 꺼내 `requests.post()`. 제한 시간 0.5초 |
| 종료 신호 | `data_queue.put(None)` | `start_sniffing()`의 `finally`에서 워커를 멈춘다 |
| 수신부 | `ServerService._handleSniffedData()` | 본문을 읽고 JSON으로 파싱, 로그 남김, `{"status":"success"}` 응답 |
| 실행 | `ServerService._startSniffer()` | 임베디드 파이썬 경로와 스크립트 경로를 찾아 `Process.start` |
| 종료 | `ServerService.stopSniffer()` | `taskkill /PID <pid> /T /F`, 잔류 확인 |
| 로그 전달 | `_snifferProcess.stdout/stderr` | `utf8.decoder` + `LineSplitter`로 줄 단위 수집 → 대시보드 로그 |

## 데이터 흐름

```
 pyshark 패킷 --process_mysql_packet()--> order_data(dict)
                                            |
                                  data_queue.put()   (즉시 반환, 대기 없음)
                                            v
                              [send_worker 스레드] get() --> requests.post(timeout=0.5s)
                                            |
                                            v   HTTP POST /api/external_order
                    [Dart shelf 서버] _handleSniffedData(): readAsString -> jsonDecode -> 로그
                                            |
                                            x   (이 지점에서 주문 목록·WebSocket 방송으로 이어지는 코드가 없다)

 서버 시작 --> _startSniffer() --> Process.start(python, ['-u', 스크립트, 어댑터])
 서버 종료 --> stopSniffer()  --> taskkill /T /F --> 500ms 뒤 tasklist 로 tshark.exe·python.exe 잔류 확인
```

## 핵심 코드 해설

### 1. 워커: 실패해도 멈추지 않는 전송

`python_packetSnip/main.py`의 `send_worker()`는 `None`이 올 때까지 큐에서 꺼내 전송한다. 응답 코드가 200이 아니거나 네트워크 오류가 나도 로그만 남기고 다음 항목으로 간다.

```python
data = data_queue.get()
if data is None: break
try:
    response = requests.post(SERVER_URL, json=data, timeout=0.5)
    ...
except requests.exceptions.RequestException as e:
    log("ERROR", f"Network error: {e}")
data_queue.task_done()
```

`SERVER_URL`은 서버 쪽 `/api/external_order` 경로를 가리키는 모듈 상수다(같은 PC의 서버 주소, `<값 생략>`).

### 2. 프로듀서가 넣는 데이터

주문으로 판단하면 아래 모양의 딕셔너리를 큐에 넣는다.

| 키 | 값 |
|---|---|
| `type` | 문맥 쿼리에 주문 테이블 이름이 들어 있으면 `tb_order`, 아니면 `tb_suborder` |
| `seat_no` | 바이너리 파라미터의 9번 인덱스 |
| `total_price` | 7번 인덱스 |
| `stmt_id` | 문장 ID |
| `timestamp` | ISO 8601 시각 |

### 3. 서버: 스니퍼 실행 경로 결정

`ServerService._pythonPath`와 `_scriptPath`는 배포 환경을 먼저 찾고, 없으면 개발 환경으로 내려간다.

| 순서 | 파이썬 | 스크립트 |
|---|---|---|
| 1 | 실행 파일 폴더의 `python_assets/python/python.exe` | `python_assets/main.py` |
| 2 | 실행 파일 위로 3~7단계 올라가며 `python_runtime/python.exe` | 같은 방식으로 `python_packetSnip/main.py` |
| 3 | 상대 경로 기본값 | 상대 경로 기본값 |

실행은 쉘 없이 직접 한다.

```dart
_snifferProcess = await Process.start(
  pythonPath,
  ['-u', scriptPath, adapterGuid],
  runInShell: false,
  workingDirectory: _executableDir,
);
```

`-u`는 파이썬 출력 버퍼를 끄는 옵션이고, 마지막 인자는 캡처할 어댑터 이름이다. `main.py`는 `sys.argv[1]`을 어댑터로 쓴다.

### 4. 서버: 어댑터 찾기와 종료

`_findLoopbackAdapter()`는 파이썬에게 `pyshark`의 인터페이스 목록을 출력하게 한 뒤 `NPF_Loopback`이 들어 있으면 그 이름을, 아니면 정규식으로 첫 `NPF_{GUID}`를 쓰고, 모두 실패하면 기본 이름을 쓴다. 종료는 `stopSniffer()`가 `taskkill /T /F`로 자식(tshark)까지 지운 뒤 500ms 후 `tasklist`로 `tshark.exe`와 `python.exe`가 남았는지 로그에 남긴다.

## 따라 만들기

`확인 상태: 미검증`

| 단계 | 할 일 | 기대 결과 |
|---|---|---|
| 1 | 스니퍼에 `queue.Queue`와 `send_worker` 스레드(`daemon=True`)를 만든다 | 스레드가 큐 대기 상태로 시작한다 |
| 2 | 분석 함수에서 전송 대신 `data_queue.put(dict)`만 한다 | 캡처 루프가 전송 시간과 무관하게 계속 돈다 |
| 3 | 워커에서 `requests.post`에 짧은 `timeout`을 주고 예외를 삼킨다 | 서버가 꺼져 있어도 스니퍼가 죽지 않는다 |
| 4 | 종료 때 `put(None)`으로 워커를 멈춘다 | 프로세스가 정상 종료한다 |
| 5 | Dart 서버에 `shelf` 라우트를 만들어 JSON 본문을 받고 `{"status":"success"}`를 돌려준다 | 스니퍼 로그에 "Data sent"가 찍힌다 |
| 6 | 서버 시작 시 `Process.start(..., runInShell: false)`로 스니퍼를 띄우고 stdout을 `LineSplitter`로 로그에 연결한다 | 대시보드에 스니퍼 로그가 줄 단위로 나온다 |
| 7 | 서버 종료 시 `taskkill /PID <pid> /T /F`로 트리 전체를 종료한다 | 서버를 끈 뒤 `tshark.exe`가 남지 않는다 |
| 8 | (이 소스에 없는 단계) 수신 핸들러에서 주문 모델을 만들어 주문 목록에 넣고 WebSocket으로 방송한다 | 태블릿에 신규 주문이 뜬다 |

## 알려진 한계·주의

{% hint style="warning" %}
WARNING: `_handleSniffedData()`는 받은 본문을 로그에 남기고 성공 응답만 돌려준다. 주문 목록에 넣거나 `ORDER_CREATE`를 방송하는 코드는 이 스냅샷에 없다. 주문 방송은 관리 화면의 테스트 주문 버튼(`header.dart`에서 `generateTestOrder` → `broadcastNewOrder`)에서만 호출된다. 스니퍼 → 태블릿 경로의 마지막 구간은 미구현으로 보인다.
{% endhint %}

{% hint style="info" %}
NOTE: 큐에 크기 제한이 없고 전송 실패 시 재시도가 없다. 실패한 주문은 버려진다. 서버가 오래 응답하지 않으면 큐가 메모리에서 계속 커진다.
{% endhint %}

- 서버 수신 경로 `/api/external_order`와 `/api/kitchen_data`는 인증이 없고, 서버는 모든 인터페이스(`0.0.0.0`)에 바인드한다. 같은 네트워크의 다른 기기가 접근할 수 있으므로 방화벽과 사설망(원본은 Tailscale을 안내) 안에서만 운영해야 한다.
- 서버 로그 문자열에 `스ни퍼`처럼 키릴 문자가 섞인 오타가 있다(`_handleSniffedData`의 오류 로그). 동작에는 영향이 없다.
- `stopSniffer()`는 강제 종료(`/F`)라 스니퍼가 로그를 정리할 기회가 없다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 큐가 없다면 어떤 순간에 패킷이 유실되는지 내 말로 설명해 보자.
- [ ] 전송 실패 항목을 버리지 않으려면 어떤 구조를 더하겠는가?
- [ ] 서버가 스니퍼를 직접 띄우는 방식과 서비스로 따로 두는 방식 중 무엇을 택하겠는가?
