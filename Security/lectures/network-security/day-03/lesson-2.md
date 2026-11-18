# 2. 트렁크: 선 하나에 여러 VLAN

> 상위: [3일차 스위칭과 VLAN](README.md)
> 실습: [2-1. 트렁크 설정 실습](lesson-2-lab.md), 명령 모음 [0. 실습 명령어 모음](commands.md)
> 그림: 2. 트렁크: 선 하나에 여러 VLAN 그림 (9장)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-03-002-DO |
| 유형 | D&O (개념) |
| 목적 | 트렁크와 802.1Q 태그의 원리, access 포트와 trunk 포트의 차이, 트렁크가 저절로 생기지 않게 하는 설정을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비 출력은 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 트렁크가 VLAN 태그를 붙여 여러 VLAN을 한 선으로 나른다는 것을 안다.
- access 포트와 trunk 포트를 구분한다.
- 트렁크에 필요한 VLAN만 허락하고, 트렁크가 저절로 생기지 않게 설정한다.
- `show interfaces trunk`로 트렁크 상태를 읽는다.

## 목적

영업팀 자리가 1층의 HQ-SW1과 2층의 HQ-SW2에 나뉘어 있다. 두 스위치를 선 하나로 이었을 때, 그 선은 어느 VLAN에 넣어야 할까. VLAN 10에 넣으면 개발팀(VLAN 30)이 1층 서버에 갈 수 없고, VLAN 30에 넣으면 영업팀이 막힌다. VLAN마다 선을 하나씩 깔면 부서가 늘 때마다 선이 늘어난다.

선 하나로 여러 VLAN을 나르되, 받는 쪽이 어느 VLAN의 것인지 알 수 있어야 한다.

## 1. 태그를 붙여 나른다

트렁크는 여러 VLAN의 프레임을 한 선으로 나르는 연결이다. 보내는 스위치가 프레임마다 VLAN 번호가 적힌 태그를 붙이고, 받는 스위치가 태그를 보고 해당 VLAN에 넘긴 뒤 태그를 뗀다. 이 방식의 표준 이름이 IEEE 802.1Q이고, 줄여서 dot1Q라고 부른다.

```
보통 프레임    [MAC 헤더 | IP 헤더 | 데이터 | 꼬리]
트렁크 위      [MAC 헤더 | 802.1Q 태그 (VLAN 10) | IP 헤더 | 데이터 | 꼬리]
```

택배 트럭 한 대에 여러 층으로 갈 상자를 싣는 것과 같다. 상자마다 층 번호 스티커를 붙여 싣고, 도착한 건물에서 스티커를 보고 층별로 나눈 뒤 스티커를 뗀다. PC는 스티커가 붙은 상자를 본 적이 없다. 태그는 스위치 사이에서만 붙었다 떨어진다.

태그 안에서 VLAN 번호에 쓰는 자리는 12비트다. 2¹² = 4096가지 중 0과 4095를 빼서 VLAN 번호가 1~4094인 것이다.

{% hint style="info" %}
NOTE: 2일차에 본 캡슐화가 여기서도 일어난다. 2계층 헤더 안에 칸이 하나 더 끼어드는 것이다.
{% endhint %}

## 2. access 포트와 trunk 포트

| | access 포트 | trunk 포트 |
|---|---|---|
| 꽂는 것 | PC, 서버, 프린터 | 다른 스위치, 라우터 |
| 다루는 VLAN | 하나 | 여럿 |
| 태그 | 붙이지 않는다 | 붙인다 (native VLAN만 빼고) |
| 명령 | `switchport mode access` | `switchport mode trunk` |

native VLAN은 트렁크 위에서 태그 없이 오가는 VLAN이다. 처음에는 VLAN 1이다. 트렁크 양쪽의 native VLAN이 다르면, 한쪽이 태그 없이 보낸 프레임을 다른 쪽이 엉뚱한 VLAN으로 받게 된다.

## 3. 새봄상사의 트렁크

트렁크는 두 곳이다. HQ-SW1과 HQ-R1 사이(Gi0/1), 그리고 HQ-SW1과 HQ-SW2 사이(Gi0/2)다.

```
interface gi0/2
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40,99
 switchport trunk native vlan 900
 switchport nonegotiate
```

| 명령 | 하는 일 | 왜 |
|---|---|---|
| `switchport mode trunk` | 이 포트를 트렁크로 못 박는다 | 협상에 맡기지 않는다 |
| `switchport trunk allowed vlan ...` | 이 트렁크로 나를 VLAN을 정한다 | 필요한 VLAN만. 최소 권한 |
| `switchport trunk native vlan 900` | 태그 없이 오가는 VLAN을 아무도 쓰지 않는 900으로 | 4절 |
| `switchport nonegotiate` | 트렁크 협상(DTP) 신호를 보내지 않는다 | 4절 |

HQ-SW2의 Gi0/1에도 똑같이 설정한다. 트렁크는 양쪽이 짝이 맞아야 한다. 특히 native VLAN을 한쪽만 바꾸면 `%CDP-4-NATIVE_VLAN_MISMATCH` 알림이 계속 뜬다. 이 알림이 보이면 반대쪽을 잊은 것이다.

라우터 쪽 트렁크(Gi0/1)는 native VLAN을 바꾸지 않고 둔다. 라우터는 태그 없는 프레임을 받을 서브인터페이스가 없어서, native VLAN으로 오는 프레임은 어차피 버린다.

## 4. 트렁크를 저절로 생기게 두지 않는다

시스코 스위치는 처음에 포트끼리 협상해서 트렁크를 만들 수 있게 되어 있다. 이 협상을 DTP(Dynamic Trunking Protocol)라고 한다. 편해 보이지만 보안에는 구멍이다.

| 위험 | 어떻게 일어나나 | 막는 방법 |
|---|---|---|
| 가짜 트렁크 | PC 자리 포트에 협상 신호를 보내는 장비를 꽂으면 그 포트가 트렁크가 되어 모든 VLAN의 프레임이 흘러든다 | PC 자리는 `switchport mode access`로 고정 |
| 협상 신호 | 트렁크 포트가 계속 협상 신호를 내보낸다 | 트렁크에는 `switchport nonegotiate` |
| 이중 태그 | native VLAN에 있는 PC가 태그를 두 겹 붙여 보내면, 첫 스위치가 바깥 태그만 떼고 안쪽 태그대로 다른 VLAN에 넘긴다 | native VLAN을 아무 포트도 없는 번호(900)로 |
| 너무 넓은 트렁크 | 트렁크가 모든 VLAN을 나르면 필요 없는 곳까지 퍼진다 | `allowed vlan`으로 필요한 것만 |

{% hint style="info" %}
NOTE: 여기 적은 공격은 이름과 원리만 안다. 오늘 할 일은 이런 일이 일어날 틈을 설정에서 닫는 것이다. 12일차에 같은 네트워크 안에서 일어나는 공격을 내 실습망에서 직접 관찰한다.
{% endhint %}

## 5. 확인

```
HQ-SW1#show interfaces trunk
Port        Mode         Encapsulation  Status        Native vlan
Gi0/1       on           802.1q         trunking      1
Gi0/2       on           802.1q         trunking      900

Port        Vlans allowed on trunk
Gi0/1       10,20,30,40,99
Gi0/2       10,20,30,40,99
```

| 칸 | 읽는 법 |
|---|---|
| Mode on | 협상 없이 트렁크로 못 박혀 있다 |
| Status trunking | 트렁크로 동작하는 중이다 |
| Native vlan | 태그 없이 오가는 VLAN. 양쪽이 같아야 한다 |
| Vlans allowed | 이 트렁크로 오가는 VLAN |

출력 아래쪽에 표가 두 개 더 있다. 오늘은 위의 두 표만 읽는다.

2층 영업팀 PC(HQ-SW2 Fa0/11)에서 1층 영업팀 PC로 ping이 되면, VLAN 10이 트렁크를 타고 두 스위치를 건넌 것이다.

## 6. 탐지·방어

| 항목 | 내용 |
|---|---|
| 원인 | 포트가 협상으로 트렁크가 될 수 있는 상태(`dynamic` 계열 모드), 트렁크가 모든 VLAN을 나름, native VLAN이 사용 중인 VLAN과 같음 |
| 완화 | PC 자리 `switchport mode access`, 트렁크 `switchport mode trunk`와 `switchport nonegotiate`, `allowed vlan` 제한, native VLAN을 빈 VLAN으로 |
| 흔적 | PC 자리 포트가 `show interfaces trunk`에 나타나면 의심한다. 양쪽 native VLAN이 다르면 `%CDP-4-NATIVE_VLAN_MISMATCH` 로그가 반복된다 (미검증) |

## 약어·용어

| 용어 | 뜻 |
|---|---|
| 트렁크 | 여러 VLAN의 프레임을 한 선으로 나르는 연결 |
| 802.1Q (dot1Q) | VLAN 태그를 붙이는 IEEE 표준 |
| native VLAN | 트렁크 위에서 태그 없이 오가는 VLAN |
| DTP | Dynamic Trunking Protocol. 포트끼리 트렁크 여부를 협상하는 시스코 프로토콜 |
| CDP | Cisco Discovery Protocol. 이웃 장비 정보를 주고받는 프로토콜 |

## 함께 생각해 보기

- 트렁크의 `allowed vlan`에서 99를 빼면 무엇이 안 될까?
- 누군가 1층 영업팀 자리의 포트에 소형 스위치를 꽂아 자리를 늘렸다. `switchport mode access`가 있을 때와 없을 때 무엇이 다를까?

## 강의 메모

### 시간 배분 (30분)

| 절 | 시간 | 방식 |
|---|---|---|
| 목적, 1 태그 | 8분 | 택배 트럭 비유. 선을 VLAN마다 까는 그림과 비교 |
| 2 access와 trunk | 4분 | |
| 3 새봄상사의 트렁크 | 10분 | 실습 2-1. 한쪽만 native VLAN을 바꿔 알림을 일부러 본다 |
| 4 저절로 생기지 않게 | 5분 | 표만 짚는다 |
| 5 확인 | 3분 | `show interfaces trunk`를 같이 읽는다 |

### 물어볼 것

- "트럭 한 대에 여러 층 상자를 실으려면 무엇이 필요할까?" 층 번호 스티커, 곧 태그다.
- "PC는 태그를 볼까?" 보지 않는다. 태그는 스위치 사이에서만 붙었다 떨어진다.
- 첫 번째 함께 생각해 보기의 답: 2층 HQ-SW2의 관리 주소(VLAN 99)로 접속할 수 없게 된다. 관리 VLAN이 트렁크를 건너지 못하기 때문이다.
- 두 번째 함께 생각해 보기의 답: `switchport mode access`가 있으면 그 포트는 끝까지 VLAN 10 하나만 다룬다. 없으면 꽂힌 장비가 협상을 걸어 트렁크가 될 여지가 생긴다. 다만 소형 스위치를 몰래 꽂는 것 자체도 막아야 할 일이고, 그것은 12일차의 포트 보안에서 다룬다.

### 자주 헷갈리는 것

| 헷갈리는 것 | 바로잡기 |
|---|---|
| 트렁크 포트도 VLAN에 넣어야 한다 | 트렁크는 여러 VLAN을 나른다. `switchport access vlan`은 access 포트의 명령이다 |
| native VLAN은 관리 VLAN이다 | 다른 개념이다. 관리 VLAN(99)은 장비에 접속하는 대역이고, native VLAN(900)은 태그 없이 오가는 VLAN이다 |
| 라우터에도 `switchport mode trunk`를 친다 | 라우터에는 이 명령이 없다. 라우터는 서브인터페이스의 `encapsulation dot1Q`로 태그를 다룬다 |
| `allowed vlan`에 VLAN을 하나씩 더하려면 다시 다 친다 | 덧붙일 때는 `switchport trunk allowed vlan add 50` |

### 진행 요령

- native VLAN을 한쪽만 바꿔 `NATIVE_VLAN_MISMATCH` 알림을 일부러 보게 하면, 트렁크는 양쪽이 짝을 맞춰야 한다는 것이 기억에 남는다. 확인한 뒤 반대쪽도 바꾼다.
- VLAN 900은 만들어 두기만 하고 어느 포트에도 넣지 않는다. 아무도 없는 VLAN이어야 이중 태그가 갈 곳이 없다.
- 이중 태그 공격은 원리를 그림 한 장으로만 보여 준다. 실습으로 재현하지 않는다.

### 출처

- 키워드 요약 3월 25일 "트렁킹 서브인터페이스 다른 VLAN 간 통신"(802.1q 태깅, native VLAN), "포트 기반 VLAN 트렁크"(dynamic 모드는 보안상 비권장)
- 정보보안개론 3장(스위칭 환경의 공격)

## 그림 목록

2. 트렁크: 선 하나에 여러 VLAN 그림 (9장). 프레임 이름의 번호 순서대로 Slideshow 스크립트가 넘긴다. 그림 파일은 이 저장소에 없다.

| 장 | 화면 | 절 |
|---|---|---|
| 01 | 두 스위치 사이의 선은 어느 VLAN에? | 목적 |
| 02 | 태그를 붙여 나름: IEEE 802.1Q | 1 |
| 03 | 택배 트럭과 층 번호 스티커 | 1 |
| 04 | access 포트와 trunk 포트 | 2 |
| 05 | 새봄상사의 트렁크 두 곳 | 3 |
| 06 | 트렁크 설정 네 줄 | 3 |
| 07 | 트렁크를 저절로 생기게 두지 않음 | 4 |
| 08 | 이중 태그: 바깥 태그가 떨어지고 안쪽 태그로 건너감 | 4 |
| 09 | show interfaces trunk | 5 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 강의 노트를 AMM D&O 형식으로 재작성. 평서체 변환, 6절 탐지·방어와 약어·용어 추가, 내 말로 채우기 추가. 실습 대본은 2-1 실습 문서로 분리 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 트렁크에서 태그가 왜 필요한지 택배 비유 말고 내 말로 적는다.
- [ ] PC 자리 포트를 `switchport mode access`로 고정하지 않으면 어떤 일이 생길 수 있는지 적는다.
- [ ] native VLAN을 아무도 쓰지 않는 번호로 바꾸는 이유를 내 말로 적는다.
