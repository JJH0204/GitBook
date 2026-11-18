# Snort 설치 및 침입 탐지 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-005-MP |
| 목적 | Snort 3를 소스에서 빌드해 설치하고 커뮤니티 룰과 사용자 룰로 네트워크 침입을 탐지(IDS 모드)한다 |
| 적용 대상 | Ubuntu Linux 가상 머신(실습망), root 또는 sudo 권한, 인터넷 연결 |
| 소요 시간 | 약 60분 (빌드 시간 포함) |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·빌드·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 탐지 전용(IDS) 구성이다. 트래픽을 차단하는 인라인(IPS) 모드는 다루지 않는다. 룰 문법은 [Snort 룰 문법](snort-rule.md) (SEC-DEF-004-REF)을 따른다. 원본의 `master.zip` 다운로드는 항상 최신 개발 소스를 받으므로 시점에 따라 결과가 달라질 수 있다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [침입 탐지 시스템 (IDS)](ids.md) | SEC-DEF-001-DO | IDS 개념 |
| [Snort 룰 문법](snort-rule.md) | SEC-DEF-004-REF | 룰 작성 |
| [Suricata 설치 및 설정](suricata.md) | SEC-DEF-006-MP | 같은 룰 형식을 쓰는 다른 엔진 |
| 설치 참고 글 | - | https://velog.io/@2jinu/Snort-%EC%84%A4%EC%B9%98-0nl990xy |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 감시 서버 | Ubuntu Linux 가상 머신, 2코어·4GB 이상 권장 | 빌드에 메모리를 많이 쓴다 |
| 2 | 네트워크 인터페이스 | 감시할 NIC (예: `enp0s3`) | `<인터페이스 이름>`으로 표기한다 |
| 3 | 소스 | libdaq, gperftools 2.13, Snort 3, 커뮤니티 룰 | 모두 인터넷에서 내려받는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: NIC를 promiscuous 모드로 바꾸고 GRO/LRO를 끄면 해당 NIC의 처리 성능이 달라진다. 서비스 중인 운영 서버가 아닌 실습 환경에서 수행한다. 원격(SSH)으로 접속 중이라면 접속에 쓰는 NIC를 대상으로 하기 전에 콘솔 접근을 확보한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 인터페이스 이름을 확인한다: `ip --brief addr` | 감시할 NIC 이름이 보인다 |
| 2 | 인터넷 연결을 확인한다: `ping -c 3 <외부 호스트>` | 응답이 온다 |
| 3 | 디스크 여유를 확인한다: `df -h /` | 5GB 이상 남아 있다 |

## 5. 절차

### A. 기본 패키지와 의존성 설치

1. (5-A-01) 기본 도구를 설치한다: `apt-get install -y iputils-ping vim wget unzip git` → 결과: 오류 없이 끝난다.
2. (5-A-02) 의존성을 설치한다(둘 중 하나. 아래는 짧은 목록): 

```bash
sudo apt update
sudo apt install -y build-essential libpcap-dev libpcre3-dev zlib1g-dev libdumbnet-dev bison flex liblzma-dev openssl libssl-dev pkg-config libhwloc-dev cmake libsqlite3-dev uuid-dev libnetfilter-queue-dev libmnl-dev libluajit-5.1-dev libdaq-dev autoconf libtool
```

→ 결과: 모든 패키지가 설치된다. 원본에는 다음을 더 넣은 긴 목록도 있었다: `libnet1-dev`, `luajit`, `hwloc`, `cpputest`, `libcmocka-dev`, `autotools-dev`, `libunwind-dev`, `libfl-dev`. 빌드 중 헤더가 없다는 오류가 나면 해당 패키지를 추가한다.

### B. libdaq 설치

1. (5-B-01) 소스를 받는다: `git clone https://github.com/snort3/libdaq.git` → 결과: `libdaq` 디렉터리가 생긴다.
2. (5-B-02) 디렉터리로 이동한다: `cd ./libdaq`
3. (5-B-03) 설정한다: `./bootstrap && ./configure` → 결과: 오류 없이 끝난다.
4. (5-B-04) 빌드하고 설치한다: `make && make install` → 결과: `/usr/local/lib`에 libdaq가 설치된다.

### C. gperftools 설치

1. (5-C-01) 소스를 받는다: `wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.13/gperftools-2.13.tar.gz`
2. (5-C-02) 압축을 푼다: `tar zxf ./gperftools-2.13.tar.gz`
3. (5-C-03) 빌드하고 설치한다: `cd ./gperftools-2.13 && ./configure && make && make install` → 결과: 오류 없이 끝난다.

### D. Snort 3 빌드와 설치

1. (5-D-01) 홈 디렉터리로 이동해 소스를 받는다: `cd && wget https://github.com/snort3/snort3/archive/refs/heads/master.zip`
2. (5-D-02) 압축을 푼다: `unzip master.zip` → 결과: `snort3-master` 디렉터리가 생긴다.
3. (5-D-03) 빌드를 설정한다: `cd snort3-master/ && ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc` → 결과: `build` 디렉터리가 생긴다.
4. (5-D-04) 빌드하고 설치한다: `cd ./build && make && make install` → 결과: 오류 없이 끝난다. 코어 수에 따라 수십 분이 걸린다.
5. (5-D-05) 버전을 확인한다: `snort -V` → 결과: Snort 버전 정보가 출력된다. 공유 라이브러리를 찾지 못하면 `ldconfig`를 실행한 뒤 다시 입력한다(원본에 없던 보충, 미검증).
6. (5-D-06) 기본 설정을 검사한다: `snort -c /usr/local/etc/snort/snort.lua` → 결과: 설정 검증이 끝나고 오류가 없다.

### E. NIC 설정 (promiscuous, GRO/LRO 비활성화)

1. (5-E-01) 서비스 파일을 만든다: `vi /etc/systemd/system/snort3-nic.service`
2. (5-E-02) 아래 내용을 입력한다. `<인터페이스 이름>`은 감시할 NIC로 바꾼다.

```ini
[Unit]
Description=Set Snort 3 NIC in promiscuous mode and Disable GRO, LRO on boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ip link set dev <인터페이스 이름> promisc on
ExecStart=/usr/sbin/ethtool -K <인터페이스 이름> gro off lro off
TimeoutStartSec=0
RemainAfterExit=yes

[Install]
WantedBy=default.target
```

3. (5-E-03) 서비스를 등록하고 시작한다: `systemctl daemon-reload && systemctl start snort3-nic && systemctl enable snort3-nic` → 결과: 오류 없이 끝난다.
4. (5-E-04) 설정이 적용됐는지 확인한다: `ip link show <인터페이스 이름>` → 결과: 플래그에 `PROMISC`가 있다.
5. (5-E-05) 오프로드 상태를 확인한다: `ethtool -k <인터페이스 이름> | grep receive-offload` → 결과: `generic-receive-offload: off`, `large-receive-offload: off`가 보인다. (원본의 `grep receive -offload`는 공백 때문에 오류가 나므로 `receive-offload`로 정정했다.)

### F. 커뮤니티 룰과 변수 설정

1. (5-F-01) 룰 디렉터리를 만든다: `mkdir /usr/local/etc/snort/rules`
2. (5-F-02) 커뮤니티 룰을 내려받아 푼다: `wget -qO- https://www.snort.org/downloads/community/snort3-community-rules.tar.gz | tar xz -C /usr/local/etc/snort/rules/` → 결과: `snort3-community-rules` 디렉터리가 생긴다.
3. (5-F-03) 설정 파일을 백업한다: `cp /usr/local/etc/snort/snort.lua /usr/local/etc/snort/snort.lua.bak`
4. (5-F-04) 설정 파일을 연다: `vi /usr/local/etc/snort/snort.lua`
5. (5-F-05) 변수를 환경에 맞게 수정한다.

```lua
HOME_NET = '<보호할 사설 대역, 예: 192.168.0.0/16>'
EXTERNAL_NET = '!$HOME_NET'
```

6. (5-F-06) `ips` 블록의 `rules`에 커뮤니티 룰을 포함한다.

```lua
rules = [[
  include /usr/local/etc/snort/rules/snort3-community-rules/snort3-community.rules
]]
```

→ 결과: 5-F-05, 5-F-06의 값이 파일에 저장되어 있다. 원본은 `snort.lua`의 24, 28, 192~195행 부근이다.

### G. 사용자 룰과 OpenAppID 설정

1. (5-G-01) 사용자 룰 파일을 연다: `vi /usr/local/etc/snort/rules/local.rules`
2. (5-G-02) 시험용 룰을 입력한다: `alert icmp any any -> $HOME_NET any (msg:"icmp msg";sid:1000001;rev:1;)` → 결과: ICMP 패킷을 경고로 기록하는 룰이 저장된다.
3. (5-G-03) `snort.lua`의 `rules` 블록에 `local.rules`를 먼저 포함한다.

```lua
rules = [[
  include /usr/local/etc/snort/rules/local.rules
  include /usr/local/etc/snort/rules/snort3-community-rules/snort3-community.rules
]]
```

4. (5-G-04) (선택) OpenAppID 패키지를 받아 푼다: `wget https://www.snort.org/downloads/openappid/33380 -O OpenAppId-33380.tgz && tar -xzvf OpenAppId-33380.tgz`
5. (5-G-05) (선택) 탐지기 디렉터리를 복사한다: `cp -R odp /usr/local/lib/`
6. (5-G-06) (선택) `snort.lua`의 `appid` 설정에서 탐지기 경로를 `/usr/local/lib`로 지정한다 → 결과: `app_detector_dir`가 `/usr/local/lib`이다. 원본은 "snort.lua를 편집한다"까지만 적혀 있어 이 설정 항목은 보충한 것이며 미검증이다.

### H. 탐지 실행

1. (5-H-01) 설정과 룰 파일을 검사한다: `snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules` → 결과: 오류 없이 검증이 끝난다.
2. (5-H-02) 탐지를 실행한다: `snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/snort/rules/local.rules -i <인터페이스 이름> -A alert_fast -s 65535 -k none` → 결과: 실행되어 패킷을 기다린다. Ctrl + C로 종료한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `snort -V` | 버전이 출력된다 | 오류 없음 |
| 2 | 5-H-02 실행 중 다른 PC에서 감시 서버로 `ping -c 3 <서버 IP>` | 터미널에 `icmp msg` 경고가 출력된다 | 경고가 3건 이상 나온다 |
| 3 | `ip link show <인터페이스 이름>` | `PROMISC` 플래그가 있다 | 플래그가 있다 |

## 7. 복구

1. (7-01) 서비스를 끄고 NIC 설정을 되돌린다: `systemctl disable --now snort3-nic` 이어서 `ip link set dev <인터페이스 이름> promisc off` 와 `ethtool -K <인터페이스 이름> gro on lro on` → 결과: `ip link show`에서 `PROMISC`가 사라진다. (LRO는 장치에 따라 켤 수 없으면 `fixed` 메시지가 나온다.)
2. (7-02) 서비스 파일을 지운다: `rm /etc/systemd/system/snort3-nic.service && systemctl daemon-reload`
3. (7-03) 설정을 되돌린다: `cp /usr/local/etc/snort/snort.lua.bak /usr/local/etc/snort/snort.lua`
4. (7-04) Snort 설치 파일은 `/usr/local` 아래에 있다. 필요하면 `snort3-master/build`에서 `make uninstall`을 시도한다(지원 여부 확인 필요).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 인터페이스 이름을 `<인터페이스 이름>`으로 일반화하고 `grep` 명령 오류를 정정했다. CAUTION, 기능 확인, 복구 절을 추가했다. 두 개였던 의존성 설치 예시는 짧은 목록으로 합치고 차이를 적었다. 중복된 한 줄 설치 명령은 삭제했다 |
