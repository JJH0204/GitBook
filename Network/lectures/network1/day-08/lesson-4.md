# 4. 포트 보안 — 아무나 꽂지 못하게

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-08-004-DO |
| 유형 | D&O (개념) |
| 목적 | 스위치 포트 보안의 원리(MAC 제한, sticky, 위반 모드)와 err-disabled 복구 개념, 한계를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 스위치 포트가 기본적으로 무방비라는 것을 이해한다.
- 포트 보안(Port Security)이 MAC 주소로 접속을 제한하는 원리를 안다.
- sticky 학습과 위반 시 동작(shutdown, restrict, protect)을 구분한다.
- err-disabled된 포트를 복구하는 순서를 안다.

## 이전 학습과의 연결

[1_원격접속_Telnet과SSH](lesson-1.md)에서 장비에 들어오는 문(VTY)을 SSH로 잠갔다. 그런데 사무실 벽의 랜 포트는 어떨까. 누군가 자기 노트북을 들고 와서 빈자리 랜선에 꽂으면 다음과 같다.

- 스위치는 아무 MAC이나 배운다(4일차 Learning). → [1_스위치_동작원리](../day-04/lesson-1.md)
- 그 포트가 VLAN 10이면 그 노트북은 곧바로 영업팀 동네 주민이 된다(7일차).
- DHCP가 켜져 있으면 IP까지 받아 간다(방금 [2_DHCP와_DNS](lesson-2.md)에서 만든 그 서비스).

오늘 만든 편리함(DHCP)이 침입자에게도 편리하다.

## 1. 구성 요소

### 포트 보안 — 이 포트에는 이 MAC만

포트마다 "허락된 MAC 주소" 목록을 두고, 모르는 MAC이 들어오면 막는다.

```
SW1 Fa0/1  ─  허락된 MAC: 0001.4295.1A01 (PC0) 딱 하나
                │
    PC0 꽂음 → 통과
    노트북 꽂음 → 모르는 MAC → 포트 차단
```

- 비유는 사원증 출입문이다. 등록된 사원증(MAC)만 문이 열린다. 모르는 카드를 대면 경보가 울리고 문이 잠긴다. 관리자가 와서 풀어줘야 다시 열린다.

### 설정 — 다섯 줄

```bash
interface fa0/1
 switchport mode access                      # ① 전제: 액세스 포트여야 한다 (7일차)
 switchport port-security                    # ② 포트 보안 켜기
 switchport port-security maximum 1          # ③ 허락할 MAC 개수 (기본값도 1)
 switchport port-security mac-address sticky # ④ 처음 들어온 MAC 을 자동으로 등록
 switchport port-security violation shutdown # ⑤ 위반하면 포트를 꺼버린다 (기본값)
```

| 줄 | 뜻 |
|---|---|
| ① `mode access` | 포트 보안은 액세스 포트에서만 된다. 모드가 `dynamic`이면 `Command rejected`가 나온다 |
| ③ `maximum 1` | 이 포트에는 기기 한 대만 허용한다 |
| ④ `sticky` | MAC을 손으로 입력하지 않아도 처음 온 MAC을 끈끈이처럼 붙잡아 설정에 적는다 |
| ⑤ `violation` | 모르는 MAC이 오면 어떻게 할지 정한다 (아래 표) |

### sticky — 손으로 MAC을 입력할 필요가 없다

- 방법 1: `switchport port-security mac-address 0001.4295.1A01`로 직접 입력한다. 오타가 나기 쉽고 수백 대면 감당이 안 된다.
- 방법 2: sticky. PC가 처음 한 번 통신하면 그 MAC을 배워서 running-config에 자동으로 적는다.

```
interface FastEthernet0/1
 switchport port-security mac-address sticky 0001.4295.1A01   ← 스위치가 스스로 적은 줄
```

{% hint style="warning" %}
CAUTION: sticky로 배운 MAC도 `copy running-config startup-config`를 해야 재부팅 후 남는다.
{% endhint %}

### 위반했을 때 — 세 가지 모드

| 모드 | 모르는 프레임 | 포트 | 기록(로그, 카운터) | 비유 |
|---|---|---|:---:|---|
| shutdown (기본) | 버림 | 통째로 꺼짐 (err-disabled) | 기록함 | 경보 + 출입문 봉쇄 |
| restrict | 버림 | 살아 있음 | 기록함 | 경보만, 문은 그대로 |
| protect | 버림 | 살아 있음 | 기록 안 함 | 조용히 무시 |

- 기본값 shutdown이 가장 확실하다. 단점은 그 포트의 정상 사용자도 같이 끊긴다는 것이다.
- `restrict`는 정상 기기는 계속 쓰고 침입 기록만 남긴다. 사무실에서 많이 쓴다.

## 2. 동작 원리

### err-disabled — 꺼진 포트 되살리기

```
SW1# show port-security interface fa0/1
Port Security              : Enabled
Port Status                : Secure-shutdown        ← 위반으로 꺼졌다
Violation Mode             : Shutdown
Maximum MAC Addresses      : 1
Total MAC Addresses        : 1
Sticky MAC Addresses       : 1
Last Source Address:Vlan   : 00D0.BA8E.2C11:10      ← 범인의 MAC
Security Violation Count   : 1
```

복구 순서는 범인을 먼저 치우는 것이다.

1. 침입 기기의 선을 뽑는다. 안 뽑고 켜면 즉시 다시 꺼진다.
2. 포트를 껐다 켠다.

```bash
interface fa0/1
 shutdown
 no shutdown
```

- PT 화면에서는 위반한 포트의 링크가 빨간색으로 바뀐다. `show interfaces fa0/1`에는 `down (err-disabled)`가 나온다.

### 안 쓰는 포트는 끄고 격리한다

```bash
interface range fa0/5 - 22
 switchport mode access
 switchport access vlan 999        # 아무 데도 연결 안 된 "주차장 VLAN"
 shutdown                          # 그리고 꺼둔다
```

- 실무 보안 기본기는 안 쓰는 포트를 꺼두고, 쓰는 포트에는 포트 보안을 거는 것이다. 7일차의 네이티브 VLAN 변경, 오늘의 SSH와 함께 스위치 보안 3종 세트다.

### 한계 — MAC은 위조할 수 있다

- 무선 보안에서 "MAC 필터링은 보조 수단"이라고 하는 이유와 같다. → [5_무선랜과_IPv6](lesson-5.md)
- 누군가 PC0의 MAC을 알아내 자기 노트북 MAC을 똑같이 바꾸면 통과한다.
- 그래서 실무는 802.1X(사용자 계정으로 포트 인증)까지 간다. 이름만 소개한다. 11일차 서버 보안과 연결된다. → [11일차 · 서버 보안](../../network2/day-11/README.md)

## 3. 실습 연계와 확인 질문

- 실습 STEP 6: [0_실습_명령어_모음](commands.md), 절차 문서 [서버 설정 실습](lesson-6.md).
- "포트 보안 명령이 `Command rejected`로 거부된다" → 포트가 액세스 모드가 아니다.
- "침입 노트북을 뽑지 않고 `no shutdown`을 했다" → 바로 다시 꺼진다.
- "정상 PC를 새것으로 바꿨더니 포트가 꺼졌다" → sticky가 옛 PC의 MAC을 기억하고 있다. `no switchport port-security mac-address sticky <옛 MAC>` 또는 `clear port-security sticky interface fa0/1` 후 새로 학습시킨다.

## 4. 강의 메모

- "DHCP가 침입자에게도 친절하다"로 연다. 방금 만든 서비스가 위협이 되는 반전이다.
- 비유는 사원증 출입문이다. shutdown(봉쇄), restrict(경보만), protect(조용히) 세 모드가 모두 설명된다.
- 실습은 침입, 빨간 불, 범인 MAC 확인, 복구의 4컷으로 진행한다. `Last Source Address`에서 범인 MAC을 찾는 장면이 재미있다.
- 복구할 때 범인부터 뽑는다. 이 순서를 빼먹으면 "왜 또 꺼져요?"가 나온다.
- MAC 위조 가능성은 꼭 말해준다. "완벽한 보안은 없다, 겹겹이 쌓는다"가 2단계 11일차 서버 보안의 복선이다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| Port Security | 포트별로 허용 MAC을 제한하는 스위치 기능 |
| sticky | 학습한 MAC을 running-config에 자동 기록하는 방식 |
| violation | 허용되지 않은 MAC이 들어왔을 때의 동작 설정 |
| err-disabled | 오류(위반)로 스위치가 포트를 꺼 둔 상태 |
| 802.1X | 사용자 계정으로 포트 접속을 인증하는 표준 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 스위치가 기본적으로 낯선 기기를 막지 않는 이유를 내 말로 설명해 본다.
- [ ] shutdown, restrict, protect 중 사무실에 어울리는 모드를 고르고 이유를 적어 본다.
- [ ] 공용 공간에서 아무나 랜선을 꽂을 수 있는 곳을 본 경험이 있다면 적어 본다.
