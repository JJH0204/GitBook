# 실습 1. RIPv2 — 라우터끼리 알아서 채우게 하기

> 상위: [5일차 · 라우팅 프로토콜](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-05-007-MP |
| 목적 | 라우터 3대에 RIPv2를 설정해 정적 경로 없이 `192.168.10.0/24`, `192.168.30.0/24` 사이의 경로가 자동으로 채워지는 것을 확인하고, 회선을 끊었다 이어 자동 수렴을 관찰한다 |
| 적용 대상 | Cisco Packet Tracer, Cisco IOS 라우터 3대(R1~R3), 스위치 2대, PC 2대 |
| 소요 시간 | 약 85분(그림 만들기 25분 포함) |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

```
[PC0]──[SW1]──[R1]══════[R2]══════[R3]──[SW2]──[PC2]
 .10.1         20.0/24       50.0/24        .30.1
 192.168.10.0/24                        192.168.30.0/24
```

| 장비 | G0/0 | G0/1 |
|---|---|---|
| R1 | 192.168.10.254 (PC0 쪽) | 192.168.20.1 |
| R2 | 192.168.50.1 | 192.168.20.2 |
| R3 | 192.168.30.254 (PC2 쪽) | 192.168.50.2 |

- PC0: IP `192.168.10.1`, 마스크 `255.255.255.0`, 게이트웨이 `192.168.10.254`
- PC2: IP `192.168.30.1`, 마스크 `255.255.255.0`, 게이트웨이 `192.168.30.254`

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N1-05-001-DO | 1. 라우팅 프로토콜 개요 |
| [lesson-2.md](lesson-2.md) | LEC-N1-05-002-DO | 2. RIP — 디스턴스 벡터 |
| [lesson-4.md](lesson-4.md) | LEC-N1-05-004-DO | 4. 라우팅 프로토콜 실습 |
| [commands.md](commands.md) | LEC-N1-05-006-REF | 0. 5일차 실습 명령어 |
| [lesson-4-troubleshooting.md](lesson-4-troubleshooting.md) | LEC-N1-05-011-TS | 5일차 실습 문제 해결 |
| [4일차 실습 명령어](../day-04/commands.md) | - | CLI 기본기 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 4일차와 같은 버전 | |
| 2 | 라우터 3대 | R1, R2, R3 | 인터페이스 `G0/0`, `G0/1` |
| 3 | 스위치 2대 | SW1, SW2 | |
| 4 | PC 2대 | PC0, PC2 | |
| 5 | 케이블 | 라우터끼리 크로스오버, 라우터↔스위치·PC↔스위치는 다이렉트 | |
| 6 | 새 `.pkt` 파일 | 앞 회차 파일을 고쳐 쓰지 않는다 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 앞 회차 파일을 열어 고쳐 쓰지 않는다. 새 파일에서 처음부터 만든다. 설정이 섞이면 원인을 찾기 어렵다.
{% endhint %}

{% hint style="warning" %}
CAUTION: RIP은 30초 주기로 정보를 주고받는다. 명령을 입력해도 경로가 즉시 생기지 않는다. 30초를 기다린 뒤 `show ip route`를 다시 입력한다. 경로가 없다고 설정을 지우지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 새 Packet Tracer 파일을 연다 | 빈 작업 영역이 보인다 |
| 2 | 구역 A로 그림을 만든다 | 링크 점이 모두 초록이다 |
| 3 | 구역 B~D로 인터페이스를 설정한다 | 세 라우터 모두 `show ip interface brief`에서 `up/up` 2개 |

## 5. 절차

### A. 그림 만들기 (마우스 조작)

1. (5-A-01) 라우터 3대, 스위치 2대, PC 2대를 꺼내 위 그림처럼 배치한다. → 결과: 장비가 작업 영역에 놓인다.
2. (5-A-02) 케이블을 연결한다. → 결과: 링크 점이 초록이 될 때까지 기다린다.
3. (5-A-03) `PC0` > `Desktop` > `IP Configuration`에 IP, 마스크, 게이트웨이를 입력한다. → 결과: 값이 저장된다.
4. (5-A-04) PC2도 같은 방법으로 입력한다. → 결과: 값이 저장된다. 여기까지 끝나면 이후는 CLI로 진행한다.

### B. R1 인터페이스 설정

1. (5-B-01) R1의 `CLI` 탭에서 다음 명령을 이어서 입력한다.

```
enable
configure terminal
no ip domain-lookup
hostname R1
interface g0/0
 ip address 192.168.10.254 255.255.255.0
 no shutdown
 exit
interface g0/1
 ip address 192.168.20.1 255.255.255.0
 no shutdown
end
show ip interface brief
```

→ 결과: 두 인터페이스가 `up/up`이다.

{% hint style="warning" %}
CAUTION: `no shutdown`을 빠뜨리면 `C` 경로가 생기지 않는다.
{% endhint %}

### C. R2 인터페이스 설정

1. (5-C-01) R2의 `CLI` 탭에서 다음 명령을 입력한다.

```
enable
configure terminal
no ip domain-lookup
hostname R2
interface g0/1
 ip address 192.168.20.2 255.255.255.0
 no shutdown
 exit
interface g0/0
 ip address 192.168.50.1 255.255.255.0
 no shutdown
end
show ip interface brief
```

→ 결과: 두 인터페이스가 `up/up`이다.

### D. R3 인터페이스 설정

1. (5-D-01) R3의 `CLI` 탭에서 다음 명령을 입력한다.

```
enable
configure terminal
no ip domain-lookup
hostname R3
interface g0/1
 ip address 192.168.50.2 255.255.255.0
 no shutdown
 exit
interface g0/0
 ip address 192.168.30.254 255.255.255.0
 no shutdown
end
show ip interface brief
show ip route
```

→ 결과: `up/up` 2개. 라우팅 테이블에 `C` 2개, `L` 2개만 있다. 남의 네트워크는 하나도 모른다.

### E. 먼저 실패 확인

1. (5-E-01) PC0의 `Desktop` > `Command Prompt`에서 `ping 192.168.10.254`를 입력한다. → 결과: 성공한다.
2. (5-E-02) `ping 192.168.30.1`을 입력한다. → 결과: 실패한다. 경로가 없기 때문이다. 메시지를 읽는다.

### F. R1·R2에만 RIP 켜기

이번에는 "어디로 가라"가 아니라 "내가 가진 네트워크는 이것들이다"만 알려 준다.

1. (5-F-01) R1의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
router rip
 version 2
 no auto-summary
 network 192.168.10.0
 network 192.168.20.0
end
show ip protocols
```

→ 결과: RIP이 돌고 있고 알린 `network`가 보인다.

{% hint style="danger" %}
WARNING: `network` 뒤에는 내가 가진(직접 연결된) 네트워크를 적는다. 4일차 `ip route`와 정반대다. 목적지를 적으면 무시된다.
{% endhint %}

2. (5-F-02) R2의 `CLI` 탭에서 다음 명령을 입력한다. 한쪽만 켜면 아무 일도 일어나지 않는다.

```
configure terminal
router rip
 version 2
 no auto-summary
 network 192.168.20.0
 network 192.168.50.0
end
show ip route
```

→ 결과: 30초 기다린 뒤 `R 192.168.10.0`이 보인다. 바로 보이지 않으면 30초 뒤 `show ip route`를 한 번 더 입력한다(`↑` 키).

3. (5-F-03) R1에서 `show ip route`와 `show ip route rip`을 입력한다. → 결과: `R 192.168.50.0/24 [120/1] via 192.168.20.2`가 보인다. 아직 30.0은 없다. R3이 아직 아무 말도 하지 않기 때문이다.

```
R    192.168.50.0/24 [120/1] via 192.168.20.2, 00:00:12, GigabitEthernet0/1
─┬─                   ─┬─ ─┬─      ─────┬─────  ────┬───
 RIP이 알려 줌          AD  홉 수     다음 홉      12초 전에 들었다
```

### G. R3에 RIP 켜기

1. (5-G-01) R3의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
router rip
 version 2
 no auto-summary
 network 192.168.30.0
 network 192.168.50.0
end
show ip route
```

→ 결과: 30초 기다린 뒤 `R 192.168.10.0`, `R 192.168.20.0`이 보인다.

2. (5-G-02) R1로 이동한다. R1에는 아무것도 입력하지 않고 `show ip route`만 입력한다. → 결과: 30~60초 뒤 `R 192.168.30.0/24 [120/2] via 192.168.20.2`가 새로 생긴다. 홉이 2다.

```
R    192.168.50.0/24 [120/1] via 192.168.20.2   ← 아까 있던 것
R    192.168.30.0/24 [120/2] via 192.168.20.2   ← 새로 생겼다
```

3. (5-G-03) PC0에서 `ping 192.168.30.1`을 입력한다. → 결과: 성공한다.
4. (5-G-04) PC0에서 `tracert 192.168.30.1`을 입력한다. → 결과: 라우터 3대를 거치는 것이 보인다.
5. (5-G-05) 세 라우터에서 `copy running-config startup-config`를 입력한다. → 결과: 저장이 끝난다.
6. (5-G-06) 패킷트레이서 파일을 `Ctrl + S`로 저장한다. → 결과: 파일이 저장된다.

### H. 끊었다 잇기 (자동 수렴 관찰)

정적이었다면 사람이 지우고 사람이 다시 넣어야 한다. 동적은 어떻게 되는지 본다.

1. (5-H-01) R3의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
interface g0/0
 shutdown
end
show ip route
```

→ 결과: `C 192.168.30.0`이 사라진다.

2. (5-H-02) R1에서 `show ip route`를 입력한다. → 결과: 잠시 뒤 `R 192.168.30.0`이 사라진다. 아무도 지우라고 하지 않았다.
3. (5-H-03) PC0에서 `ping 192.168.30.1`을 입력한다. → 결과: 실패한다.
4. (5-H-04) R3의 `CLI` 탭에서 다음 명령을 입력한다.

```
configure terminal
interface g0/0
 no shutdown
end
```

→ 결과: 오류 없이 끝난다.

5. (5-H-05) R1에서 `show ip route`를 입력한다. → 결과: 최대 30초 안에 `R 192.168.30.0`이 다시 생긴다.
6. (5-H-06) PC0에서 `ping 192.168.30.1`을 입력한다. → 결과: 다시 성공한다.

오늘의 한 문장: 사람이 고친 것이 아니라 라우터들이 서로 알려서 고쳤다. RIP은 30초 주기라 반응이 굼뜨고 큰 망에서는 몇 분씩 걸리기도 한다. 그래서 OSPF가 나왔다. → [LEC-N1-05-008-MP](lesson-4-lab-ospf.md)

7. (5-H-07) 패킷트레이서 파일을 저장하고 닫는다. → 결과: 다음 실습은 새 파일에서 시작한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | R1에서 `show ip route` | `R` 경로 2개 | `50.0 [120/1]`, `30.0 [120/2]` |
| 2 | R3에서 `show ip route` | `R` 경로 2개 | `10.0`, `20.0` 경로가 `R`로 보인다 |
| 3 | PC0에서 `ping 192.168.30.1` | 응답이 온다 | 4개 모두 성공 |
| 4 | PC0에서 `tracert 192.168.30.1` | 경유 라우터가 보인다 | 라우터 3대 |
| 5 | R3 `g0/0` shutdown 후 R1 확인 | 30.0 경로가 사라졌다 | `R 192.168.30.0` 없음 |
| 6 | R3 `g0/0` no shutdown 후 R1 확인 | 30.0 경로가 다시 생긴다 | 30초 이내 `R 192.168.30.0` |

## 7. 복구

1. (7-01) 실습 설정을 지우려면 세 라우터에서 `configure terminal` → `no router rip` → `end`를 입력한다. → 결과: `show ip route`에서 `R` 경로가 사라진다.
2. (7-02) R3 `g0/0`이 `shutdown` 상태로 남아 있으면 `no shutdown`을 입력한다. → 결과: `C 192.168.30.0`이 다시 보인다.
3. (7-03) 파일 전체를 되돌리려면 저장하지 않고 닫은 뒤 다시 만든다. 새 파일에서 시작하는 방식이므로 앞 회차 파일에는 영향이 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 commands.md의 준비·실습 1과 lesson-4.md의 RIPv2 절을 별도 MP 문서로 분리하고 AMM 형식으로 정리했다 |
