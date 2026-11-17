# 도메인 네임 시스템 (DNS)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | NET-PRT-009-DO |
| 유형 | D&O (개념) |
| 목적 | DNS의 역할, 질의 방식, 레코드 종류, 주/보조 서버 관계를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 네트워크 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 Linux BIND 구축 절차가 대부분이었다. 절차는 [dns-server-bind.md](dns-server-bind.md)(NET-PRT-014-MP)로 분리했다. 이 문서의 DNS 개념, 레코드 표, 질의 순서는 원본에 없어 일반 개념으로 새로 추가했다.
{% endhint %}

## 1. 목적

DNS(Domain Name System)는 사람이 읽는 도메인 이름을 IP 주소로 바꾸는 분산 이름 체계다. 클라이언트가 `www.example.com` 같은 이름으로 접속하면 DNS가 대응하는 IP 주소를 알려 준다.

## 2. 구성 요소

### 2.1 기본 정보

| 항목 | 값 |
|---|---|
| 계층 | 응용 계층 |
| 포트 | 53 (UDP와 TCP) |
| 일반 질의 | UDP 53 |
| TCP 53 사용 | 응답이 큰 경우, 영역 전송(zone transfer) |

### 2.2 주요 레코드

| 레코드 | 의미 | 예 |
|---|---|---|
| A | 이름 → IPv4 주소 | `www.example.com` → `192.0.2.10` |
| AAAA | 이름 → IPv6 주소 | `www.example.com` → `2001:db8::10` |
| CNAME | 이름의 별칭(정식 이름 지정) | `blog.example.com` → `www.example.com` |
| MX | 메일 서버 | `example.com` → `mail.example.com` |
| NS | 해당 영역의 네임 서버 | `example.com` → `ns1.example.com` |
| TXT | 임의 텍스트(메일 인증 등) | |
| PTR | IP 주소 → 이름(역방향 조회) | `10.2.0.192.in-addr.arpa` → `www.example.com` |
| SOA | 영역의 관리 정보(시작 권한) | |

### 2.3 주 서버와 보조 서버 (Master & Slave)

| 서버 | 역할 |
|---|---|
| 주 서버 (Master, Primary) | 도메인 정보의 zone 파일을 관리한다 |
| 보조 서버 (Slave, Secondary) | 주 서버의 zone 데이터를 복제해 미러링(백업)한다 |

주 서버와 보조 서버는 동기화로 DNS 서버를 이중화한다. 데이터 변경은 주 서버의 zone 데이터에서만 한다.

{% hint style="info" %}
NOTE: 원본은 "zone 파일이 업로드되는 대로 Slave로 전송"된다고 적었다. 실제로는 주 서버가 NOTIFY를 보내거나 보조 서버가 SOA의 갱신 주기마다 일련번호를 확인해, 번호가 더 크면 영역 전송(AXFR 또는 IXFR, 보통 TCP 53)으로 복제한다. 그래서 zone을 고칠 때 SOA 일련번호를 올려야 한다. 확인 필요.
{% endhint %}

## 3. 동작 원리

```
클라이언트 -> 리졸버(재귀 DNS 서버) -> 루트 -> TLD(.com) -> 권한 서버(example.com)
            <------------------ IP 주소 응답 <------------------
```

1. 클라이언트가 설정된 DNS 서버(리졸버)에 `www.example.com`의 IP를 묻는다.
2. 리졸버가 캐시에 없으면 루트 서버, TLD 서버, 권한(authoritative) 서버 순서로 질의한다.
3. 권한 서버가 A 레코드를 응답한다.
4. 리졸버가 응답을 TTL 동안 캐시하고 클라이언트에 돌려준다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| zone | 한 네임 서버가 관리하는 도메인 영역 |
| 리졸버 (Resolver) | 클라이언트 대신 이름을 조회하는 DNS 서버 |
| TTL | Time To Live. 캐시 유효 시간 |
| TLD | Top-Level Domain. 최상위 도메인(`.com` 등) |
| AXFR / IXFR | 전체 / 증분 영역 전송 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [dns-server-bind.md](dns-server-bind.md) | NET-PRT-014-MP | DNS 서버 구축 (BIND) |
| [domain_name.md](domain_name.md) | NET-PRT-013-DO | 도메인 이름 |
| [port.md](port.md) | NET-PRT-012-DO | 네트워크 포트 번호 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] DNS가 없다면 웹 사이트에 접속할 때 무엇이 불편할까? 내 말로 적어 본다.
- [ ] 내 PC에서 `nslookup`으로 도메인 하나를 조회해 보고, 본 결과를 적어 본다.
