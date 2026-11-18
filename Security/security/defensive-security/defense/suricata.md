# Suricata 설치 및 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-006-MP |
| 목적 | Suricata를 소스에서 설치해 IDS로 실행하고 룰을 적용하며 경고 로그를 확인한다 |
| 적용 대상 | Ubuntu Linux 가상 머신(실습망), root 권한, 인터넷 연결, Suricata 7.0.6 |
| 소요 시간 | 약 50분 (빌드 시간 포함) |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·빌드·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 IDS(탐지) 모드로 실행한다. 원본의 `./configure`에 `--enable-efqueue` 옵션이 있는데 이는 Suricata 공식 옵션이 아닐 수 있다(NFQUEUE 지원은 `--enable-nfqueue`). 원문 그대로 두고 확인 필요로 표시한다. 원본 13단계(fast.log)는 "출력이 안 되었다"고 적혀 있어 이 문서의 기능 확인과 문제 해결 방법에서 보충했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [침입 탐지 시스템 (IDS)](ids.md) | SEC-DEF-001-DO | IDS 개념 |
| [Snort 룰 문법](snort-rule.md) | SEC-DEF-004-REF | Suricata도 같은 룰 형식을 쓴다 |
| 공식 사이트 | - | https://suricata.io/download/ , https://oisf.net/ |
| 설치 참고 글 | - | https://daeunnniii.tistory.com/107 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 감시 서버 | Ubuntu Linux 가상 머신, 2코어 이상 | |
| 2 | 네트워크 인터페이스 | 감시할 NIC | `<인터페이스 이름>`으로 표기한다 |
| 3 | `jq` | JSON 로그 조회용 | 5-I에서 설치한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 5-E의 설정 파일 검사(`-T`)를 통과하지 않은 상태로 서비스를 시작하면 서비스가 시작되지 않는다. 설정을 바꿀 때마다 `suricata -T`를 먼저 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-L의 `systemctl restart suricata`는 탐지를 잠시 멈춘다. 그 시간의 트래픽은 검사되지 않는다. IDS 모드에서는 통신이 끊기지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 인터페이스 이름을 확인한다: `ip --brief addr` | 감시할 NIC 이름이 보인다 |
| 3 | 디스크 여유를 확인한다: `df -h /` | 5GB 이상 남아 있다 |

## 5. 절차

### A. 패키지 설치

1. (5-A-01) 빌드와 분석에 필요한 패키지를 설치한다: 

```bash
apt -y install libpcre2-dev libpcre3 libpcre3-dbg libpcre3-dev build-essential autoconf automake libtool libpcap-dev libyaml-0-2 libyaml-dev libcap-ng-dev libcap-ng0 make libmagic-dev libjansson-dev libjansson4 pkg-config libnspr4-dev libnss3-dev liblz4-dev rustc cargo python3-pip
```

2. (5-A-02) Netfilter 패키지를 설치한다: `apt install -y libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev libnfnetlink0` → 결과: 두 명령 모두 오류 없이 끝난다.

### B. 소스 설치

1. (5-B-01) 소스를 받는다: `wget https://www.openinfosecfoundation.org/download/suricata-7.0.6.tar.gz`
2. (5-B-02) 압축을 푼다: `tar xzf suricata-7.0.6.tar.gz` → 결과: `suricata-7.0.6` 디렉터리가 생긴다.
3. (5-B-03) 설정한다: `cd ./suricata-7.0.6 && ./configure --enable-efqueue --prefix=/usr --sysconfdir=/etc --localstatedir=/var` → 결과: 오류 없이 끝난다. `--enable-efqueue` 때문에 오류가 나면 이 옵션을 빼거나 `--enable-nfqueue`로 바꾼다(확인 필요).
4. (5-B-04) 빌드하고 설치한다: `make && make install-full` → 결과: 설치 요약이 출력되고 룰 파일과 설정 파일이 `/etc/suricata`에 설치된다.

### C. 설치 확인

1. (5-C-01) 버전을 확인한다: `suricata -V` → 결과: `This is Suricata version 7.0.6 RELEASE`가 출력된다.
2. (5-C-02) 인터페이스를 확인한다: `ip --brief addr` → 결과: `lo`, `<인터페이스 이름>`과 IP가 나열된다.

### D. 설정 파일 편집

1. (5-D-01) 설정 파일을 백업한다: `cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak`
2. (5-D-02) 설정 파일을 연다: `vi /etc/suricata/suricata.yaml`
3. (5-D-03) 아래 항목을 수정한다.

| 항목 | 값 |
|---|---|
| `HOME_NET` | `"[<보호할 사설 대역, 예: 192.168.0.0/16>]"` |
| `default-log-dir` | `/var/log/suricata/` |
| `community-id` | `true` |
| `af-packet`의 `interface` | `<인터페이스 이름>` (패킷을 탐지할 인터페이스) |
| `promisc` | `true` |

→ 결과: 표의 값이 저장되어 있다.

### E. 설정 문법 검사

1. (5-E-01) 검사한다: `suricata -T -c /etc/suricata/suricata.yaml -v` → 결과: 마지막에 `Configuration provided was successfully loaded. Exiting.`이 출력된다.

### F. 시험 실행

1. (5-F-01) 실행한다: `suricata -c /etc/suricata/suricata.yaml -i <인터페이스 이름>` → 결과: 엔진이 시작되고 패킷을 기다린다.
2. (5-F-02) Ctrl + C로 종료한다.

### G. systemd 서비스 등록

1. (5-G-01) 서비스 파일을 만든다: `vi /etc/systemd/system/suricata.service`
2. (5-G-02) 아래 내용을 입력한다.

```ini
[Unit]
Description=Suricata IDS/IPS
After=network.target

[Service]
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -i <인터페이스 이름>

[Install]
WantedBy=default.target
```

3. (5-G-03) 서비스를 등록하고 시작한다: `systemctl daemon-reload && systemctl enable suricata && systemctl start suricata` → 결과: 오류 없이 끝난다.
4. (5-G-04) 상태를 확인한다: `systemctl status suricata` → 결과: `active (running)`이 보인다. 시작되지 않으면 5-D, 5-E를 다시 확인한다.

### H. 탐지 시험

1. (5-H-01) 시험 사이트에 접속한다: `curl https://testmynids.org/uid/index.html` → 결과: `uid=0(root) gid=0(root) groups=0(root)` 형태의 내용이 출력된다. 이 요청은 IDS 시험용 패턴을 발생시키는 공개 시험 페이지다.
2. (5-H-02) 경고 로그를 확인한다: `cat /var/log/suricata/fast.log` → 결과: 시험 시그니처(예: `2100498`) 경고가 보인다. 원본 작성자는 출력이 없었다고 적었다. 출력이 없으면 6절 문제 해결 표를 따른다.

### I. JSON 로그 조회

1. (5-I-01) `jq`를 설치한다: `apt install -y jq`
2. (5-I-02) 특정 시그니처의 경고만 조회한다: `jq 'select(.alert.signature_id==2100498)' /var/log/suricata/eve.json` → 결과: 해당 경고의 JSON이 출력된다.

### J. 사용자 룰 작성과 적용

1. (5-J-01) 디렉터리와 파일을 만든다: `cd /etc/suricata && mkdir ./rules && vi ./rules/local.rules`
2. (5-J-02) 시험용 룰을 입력한다(Snort 룰과 같은 형식): `alert icmp any any -> $HOME_NET any (msg:"icmp packet";sid:100001;rev:1;)` → 결과: ICMP 패킷을 경고로 기록하는 룰이 저장된다.
3. (5-J-03) `suricata.yaml`의 `rule-files:` 목록에 `- /etc/suricata/rules/local.rules` 줄을 추가한다. 원본은 `rule-files` 항목이라고 적지 않고 "줄을 추가한다"고만 적었다.
4. (5-J-04) 문법을 검사한다: `suricata -T -c /etc/suricata/suricata.yaml -v` → 결과: `successfully loaded`가 출력된다.
5. (5-J-05) 다른 PC에서 `ping -c 3 <서버 IP>`를 보낸다.
6. (5-J-06) 실시간으로 확인한다: `tail -fv /var/log/suricata/fast.log` 또는 `tail -f /var/log/suricata/eve.json | jq 'select(.event_type=="alert")'` → 결과: `icmp packet` 경고가 나타난다.

### K. 룰 업데이트

1. (5-K-01) 룰 소스 목록을 갱신한다: `suricata-update update-sources`
2. (5-K-02) 제공되는 소스를 확인한다: `suricata-update list-sources` → 결과: 소스 이름 목록이 출력된다.
3. (5-K-03) 사용할 소스를 켠다: `suricata-update enable-source tgreen/hunting`
4. (5-K-04) 룰을 가져온다: `suricata-update -o /etc/suricata/rules` → 결과: 룰 파일이 만들어진다.

### L. 서비스 재시작

1. (5-L-01) 재시작한다: `systemctl restart suricata` → 결과: 오류 없이 끝나고 `systemctl status suricata`가 `active (running)`이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `suricata -T -c /etc/suricata/suricata.yaml -v` | 설정을 읽는다 | `successfully loaded` 출력 |
| 2 | `systemctl is-active suricata` | 실행 중이다 | `active` 출력 |
| 3 | `curl https://testmynids.org/uid/index.html` 후 `fast.log` 확인 | 시험 경고가 기록된다 | `fast.log`에 경고 1건 이상 |
| 4 | 다른 PC에서 `ping` 후 `fast.log` 확인 | `icmp packet` 경고가 기록된다 | 경고 3건 이상 |

문제 해결(`fast.log`에 경고가 없을 때, 확인 필요):

| 증상 | 점검 |
|---|---|
| 서비스는 `active`인데 경고가 없다 | 감시 NIC 이름이 `af-packet`의 `interface`와 서비스 파일 `-i`에서 같은지 확인한다 |
| 룰이 로드되지 않는다 | `rule-files`에 경로가 있는지, `suricata.log`에 룰 오류가 없는지 확인한다 |
| 시험 사이트 경고가 없다 | 시험 룰(시그니처 `2100498`)이 `suricata-update`로 설치되어 있는지 확인한다 |

## 7. 복구

1. (7-01) 서비스를 중지하고 끈다: `systemctl disable --now suricata`
2. (7-02) 서비스 파일을 지운다: `rm /etc/systemd/system/suricata.service && systemctl daemon-reload`
3. (7-03) 설정을 되돌린다: `cp /etc/suricata/suricata.yaml.bak /etc/suricata/suricata.yaml`
4. (7-04) 사용자 룰을 되돌린다: `rm /etc/suricata/rules/local.rules` 그리고 `suricata.yaml`에서 추가한 줄을 지운다.

## 8. 참조: 실행 옵션

| 옵션 | 뜻 |
|---|---|
| `-c <설정 파일 경로>` | Suricata 설정 파일 |
| `-i <인터페이스 이름>` | 패킷을 탐지할 인터페이스 |
| `-T` | 설정을 검사하고 종료한다 |
| `suricata-update` | 룰을 포함해 갱신하는 명령 |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 인터페이스 이름을 `<인터페이스 이름>`으로 일반화했다. CAUTION, 기능 확인(문제 해결 표 포함), 복구 절을 추가했다. 원본의 `jq` 표기 오류(`.alert .signature_id`)를 `.alert.signature_id`로 정정했다 |
