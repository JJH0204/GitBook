# Snort Rule

## action

* alert: 경고
* log:
* pass:
* active:
* reject: 패킷 차단 + log화 + 상대에 메시지 전달
* drop: 패킷 차단 + log화
* sdrop: 패킷 차단

## protocol

* 탐지할 패킷 종류
* tcp / icmp / udp / ip / any

## source A\&P / Destination A\&P

* `any`: 모든 Address 또는 모든 Port
* Port
  * `10-20`: 10번에서 20번 사이
  * `:10`: 10번 포트 이하
  * `10:`: 10번 포트 이상
  * `!10`: 10번 포트 제외 모든 포트
* Address
  * `192.168.100.0/24`: 네트워크 대역
  * `[192.168.100.0/24,192.168.200.0/24]`: 둘 이상의 주소

## -> / <>

* 탐지할 트래픽 방향 지정

## option

* `msg`: 탐지 시 출력될 메시지 지정
* `sid`: 룰을 식별하는 고유 번호 (중복 불가)
* `rev`: 룰의 버전 (룰 수정 시 자동으로 1 증가)
* `content`: 패킷 내 문자열을 지정해 검사
  * injection 공격 방어를 위해 사용
* `nocase`: 패킷 내 문자열 대소문자 구분 없이 식별
