# VLAN 트렁킹 프로토콜 (VTP)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-RSW-009-DO |
| 유형 | D&O (개념) |
| 목적 | VTP의 모드 3가지, 동기화 조건, 리비전 번호의 동작, 사고 위험을 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 리비전 번호 초기화 조건은 정정했다. 정정한 곳은 NOTE에 표시했다. 명령 표는 유지했다. 설정 절차는 [vlan-config.md](vlan-config.md)(NET-RSW-013-MP)에 있다.
{% endhint %}

## 1. 목적

VTP(VLAN Trunking Protocol)는 Cisco 스위치 사이에서 VLAN 정보를 동기화하는 프로토콜이다. 한 스위치(Server)에서 VLAN을 만들면 같은 도메인의 다른 스위치가 그 VLAN 목록을 자동으로 받는다. 광고는 트렁크 링크로만 전달된다.

## 2. 구성 요소

### 2.1 VTP 모드

| 번호 | 모드 | VLAN 생성·삭제 | 동기화 | 설명 |
|---|---|---|---|---|
| 1 | Server | 가능 | 한다 | VLAN 설정을 공유하는 주체다. Revision 값이 높은 쪽 설정이 기준이 된다 |
| 2 | Client | 불가 | 한다 | Server에서 VLAN 정보를 받아 온다 |
| 3 | Transparent | 가능(자기 자신에게만) | 안 한다 | 완전 독립 모드다. 받은 광고는 다른 스위치로 중계만 한다. 자신의 VLAN은 공유하지 않는다 |

### 2.2 동기화 조건

| 번호 | 조건 | 내용 |
|---|---|---|
| 1 | VTP 도메인 | 이름이 같아야 한다 |
| 2 | 링크 | 스위치끼리 트렁크로 연결돼야 한다 |
| 3 | 비밀번호 | 설정했다면 같아야 한다 |
| 4 | Revision | Server 또는 Client 중 Revision이 가장 높은 쪽 정보가 다른 스위치를 덮어쓴다 |

### 2.3 VTP 명령

| 번호 | 명령 | 뜻 |
|---|---|---|
| 1 | `vtp mode <모드>` | 스위치의 VTP 모드를 설정한다. 모드는 `server`, `client`, `transparent` 중 하나다 |
| 2 | `vtp domain <이름>` | VTP 도메인 이름을 설정한다 |
| 3 | `show vtp status` | VTP 상태(모드, 도메인, Revision)를 확인한다 |
| 4 | `vtp password <비밀번호>` | VTP 비밀번호를 설정한다 |
| 5 | `vtp version <버전>` | VTP 버전(1, 2, 3)을 설정한다 |

### 2.4 VTP 리비전 번호

| 번호 | 항목 | 내용 |
|---|---|---|
| 1 | 증가 | VLAN을 추가, 삭제, 이름 변경할 때마다 1씩 증가한다 |
| 2 | 초기화 | VTP 도메인 이름을 바꾸거나, 모드를 Transparent로 바꿨다가 되돌리면 0으로 초기화된다 |

{% hint style="info" %}
NOTE: 원본은 "Trunk 연결 정보가 수정되면 값이 0으로 초기화된다"고 적었다. 일반적으로 트렁크 변경만으로는 초기화되지 않는다. 확인 필요.
{% endhint %}

## 3. 동작 원리

1. Server에서 VLAN을 추가, 삭제, 수정한다.
2. Server의 Revision이 1 증가한다.
3. Server가 트렁크로 새 VLAN 정보를 광고한다.
4. 같은 도메인의 스위치가 받은 Revision을 자신의 Revision과 비교한다.
5. 받은 값이 더 높으면 자신의 VLAN 정보를 광고된 내용으로 바꾼다. 같거나 낮으면 무시한다.
6. Transparent 스위치는 자신의 VLAN 정보를 바꾸지 않고 광고를 이웃으로 넘긴다.

{% hint style="danger" %}
WARNING: Revision이 높은 스위치(예: 다른 곳에서 쓰던 스위치)를 같은 도메인의 트렁크에 연결하면, 그 스위치의 VLAN 목록이 기존 스위치 전체의 VLAN 정보를 덮어쓸 수 있다. 기존 VLAN이 삭제돼 단말이 통신하지 못하는 사고가 난다. 새 스위치는 연결 전에 Revision을 0으로 만든다(2.4절). 방법은 [vlan-config.md](vlan-config.md)의 구역 D를 본다. 확인 필요.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| VTP | VLAN Trunking Protocol. Cisco 독자 프로토콜 |
| VTP Domain | VTP 광고를 공유하는 스위치 묶음의 이름 |
| Revision | VLAN 데이터베이스 변경 횟수를 나타내는 번호 |
| Trunk | 여러 VLAN을 나르는 링크 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] VTP를 쓰면 편해지는 점과 위험해지는 점을 하나씩 쓴다.
- [ ] Transparent 모드를 쓰는 상황을 내 말로 설명한다.
- [ ] 새 스위치를 기존 네트워크에 붙이기 전에 무엇을 확인할지 순서대로 쓴다.
