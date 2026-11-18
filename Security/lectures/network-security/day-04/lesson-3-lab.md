# 3-1. 예비 회선과 장애 시험 실습

> 상위: [4일차 정적 라우팅과 지사 연결](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-04-007-MP |
| 목적 | 두 라우터에 시리얼 모듈을 꽂아 예비 회선을 잇고, 플로팅 정적 경로를 넣은 뒤, 주 회선을 끊어 예비 경로로 넘어가는지 시험한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (2911 라우터 HQ-R1과 BR-R1, HWIC-2T 모듈). 2-1 실습을 마친 상태. 격리된 가상 실습망이다 |
| 소요 시간 | 약 36분 (모듈과 예비 회선 15분, 플로팅 경로 8분, 장애 시험 13분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-04-003-DO | 회선 이중화 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-04-006-MP | 선행 실습. 지사 장비 설치와 정적 경로 |
| [commands.md](commands.md) | LEC-SN-04-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-04-008-MP | 다음 실습. 지사 연결 기록 작성과 커밋 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 라우터 두 대 | 2911 (HQ-R1, BR-R1) | 2-1 실습에서 구성을 마친 장비 |
| 2 | 시리얼 모듈 | HWIC-2T 두 개 | 라우터마다 하나 |
| 3 | 케이블 | Serial DCE | HQ-R1을 먼저 눌러 연결한다 |
| 4 | PC | BR-PC1 | 멈추지 않는 ping에 쓴다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 모듈을 꽂기 전에 `copy running-config startup-config`로 저장한다. 저장하지 않고 전원을 끄면 RAM의 설정이 모두 사라진다. 구역 A의 첫 단계를 건너뛰지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 C에서 주 회선을 `shutdown`한 채로 실습을 끝내지 않는다. 확인한 뒤 반드시 `no shutdown`으로 살린다.
{% endhint %}

{% hint style="info" %}
NOTE: 패킷트레이서 PC에서 `ping -t`가 안 되면 `ping -n 100`으로 대신한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습의 기능 확인을 통과했다 | BR-PC1에서 `ping 192.168.10.98`이 성공한다 |
| 2 | `02_설계/IP_설계표.md`에 예비 회선 /30(192.168.99.4/30)을 적었다 | 파일에 해당 줄이 있다 |
| 3 | Always Show Port Labels를 켰다 | 포트 이름이 보인다 |

## 5. 절차

### A. 시리얼 모듈과 예비 회선

두 라우터 모두 같은 순서로 한다.

1. (5-A-01) `copy running-config startup-config`로 저장한다. → 결과: `[OK]`가 나온다.
2. (5-A-02) 라우터를 누르고 Physical 탭에서 전원 스위치를 끈다.
3. (5-A-03) 왼쪽 목록의 HWIC-2T를 빈 슬롯으로 끌어다 넣는다.
4. (5-A-04) 전원을 켜고 부팅을 기다린다. → 결과: 저장한 설정으로 부팅한다.
5. (5-A-05) Serial DCE 케이블을 고르고 HQ-R1을 먼저 눌러 Se0/0/0에, 이어서 BR-R1의 Se0/0/0에 잇는다. 먼저 누른 HQ-R1 쪽이 DCE가 된다.
6. (5-A-06) HQ-R1에서 예비 회선 포트를 설정한다.

```
configure terminal
interface se0/0/0
 description To BR-R1 backup
 ip address 192.168.99.5 255.255.255.252
 clock rate 64000
 no shutdown
 end
```

7. (5-A-07) BR-R1에서 예비 회선 포트를 설정한다.

```
configure terminal
interface se0/0/0
 description To HQ-R1 backup
 ip address 192.168.99.6 255.255.255.252
 no shutdown
 end
```

8. (5-A-08) `show controllers serial 0/0/0`으로 DCE 쪽을 확인한다. DCE로 나오는 쪽에만 `clock rate`를 넣는다. 이미 clock rate가 들어 있으면 그대로 둔다.
9. (5-A-09) HQ-R1에서 `ping 192.168.99.6`을 입력한다. → 결과: Reply가 오면 예비 회선이 이어진 것이다.

### B. 플로팅 정적 경로

1. (5-B-01) HQ-R1에 예비 경로를 넣는다: `ip route 192.168.20.0 255.255.255.224 192.168.99.6 250`
2. (5-B-02) BR-R1에 예비 경로를 넣는다: `ip route 0.0.0.0 0.0.0.0 192.168.99.5 250`
3. (5-B-03) 두 라우터에서 `show ip route static`을 입력한다. → 결과: 예비 경로는 아직 보이지 않는다. 주 경로(관리 거리 1)가 살아 있는 동안에는 표에 오르지 않는 것이 정상이다.
4. (5-B-04) `show running-config | include ip route`를 입력한다. → 결과: 250이 붙은 줄이 설정에 들어 있다.

### C. 장애 시험

1. (5-C-01) BR-PC1의 명령 프롬프트에서 멈추지 않는 ping을 건다: `ping -t 192.168.10.98` → 결과: Reply가 계속 온다.
2. (5-C-02) HQ-R1에서 주 회선을 끈다.

```
configure terminal
interface gi0/1
 shutdown
 end
show ip route static
```

→ 결과: `[250/0] via 192.168.99.6`이 보이고, BR-PC1의 ping이 몇 번 끊겼다가 돌아온다.

3. (5-C-03) 끊긴 동안 빠진 ping 개수를 센다. → 결과: 개수를 기록해 둔다.
4. (5-C-04) 주 회선을 살린다.

```
configure terminal
interface gi0/1
 no shutdown
 end
```

→ 결과: `show ip route static`에서 경로가 다시 [1/0]으로 돌아온다.

5. (5-C-05) BR-PC1의 ping을 Ctrl+C로 멈춘다.
6. (5-C-06) 세 장비(HQ-R1, BR-R1, BR-SW1)를 모두 저장한다: `copy running-config startup-config`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | HQ-R1에서 `ping 192.168.99.6` | Reply | 5개 모두 성공 |
| 2 | 주 회선이 살아 있을 때 `show ip route static` | 주 경로 [1/0]만 보임 | 예비 경로가 보이지 않음 |
| 3 | `shutdown` 직후 BR-PC1의 `ping -t` | 몇 개 빠진 뒤 다시 Reply | 통신이 자동으로 복구됨 |
| 4 | `shutdown` 뒤 HQ-R1의 `show ip route static` | `[250/0] via 192.168.99.6` | 해당 줄 존재 |
| 5 | `no shutdown` 뒤 경로표 | 주 경로 [1/0] 복귀 | 해당 줄 존재 |

## 7. 복구

1. (7-01) 주 회선이 꺼진 채라면 HQ-R1의 Gi0/1에서 `no shutdown`을 입력한다.
2. (7-02) 예비 경로를 지우려면 같은 줄 앞에 `no`를 붙인다.

```
no ip route 192.168.20.0 255.255.255.224 192.168.99.6 250
```

3. (7-03) 모듈을 잘못 꽂아 설정이 비었다면 2-1 실습(LEC-SN-04-006-MP)의 구역 A~C를 다시 입력한다. 이번에는 저장을 먼저 한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 5~7번을 AMM 형식 MP로 분리. 번호(5~7)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
