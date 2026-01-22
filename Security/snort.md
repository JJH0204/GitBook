# snort

* IDS: 침입 탐지 시스템 구축을 위해 사용되는 우분투 리눅스 기반 엔진
* 관련자료: https://velog.io/@2jinu/Snort-%EC%84%A4%EC%B9%98-0nl990xy

{% stepper %}
{% step %}
### 준비: 기본 패키지 설치

원활한 작업을 위해 다음을 미리 설치하세요:

```
apt-get install -y iputils-ping vim wget unzip git
```
{% endstep %}

{% step %}
### 의존성 파일 설치

다음 의존성들을 설치합니다:

{% code title="의존성 설치 (예시 1)" %}
```bash
apt install build-essential libpcap-dev libpcre3-dev libnet1-dev zlib1g-dev luajit hwloc libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake cpputest libsqlite3-dev uuid-dev libcmocka-dev libnetfilter-queue-dev libmnl-dev autotools-dev libluajit-5.1-dev libunwind-dev libfl-dev -y
```
{% endcode %}

또는 아래 명령 예시를 사용하세요:

{% code title="의존성 설치 (예시 2)" %}
```bash
sudo apt update
sudo apt install -y \
  build-essential \
  libpcap-dev \
  libpcre3-dev \
  zlib1g-dev \
  libdumbnet-dev \
  bison \
  flex \
  liblzma-dev \
  openssl \
  libssl-dev \
  pkg-config \
  libhwloc-dev \
  cmake \
  libsqlite3-dev \
  uuid-dev \
  libnetfilter-queue-dev \
  libmnl-dev \
  libluajit-5.1-dev \
  libdaq-dev \
  autoconf \
  libtool
```
{% endcode %}
{% endstep %}

{% step %}
### libdaq 소스 설치 (Git)

깃을 활용해 libdaq를 설치합니다.

{% code title="libdaq 설치" %}
```bash
git clone https://github.com/snort3/libdaq.git
cd ./libdaq

./bootstrap && ./configure
make && make install
```
{% endcode %}

이미지:&#x20;
{% endstep %}

{% step %}
### gperftools 설치

gperftools 소스를 다운로드하고 설치합니다.

{% code title="gperftools 설치" %}
```bash
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.13/gperftools-2.13.tar.gz
tar zxf ./gperftools-2.13.tar.gz
cd ./gperftools-2.13
./configure
make
make install
```
{% endcode %}

이미지:&#x20;
{% endstep %}

{% step %}
### Snort 소스 설치 및 컴파일

Snort 소스를 받아 빌드/설치합니다.

{% code title="snort 설치" %}
```bash
cd
wget https://github.com/snort3/snort3/archive/refs/heads/master.zip
unzip master.zip
cd snort3-master/
./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
cd ./build
make
make install

snort -V
snort -c /usr/local/etc/snort/snort.lua
```
{% endcode %}

한 줄로 실행하려면:

```bash
cd && wget https://github.com/snort3/snort3/archive/refs/heads/master.zip && unzip master.zip && cd ./snort3-master/ && ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc && cd ./build && make && make install
```
{% endstep %}

{% step %}
### 시스템 서비스: NIC 설정 (promiscuous, GRO/LRO 비활성화)

systemd 서비스 파일을 생성하여 부팅 시 NIC를 promiscuous 모드로 설정하고 GRO/LRO를 비활성화합니다.

{% code title="/etc/systemd/system/snort3-nic.service" %}
```ini
[Unit]
Description=Set Snort 3 NIC in promiscuous mode and Disable GRO, LRO on boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ip link set dev enp0s3 promisc on
ExecStart=/usr/sbin/ethtool -K enp0s3 gro off lro off
TimeoutStartSec=0
RemainAfterExit=yes

[Install]
WantedBy=default.target
```
{% endcode %}

적용 명령:

```bash
systemctl daemon-reload
systemctl start snort3-nic
systemctl enable snort3-nic
```
{% endstep %}

{% step %}
### 패킷 탐지 활성화 및 네트워크 수신 설정 확인

패킷 탐지 활성화:

```bash
ip link set dev enp0s3 promisc on
```

네트워크 수신 관련 확인/설정:

```bash
ethtool -k enp0s3 | grep receive -offload
ethtool -K enp0s3 gro off lro off
```
{% endstep %}

{% step %}
### Snort 커뮤니티 룰 설치

룰 저장경로 생성 후 커뮤니티 룰을 설치합니다.

{% code title="커뮤니티 룰 설치" %}
```bash
mkdir /usr/local/etc/snort/rules
wget -qO- https://www.snort.org/downloads/community/snort3-community-rules.tar.gz | tar xz -C /usr/local/etc/snort/rules/
```
{% endcode %}

snort.lua에 변수 및 룰 포함 예:

```lua
-- /usr/local/etc/snort/snort.lua 예시 (일부)
24 HOME_NET = '192.168.0.0/16'
...
28 EXTERNAL_NET = '!$HOME_NET'

192     variables = default_variables,
193     rules = [[
194       include /usr/local/etc/snort/rules/snort3-community-rules/snort3-community.rules
195     ]]
```

룰 확인:

```bash
cd /usr/local/etc/snort/rules/snort3-community-rules/
more snort3-community.rules
```
{% endstep %}

{% step %}
### 커스텀 룰 작성 및 OpenAppID 설정

local.rules 작성 예:

```bash
cd /usr/local/etc/snort/rules
vi local.rules

# 예시 룰 내용
alert icmp any any -> $HOME_NET any (msg:"icmp msg";sid:1000001;rev:1;)
```

snort.lua에서 local.rules 포함:

```lua
192     rules = [[
193       include /usr/local/etc/snort/rules/local.rules
194       include /usr/local/etc/snort/rules/snort3-community-rules/snort3-community.rules
195     ]]
```

OpenAppID 설치 및 snort.lua 설정:

```bash
wget https://www.snort.org/downloads/openappid/33380 -O OpenAppId-33380.tgz
tar -xzvf OpenAppId-33380.tgz
cp -R odp /usr/local/lib/
vi /usr/local/etc/snort/snort.lua
```
{% endstep %}

{% step %}
### 시스템 및 탐지 실행 확인

설정 파일 검사:

```bash
snort -c /usr/local/etc/snort/snort.lua
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules
```

탐지 실행 예:

```bash
snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules -i enp0s3 -A alert_fast -s 65535 -k none
```
{% endstep %}
{% endstepper %}

참고: Snort Rule 관련 문서는 별도 페이지를 참조하세요: [Snort Rule](/broken/pages/b467014e975ccc5f1df1ca09e29b630ed88274a8)
