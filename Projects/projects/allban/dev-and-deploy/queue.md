# 큐 기반 비동기 데이터 동기화 (Queue)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-005-DO |
| 유형 | D&O (설계 회고) + 예제 코드 |
| 목적 | 패킷 수집과 서버 전송을 큐로 분리한 이유와 구조를 설명한다 |
| 확인 상태 | 미검증 (코드를 읽고 정리했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 배경과 문제

{% hint style="info" %}
NOTE: 서버 프로그램을 실행하면 손님 PC에서 메뉴판을 열어도 메뉴가 보이지 않거나 로그인에 평소보다 오래 걸리는 변화가 있었다. 원인을 찾는 과정에서 아래 문제를 확인했다.
{% endhint %}

- 초기 구조: 패킷을 감지하는 즉시 `requests.post()`로 서버에 데이터를 보냈다.
- 동기식 지연(Blocking): 서버 응답이 늦거나 네트워크가 불안정하면 전송이 끝날 때까지 스니퍼 엔진이 멈춰 다음 패킷을 놓쳤다.
- 리소스 낭비: 패킷마다 전송 완료를 기다려 CPU를 효율적으로 쓰지 못했다.

## 2. 구성 요소

프로듀서-컨슈머(Producer-Consumer) 패턴을 Python `queue.Queue`와 멀티스레딩으로 구현했다.

| 구성 요소 | 예제의 이름 | 역할 |
|---|---|---|
| Producer (스니퍼 엔진) | `packet_producer_mock()` | 패킷을 가공해 큐에 넣고 바로 다음 패킷 탐지로 돌아간다 |
| Queue (데이터 버퍼) | `data_queue` | 수집 속도와 전송 속도의 차이를 메모리에서 완충한다 |
| Consumer (워커 스레드) | `send_worker()` | 큐에서 하나씩 꺼내 서버로 전송한다. 전송이 늦어도 수집 엔진에 영향이 없다 |

## 3. 동작 원리

1. 스니퍼가 패킷을 가공한 주문 데이터를 `data_queue.put()`으로 넣는다. 대기 없이 바로 끝난다.
2. 워커 스레드가 `data_queue.get()`으로 데이터를 꺼낸다. 데이터가 올 때까지 대기한다.
3. 워커가 `requests.post()`로 서버에 보낸다. 제한 시간은 1.0초다.
4. 워커가 `task_done()`으로 완료를 알린다.
5. 종료 신호로 `None`이 오면 워커가 반복문을 빠져나간다.

이 구조는 유니티 게임 서버에서 패킷을 큐에 쌓고 메인 루프에서 처리하는 비동기 방식과 같은 원리다.

## 4. 예제 코드

```python
import queue
import threading
import requests
import time
import sys

# 1. 스레드 간 안전한 데이터 교환을 위한 큐 생성
data_queue = queue.Queue()

def send_worker():
    """
    [Consumer] 큐에서 데이터를 가져와 서버로 전송하는 전용 스레드
    """
    print("[Worker] 전송 워커 스레드가 가동되었습니다.")
    while True:
        # 큐에서 데이터 인출 (데이터가 올 때까지 대기)
        item = data_queue.get()
        if item is None:  # 종료 신호 확인
            break
            
        try:
            # 서버 전송 시도 (Timeout을 짧게 설정하여 워커가 묶이지 않게 함)
            response = requests.post("http://localhost:8080/api/order", json=item, timeout=1.0)
            if response.status_code == 200:
                print(f"[Worker] 서버 전송 성공: {item['seat_no']}번 좌석")
            else:
                print(f"[Worker] 전송 실패: HTTP {response.status_code}")
        except Exception as e:
            print(f"[Worker] 네트워크 오류 발생: {e}")
        
        # 작업 완료 보고
        data_queue.task_done()

def packet_producer_mock():
    """
    [Producer] 패킷을 탐지하고 큐에 데이터를 넣는 역할을 모사함
    """
    print("[Sniffer] 패킷 스니핑 엔진 가동 중...")
    for i in range(1, 6):
        # 패킷 가공 데이터 생성
        order_info = {
            "type": "tb_order",
            "seat_no": f"PC-{i:02d}",
            "amount": 5000 * i,
            "timestamp": time.time()
        }
        
        # 큐에 데이터 삽입 (Non-blocking)
        data_queue.put(order_info)
        print(f"[Sniffer] 주문 감지 및 큐 삽입: {order_info['seat_no']}")
        
        # 패킷이 몰려오는 상황 가정
        time.sleep(0.1)

# 시스템 실행부
if __name__ == "__main__":
    # 워커 스레드 생성 및 시작
    worker = threading.Thread(target=send_worker, daemon=True)
    worker.start()

    # 스니핑 시작
    packet_producer_mock()

    # 큐의 모든 작업이 완료될 때까지 대기
    data_queue.join()
    print("[Main] 모든 데이터 처리 및 전송이 완료되었습니다.")
```

{% hint style="info" %}
NOTE: 예제의 전송 주소 `http://localhost:8080/api/order`는 모의 값이다. 실제 서버 주소는 `<값 생략>`이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 예제는 전송이 실패하면 해당 항목을 버린다(재시도 없음). 큐는 수집 중단을 막을 뿐이고 전송 실패 시 유실은 막지 않는다. 큐에 크기 제한도 없어, 서버가 오래 응답하지 않으면 메모리 사용량이 늘어난다. 원본에는 이 점이 적혀 있지 않다.
{% endhint %}

## 5. 결과와 근거

| 항목 | 원본의 주장 | 측정값 |
|---|---|---|
| 데이터 무결성 | 초당 수십 건의 주문이 동시에 발생해도 큐가 버퍼 역할을 해 유실률을 0%에 가깝게 유지했다 | 원본에 없음, 확인 필요 |
| 시스템 응답성 | 네트워크 지연이나 서버 장애에서도 스니퍼 엔진이 독립 동작해 대시보드 로그 출력이 끊기지 않았다 | 원본에 없음, 확인 필요 |
| 유지보수 | 전송 로직(HTTP, Webhook 등)을 바꿔도 스니퍼 핵심 로직은 그대로 두고 워커 스레드만 고치면 된다 | 구조상 설명, 확인 필요 |

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| Producer | 데이터를 만들어 큐에 넣는 쪽 |
| Consumer | 큐에서 꺼내 처리하는 쪽 |
| Blocking | 작업이 끝날 때까지 호출한 쪽이 멈추는 방식 |
| Timeout | 응답을 기다리는 최대 시간 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 동기식 전송에서 패킷 유실이 생기는 과정을 내 말로 설명하면?
- [ ] 큐를 넣고도 유실이 남을 수 있는 경우는 언제인가?
- [ ] 이 구조를 다른 프로젝트에 적용한다면 어디에 쓰겠는가?
