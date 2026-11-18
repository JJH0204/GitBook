# Kali Linux 고정 IP 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ENV-002-MP |
| 목적 | Kali Linux VM의 네트워크 인터페이스에 고정 IP를 설정한다 |
| 적용 대상 | 허가받은 격리 실습 환경. Kali Linux VM, `/etc/network/interfaces`를 사용하는 구성 |
| 소요 시간 | 약 5분 |
| 확인 상태 | 미검증 (원본 설정 예시를 정리한 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 최신 Kali는 NetworkManager를 기본으로 쓰며 `/etc/network/interfaces`를 쓰지 않는 구성이 있다. 이 경우 `nmcli` 또는 네트워크 설정 화면을 쓴다. 이 환경에서 확인하지 않았다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kalilinuxsetupforvirtualbox.md](kalilinuxsetupforvirtualbox.md) | SEC-ENV-003-MP | Kali Linux 버추얼박스 설정 |
| [lanenvsetup.md](../../Network/fundamentals/basics/lanenvsetup.md) | 미확인 | IP 설정 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Kali Linux VM | 실습망(호스트 전용 또는 NAT 네트워크)에 연결됨 | |
| 2 | 관리자 권한 | `sudo` 가능한 계정 | |
| 3 | 실습망 정보 | 대역, 서브넷 마스크, 게이트웨이 | 예: `192.168.56.0/24` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: IP를 잘못 넣으면 VM 네트워크가 끊긴다. 수정 전에 설정 파일을 백업한다(5-A-01).
{% endhint %}

{% hint style="danger" %}
WARNING: 취약 VM이 있는 실습망은 인터넷에 직접 연결하지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 인터페이스 이름을 확인한다: `ip addr` | 예: `eth0`가 보인다 |
| 2 | 사용할 IP가 실습망에서 비어 있는지 확인한다 | 다른 VM과 겹치지 않는다 |

## 5. 절차

**A. 설정 파일 편집**

1. (SUBTASK 5-A-01) 설정 파일을 백업한다: `sudo cp /etc/network/interfaces /etc/network/interfaces.bak` → 결과: `.bak` 파일이 생긴다.
2. (SUBTASK 5-A-02) 편집기로 파일을 연다: `sudo vi /etc/network/interfaces` → 결과: 편집기가 열린다.
3. (SUBTASK 5-A-03) 아래 내용을 입력한다. 값은 실습망에 맞게 바꾼다. → 결과: 파일에 `static` 설정이 있다.

```
auto eth0
iface eth0 inet static
address <IP 주소>
netmask <서브넷 마스크>
gateway <게이트웨이 IP>
```

| 항목 | 설명 | 예 |
|---|---|---|
| `auto eth0` | 부팅 시 장치를 활성화한다 | |
| `iface eth0 inet static` | IPv4 고정 주소로 설정한다 | |
| `address` | 장치 IP | `192.168.56.101` |
| `netmask` | 서브넷 마스크 | `255.255.255.0` |
| `gateway` | 게이트웨이 IP. 호스트 전용 네트워크처럼 게이트웨이가 없으면 생략한다 | |

**B. 적용**

1. (SUBTASK 5-B-01) 네트워크 서비스를 재시작한다: `sudo systemctl restart networking` → 결과: 오류 없이 끝난다. 서비스 이름은 구성에 따라 다르다(확인 필요).

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ip addr show eth0` | 설정한 IP가 보인다 | `address`와 일치 |
| 2 | `ping -c 3 <게이트웨이 IP>` 또는 다른 실습 VM | 응답이 온다 | 손실 0% |

## 7. 복구

1. (SUBTASK 7-01) 백업을 되돌린다: `sudo cp /etc/network/interfaces.bak /etc/network/interfaces` → 결과: 원래 설정이 돌아온다.
2. (SUBTASK 7-02) 서비스를 재시작한다: `sudo systemctl restart networking`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 원본의 `geteway`를 `gateway`로, `address = IP` 형식을 설정 파일 문법(`address <IP>`)으로 정정. 백업·확인·복구 추가 |
