# 네트워크와 프로토콜의 관계

* A Protocol
* pc 1
* pc 2
* pc 3
* B Protocol
* pc 1
* pc 2
* pc 3
* C Protocol
* pc 1
* pc 2
* pc 3
* 서로 다른 프로토콜을 사용하는 네트워크 간 데이터 통신 시\
  네트워크 전송 규약이 다르기 때문에 전송이 불가능하다.\
  네트워크 전송 규약을 프로토콜 이라 칭할 수 있다.
* 약속된 IP 프로토콜
* Encapsulation
* Decapsulation
* Decapsulation
* 외부 통신 시 약속된 프로토콜을 사용하도록 미리 약속을 하면\
  Encapsulation, Decapsulation 과정을 통해\
  서로 다른 프로토콜을 사용하는 네트워크 간 통신이 가능해 진다.
* PC에서 다른 PC로 데이터를 전송할 때 데이터를 "패키지화" 하는 과정을 의미\
  데이터는 초기에 PDU(Protocol Data Unit)라는 형식으로 생성\
  PDU가 다른 PC로 전송될 때 여러번의 패키지 과정이 실시된다.
* 프로토콜 헤더를 추가해 전송\
  데이터를 수신할 때는 헤더를 식별하고\
  헤더 정보를 내부 프로토콜 정보로 변경해 로컬 환경에서 읽는다.
