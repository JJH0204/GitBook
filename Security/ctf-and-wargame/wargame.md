# 워게임 개요 (Wargame)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-CTF-001-DO |
| 유형 | D&O (개념) |
| 목적 | 워게임이 무엇인지, 어떤 분야로 나뉘는지, 어떤 환경과 플랫폼으로 시작하는지 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 플랫폼 현황을 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본의 "드림핵 워게임의 준비물" 절은 준비물과 외부 플랫폼 목록이 섞여 있었다. 이 문서는 준비물(2.2절)과 플랫폼(2.3절)으로 나눴다. 분야별 설명(2.1절)과 플랫폼별 특징 설명은 원본에 없던 보충이며 미검증이다.
{% endhint %}

## 1. 목적

워게임(Wargame)은 제작자가 의도적으로 취약점을 넣어 둔 모의 해킹 환경이다. 참가자는 취약점을 찾고, 원리를 이해하고, 해결 방법을 찾아 정답 문자열(플래그, flag)을 얻는다. 처음에는 어렵지만 문제를 풀수록 익숙해지고, 개념과 도구 사용이 함께 늘어난다.

{% hint style="danger" %}
WARNING: 워게임 문제는 운영자가 허용한 대상에만 시도한다. 허가받지 않은 시스템에 같은 기법을 쓰는 것은 불법이다.
{% endhint %}

## 2. 구성 요소

### 2.1 워게임 분야

| 분야 | 설명 |
|---|---|
| Pwnable | 실행 파일이나 서비스의 메모리 취약점을 분석해 제어 흐름을 바꾼다 |
| Web | 웹 애플리케이션의 취약점을 찾는다 |
| Reversing | 실행 파일을 분석해 동작을 알아낸다 |
| Crypto | 암호 방식의 약점을 이용해 평문을 복원한다 |
| Forensics | 파일, 메모리, 네트워크 기록에서 단서를 찾는다 |
| Misc | 위 분야에 속하지 않는 문제 |
| Network | 네트워크 프로토콜과 트래픽을 분석한다 |
| Kernel, Browser, Blockchain | 해당 영역의 고난도 분석 문제 |

### 2.2 준비물

| 준비물 | 용도 |
|---|---|
| Ubuntu Linux | 풀이 환경 |
| nc (netcat) | 문제 서버에 접속한다 |

### 2.3 워게임 플랫폼

| 플랫폼 | 문서 | 비고 |
|---|---|---|
| OverTheWire | [Bandit 워게임](badit.md) (SEC-CTF-002-DO) | 리눅스 명령어 기초 |
| SuNiNaTaS | [SuNiNaTaS 워게임 풀이](suninatas.md) (SEC-CTF-003-TS) | 웹 문제 |
| Webhacking.kr | [Webhacking.kr 워게임](webhacking.kr.md) (SEC-CTF-005-DO) | 웹 문제 |
| 드림핵 (Dreamhack) | 없음 | 원본 절 제목에만 언급됐다 |
| Hack The Box | [hackthebox](https://www.hackthebox.com/) | |
| TryHackMe | [tryhackme](https://tryhackme.com/) | |
| Root Me | [root-me](https://www.root-me.org/?lang=en) | |
| pwnable.kr | [pwnable.kr](https://pwnable.kr/play.php) | |
| OverTheWire | [overthewire](https://overthewire.org/wargames/) | 전체 목록 |

## 3. 동작 원리

1. 플랫폼이 문제 서버나 파일을 제공한다.
2. 참가자가 문제의 성격(분야)을 파악한다.
3. 취약점을 찾고 공략 방법을 세운다.
4. 플래그를 얻어 플랫폼에 제출한다.
5. 풀이를 정리한다. 정리 방법은 [라이트업 작성 가이드](write-up.md)(SEC-CTF-008-DO)를 따른다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 플래그(flag) | 문제를 풀었음을 증명하는 문자열 |
| 라이트업(write-up) | 풀이 과정을 정리한 글 |
| CTF (Capture The Flag) | 제한 시간 안에 문제를 풀어 점수를 겨루는 대회 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 워게임을 처음 풀 때 막혔던 지점과 넘어간 방법은 무엇인가?
- [ ] 분야 중 가장 먼저 배우고 싶은 것과 그 이유는 무엇인가?
