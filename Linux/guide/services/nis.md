# 네트워크 정보 서비스 (NIS)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SVC-001-DO |
| 유형 | D&O (개념·원리) |
| 목적 | NIS의 구성, 도메인, 맵, 사용 사례, 보안 한계를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

NIS(Network Information Service)는 네트워크의 여러 시스템이 같은 구성 파일을 쓰도록 유지하는 분산 데이터베이스 서비스다. Sun Microsystems가 UNIX 기반 시스템을 중앙에서 관리하려고 개발했다.

## 2. 구성 요소

| 구성 요소 | 역할 |
|---|---|
| 마스터 서버 | 주요 데이터를 저장하고 관리한다 |
| 슬레이브 서버 | 마스터 서버의 백업이며 클라이언트 요청을 처리한다 |
| 클라이언트 | 서버에 사용자, 호스트 정보를 조회한다 |
| NIS 도메인 | 서버와 클라이언트를 묶는 관리 단위. 계층 구조가 없고 네트워크를 하나의 도메인으로 묶을 수 있다 |
| NIS 맵 | 정보를 저장하는 키-값 데이터베이스 |

### 주요 맵

| 맵 | 내용 |
|---|---|
| `passwd.byname` | 사용자 이름을 키로 암호 정보를 저장한다 |
| `hosts.byname` | 호스트 이름을 키로 IP 주소를 저장한다 |
| 그 밖의 맵 | `passwd`, `group`, `hosts`, `networks`, `protocols`, `services` 등 |

## 3. 동작 원리

1. 관리자가 마스터 서버의 맵을 수정한다.
2. 마스터 서버가 변경된 맵을 슬레이브 서버에 전달한다.
3. 클라이언트가 서버(마스터 또는 슬레이브)에 맵을 조회한다.
4. 서버가 응답하면 클라이언트는 그 정보를 로컬 파일 대신 쓴다.

### 사용 사례

| 사례 | 효과 |
|---|---|
| 중앙 관리 | 모든 사용자와 호스트 정보를 중앙에서 관리한다. 사용자나 시스템을 추가할 때 각 시스템에서 개별 설정을 하지 않는다 |
| 네트워크 관리 | IP 주소, 네트워크 마스크, 호스트 이름 등의 정보를 일관되게 유지한다 |

{% hint style="warning" %}
CAUTION: NIS는 암호화되지 않은 통신을 사용한다. 민감한 데이터가 도청될 위험이 있다. 이 때문에 더 강력한 보안 기능을 제공하는 NIS+나 LDAP로 대체되는 경우가 많다.
{% endhint %}

## 4. 약어·용어

| 용어 | 풀이 |
|---|---|
| NIS | Network Information Service |
| NIS+ | NIS의 보안 강화 후속 버전 |
| LDAP | Lightweight Directory Access Protocol. 디렉터리 서비스 프로토콜 |
| 맵(map) | NIS가 정보를 저장하는 데이터베이스 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [service-management.md](service-management.md) | LNX-SVC-002-MP | 불필요한 서비스 관리 및 비활성화 |
| [IBM: NIS 개요](https://www.ibm.com/docs/en/aix/7.1?topic=services-network-information-service-nis-overview) | | 외부 자료 |
| [Oracle: NIS 개요](https://docs.oracle.com/cd/E36784_01/html/E36871/nis-overview.html) | | 외부 자료 |
| [Oracle 문서](https://docs.oracle.com/cd/E19253-01/816-4556/anis1-25461/index.html) | | 외부 자료 |
| [Wikipedia: Network Information Service](https://en.wikipedia.org/wiki/Network_Information_Service) | | 외부 자료 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] NIS 도메인과 DNS 도메인은 어떻게 다를까?
- [ ] NIS 환경에서 새 사용자를 추가하면 어떤 서버의 어떤 데이터가 바뀔까?
- [ ] NIS의 통신이 암호화되지 않으면 어떤 공격이 가능한지 설명해 보자.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본을 D&O 형식으로 재작성. 외부 링크를 참조 절로 모았다. 동작 원리 4단계는 원본의 서버 역할 설명을 순서로 정리한 것이다 |
