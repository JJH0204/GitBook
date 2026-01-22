# Suricata

Related sites:

* https://oisf.net/
* https://suricata.io/download/

## Install on Ubuntu Linux

Reference: https://daeunnniii.tistory.com/107

### 환경 구성

{% stepper %}
{% step %}
### 1) 필수 패키지 설치

네트워크 분석 및 빌드에 필요한 패키지 설치:

```bash
apt -y install libpcre2-dev libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libyaml-0-2 libyaml-dev libcap-ng-dev libcap-ng0 make libmagic-dev libjansson-dev libjansson4 pkg-config libnspr4-dev libnss3-dev liblz4-dev rustc cargo python3-pip
```
{% endstep %}

{% step %}
### 2) Netfilter 패키지 설치

네트워크 패킷 필터링을 위해 필요한 패키지:

```bash
apt install -y libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0
```
{% endstep %}

{% step %}
### 3) Suricata 소스 다운로드 및 압축 해제

```bash
wget https://www.openinfosecfoundation.org/download/suricata-7.0.6.tar.gz
tar xzf suricata-7.0.6.tar.gz
```
{% endstep %}

{% step %}
### 4) Suricata 환경 설정 (configure)

```bash
cd ./suricata-7.0.6 && ./configure --enable-efqueue --prefix=/usr --sysconfdir=/etc --localstatedir=/var
```
{% endstep %}

{% step %}
### 5) 컴파일 및 설치

```bash
make && make install-full
```

설치 결과 창 예시:<br>
{% endstep %}

{% step %}
### 6) 설치 확인

버전 확인:

```bash
suricata -V
```

인터페이스 이름 확인:

```bash
ip --brief add
```

예시 결과:

> lo UNKNOWN 127.0.0.1/8 ::1/128\
> enp0s3 UP 192.168.1.118/16 fe80::a00:27ff:fe41:6cb2/64
{% endstep %}

{% step %}
### 7) 설정 파일 편집

```bash
vi /etc/suricata/suricata.yaml
```

주요 수정 예:

* HOME\_NET: "\[192.168.0.0/16]" (사설 IP 대역)
* default-log-dir: /var/log/suricata/
* community-id: true
* interface: enp0s3 (패킷 탐지할 인터페이스로 변경)
* promisc: true
* interface(캡쳐 설정): enp0s3
{% endstep %}

{% step %}
### 8) 설정 파일 문법 검사

```bash
suricata -T -c /etc/suricata/suricata.yaml -v
```

예시 출력:

```
Notice: suricata: This is Suricata version 7.0.6 RELEASE running in SYSTEM mode
Info: cpu: CPUs/cores online: 2
Info: suricata: Running suricata under test mode
Info: suricata: Setting engine mode to IDS mode by default
...
Notice: suricata: Configuration provided was successfully loaded. Exiting.
```
{% endstep %}

{% step %}
### 9) Suricata 실행 (테스트)

테스트 실행 (Ctrl + C로 종료):

```bash
suricata -c /etc/suricata/suricata.yaml -i enp0s3
```
{% endstep %}

{% step %}
### 10) systemd 서비스 추가

서비스 파일 생성:

```bash
vi /etc/systemd/system/suricata.service
```

파일 내용 예:

```
[Unit]
Description=Suricata IDS/IPS
After=network.target

[Service]
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -i enp0s3

[Install]
WantedBy=default.target
```

새로운 서비스를 추가하려면 이 방법으로 설정합니다.
{% endstep %}

{% step %}
### 11) 서비스 실행

```bash
systemctl daemon-reload && systemctl enable suricata && systemctl start suricata
```

정상 실행되지 않으면 위 설정을 다시 확인하십시오.
{% endstep %}

{% step %}
### 12) 탐지 테스트

테스트 사이트 접속:

```bash
curl https://testmynids.org/uid/index.html
```

같은 내용이 출력되면 정상입니다.<br>
{% endstep %}

{% step %}
### 13) 로그 확인

fast.log 확인:

```bash
cat /var/log/suricata/fast.log
```

(문서 작성자는 출력이 안되었다고 함) 로그 파일 설명 이미지:<br>
{% endstep %}

{% step %}
### 14) JSON 툴 설치 및 사용

jq 설치:

```bash
apt install -y jq
```

예: 특정 signature\_id 필터링

```bash
jq 'select(.alert .signature_id==2100498)' /var/log/suricata/eve.json
```

Note: jp(=jq) 사용법: '명령어(.요소 .요소==찾는 값)' json 파일 경로
{% endstep %}

{% step %}
### 15) 룰 작성 및 적용

로컬 룰 디렉토리 생성 및 파일 작성:

```bash
cd /etc/suricata && mkdir ./rules && vi ./rules/local.rules
```

예: local.rules에 작성 (Snort Rule 방식과 동일)

```
alert icmp any any -> $HOME_NET any (msg:"icmp packit";sid:100001;rev:1;)
```

suricata.yaml에 룰 추가 (예시 위치):

```yaml
# 파일 편집에서 다음 줄을 추가
- /etc/suricata/rules/local.rules
```

룰 적용 검사:

```bash
suricata -T -c /etc/suricata/suricata.yaml -v
```

패킷을 발생시킨 뒤 fast.log 확인:

```bash
cat /var/log/suricata/fast.log
```

실시간 보기:

```bash
tail -fv /var/log/suricata/fast.log
tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'
```
{% endstep %}

{% step %}
### 16) Rules 업데이트

Vendor 갱신 및 외부 룰 소스 관리 예시:

```bash
# Vendor 갱신
suricata-update update-sources

# 외부 업체에서 제공하는 rules list
suricata-update list-sources

suricata-update enable-source tgreen/hunting
suricata-update -o /etc/suricata/rules

systemctl restart suricata
```
{% endstep %}
{% endstepper %}

***

{% hint style="info" %}
suricata 설치 시 주요 정보:

* 실행 옵션: -c \[suricata 설정 파일 경로] -i \[적용할 인터페이스]
* 룰을 포함해 관리 시스템을 업데이트 하기 위해 suricata-update 등 명령어를 사용합니다.
{% endhint %}
