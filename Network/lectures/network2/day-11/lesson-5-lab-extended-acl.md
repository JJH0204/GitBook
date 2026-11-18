# 실습. 확장 ACL로 웹은 모두에게, SSH는 개발팀만

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-010-MP |
| 목적 | 표준 ACL 실습의 구성에 확장 ACL을 적용해 같은 PC에서 포트에 따라 허용과 거부가 갈리는 것을 확인한다 |
| 적용 대상 | Cisco Packet Tracer. LEC-N2-11-008-MP의 구성(R1, 스위치 2대, Server0, PC_인사, PC_개발) |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N2-11-009-DO | 5. ACL 확장 |
| [lesson-4-lab-standard-acl.md](lesson-4-lab-standard-acl.md) | LEC-N2-11-008-MP | 실습. 표준 ACL (이 구성을 그대로 쓴다) |
| [commands.md](commands.md) | LEC-N2-11-018-REF | 0. 11일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 수업 버전 | LEC-N2-11-008-MP의 파일을 그대로 쓴다 |
| 2 | Server0 | 서비스 `HTTP` On, `SSH` 또는 `Telnet` On | SSH를 쓰면 계정 하나를 만들어 둔다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: PT 버전에 따라 PC의 `ssh` 클라이언트가 없을 수 있다. 없으면 Telnet(23)으로 바꿔 같은 실습을 한다(`eq 22`를 `eq 23`으로). 수업 전 리허설에서 반드시 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 규칙 순서를 바꾸지 않는다. `permit ip any any`는 항상 마지막 줄이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | LEC-N2-11-008-MP의 구성이 있다 | 두 PC에서 서버로 `ping`이 성공한다 |
| 2 | 앞 실습의 표준 ACL이 떼어져 있다(5-B) | `show ip interface g0/0`에 ACL 표시가 없다 |

## 5. 절차

### A. Server0 서비스 켜기

1. (5-A-01) `Server0`의 `Services` 탭에서 `HTTP`를 `On`으로 한다. → 결과: 웹 서비스가 켜진다.
2. (5-A-02) `SSH` 또는 `Telnet`을 `On`으로 하고 계정을 하나 만든다. → 결과: 로그인 계정이 생긴다.

### B. 앞 실습의 ACL 떼기

1. (5-B-01) R1에서 다음 명령을 입력한다.

```
configure terminal
interface g0/0
 no ip access-group 10 out
exit
```

→ 결과: 표준 ACL 10이 인터페이스에서 떨어진다.

### C. 확장 ACL 적용: 웹은 모두, SSH는 개발팀만

1. (5-C-01) R1에서 다음 명령을 입력한다.

```
access-list 110 permit tcp host 192.168.20.11 host 192.168.10.100 eq 22
access-list 110 deny   tcp any                host 192.168.10.100 eq 22
access-list 110 permit ip  any any
interface g0/1
 ip access-group 110 in
end
```

→ 결과: 오류 없이 끝난다. `show access-lists`에 110번 세 줄이 보인다.

### D. 검증: 같은 PC, 포트에 따라 갈린다

1. (5-D-01) `PC_개발`의 `Web Browser`에서 `http://192.168.10.100`을 연다. → 결과: 열린다.
2. (5-D-02) `PC_개발`의 `Command Prompt`에서 `ssh -l <계정> 192.168.10.100`을 입력한다. → 결과: 로그인 프롬프트가 뜬다.
3. (5-D-03) `PC_인사`의 `Web Browser`에서 `http://192.168.10.100`을 연다. → 결과: 열린다(막히지 않는다).
4. (5-D-04) `PC_인사`에서 `ssh -l <계정> 192.168.10.100`을 입력한다. → 결과: 연결에 실패한다. 이 포트만 막혔다.
5. (5-D-05) R1에서 `show access-lists`를 입력한다. → 결과: 어느 줄의 match가 올라갔는지 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | PC_개발 → 웹 | 열린다 | 페이지 표시 |
| 2 | PC_개발 → SSH | 연결된다 | 로그인 프롬프트 |
| 3 | PC_인사 → 웹 | 열린다 | 페이지 표시 |
| 4 | PC_인사 → SSH | 실패한다 | 연결 거부 또는 타임아웃 |

## 7. 복구

1. (7-01) ACL을 인터페이스에서 뗀다.

```
configure terminal
interface g0/1
 no ip access-group 110 in
exit
```

→ 결과: 두 PC 모두 SSH가 된다.

2. (7-02) ACL을 지우려면 `no access-list 110`을 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-5.md`의 실습 절과 `commands.md`의 STEP 5를 AMM 형식 MP로 분리 |
