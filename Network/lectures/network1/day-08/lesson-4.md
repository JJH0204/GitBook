# 4. 포트 보안 — 아무나 꽂지 못하게

> 상위: [8일차 · 네트워크 장비에서의 서버 설정](README.md)

## 🎯 학습 목표

- 스위치 포트가 **기본적으로 무방비**라는 것을 이해한다
- **포트 보안(Port Security)** 이 MAC 주소로 접속을 제한하는 원리를 안다
- **sticky** 학습과 위반 시 동작(**shutdown / restrict / protect**)을 구분한다
- **err-disabled** 된 포트를 복구한다

## 🌉 다리 놓기: "SSH 로 현관은 잠갔다. 그런데 벽에 난 콘센트는?"

[1_원격접속_Telnet과SSH](lesson-1.md)에서 **장비에 들어오는 문**(VTY)을 SSH 로 잠갔다.
그런데 사무실 벽의 **랜 포트**는? 누군가 자기 노트북을 들고 와서 **빈자리 랜선에 꽂으면**…

- 스위치는 **아무 MAC 이나 배운다** (4일차 Learning) → [1_스위치_동작원리](../day-04/lesson-1.md)
- 그 포트가 VLAN 10 이면 → 그 노트북은 **곧바로 영업팀 동네 주민**이 된다 (7일차)
- DHCP 가 켜져 있으니 → **IP 까지 친절하게** 받아간다 (방금 [2_DHCP와_DNS](lesson-2.md)에서 만든 그 서비스)

> 🗣 **"오늘 우리가 만든 편리함(DHCP)이 침입자에게도 편리합니다."**

## 📖 포트 보안 — 이 포트에는 이 MAC 만

> **포트마다 "허락된 MAC 주소" 목록을 두고, 모르는 MAC 이 들어오면 막는다.**

```
SW1 Fa0/1  ─  허락된 MAC: 0001.4295.1A01 (PC0) 딱 하나
                │
    PC0 꽂음 → ✅ 통과
    노트북 꽂음 → 🚨 모르는 MAC → 포트 차단
```

> 💡 **비유: 사원증 출입문.** 등록된 사원증(MAC)만 문이 열린다.
> 모르는 카드를 대면 **경보가 울리고 문이 잠긴다** — 관리자가 와서 풀어줘야 다시 열린다.

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
|----|-----|
| ① `mode access` | 포트 보안은 **액세스 포트에서만** 된다. 모드가 `dynamic` 이면 `Command rejected` |
| ③ `maximum 1` | 이 포트엔 **기기 한 대만** |
| ④ `sticky` | MAC 을 손으로 치지 않아도 **처음 온 MAC 을 "끈끈이"처럼 붙잡아** 설정에 적는다 |
| ⑤ `violation` | 모르는 MAC 이 오면 어떻게 할지 (아래) |

### sticky — 손으로 MAC 을 칠 필요가 없다

- 방법 1: `switchport port-security mac-address 0001.4295.1A01` — **직접 입력** (오타 · 수백 대면 지옥)
- 방법 2: **sticky** — PC 가 **처음 한 번 통신하면** 그 MAC 을 배워서 running-config 에 **자동으로 적는다**

```
interface FastEthernet0/1
 switchport port-security mac-address sticky 0001.4295.1A01   ← 스위치가 스스로 적은 줄
```

> ⚠️ sticky 로 배운 MAC 도 **`copy running-config startup-config` 해야 재부팅 후 남는다.**

### 위반했을 때 — 세 가지 모드

| 모드 | 모르는 프레임 | 포트 | 기록(로그 · 카운터) | 비유 |
|------|---------------|------|:---:|------|
| **shutdown** (기본) | 버림 | **통째로 꺼짐** (err-disabled) | ✅ | 경보 + 출입문 봉쇄 |
| **restrict** | 버림 | 살아 있음 | ✅ | 경보만, 문은 그대로 |
| **protect** | 버림 | 살아 있음 | ❌ | 조용히 무시 |

- 기본값 **shutdown** 이 가장 확실하다 — 그 포트의 **정상 사용자도 같이 끊긴다**는 게 단점
- `restrict` 는 **정상 기기는 계속 쓰고, 침입 기록만** 남긴다 → 사무실에서 많이 쓴다

### err-disabled — 꺼진 포트 되살리기

```
SW1# show port-security interface fa0/1
Port Security              : Enabled
Port Status                : Secure-shutdown        ← 🚨 위반으로 꺼졌다
Violation Mode             : Shutdown
Maximum MAC Addresses      : 1
Total MAC Addresses        : 1
Sticky MAC Addresses       : 1
Last Source Address:Vlan   : 00D0.BA8E.2C11:10      ← 범인의 MAC
Security Violation Count   : 1
```

**복구 순서** — 범인을 먼저 치운다

1. 침입 기기의 선을 **뽑는다** (안 뽑고 켜면 **즉시 다시 꺼진다**)
2. 포트를 **껐다 켠다**

```bash
interface fa0/1
 shutdown
 no shutdown
```

> 💡 PT 화면에서는 위반한 포트의 링크가 **빨간색**으로 바뀐다. `show interfaces fa0/1` 에는 `down (err-disabled)`.

## 📖 이것도 한 줄 상식 — 안 쓰는 포트는 끄고 격리한다

```bash
interface range fa0/5 - 22
 switchport mode access
 switchport access vlan 999        # 아무 데도 연결 안 된 "주차장 VLAN"
 shutdown                          # 그리고 꺼둔다
```

> 실무 보안 기본기: **안 쓰는 포트는 꺼두고, 쓰는 포트는 포트 보안.**
> (7일차의 **네이티브 VLAN 변경**, 오늘의 **SSH** 와 함께 "스위치 보안 3종 세트")

## 📖 한계 — MAC 은 위조할 수 있다

- 무선 보안에서 **"MAC 필터링은 보조 수단"** 이라고 하는 이유와 같다 → [5_무선랜과_IPv6](lesson-5.md)
- 누군가 PC0 의 MAC 을 알아내 **자기 노트북 MAC 을 똑같이 바꾸면** 통과한다
- 그래서 실무는 **802.1X**(사용자 계정으로 포트 인증) 까지 간다 — 이름만. 11일차 서버 보안과 연결 → [11일차 · 서버 보안](../../network2/day-11/README.md)

## 🧪 질문 / 실습

- 실습 STEP 6 → [0_실습_명령어_모음](commands.md) · 해설 [6_서버설정_실습](lesson-6.md)
- "포트 보안 명령이 `Command rejected` 로 거부된다" → 포트가 **액세스 모드가 아니다**
- "침입 노트북을 뽑지 않고 `no shutdown` 했다" → **바로 다시 꺼진다**
- "정상 PC 를 새것으로 바꿨더니 포트가 꺼졌다" → sticky 가 **옛 PC 의 MAC** 을 기억하고 있다
  → `no switchport port-security mac-address sticky <옛 MAC>` 또는 `clear port-security sticky interface fa0/1` 후 새로 학습

## 📝 강의 메모

- **"DHCP 가 침입자에게도 친절하다"** 로 연다 — 방금 만든 서비스가 위협이 되는 반전
- 비유는 **사원증 출입문** — shutdown(봉쇄) · restrict(경보만) · protect(조용히) 세 모드가 다 설명된다
- 실습은 **침입 → 빨간 불 → 범인 MAC 확인 → 복구** 4컷으로. `Last Source Address` 에서 **범인 MAC 을 찾는 장면**이 재미있다
- ⚠️ 복구할 때 **범인부터 뽑는다** — 이 순서를 빼먹으면 "왜 또 꺼져요?"
- MAC 위조 가능성은 꼭 말해준다 — **"완벽한 보안은 없다, 겹겹이 쌓는다"** 가 2단계 11일차 서버 보안의 복선
