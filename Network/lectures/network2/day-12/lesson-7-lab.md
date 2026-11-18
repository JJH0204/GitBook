# squid 프록시 구축과 차단 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-017-MP |
| 목적 | squid를 설치해 프록시를 경유하는 요청에서 캐시(`TCP_MISS`, `TCP_HIT`)를 확인하고, 도메인 차단 규칙을 추가해 `403`을 확인한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM), 창 3개(`①` 작업, `②` 클라이언트, `③` 관찰). 오늘 수업에서는 하지 않고 13일차에 한다 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다. 차단 규칙의 위치는 확인 필요) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [lesson-7.md](lesson-7.md) | LEC-N2-12-007-DO | Proxy 서버 (squid) |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | 인터넷 연결 필요 |
| 2 | SSH 창 3개 | `ssh student@192.168.x.x` | `①` 작업, `②` 클라이언트, `③` 관찰 |
| 3 | 패키지 | `squid`, `curl` | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `/etc/squid/squid.conf`를 고치기 전에 5-D-01의 `.bak` 백업을 한다. 규칙 순서가 틀리면 모든 요청이 거부되거나 차단이 먹지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 실습은 `127.0.0.1`의 프록시만 쓴다. 차단 대상 `example.com`은 문서용 도메인이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SSH 창 3개를 연다 | 창마다 프롬프트가 보인다 |
| 2 | 인터넷이 된다 | `curl -I http://example.com`이 `200` 계열 응답을 낸다 |

## 5. 절차

### A. 설치와 확인 (창 ①)

1. (5-A-01) 설치한다: `sudo apt install squid -y` → 결과: 오류 없이 끝난다.
2. (5-A-02) 상태를 본다: `systemctl status squid --no-pager | head -5` → 결과: `active (running)`.
3. (5-A-03) 포트를 본다: `sudo ss -tulnp | grep 3128` → 결과: 3128 LISTEN이 보인다.

### B. 로그 관찰 시작 (창 ③)

1. (5-B-01) 실시간으로 본다: `sudo tail -f /var/log/squid/access.log` → 결과: 대기 상태가 된다.

### C. 프록시 경유 검증 (창 ②)

1. (5-C-01) 직접 나간다: `curl -I http://example.com` → 결과: 응답 헤더가 온다. 창 ③에는 아무것도 찍히지 않는다.
2. (5-C-02) 프록시를 경유한다: `curl -I -x http://127.0.0.1:3128 http://example.com` → 결과: 창 ③에 `TCP_MISS/200`이 찍힌다.
3. (5-C-03) 한 번 더 경유한다: `curl -I -x http://127.0.0.1:3128 http://example.com` → 결과: 사이트가 캐시를 허용하면 `TCP_HIT/200`이 찍힌다.

{% hint style="info" %}
NOTE: `TCP_HIT`는 사이트가 캐시를 허용할 때만 뜬다. 안 뜨면 응답 헤더의 `Cache-Control` 때문이다.
{% endhint %}

### D. 차단 규칙 추가 (창 ①)

1. (5-D-01) 백업한다: `sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak`
2. (5-D-02) 편집기를 연다: `sudo nano /etc/squid/squid.conf`
3. (5-D-03) `http_access allow localhost` 줄을 찾는다(`Ctrl+W`).
4. (5-D-04) 그 줄의 바로 위에 두 줄을 추가한다. 평가는 위에서부터 하고 처음 맞는 규칙을 적용한다.

```
acl blocked_sites dstdomain .example.com
http_access deny blocked_sites
```

{% hint style="danger" %}
WARNING: 이 두 줄을 `http_access deny all` 바로 위에만 두면 안 될 수 있다. 우분투 기본 설정은 `http_access allow localhost`가 `deny all`보다 먼저 나와서, 로컬 요청이 차단 규칙에 닿기 전에 허용된다. 원본 노트의 "deny all 위쪽" 지시를 이렇게 고쳤다. 확인 필요.
{% endhint %}

5. (5-D-05) 저장하고 나간다: `Ctrl+O`, `Enter`, `Ctrl+X`
6. (5-D-06) 문법을 검사한다: `sudo squid -k parse > /dev/null && echo "문법 OK"` → 결과: `문법 OK`.
7. (5-D-07) 재시작한다: `sudo systemctl restart squid` → 결과: 오류 없이 끝난다.

### E. 차단 확인 (창 ②)

1. (5-E-01) 차단 대상으로 요청한다: `curl -I -x http://127.0.0.1:3128 http://example.com` → 결과: `403 Forbidden`.
2. (5-E-02) 다른 사이트로 요청한다: `curl -I -x http://127.0.0.1:3128 http://neverssl.com` → 결과: 응답이 정상으로 온다.
3. (5-E-03) 창 ③을 본다. → 결과: `TCP_DENIED/403`이 찍힌다. 누가, 언제, 어디를 시도했는지 남는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo ss -tulnp \| grep 3128` | LISTEN | 3128이 보인다 |
| 2 | 프록시 경유 요청 2회 | MISS 다음 HIT | 로그에 `TCP_MISS`와 `TCP_HIT`(캐시 허용 시) |
| 3 | 차단 후 `example.com` 요청 | 차단 | `403 Forbidden` |
| 4 | 차단 후 `neverssl.com` 요청 | 허용 | 정상 응답 |

수업 종료 시 점검: 프록시가 7계층에서 본다는 말의 뜻을 NAT와 비교해 말할 수 있다.

## 7. 복구

1. (7-01) 설정을 되돌린다: `sudo cp /etc/squid/squid.conf.bak /etc/squid/squid.conf`
2. (7-02) 재시작한다: `sudo systemctl restart squid`
3. (7-03) 서비스를 끈다(선택): `sudo systemctl disable --now squid` → 결과: `ss -tulnp | grep 3128`에 아무것도 나오지 않는다.
4. (7-04) 창 ③에서 `Ctrl+C`로 로그 관찰을 멈춘다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-7.md`의 구축 절과 `commands.md` STEP 7을 AMM 형식 MP로 분리. 차단 규칙의 삽입 위치를 `http_access allow localhost` 위로 고침(확인 필요) |
