# Kali Linux 환경 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ENV-001-MP |
| 목적 | 호스트 PC에 Kali Linux 실습 VM을 만들고 격리 네트워크에서 동작하게 한다 |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱). 호스트: VirtualBox를 설치할 수 있는 PC |
| 소요 시간 | 약 60분 (이미지 다운로드 시간 제외) |
| 확인 상태 | 미검증 (원본의 링크 모음을 절차로 정리한 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 설치 방법 외부 블로그 링크와 관련 문서 링크만 있는 목록 페이지였다. 설치 세부 단계는 원본에 없어 참조 문서로 대체했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kalilinuxsetupforvirtualbox.md](kalilinuxsetupforvirtualbox.md) | SEC-ENV-003-MP | Kali Linux 버추얼박스 설정 |
| [kali-ip-setup.md](kali-ip-setup.md) | SEC-ENV-002-MP | Kali Linux 고정 IP 설정 |
| [metasploitable3-win2k8.md](metasploitable3-win2k8.md) | SEC-ENV-004-MP | Metasploitable3 Windows 2008 |
| [wireshark.md](../security/defensive-security/defense/wireshark.md) | 미확인 | Wireshark |
| [ddos.md](../security/offensive-security/system/ddos.md) | 미확인 | DDoS |
| [Kali 설치 방법 (외부 블로그)](https://greensul.tistory.com/277) | - | 칼리 리눅스 설치 방법 |
| Kali Linux 공식 문서 | - | 이미지 다운로드, 기본 계정 안내 (공식 사이트에서 확인) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 호스트 PC | RAM 8GB 이상, 여유 디스크 40GB 이상 | 권장값. 확인 필요 |
| 2 | VirtualBox | 최신 안정 버전 | 공식 사이트에서만 받는다 |
| 3 | Kali Linux 이미지 | VirtualBox용 이미지 또는 설치 ISO | 공식 사이트에서만 받는다. 이 문서에 직접 링크·해시는 적지 않는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차로 만든 도구를 사용하는 것은 불법이다. 격리된 실습망에서만 수행한다.
{% endhint %}

{% hint style="danger" %}
WARNING: 취약 VM은 인터넷에 직접 노출하지 않는다. 호스트 전용 또는 격리된 NAT 네트워크에서만 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: Kali의 기본 계정과 비밀번호는 공식 문서에 적힌 값을 쓰고, 설치 후 바로 변경한다. 이 문서에는 적지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 호스트에 VirtualBox를 설치한다 | VirtualBox 관리자 화면이 열린다 |
| 2 | 공식 사이트에서 Kali 이미지를 받는다 | 파일이 호스트 디스크에 있다 |
| 3 | 호스트 디스크의 여유 공간을 확인한다 | 40GB 이상 |

## 5. 절차

**A. VM 생성**

1. (SUBTASK 5-A-01) VirtualBox에서 Kali 이미지로 새 VM을 만든다. 설치 방법은 참조의 외부 블로그 또는 Kali 공식 문서를 따른다. → 결과: VM 목록에 Kali VM이 나타난다.

**B. VirtualBox 설정**

1. (SUBTASK 5-B-01) SEC-ENV-003-MP를 수행한다. → 결과: USB와 네트워크 설정이 끝난다.

**C. IP 설정**

1. (SUBTASK 5-C-01) SEC-ENV-002-MP를 수행한다. → 결과: Kali VM이 실습망 대역의 고정 IP를 가진다.

**D. 스냅샷 생성**

1. (SUBTASK 5-D-01) VM을 종료한다.
2. (SUBTASK 5-D-02) `머신 > 스냅샷`에서 스냅샷을 만든다. 이름은 `<초기 상태>`로 한다. → 결과: 스냅샷 목록에 항목이 나타난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Kali VM을 부팅한다 | 로그인 화면이 나타난다 | 로그인 성공 |
| 2 | VM에서 `ip addr`를 실행한다 | 실습망 대역의 IP가 보인다 | 예: `192.168.56.x` |
| 3 | 다른 실습 VM으로 `ping <대상 IP>`를 보낸다 | 응답이 온다 | 손실 0% |

## 7. 복구

1. (SUBTASK 7-01) 설정이 꼬이면 VM을 종료하고 스냅샷 `<초기 상태>`로 복원한다. → 결과: 스냅샷 시점의 설정으로 돌아간다.
2. (SUBTASK 7-02) VM을 삭제하려면 VirtualBox에서 `제거 > 모든 파일 삭제`를 선택한다. 삭제한 VM은 복구되지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 빈 항목 "kali 한글"은 내용이 없어 삭제 |
