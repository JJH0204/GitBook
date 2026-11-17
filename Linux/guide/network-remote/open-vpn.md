# pfSense 기반 OpenVPN

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-NRM-005-MP |
| 목적 | OpenVPN 실습을 위한 pfSense 가상 머신 준비 단계를 정리한다 |
| 적용 대상 | VM 프로그램(가상화 소프트웨어)이 있는 PC, pfSense 설치 ISO |
| 소요 시간 | 미측정 |
| 확인 상태 | 미검증 (원본은 제목과 개요만 있고 설치·VPN 설정 절차가 없다. 이 문서는 절차를 보강하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 작성 중이다. 원본에 pfSense 설치 이하의 내용이 없어 OpenVPN 서버 설정 절차는 포함하지 않았다. 절차를 추가할 때 이 Task ID를 유지한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [VPN (Network 스페이스)](../../../Network/security/vpn.md) | | VPN 개념 |
| [pfSense (j-log 외부 문서)](https://krjaeh0.gitbook.io/j-log/security/security/tools/toolbox/pfsense) | | pfSense 도구 설명 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | pfSense 전용 ISO 파일 | pfSense 배포 사이트에서 받은 설치 이미지 | FreeBSD 기반 방화벽·라우터 배포판이다 |
| 2 | VM 프로그램 | VirtualBox, VMware 등 | 연습 환경으로 쓴다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 실습은 격리된 가상 네트워크에서 한다. 실제 운영망에 pfSense VM을 연결하면 기존 네트워크의 게이트웨이·DHCP와 충돌할 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | pfSense ISO를 내려받는다 | 파일이 PC에 있다 |
| 2 | VM 프로그램이 동작한다 | 새 VM을 만들 수 있다 |

## 5. 절차

### A. pfSense VM 설치

1. (5-A-01) VM 프로그램에서 새 VM을 만든다. 운영체제 유형은 FreeBSD로 선택한다.
2. (5-A-02) pfSense ISO를 VM의 광학 드라이브에 연결한다.
3. (5-A-03) VM을 시작하고 설치 화면의 안내에 따라 설치한다. → 결과: pfSense 콘솔 메뉴가 나온다.

{% hint style="info" %}
NOTE: 5-A-03 이후의 인터페이스 지정, OpenVPN 서버·인증서·클라이언트 설정은 원본에 없어 작성하지 않았다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | VM 재부팅 | pfSense 콘솔 메뉴가 나온다 | 메뉴 번호 목록이 보인다 |

## 7. 복구

1. (7-01) VM을 종료한다.
2. (7-02) VM을 삭제한다. 가상 디스크도 함께 지운다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 개요만 있던 원본을 MP 형식으로 재작성. 작성 중 상태를 NOTE로 표시했다 |
