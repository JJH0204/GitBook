# Dynamic Routing Protocol

동적 라우팅은 라우터가 **자동으로 경로를 학습/갱신**하는 방식입니다.

* 정적 라우팅: 사람이 직접 경로를 고정한다.
* 동적 라우팅: 라우팅 프로토콜이 경로 정보를 교환한다.

### 언제 쓰나

* 경로 변경이 잦다.
* 라우터 수가 많다.
* 장애 시 우회가 필요하다.

### 핵심 개념

* **Metric**: 최적 경로 선택 기준(홉 수, 비용, 대역폭 등).
* **Convergence**: 네트워크 변화 후 “안정 상태”로 수렴하는 시간.

### 프로토콜별 페이지

* [RIP](rip.md)
* [OSPF](ospf.md)
* [EIGRP](eigrp.md)

<table data-view="cards"><thead><tr><th>라우팅 프로토콜</th><th data-card-target data-type="content-ref">페이지</th></tr></thead><tbody><tr><td>RIP</td><td><a href="rip.md">rip.md</a></td></tr><tr><td>EIGRP</td><td><a href="eigrp.md">eigrp.md</a></td></tr><tr><td>OSPF</td><td><a href="ospf.md">ospf.md</a></td></tr></tbody></table>
