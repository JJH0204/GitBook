# DNS 서버 구축 (BIND)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-014-MP |
| 목적 | CentOS 계열 Linux 서버에 BIND로 DNS 서버를 구축하고 zone 하나를 등록한다 |
| 적용 대상(Effectivity) | RHEL 계열 Linux(원본은 CentOS 7 자료를 참고, 명령은 `dnf` 사용), BIND(named) |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 원본 `dns.md`의 절차를 분리한 새 문서다. 원본의 zone 블록에 `tile`로 적힌 키워드는 `file`의 오타라 고쳤고, 예시 도메인은 `example.com`, IP는 `192.0.2.10`으로 바꿨다. 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [dns.md](dns.md) | NET-PRT-009-DO | 도메인 네임 시스템 (DNS) |
| [domain_name.md](domain_name.md) | NET-PRT-013-DO | 도메인 이름 |

외부 자료:

* [리눅스 서버에 구축](https://velog.io/@sherlockid8/Linux-CentOS-7-DNS-%EB%84%A4%EC%9E%84%EC%84%9C%EB%B2%84-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0)
* [윈도우 서버에 구축](https://ast-216.tistory.com/14)
* [Master와 Slave 관련 자료](https://rlahjxx.tistory.com/15)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Linux 서버 | RHEL 계열, root 권한 | |
| 2 | 패키지 | `bind`, `bind-utils` | `nslookup` 사용에 `bind-utils`가 필요하다 |
| 3 | 방화벽 | firewalld | 53/tcp, 53/udp 개방 |
| 4 | 서버 고정 IP | 예: `192.0.2.10` | 문서용 주소다. 실제 값으로 바꾼다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 원본 예시의 `allow-query { any; }`와 `listen-on port 53 { any; }`는 모든 곳의 질의를 허용한다. 인터넷에 노출된 서버에서는 허용 대상을 내부 대역으로 제한한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 원본 예시는 `dnssec-validation no;`로 DNSSEC 검증을 끈다. 학습용 구성이다. 운영 서버에서는 기본값(켜짐)을 유지한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한으로 접속한다 | `whoami` 결과가 `root`다 |
| 2 | 서버가 인터넷 저장소에 접근한다 | `dnf repolist`가 오류 없이 끝난다 |
| 3 | 서버의 IP 주소를 확인한다 | `ip addr`에 고정 IP가 보인다 |

## 5. 절차

### A. BIND 설치

1. (5-A-01) BIND와 도구를 설치한다: `dnf install bind bind-utils -y` → 결과: 설치가 오류 없이 끝난다.
2. (5-A-02) 설정 파일을 연다: `vi /etc/named.conf` → 결과: 편집기에 `options` 블록이 보인다.

### B. named.conf 수정

1. (5-B-01) `options` 블록에서 아래 네 줄을 수정한다.

```
listen-on port 53 { any; };
listen-on-v6 port 53 { none; };
allow-query { any; };
dnssec-validation no;
```

→ 결과: 파일에 위 값이 저장된다.

### C. 서비스와 방화벽

1. (5-C-01) 서비스를 시작한다: `systemctl restart named`
2. (5-C-02) 부팅 시 자동 시작을 켠다: `systemctl enable named`
3. (5-C-03) 상태를 확인한다: `systemctl status named` → 결과: `active (running)`이 보인다.
4. (5-C-04) TCP 53을 연다: `firewall-cmd --permanent --add-port=53/tcp`
5. (5-C-05) UDP 53을 연다: `firewall-cmd --permanent --add-port=53/udp`
6. (5-C-06) 방화벽 설정을 적용한다: `firewall-cmd --reload`
7. (5-C-07) 설정을 확인한다: `firewall-cmd --list-all` → 결과: `ports`에 `53/tcp 53/udp`가 보인다.

### D. zone 등록

1. (5-D-01) `/etc/named.conf` 끝에 zone 블록을 추가한다. 도메인은 큰따옴표로 감싼다.

```
zone "example.com" IN {
	type master;
	file "example.com.zone";
	allow-update { none; };
};
```

2. (5-D-02) 문법을 검사한다: `named-checkconf /etc/named.conf` → 결과: 출력이 없다(오류 없음).

### E. zone 파일 작성

1. (5-E-01) 기본 파일을 복사한다: `cp /var/named/named.localhost /var/named/example.com.zone`
2. (5-E-02) 소유권을 설정한다: `chown root:named /var/named/example.com.zone`
3. (5-E-03) 파일을 연다: `vi /var/named/example.com.zone`
4. (5-E-04) 내용을 아래처럼 작성한다.

```
$TTL 1D
@    IN    SOA    @    rname.invalid.    ( 2    1D    1H    1W    1H )
           IN     NS   @
           IN     A    192.0.2.10

www        IN     A    192.0.2.10
ftp        IN     A    192.0.2.10
```

→ 결과: 파일이 저장된다.

{% hint style="warning" %}
CAUTION: 도메인 이름에 `_` 같은 특수문자를 넣으면 오류가 발생한다.
{% endhint %}

5. (5-E-05) zone 파일을 검사한다: `named-checkzone example.com /var/named/example.com.zone` → 결과: `OK`가 출력된다.
6. (5-E-06) 서비스를 다시 시작한다: `systemctl restart named`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `nslookup`을 실행하고 `server <DNS 서버 IP>`를 입력한다 | 프롬프트가 `>`로 유지된다 | 오류 메시지가 없다 |
| 2 | `www.example.com`을 입력한다 | A 레코드 응답이 출력된다 | `192.0.2.10`이 출력된다 |

## 7. 복구

1. (7-01) 서비스를 중지한다: `systemctl stop named`
2. (7-02) 자동 시작을 끈다: `systemctl disable named`
3. (7-03) 방화벽에서 53 포트를 닫는다: `firewall-cmd --permanent --remove-port=53/tcp`, `firewall-cmd --permanent --remove-port=53/udp` 실행 후 `firewall-cmd --reload`
4. (7-04) `/etc/named.conf`를 5-B 이전 값으로 되돌리고 5-D에서 추가한 zone 블록을 지운다.

## 8. 클라이언트 설정 참고

| 항목 | 위치 |
|---|---|
| 랜카드 설정 파일 | `/etc/NetworkManager/system-connections/` |
| DNS 클라이언트 설정 | `/etc/resolv.conf` |

{% hint style="info" %}
NOTE: 원본은 `/etc/resolv.conf` 수정 후 재부팅을 권장했다. NetworkManager를 쓰는 시스템은 이 파일을 다시 덮어쓸 수 있으므로 NetworkManager 연결 설정에서 DNS를 지정하는 편이 안전하다. 재부팅은 필수가 아니다. 확인 필요.
{% endhint %}

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `dns.md`에서 절차를 분리해 AMM 형식으로 작성 |
