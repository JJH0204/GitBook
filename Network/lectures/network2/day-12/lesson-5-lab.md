# bind9 DNS 서버 구축 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-015-MP |
| 목적 | bind9로 `student.local` 존을 가진 DNS 서버를 구축하고, `dig`로 검증하고, 레코드를 추가하며 Serial 올리는 사이클을 익힌다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM, `systemd-resolved` 기본 동작), 창 2개(`①` 작업, `②` 클라이언트) |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [lesson-5.md](lesson-5.md) | LEC-N2-12-005-DO | DNS 서버 (bind9) |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | 인터넷 연결(`apt`) 필요 |
| 2 | SSH 창 2개 | `ssh student@192.168.x.x` | `①` 작업, `②` 클라이언트 |
| 3 | VM의 IP 주소 | `ip -br a`로 확인 | 아래에서 `192.168.x.x`를 이 값으로 바꾼다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `listen-on`에 `any`를 쓰지 않는다. `systemd-resolved`가 `127.0.0.53:53`을 쓰고 있어 `Address already in use`로 `named`가 죽는다. 내 IP와 `127.0.0.1`만 적는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: VM의 기본 DNS 설정은 바꾸지 않는다. 이 실습은 `dig @127.0.0.1`로 직접 묻기만 한다. 기본 DNS가 틀리면 `apt`가 멈춘다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM의 IP를 확인한다 | `ip -br a`에서 `192.168.x.x`가 보인다 |
| 2 | 53번 포트의 현재 상태를 본다 | `sudo ss -tulnp \| grep ':53 '`에 `127.0.0.53`(resolved)이 보인다 |
| 3 | SSH 창 2개를 연다 | 창마다 프롬프트가 보인다 |

## 5. 절차

### A. 설치 (창 ①)

1. (5-A-01) 설치한다: `sudo apt install bind9 bind9-utils bind9-dnsutils -y` → 결과: 오류 없이 끝난다.

### B. 설정 1: 듣는 주소 지정 (창 ①)

1. (5-B-01) 백업한다: `sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak`
2. (5-B-02) 편집기를 연다: `sudo nano /etc/bind/named.conf.options`
3. (5-B-03) `options {` 바로 아래에 4줄을 추가한다. `192.168.x.x`는 4절에서 확인한 내 IP로 바꾼다.

```
        listen-on port 53 { 127.0.0.1; 192.168.x.x; };
        listen-on-v6 { none; };
        forwarders { 8.8.8.8; 1.1.1.1; };
        allow-query { any; };
```

{% hint style="info" %}
NOTE: 파일에 이미 `listen-on-v6 { any; };`나 `forwarders` 줄이 있으면 같은 이름의 줄을 중복해서 넣지 않고 기존 줄을 위 값으로 고친다. 중복되면 `named-checkconf`가 오류를 낸다.
{% endhint %}

### C. 설정 2: 존 선언 (창 ①)

1. (5-C-01) 편집기를 연다: `sudo nano /etc/bind/named.conf.local`
2. (5-C-02) 맨 아래에 추가한다:

```
zone "student.local" {
    type master;
    file "/etc/bind/db.student.local";
};
```

### D. 설정 3: 존 파일 (창 ①)

1. (5-D-01) 템플릿을 복사한다: `sudo cp /etc/bind/db.local /etc/bind/db.student.local`
2. (5-D-02) 편집기를 연다: `sudo nano /etc/bind/db.student.local`
3. (5-D-03) 아래 모양이 되도록 고친다. 이름 끝의 점(`.`)을 빠뜨리지 않는다.

```
$TTL    604800
@   IN  SOA ns1.student.local. admin.student.local. (
            2026092001  ; Serial
            604800      ; Refresh
            86400       ; Retry
            2419200     ; Expire
            604800 )    ; Negative TTL
;
@       IN  NS      ns1.student.local.
ns1     IN  A       192.168.x.x
www     IN  A       192.168.x.x
web     IN  CNAME   www.student.local.
@       IN  MX  10  mail.student.local.
mail    IN  A       192.168.x.x
```

### E. 문법 검사, 기동, 확인 (창 ①)

1. (5-E-01) 설정 문법을 검사한다: `sudo named-checkconf` → 결과: 아무 출력이 없다.
2. (5-E-02) 존 문법을 검사한다: `sudo named-checkzone student.local /etc/bind/db.student.local` → 결과: `OK`와 `loaded serial 2026092001`.
3. (5-E-03) 재시작한다: `sudo systemctl restart named`
4. (5-E-04) 상태를 본다: `systemctl status named --no-pager | head -5` → 결과: `active (running)`.
5. (5-E-05) 포트를 본다: `sudo ss -tulnp | grep ':53 '` → 결과: `127.0.0.1:53`과 `192.168.x.x:53`이 TCP와 UDP로 보인다.
6. (5-E-06) ufw를 켰다면 연다: `sudo ufw allow 53`

{% hint style="info" %}
NOTE: 실패하면 반드시 `sudo journalctl -u named -n 30 --no-pager`를 본다.
{% endhint %}

### F. 검증: 내 DNS 서버에 직접 묻는다 (창 ②)

1. (5-F-01) `dig @127.0.0.1 www.student.local +short` → 결과: `192.168.x.x`.
2. (5-F-02) `dig @127.0.0.1 web.student.local` → 결과: CNAME과 A가 두 줄로 온다.
3. (5-F-03) `dig @127.0.0.1 student.local MX +short` → 결과: `10 mail.student.local.`.
4. (5-F-04) `dig @127.0.0.1 nosuch.student.local | head -8` → 결과: `status: NXDOMAIN`.
5. (5-F-05) `dig @127.0.0.1 www.google.com +short` → 결과: IP 주소가 나온다(forwarders가 대신 찾아온다).
6. (5-F-06) `dig @127.0.0.1 www.student.local | grep flags` → 결과: `flags:` 줄에 `aa`가 있다.

### G. 레코드 추가와 Serial 올리기 (창 ①, 창 ②)

1. (5-G-01) 창 ①에서 존 파일을 연다: `sudo nano /etc/bind/db.student.local`
2. (5-G-02) 맨 아래에 한 줄을 추가한다: `ftp     IN  A       192.168.x.x`
3. (5-G-03) Serial을 1 올린다: `2026092001`을 `2026092002`로 고친다.
4. (5-G-04) 검사한다: `sudo named-checkzone student.local /etc/bind/db.student.local` → 결과: `loaded serial 2026092002`.
5. (5-G-05) 다시 읽게 한다: `sudo systemctl reload named`
6. (5-G-06) 창 ②에서 확인한다: `dig @127.0.0.1 ftp.student.local +short` → 결과: `192.168.x.x`.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo named-checkconf` | 출력 없음 | 오류 없음 |
| 2 | `dig @127.0.0.1 www.student.local +short` | 내 IP | `192.168.x.x`가 나온다 |
| 3 | `dig @127.0.0.1 www.student.local \| grep flags` | `aa` 포함 | `aa`가 있다 |
| 4 | `dig @127.0.0.1 nosuch.student.local` | 없는 이름 | `NXDOMAIN` |
| 5 | 레코드 추가 후 `dig @127.0.0.1 ftp.student.local +short` | 새 레코드 | IP가 나온다 |

수업 종료 시 점검: 고치고, 검사, 재시작, `dig` 4단계를 혼자 돌릴 수 있다.

## 7. 복구

1. (7-01) 옵션 설정을 되돌린다: `sudo cp /etc/bind/named.conf.options.bak /etc/bind/named.conf.options`
2. (7-02) `/etc/bind/named.conf.local`에서 `zone "student.local"` 블록을 지운다.
3. (7-03) 존 파일을 지운다(선택): `sudo rm /etc/bind/db.student.local`
4. (7-04) 서비스를 끈다(선택): `sudo systemctl disable --now named` → 결과: `ss -tulnp | grep ':53 '`에 `127.0.0.53`만 남는다.
5. (7-05) ufw 규칙을 지운다(5-E-06을 했다면): `sudo ufw status numbered`로 번호를 확인하고 `sudo ufw delete <번호>`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-5.md`의 구축 절과 `commands.md` STEP 5를 AMM 형식 MP로 분리. 중복 지시문 주의 NOTE 추가 |
