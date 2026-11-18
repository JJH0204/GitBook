# Allban KDS 통신 규약

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-ALB-104-REF |
| 유형 | REF (메시지·데이터 모델 표) + 흐름 해설 |
| 목적 | 관리 프로그램 서버와 태블릿 앱이 주고받는 HTTP·WebSocket 메시지와 주문·메뉴 데이터 모양을 한곳에 모은다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | PRJ-ALB-100-DO | Allban 해체 분석 |
| [queue-sync.md](queue-sync.md) | PRJ-ALB-101-DO | Allban 큐 동기화와 프로세스 관리 |
| [대시보드 실시간 로깅 및 가시성 개선](../dev-and-deploy/ui.md) | PRJ-ALB-006-DO | 서버 로그 창 |

## 이 영역이 하는 일

서버(`admin_console/lib/services/server_service.dart`, `providers/server_provider.dart`)는 태블릿(`android_app/lib/services/`, `providers/kitchen_provider.dart`)에 메뉴와 주문을 내려 주고, 태블릿의 삭제 요청과 생존 응답을 받는다. 연결 주소는 태블릿 설정 화면에서 입력한 서버 주소와 포트이며 이 문서에는 적지 않았다(`<값 생략>`).

## 구성 요소

| 구성 요소 | 파일 | 역할 |
|---|---|---|
| `ServerService` | 관리 `services/server_service.dart` | 라우팅, WebSocket 채널 집합, 방송, 정적 이미지 서빙 |
| `ServerProvider` | 관리 `providers/server_provider.dart` | 서버 켜기·끄기, 30초 하트비트, 기기 목록, 방송 헬퍼 |
| `OrderProvider`, `MenuProvider` | 관리 `providers/` | 주문·메뉴 상태, 변경 시 서버 동기화 콜백 |
| `WebSocketService` | 태블릿 `services/websocket_service.dart` | 연결, 메시지 종류별 분기, PING에 PONG 응답 |
| `ApiService` | 태블릿 `services/api_service.dart` | `/api/kitchen_data` GET(제한 10초), HEAD(제한 3초) |
| `KitchenProvider` | 태블릿 `providers/kitchen_provider.dart` | 연결·재연결, 메시지 처리, 조리 타이머, 캐시 |
| `StorageService` | 태블릿 `services/storage_service.dart` | 서버 주소 저장, 마지막 데이터 파일 캐시 |

## 데이터 흐름

```
 태블릿 시작 --> 저장된 주소 읽기 --> 캐시 파일 로드(있으면 먼저 화면에)
      |
      +--> ws://<서버>:<포트>/ws 연결
             서버: 즉시 CONNECTION_ACK 전송 -> 태블릿: 연결 성공 처리 (제한 10초)
             태블릿: REQ_KITCHEN_DATA 전송 (autoReqData)
      |
 메뉴 변경(관리 화면) --> syncAllData() --> KITCHEN_DATA 방송(메뉴, 카테고리, 대기 주문)
 신규 주문            --> ORDER_CREATE 방송
 30초마다             --> PING 방송 -> 태블릿 PONG -> 서버가 마지막 확인 시각 갱신, 65초 무응답이면 오프라인
 태블릿에서 삭제      --> DELETE_ORDER 전송 -> 서버가 ORDER_DELETE 로 전체 방송
 연결 끊김            --> 5초 뒤 자동 재연결
```

## 메시지 표

### HTTP (서버)

| 경로 | 방식 | 응답 |
|---|---|---|
| `/api/kitchen_data` | GET | 카테고리, 메뉴(이미지 경로를 서버 주소 기준 URL로 바꿈), 주문, 대기 주문 JSON. CORS 허용 헤더(`*`)가 붙는다 |
| `/api/external_order` | POST | 스니퍼가 보낸 JSON을 받아 로그만 남기고 `{"status":"success"}` ([큐 동기화](queue-sync.md) 참조) |
| `/images/...` | GET | 메뉴 이미지 정적 파일 |
| `/ws` | WebSocket | 아래 표 |

### WebSocket

| 방향 | `type` | 내용 | 처리 |
|---|---|---|---|
| 서버 → 태블릿 | `CONNECTION_ACK` | 환영 메시지, 시각 | 태블릿이 연결 성공으로 표시 |
| 서버 → 태블릿 | `PING` | 시각 | 태블릿이 `PONG` 응답 |
| 서버 → 태블릿 | `KITCHEN_DATA` | `menus`, `categories`, `orders`(대기 주문) | 태블릿이 메뉴·주문을 교체하고 캐시 파일에 저장 |
| 서버 → 태블릿 | `MENU_DATA` | 메뉴 배열 | 메뉴만 교체 |
| 서버 → 태블릿 | `ORDER_CREATE` | 주문 한 건 | 목록 맨 앞에 추가, 안 읽은 수 증가, 시스템 클릭음 |
| 서버 → 태블릿 | `ORDER_DELETE` | 주문 ID | 해당 주문 제거 |
| 태블릿 → 서버 | `PONG` | | 마지막 확인 시각 갱신 |
| 태블릿 → 서버 | `DELETE_ORDER` | `orderId` | 서버가 주문을 지우고 `ORDER_DELETE` 방송 |
| 태블릿 → 서버 | `REQ_KITCHEN_DATA` | | 서버에 처리 코드 없음(아래 한계) |
| 태블릿 → 서버 | `GET_ORDERS` | | 서버는 `ORDER_LIST`로 응답하나, 태블릿 쪽 호출 코드는 주석 처리됨 |

태블릿은 정의되지 않은 `type`을 무시하고, JSON이 아닌 메시지는 버린다.

## 데이터 모델

### 메뉴(`MenuModel`, 관리 → 태블릿)

| 키 | 의미 |
|---|---|
| `id`, `name`, `cat` | ID, 이름, 카테고리(기본 "분류 없음") |
| `time` | 조리 시간 |
| `recipe`, `image` | 레시피 문장, 이미지 파일명 또는 URL |

### 주문

| 구분 | 관리 프로그램 `OrderModel.toJson` | 태블릿 `OrderInfo.fromJson`이 읽는 키 |
|---|---|---|
| 주문 ID | `orderId` | `id` |
| 테이블 | `table` | `table` 또는 `tableNo` |
| 항목 | `items`(메뉴 객체 목록) | `ord`, `items`, `menus` 중 하나(항목은 `main`, `sub` 메뉴 ID) |
| 시각 | `time`(ISO 8601) | `time` |
| 상태 | `status`(`pending`, `cooking`, `completed`, `cancelled`) | `state`(불리언, 완료 여부), 요청 사항 `req` |

태블릿은 주문 항목의 메뉴 ID(`main`, `sub`)를 메뉴 마스터(`json/menus.json`, 서버 데이터로 갱신)에서 찾아 이름·레시피·조리 시간을 채운다(`_resolveOrder`). 항목별 상태는 `waiting`, `cooking`, `done`이며, 1초 타이머가 `cooking` 항목의 남은 시간을 줄여 0이 되면 `done`으로 바꾼다.

## 따라 만들기

`확인 상태: 미검증`

| 단계 | 할 일 | 기대 결과 |
|---|---|---|
| 1 | `shelf` 서버에 `/ws` 라우트를 만들고 연결 즉시 `CONNECTION_ACK`를 보낸다 | 태블릿이 연결 성공 표시를 한다 |
| 2 | 채널 집합을 두고 `broadcast(String)`로 모든 채널에 보낸다 | 한 번의 호출로 모든 기기가 받는다 |
| 3 | 30초 타이머로 `PING`을 방송하고, 기기별 마지막 확인 시각을 65초 기준으로 판정한다 | 끊긴 태블릿이 오프라인으로 바뀐다 |
| 4 | 태블릿에서 메시지를 `type`으로 분기하고 모르는 종류는 버린다 | 잘못된 메시지에도 앱이 멈추지 않는다 |
| 5 | 받은 `KITCHEN_DATA`를 파일로 저장하고 앱 시작 때 먼저 읽는다 | 서버 없이도 직전 화면이 뜬다 |
| 6 | 연결이 끊기면 5초 뒤 재연결한다 | 서버를 껐다 켜도 자동 복구된다 |
| 7 | 항목 상태 + 1초 타이머로 조리 남은 시간을 줄인다 | 시간이 0이 되면 완료 표시가 된다 |

## 알려진 한계·주의

{% hint style="warning" %}
WARNING: 아래 불일치는 코드를 읽은 판단이며 실행으로 확인하지 않았다.
{% endhint %}

| 번호 | 내용 |
|---|---|
| 1 | 서버가 방송하는 주문 JSON은 ID를 `orderId`로 내보내는데, 태블릿은 `id`만 읽는다. 태블릿에서 ID가 빈 문자열이 되어 삭제·중복 판별이 어긋날 수 있다. 상태 필드도 `status`와 `state`로 다르다 |
| 2 | 태블릿이 보내는 `REQ_KITCHEN_DATA`를 서버가 처리하지 않는다. 서버가 처리하는 것은 `GET_ORDERS`다. 연결 직후 데이터를 받으려면 서버의 메뉴 변경 방송이나 `/api/kitchen_data` 호출에 기대야 한다 |
| 3 | 서버는 모든 인터페이스에서 열려 있고 `/ws`, `/api/*`에 인증이 없다. 같은 네트워크의 누구나 연결해 `DELETE_ORDER`를 보낼 수 있다. 방어를 위해 방화벽·사설망 제한, 연결 토큰 검사, 주문 삭제 권한 구분이 필요하다 |
| 4 | 기기 ID를 IP 주소의 마지막 마디로 만든다(`D-<마지막 숫자>`). 서브넷이 다르면 충돌한다 |
| 5 | `ORDER_CREATE`를 만드는 곳은 관리 화면의 테스트 주문 버튼뿐이다(`header.dart`). 실제 주문 유입 경로는 [큐 동기화](queue-sync.md)의 한계 참조 |
| 6 | 태블릿 `pingServer`는 HEAD를 보내나 서버 라우트는 방식을 구분하지 않아 GET과 같이 응답한다(확인 필요) |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-19 | 최초 작성 |
