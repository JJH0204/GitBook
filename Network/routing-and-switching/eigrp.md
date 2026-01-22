# EIGRP

cisco에서 개발한 IGRP 기반의 개방형 라우팅 프로토콜\
망 구성 방식이 변경된 뒤 일어나는 불안정한 라우팅을 최소화하는데 최적화 됨\
hop count가 커 대학/병원 등에서 사용한다.\
rip와 달리 경로 비용을 가중치로 관리해 유동적이다.

* [관련정보](https://m.blog.naver.com/luexr/222441096481)

## 연결

위와 같이 초기 설정된 topology에 AS를 구분해서 라우팅 진행

각 라우터의 연결 정보는 `sh ip route`를 통해 확인한다.

다음은 라우터에서 광고할 네트워크를 설정하는 과정이다.

{% stepper %}
{% step %}
### 네트워크 광고 설정 (로컬 AS)

1. 전역 구성 모드로 진입:
   * `conf t`
2. EIGRP 프로세스 생성 및 AS 지정:
   * `router eigrp <ASN>`
3. 광고할 네트워크 추가:
   * `network <네트워크IP> <와일드카드>`
   * 참고
     * [ASN](/broken/pages/1510b86b07834d6c1616552b8243ac715f0d6be4)
     * [와일드카드 마스크](/broken/pages/d5509560da5dd097bd382b83cc1a65fda2701cda)
4. 자동 요약 해제:
   * 모든 네트워크를 설정한 뒤 `no auto-summary` 실행
5. 다른 라우터에서도 동일하게 구성

결과: 같은 AS 안에서는 ping 송수신이 원활해진다.
{% endstep %}

{% step %}
### 이웃 및 토폴로지 확인

* 라우팅 테이블에서 EIGRP로 학습한 경로는 D 코드로 표시된다.&#x20;
*   이웃 확인:

    * `sh ip eigrp neighbors`&#x20;

    이곳에 이웃 정보가 없다면 네트워크 광고 데이터를 받지 못해 라우팅 테이블을 갱신할 수 없다.
* 인터페이스 속성 확인 (경로 비용 계산에 사용):
  * `sh int <인터페이스이름>`에서 MTU, BW, DLY 확인&#x20;
* 토폴로지 테이블 확인:
  * `sh ip eigrp topology`\
    FD(Feasible Distance) 값이 가장 작은 경로가 최적 경로가 된다.
{% endstep %}
{% endstepper %}

## 서로 다른 ASN 끼리 재분배

ASN 값이 서로 다른 경우 재분배 설정이 없으면 네트워크 정보를 받아올 수 없다.\
서로 다른 라우터 끼리 연결 하는 기능을 Redistribution이라 한다.

두 가지 방법이 있다:

* Multi : 양 라우터에 재분배
* Single : 한쪽 라우터에 재분배

***

재분배 할 라우터에 접속한다.

{% stepper %}
{% step %}
### Single / 다수 재분배 설정 (예시)

1. 재분배 명령 적용 (재분배 실행할 라우터에서):
   * `router eigrp <ASN>`
   * `redistribute eigrp <연결할ASN>`

예시:

```
Router(config)#router eigrp 100
Router(config-router)#redistribute eigrp 200
```

2. 네트워크 확인:
   * `do sh ip route`

(출력 예시는 원문 참조)
{% endstep %}

{% step %}
### 추가 네트워크 광고 및 자동 요약 해제

1. 네트워크 추가:
   * `net <네트워크> <와일드카드>` (예: `net 192.168.20.192 0.0.0.63`)
2. 자동 요약 해제:
   * `no auto-summary`

예시 세션:

```
Router(config-router)#net 192.168.20.192 0.0.0.63
Router(config-router)#
%DUAL-5-NBRCHANGE: IP-EIGRP 100: Neighbor 192.168.20.193 (Serial0/3/1) is up: new adjacency

Router(config-router)#no auto-summary
```
{% endstep %}
{% endstepper %}

재분배한 라우터에서는 D 코드로 다른 AS 네트워크의 경로 정보가 표시된다.\
다른 라우터에서는 D EX로 외부에서 온 네트워크라는 점을 확인할 수 있도록 표시된다.

참고: 라우팅 프로토콜이 같으면 네트워크를 중복으로 광고해도 문제가 없다.\
다르면 한쪽에서만 진행해야 하며, 중복 광고 시 오류가 발생할 수 있다.

## 관련 문서

* [Redistribution](file:///2435498/linux_admin/Redistribution.md)
