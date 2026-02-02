# 데이터 동기화 및 큐(Queue) 기반 비동기 전송

{% hint style="info" %}
서버 프로그램을 실행하면 손님 PC에서 메뉴판을 열어도 매뉴를 확인할 수 없거나. 로그인하는데 평소보다 오랜 시간이 걸리는 변화 확인 후 원인 파악 과정에서 아래 문제에 대해서 인지함
{% endhint %}

**1. 배경 및 문제 의식: 데이터 병목과 유실**

* 초기 구조: 패킷을 감지하는 즉시 `requests.post()`를 호출하여 서버로 데이터를 전송함.
* 직면한 문제:
  * 동기식 지연(Blocking): 서버 응답이 지연되거나 네트워크 상태가 불안정할 경우, 전송 작업이 끝날 때까지 스니퍼 엔진이 멈춰서 다음 패킷을 놓치는 데이터 유실 현상이 발생함.
  * 리소스 낭비: 매 패킷마다 전송 프로세스가 완료될 때까지 기다려야 하므로, CPU 자원을 효율적으로 사용하지 못함.

**2. 해결책: 프로듀서-컨슈머(Producer-Consumer) 패턴 도입**

데이터 수집과 전송의 역할을 명확히 분리하기 위해 Python의 `queue.Queue`와 멀티스레딩을 결합한 비동기 처리 구조를 설계함.

가. 주요 메커니즘

1. Producer (스니퍼 엔진): 패킷을 가공하여 큐(Queue)에 데이터를 밀어 넣고 즉시 다음 패킷 탐지로 복귀함. (중단 없는 수집)
2. Queue (데이터 버퍼): 수집된 데이터를 메모리에 안전하게 보관하며, 전송 속도와 수집 속도 간의 차이를 완충함.
3. Consumer (워커 스레드): 큐에서 데이터를 하나씩 꺼내어 서버로 전송함. 전송 중 지연이 발생해도 수집 엔진에는 영향을 주지 않음.

**3. 구현 예제 스크립트 (Python)**

이 로직은 유니티 게임 서버에서 패킷을 큐에 쌓아두고 메인 루프에서 처리하는 비동기 방식과 동일한 원리로 설계되었습니다.

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

**4. 최종 성과 및 기술적 근거**

* 데이터 무결성 확보: 초당 수십 건의 주문 데이터가 동시에 발생하더라도 큐가 버퍼 역할을 수행하여 데이터 유실율을 0%에 가깝게 유지함.
* 시스템 응답성 향상: 네트워크 지연이나 서버 장애 상황에서도 스니퍼 엔진은 독립적으로 동작하여 대시보드 로그 출력이 끊기지 않음.
* 유지보수 용이성: 전송 로직(HTTP, Webhook 등)을 변경하더라도 스니퍼 엔진의 핵심 로직을 건드리지 않고 워커 스레드만 수정하면 됨.
