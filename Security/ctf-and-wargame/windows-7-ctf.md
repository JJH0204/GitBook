# Windows 7 취약점 실습 (CTF)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-CTF-004-DO |
| 유형 | D&O (개념, 실습 환경 설계) |
| 목적 | 윈도우 권한 상승 CTF를 위한 취약 Windows 실습 환경의 목표와 참고 자료를 정리한다 |
| 확인 상태 | 미검증 (원본에 환경 구성 절차가 없어 목표와 링크만 정리했다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 목표와 링크 목록만 있고 구성 절차가 없다. 절차(MP)는 지어내지 않았다. 구성 절차가 필요하면 원본 작성자의 메모를 먼저 추가해야 한다.
{% endhint %}

{% hint style="danger" %}
WARNING: 이 환경은 의도적으로 취약하다. 자신이 소유한 격리 VM에서만 구성하고, 호스트 네트워크와 인터넷에서 분리한다. 허가받지 않은 시스템에 이 환경의 기법을 쓰는 것은 불법이다.
{% endhint %}

## 1. 목적

외부 장치가 Windows 시스템을 공격하는 시나리오를 재현하려고 취약한 Windows 장치를 만든다. 최종 목표는 `guest` 사용자에서 관리자 권한으로 권한 상승을 시도하는 CTF 환경이다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| 취약 Windows 장치 | 공격 대상. 오래된 버전의 Windows를 쓴다 |
| `guest` 계정 | 공격자의 시작 권한 |
| 관리자 권한 | 공격의 도달 목표 |
| 공격자 장치 | 외부 장치 역할 |

## 3. 동작 원리

1. 공격자가 외부 장치에서 취약한 Windows 장치에 접근한다.
2. `guest` 권한으로 시스템에 들어간다.
3. 윈도우 권한 상승 취약점으로 관리자 권한을 얻는다.

이 환경의 전체 시나리오는 [CTF 커스텀 시나리오 설계](ctf-writeups/ctf-custom.md)가 참조한다.

## 4. 참조

| 구분 | 링크 | 비고 |
|---|---|---|
| 블로그 | [newstroyblog](https://newstroyblog.tistory.com/54) | 참고 자료 |
| 점검 가이드 | [SSV](https://ssv.skill.or.kr/cloud-security/windows-pc-security-vulnerability) | Windows PC 보안 취약점 |
| 구버전 ISO | [Internet Archive 검색](https://archive.org/search?query=windows+10) | 출처와 라이선스를 확인한다 |
| 보안 공지 | [CVE-2019-0787](https://msrc.microsoft.com/update-guide/en-US/advisory/CVE-2019-0787) | 아래 NOTE 참조 |
| 블로그 | [hong0303](https://blog.naver.com/hong0303/221258116325) | 취약점 관련 |
| 블로그 | [easy7](https://easy7.tistory.com/491) | 추가 자료 |

{% hint style="info" %}
NOTE: CVE-2019-0787은 원본에 "취약점 관련 링크"로 적혀 있다. 이 CVE가 원격 데스크톱 클라이언트의 원격 코드 실행 취약점인지 권한 상승 취약점인지 확인하지 못했다. 시나리오와 맞는지 확인이 필요하다.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| 권한 상승(privilege escalation) | 낮은 권한 계정에서 높은 권한을 얻는 것 |
| CVE | 공개된 취약점에 붙는 식별 번호 |
| VM | 가상 머신 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오래된 Windows를 실습 환경으로 쓸 때 가장 주의할 점은 무엇인가?
- [ ] 이 환경을 방어 관점에서 어떻게 점검할 것인가?
