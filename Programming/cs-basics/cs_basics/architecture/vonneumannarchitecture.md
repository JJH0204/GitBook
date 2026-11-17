# 폰 노이만 구조 (Von Neumann)

* 근대 컴퓨터는 연산과 제어를 위해 중앙처리장치(Central Processing Unit, CPU), 저장을 위해 [기억장치(Memory)](../os_memory/memory-management/memory.md)를 사용한다.
* 장치 간 데이터나 제어 신호를 교환할 수 있도록 [버스(Bus)](bus.md)라는 전자 통로를 사용한다.

{% hint style="info" %}
CPU안에 다른 저장장치가 왜 필요한가

CPU의 빠른 연산속도로 인해 주기억장치 또는 보조기억장치만 사용해서는 병목현상이 발생하게 된다.\
따라서 CPU는 데이터를 교환속도를 단축시키기 위해 "캐시"라는 저장장치를 내부에 갖게 되었다.
{% endhint %}
