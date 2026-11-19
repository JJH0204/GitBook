# [생성형 AI] nftables 개요

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-007-DO |
| 유형 | D&O (개념) |
| 목적 | nftables의 구조(테이블, 체인, 규칙)와 iptables·firewalld와의 관계를 설명한다 |
| 확인 상태 | 미검증 (이 환경에 `nft`가 설치되어 있지 않아 실행하지 못했다. 공식 문서의 알려진 동작을 정리한 것이다) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

nftables는 리눅스 커널의 패킷 필터링 프레임워크이며 iptables의 후속이다. 규칙을 하나의 도구(`nft`)와 하나의 문법으로 관리한다. 최근 배포판(RHEL 계열 9, Debian 계열)에서 firewalld와 iptables 명령은 내부적으로 nftables를 쓰는 경우가 많다.

## 2. 구성 요소

| 번호 | 구성 요소 | 역할 |
|---|---|---|
| 1 | 테이블(table) | 체인을 담는 최상위 단위. 주소 족(family)을 가진다 |
| 2 | 체인(chain) | 규칙 목록. 커널 훅(hook)에 붙는 기본 체인(`input`, `forward`, `output` 등)과 직접 만드는 일반 체인이 있다 |
| 3 | 규칙(rule) | 조건(주소, 포트, 프로토콜)과 동작(`accept`, `drop`, `reject`)의 쌍 |
| 4 | 집합(set) | 주소나 포트 묶음. 규칙에서 한 번에 비교한다 |

주소 족: `ip`(IPv4), `ip6`(IPv6), `inet`(IPv4와 IPv6 함께), `arp`, `bridge`, `netdev`.

## 3. 동작 원리

1. 패킷이 들어오면 커널은 훅 지점(예: `input`)에 붙은 체인을 우선순위(priority) 순서로 검사한다.
2. 체인의 규칙을 위에서 아래로 비교한다. 처음 맞는 규칙의 동작이 적용된다(`accept`, `drop` 등).
3. 어느 규칙에도 맞지 않으면 체인의 기본 정책(policy)이 적용된다. 기본 정책은 `accept` 또는 `drop`이다.

현재 규칙 조회(읽기 전용, root 필요):

```
nft list ruleset
```

규칙의 모양(개념 설명용 예. 실제 적용 전에 반드시 접속 경로를 확보한다):

```
table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;
    ct state established,related accept
    iif "lo" accept
    tcp dport 22 accept
  }
}
```

위 예는 들어오는 패킷의 기본 정책을 `drop`으로 하고, 이미 맺어진 연결과 루프백, TCP 22번 포트만 허용한다.

| 비교 | iptables | nftables |
|---|---|---|
| 도구 | `iptables`, `ip6tables`, `arptables`, `ebtables` 따로 | `nft` 하나 |
| 문법 | 옵션 나열(`-A INPUT -p tcp --dport 22 -j ACCEPT`) | 구조화된 블록 문법 |
| 여러 값 비교 | 규칙을 여러 개 만들거나 ipset 사용 | 집합(set)으로 한 규칙에서 비교 |
| 관계 | 새 배포판은 `iptables-nft`가 nftables 위에서 동작할 수 있다 | 커널의 현행 프레임워크 |

{% hint style="danger" %}
WARNING: 기본 정책을 `drop`으로 둔 채 SSH 허용 규칙 없이 적용하면 원격 접속이 끊긴다. 콘솔 접근을 확보한 뒤 변경한다. 같은 호스트에서 firewalld, iptables, nftables 규칙을 서로 따로 관리하면 충돌한다. 관리 도구를 하나로 정한다(LNX-SEC-001-MP, LNX-SEC-002-MP).
{% endhint %}

{% hint style="info" %}
NOTE: 규칙 파일은 배포판마다 위치가 다르다(RHEL 계열 `/etc/sysconfig/nftables.conf`, Debian 계열 `/etc/nftables.conf`). 서비스 이름은 `nftables`다. 위치와 활성화 방법은 사용하는 배포판 문서로 확인한다.
{% endhint %}

## 4. 관련 문서

| Task ID | 문서 | 용도 |
|---|---|---|
| LNX-SEC-001-MP | [firewalld 방화벽 관리](firewalld.md) | firewalld로 규칙을 관리한다 |
| LNX-SEC-002-MP | [iptables 방화벽 규칙](iptables.md) | iptables 규칙을 비교한다 |

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| hook | 커널에서 패킷이 지나는 검사 지점 |
| policy | 어느 규칙에도 맞지 않을 때 적용하는 기본 동작 |
| ct state | 연결 추적(conntrack)이 판단한 패킷의 연결 상태 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 테이블, 체인, 규칙의 관계를 내 말로 설명해 보자
- [ ] 기본 정책을 `drop`으로 하는 것과 `accept`로 하는 것의 차이를 적어 보자
- [ ] firewalld, iptables, nftables 중 내 환경에서 쓰는 도구와 그 이유를 적어 보자
