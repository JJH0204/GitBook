# CTF 개요 (CTF)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-WUP-001-DO |
| 유형 | D&O (개념) |
| 목적 | CTF(Capture The Flag)의 정의, 특징, 입문 방법을 설명하고 이 그룹의 풀이 문서로 안내한다 |
| 확인 상태 | 미검증 (원본 페이지를 정리한 것이다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

CTF는 Capture The Flag의 약자다. 공격 대상 시스템에 숨겨진 파일(Flag)의 내용을 알아내 답안으로 제출하는 대회다. 충분한 시간을 쓰는 워게임과 달리 제한 시간 안에 많은 문제를 빠르게 풀며 다른 참가자와 경쟁한다.

## 2. 구성 요소

### 2.1 장점

| 항목 | 내용 |
|---|---|
| 취약점 탐색 | 대상 시스템의 취약점을 빠르게 찾아 공격하는 연습을 한다 |
| 문제 해결력 | 창의적으로 문제를 푸는 능력을 키운다 |
| 동기 부여 | 잘 푸는 참가자를 보며 자극을 받고 팀과 협력해 성과를 낸다 |

### 2.2 특징

| 항목 | 내용 |
|---|---|
| 규모 | 동아리·학교·기업 단위부터 전 세계 참가 대회까지 다양하다 |
| 참가 형태 | 개인전도 있으나 대부분 팀으로 참가한다. 팀원이 분야를 나눠 맡는다 |
| 정답 공유 | 대회 중에는 팀원 외의 사람과 풀이나 정답을 공유하지 않고 도움을 받지 않는다 |

## 3. 동작 원리

CTF 문제는 보통 취약점의 종류, 필요한 배경 지식, 소요 시간을 알려 주지 않는다. 이 문서 그룹의 풀이는 다음 순서로 진행한다.

1. 대상 시스템의 주소와 열린 서비스를 찾는다(정보 수집).
2. 서비스의 취약점을 찾아 초기 접근을 얻는다.
3. 권한 상승으로 관리자(root) 권한을 얻는다.
4. Flag 파일을 읽어 제출한다.

일반 해킹 과정은 [해킹과정](../../security/offensive-security/pentest/hackingprocess.md)을 본다.

{% hint style="info" %}
NOTE: CTF가 어려운 입문자는 워게임을 먼저 푼다. 소규모 CTF의 쉬운 문제에 도전하거나, 종료된 CTF의 풀이(라이트업)를 읽고 부족한 부분을 공부한다. 대회에서 풀지 못한 문제는 종료 후 출제자나 풀이자의 라이트업으로 복습한다.
{% endhint %}

## 4. 풀이 문서 목록

모든 풀이는 허가받은 격리 실습 환경(VulnHub 등의 의도적 취약 VM)에서 수행한 기록이다.

| Task ID | 문서 |
|---|---|
| SEC-WUP-003-TS | [CTF: Earth (1)](ctf_1.md) |
| SEC-WUP-004-TS | [CTF: Earth (2)](ctf_earth.md) |
| SEC-WUP-018-TS | [CTF: Cybersploit 1](ctf_cybersploit.md) |
| SEC-WUP-017-TS | [CTF: Cybersploit 2](ctf_cybersploit2.md) |
| SEC-WUP-013-TS | [CTF: TechSupport](ctf_techsupport.md) |
| SEC-WUP-012-TS | [CTF: Mercury](ctf_mercury.md) |
| SEC-WUP-016-TS | [CTF: WordPress](ctf_wordpress.md) |
| SEC-WUP-014-TS | [CTF: Venus](ctf_venus.md) |
| SEC-WUP-011-TS | [CTF: Pwned](ctf_pwned.md) |
| SEC-WUP-009-TS | [CTF: HF2019](ctf_hf2019.md) |
| SEC-WUP-015-TS | [CTF: Quaoar](ctf_quaoar.md) |
| SEC-WUP-010-TS | [CTF: Kioptrix Level 1.2](ctf_kioptrix_level_1.2.md) |
| SEC-WUP-005-TS | [CTF: Account 1](ctf_account_1.md) |
| SEC-WUP-006-TS | [CTF: Account 2](ctf_account_2.md) |
| SEC-WUP-007-TS | [CTF: Cookie01](ctf_cookie01.md) |
| SEC-WUP-008-TS | [CTF: Funbox 10](ctf_funbox_10.md) |
| (bWAPP 문서) | [comminjection](../../bwapp/comminjection.md) |
| SEC-WUP-002-DO | [CTF 커스텀 시나리오 설계](ctf-custom.md) |

## 5. 참조

| 참조 | 설명 |
|---|---|
| [CTFtime](https://ctftime.org/) | 전 세계 CTF 일정과 팀 레이팅을 보여 주는 사이트 |
| [CTF 운영 제안 문서](https://github.com/pwning/docs/blob/master/suggestions-for-running-a-ctf.markdown) | CTF 운영에 관한 자세한 설명 |
| [VulnHub](https://www.vulnhub.com/) | 의도적 취약 VM 모음 |
| [해킹과정](../../security/offensive-security/pentest/hackingprocess.md) | 해킹 단계 설명 |

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| CTF | Capture The Flag. 숨겨진 Flag를 찾아 제출하는 보안 대회 |
| Flag | 공격에 성공했음을 증명하는 문자열 또는 파일 |
| 워게임(Wargame) | 시간 제한 없이 문제를 푸는 연습형 보안 문제 |
| 라이트업(Writeup) | 문제 풀이 과정을 정리한 글 |
| 권한 상승(Privilege Escalation) | 낮은 권한 계정에서 관리자 권한을 얻는 일 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] CTF와 워게임의 차이를 내 말로 적는다.
- [ ] 팀으로 CTF에 참가한다면 내가 맡고 싶은 분야와 이유를 적는다.
