# 환경 구축 작업 목록 (Task)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-NOV-004-REF |
| 유형 | REF (명령·설정 예시) |
| 목적 | Ubuntu 서버 환경 구축 중 쓴 명령과 네트워크 설정 예시를 찾아본다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 작업 목록

| 번호 | 작업 | 상태 |
|---|---|---|
| 1 | ping 설치 | 아래 2절 |
| 2 | 고정 IP 설정(netplan) | 아래 3절 |
| 3 | 쿠버네티스 환경에서 웹 서비스와 ELK Stack, Jenkins 구동 | 원본에서 취소선으로 표시됨(취소 또는 완료 여부는 원본에 없음, 확인 필요) |

## 2. ping 설치

```bash
sudo apt install iputils-ping
```

## 3. 네트워크 설정 예시(netplan)

원본은 `/etc/netplan/` 아래 설정 파일을 편집하는 예시다. 원본의 설정 값은 다음과 같다. 사설 IP 대역(192.168.x.x)과 공개 DNS(8.8.8.8)만 사용했다.

```yaml
dhcp: no
addresses:
  - 192.168.1.100-105/16
gateway4: 192.168.0.1
nameservers:
  addresses: [8.8.8.8]
```

{% hint style="info" %}
NOTE: 원본 설정에는 정정할 부분이 세 곳 있다. (1) IPv4의 DHCP 키는 `dhcp: no`가 아니라 `dhcp4: no`다. (2) `192.168.1.100-105/16`은 올바른 CIDR 표기가 아니다. 주소는 `192.168.1.100/16`처럼 하나씩 적는다. (3) `gateway4`는 폐기 예정이며 `routes`의 `to: default` 항목으로 바꾼다. 아래는 이를 반영한 예시이며 미검증이다.
{% endhint %}

```yaml
network:
  version: 2
  ethernets:
    <인터페이스 이름>:
      dhcp4: no
      addresses:
        - 192.168.1.100/16
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8]
```

설정을 적용하는 명령은 `sudo netplan apply`다. 원본에 적용 명령은 없다.

## 4. 파일·명령 요약

| 대상 | 내용 |
|---|---|
| `iputils-ping` | `ping` 명령을 제공하는 패키지 |
| `/etc/netplan/` | Ubuntu의 네트워크 설정 디렉터리 |
| `sudo netplan apply` | 설정을 적용한다 |
