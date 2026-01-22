# HIDS

* 호스트에서 발생하는 침입 사례를 검증
* Snort와 같이 RULE을 활용해 패킷 검출
* https://www.ossec.net/download-ossec/

## 설치 (Ubuntu)

{% stepper %}
{% step %}
### 1) 라이브러리 설치

```bash
apt install -y build-essential make zlib1g-dev libpcre2-dev libevent-dev libssl-dev libz-dev libsqlite3-dev

wget -q -O - https://updates.atomicorp.com/installers/atomic | bash

apt update
```
{% endstep %}

{% step %}
### 2) 서버 설치

```bash
apt install -y ossec-hids-server
```
{% endstep %}

{% step %}
### 3) 환경설정 파일 수정

파일 편집:

```bash
vi /var/ossec/etc/ossec.conf
```

예시 (추가한 부분):

```
113   <remote>
114     <connection>secure</connection>
115     <allowed-ips>192.168.0.0/16</allowed-ips> #추가
116   </remote>
```
{% endstep %}

{% step %}
### 4) 관리자(관리 툴) 실행 및 agent 관리

관리 툴 위치로 이동:

```bash
cd /var/ossec/bin
manage_agents
```

관리자 메뉴 예시(추가 단계 포함):

* agent 추가 (A)

```
Choose your action: A,E,L,R or Q: a

- Adding a new agent (use '\q' to return to the main menu).
  Please provide the following:
   * A name for the new agent: win
   * The IP Address of the new agent: 192.168.1.8
   * An ID for the new agent[001]: 001
Agent information:
   ID:001
   Name:win
   IP Address:192.168.1.8

Confirm adding it?(y/n): y
Agent added with ID 001.
```

* 키 발급 (E)

```
Choose your action: A,E,L,R or Q: e

Available agents:
   ID: 001, Name: win, IP: 192.168.1.8
Provide the ID of the agent to extract the key (or '\q' to quit): 001

Agent key information for '001' is:
MDAxIHdpbiAxOTIuMTY4LjEuOCBlMjAwOGQyNDZkMGY4YjJkNGYyOTU0OWYzNDZjMWZiOTFmYWZiMGQ3MDM5MWI4MDA3YjQzY2FmNWJjZjkxNjNi

** Press ENTER to return to the main menu.
```

{% hint style="info" %}
키는 꼭 기억하고 있어야 합니다.
{% endhint %}
{% endstep %}

{% step %}
### 5) 서버 구동 및 방화벽 설정

서버 시작:

```bash
./ossec-control start
# ./ossec-control 만 입력하면 사용가능한 명령어 확인 가능
```

방화벽 포트 추가 (예: firewalld 사용 시):

```bash
firewall-cmd --permanent --add-port=1514/tcp
firewall-cmd --permanent --add-port=1514/udp
firewall-cmd --reload
```
{% endstep %}

{% step %}
### 6) 로그 및 메시지 확인

로그 트리 보기:

```bash
tree /var/ossec/logs
```

실시간 알림 확인:

```bash
tail -f /var/ossec/logs/alerts/alerts.log
```
{% endstep %}
{% endstepper %}

{% hint style="info" %}
rootkit: 관리자 권한을 빼앗기 위해 사용하는 것
{% endhint %}

## 윈도우 Agent 설치

(이미지들)        &#x20;

## 리눅스 agent 설치

### Ubuntu Linux Install

```bash
apt install -y ossec-hids-agent

vi /var/ossec/etc/ossec.conf
# 파일 내에서 서버 IP 수정 예시:
# 5 192.168.1.113 <로 수정>
```

agent 시작 및 manage\_agents 실행:

```bash
/var/ossec/bin/ossec-control start

/var/ossec/bin/manage_agents 
i
# (키 입력)
MDAyIHVidW50dTEgMTkyLjE2OC4xLjExOCBmNjhlMzQxMzg3YTlhMDI1ZDZlNjhiNGY4YzZiZGEyZmM0NzIzYjBjMzUwNzYzYWI4ODkyNmRmN2UzYjk4Y2Y3
y
q
```

상태 확인:

```bash
/var/ossec/bin/ossec-control status
```

### Rocky Linux Install

```bash
dnf install -y gcc make zlib-devel pcre2-devel libevent-devel openssl-devel zlib-devel sqlite-devel
wget -q -O - https://updates.atomicorp.com/installers/atomic | sudo bash
dnf update
dnf install ossec-hids-agent -y
```

이후 구성 및 동작 방식은 Ubuntu와 동일합니다.

## rules 설정

정책(룰) 관리 디렉토리:

```bash
cd /var/ossec/rules
```

방화벽 포트 추가(중복 예시로 필요 시 실행):

```bash
firewall-cmd --permanent --add-port=1514/tcp
firewall-cmd --permanent --add-port=1514/udp
firewall-cmd --reload
```
