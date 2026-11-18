# 실습. 표준 ACL로 인사팀 PC 막기

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-008-MP |
| 목적 | 라우터 R1에 표준 ACL을 만들어 인사팀 PC만 서버망에서 막고, 암묵적 deny any를 실패로 확인한 뒤 `permit any`로 고친다 |
| 적용 대상 | Cisco Packet Tracer, Cisco 2911 라우터 1대, 스위치 2960 2대, 서버 1대, PC 2대 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N2-11-007-DO | 4. ACL 표준 |
| [lesson-5-lab-extended-acl.md](lesson-5-lab-extended-acl.md) | LEC-N2-11-010-MP | 실습. 확장 ACL (이 구성을 이어서 쓴다) |
| [commands.md](commands.md) | LEC-N2-11-018-REF | 0. 11일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 수업 버전 | 새 `.pkt` 파일 |
| 2 | R1 | 라우터(2911 등) | `g0/0` `192.168.10.254`, `g0/1` `192.168.20.254` |
| 3 | SW1, SW2 | 스위치 2960 | |
| 4 | Server0 | 서버 | `192.168.10.100`, GW `192.168.10.254` |
| 5 | PC_인사 | PC | `192.168.20.10`, GW `192.168.20.254` |
| 6 | PC_개발 | PC | `192.168.20.11`, GW `192.168.20.254` |

```
[PC_인사 .20.10]──┐                            ┌── Server0 192.168.10.100
                  ├──[SW2]──[R1]──[SW1]────────┤
[PC_개발 .20.11]──┘         g0/1    g0/0
```

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `deny`만 쓰고 `permit any`를 빼면 두 PC가 모두 막힌다. 4단계에서 이것을 일부러 만들어 확인한다. 의도하지 않았다면 `permit any`를 추가한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `no access-list 10`은 10번 전체를 지운다. 한 줄만 고치려 하지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 새 Packet Tracer 파일을 열고 위 그림대로 장비를 놓고 연결한다 | 링크 점이 초록이다 |
| 2 | 서버와 PC의 IP, 게이트웨이를 입력한다 | `Desktop` > `IP Configuration`에 값이 저장된다 |

## 5. 절차

### A. R1 인터페이스 설정

1. (5-A-01) R1의 `CLI` 탭에서 다음 명령을 입력한다.

```
enable
configure terminal
hostname R1
interface g0/0
 ip address 192.168.10.254 255.255.255.0
 no shutdown
exit
interface g0/1
 ip address 192.168.20.254 255.255.255.0
 no shutdown
exit
end
```

→ 결과: 두 인터페이스가 `up/up`이다. `show ip interface brief`로 확인한다.

### B. 먼저 되는 것을 확인

1. (5-B-01) `PC_인사`의 `Command Prompt`에서 `ping 192.168.10.100`을 입력한다. → 결과: 성공한다.
2. (5-B-02) `PC_개발`에서 `ping 192.168.10.100`을 입력한다. → 결과: 성공한다.

### C. 일부러 틀리기: permit 없이 deny만

1. (5-C-01) R1에서 다음 명령을 입력한다.

```
configure terminal
access-list 10 deny host 192.168.20.10
interface g0/0
 ip access-group 10 out
end
```

→ 결과: 오류 없이 끝난다.

2. (5-C-02) `PC_인사`에서 `ping 192.168.10.100`을 입력한다. → 결과: 실패한다.
3. (5-C-03) `PC_개발`에서 `ping 192.168.10.100`을 입력한다. → 결과: 실패한다. 개발팀도 막혔다. 암묵적 deny any가 작동한 것이다. 여기서 멈추고 이유를 설명한다.

### D. 고치기: permit any 추가

1. (5-D-01) R1에서 다음 명령을 입력한다.

```
configure terminal
access-list 10 permit any
end
show access-lists
```

→ 결과: 10번 ACL에 `deny host 192.168.20.10`과 `permit any` 두 줄이 보인다.

2. (5-D-02) `PC_인사`에서 `ping 192.168.10.100`을 입력한다. → 결과: 실패한다(의도대로).
3. (5-D-03) `PC_개발`에서 `ping 192.168.10.100`을 입력한다. → 결과: 성공한다.
4. (5-D-04) R1에서 `show access-lists`를 입력한다. → 결과: match 숫자가 올라가 있다.
5. (5-D-05) R1에서 `show ip interface g0/0`을 입력한다. → 결과: `Outgoing access list is 10`으로 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `PC_인사`에서 서버로 `ping` | 실패 | 응답 없음 |
| 2 | `PC_개발`에서 서버로 `ping` | 성공 | 응답 있음 |
| 3 | `show access-lists` | match 숫자가 0이 아니다 | 걸린 줄이 있다 |

## 7. 복구

1. (7-01) 다음 실습(확장 ACL)으로 이어 가려면 ACL을 인터페이스에서 뗀다.

```
configure terminal
interface g0/0
 no ip access-group 10 out
exit
```

→ 결과: 두 PC 모두 서버로 `ping`이 성공한다.

2. (7-02) ACL 자체를 지우려면 `no access-list 10`을 입력한다. → 결과: 10번 전체가 지워진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-4.md`의 실습 절과 `commands.md`의 STEP 4를 AMM 형식 MP로 분리 |
