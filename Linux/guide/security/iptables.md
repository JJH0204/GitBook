# iptables 방화벽 규칙

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SEC-002-MP |
| 목적 | firewalld를 iptables로 전환하고 규칙을 추가, 삭제, 저장한다 |
| 적용 대상 | RHEL 계열 9, root 또는 sudo 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: RHEL 계열은 기본적으로 firewalld로 접근을 제어한다. firewalld와 iptables는 둘 중 하나만 활성화한다. firewalld를 유지하려면 LNX-SEC-001-MP를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [firewalld.md](firewalld.md) | LNX-SEC-001-MP | firewalld 방화벽 관리 |
| [iptables 기본 명령어와 옵션 (tistory)](https://linuxstory1.tistory.com/entry/iptables-%EA%B8%B0%EB%B3%B8-%EB%AA%85%EB%A0%B9%EC%96%B4-%EB%B0%8F-%EC%98%B5%EC%85%98-%EB%AA%85%EB%A0%B9%EC%96%B4) | | 외부 자료 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 대상 서버 | RHEL 계열 9 | |
| 2 | 패키지 | `iptables-services`, `iptables-utils` | `dnf`로 설치한다 |
| 3 | 콘솔 접근 | 가상 머신 화면 또는 물리 콘솔 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: firewalld를 중지하면 기존 방화벽 정책이 모두 해제된다. iptables 규칙이 준비되기 전까지 서버가 보호되지 않는다. 구역 B는 콘솔에서 수행하고 SSH(22/tcp) 허용 규칙이 있는지 5-C-01에서 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: iptables 규칙은 위에서 아래로 순서대로 적용된다. `REJECT` 규칙 뒤에 추가한 규칙은 적용되지 않는다. 규칙 순서를 반드시 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | firewalld 설정을 백업한다 | `firewall-cmd --list-all-zones > <백업 파일 경로>`가 파일을 만든다 |
| 2 | 콘솔에 로그인할 수 있다 | 로그인 프롬프트가 보인다 |
| 3 | 현재 SSH 접속 IP를 확인한다 | `who`의 출력에 접속 IP가 보인다 |

## 5. 절차

### A. 설치

1. (5-A-01) 패키지를 설치한다: `dnf install -y iptables-services iptables-utils` → 결과: `Complete!`가 출력된다.
2. (5-A-02) 서비스를 시작한다: `systemctl start iptables`
3. (5-A-03) 부팅 시 자동 시작하게 한다: `systemctl enable iptables` → 결과: 오류 없이 끝난다.

### B. 기존 방화벽 서비스 비활성화

1. (5-B-01) firewalld를 중지한다: `systemctl stop firewalld`
2. (5-B-02) 부팅 시 자동 시작을 해제한다: `systemctl disable firewalld` → 결과: 오류 없이 끝난다.

### C. 규칙 확인

1. (5-C-01) 현재 규칙을 확인한다: `iptables -L` → 결과: `Chain INPUT`, `Chain FORWARD`, `Chain OUTPUT`이 출력된다. 기본 규칙에 `tcp dpt:ssh` 허용 줄이 있다.

기본 출력 예(요약)는 다음과 같다.

```sh
Chain INPUT (policy ACCEPT)
target     prot opt source      destination
ACCEPT     all  --  anywhere    anywhere     state RELATED,ESTABLISHED
ACCEPT     icmp --  anywhere    anywhere
ACCEPT     all  --  anywhere    anywhere
ACCEPT     tcp  --  anywhere    anywhere     state NEW tcp dpt:ssh
REJECT     all  --  anywhere    anywhere     reject-with icmp-host-prohibited
```

### D. 규칙 추가

{% hint style="danger" %}
WARNING: 관리자 접속 IP를 `DROP`하면 SSH 접속이 끊긴다. 소스 주소가 접속 IP와 겹치지 않는지 확인한다.
{% endhint %}

1. (5-D-01) 특정 출발지를 차단하는 규칙을 맨 위에 추가한다: `iptables -I INPUT 1 -s <IP 주소> -j DROP` → 결과: 오류 없이 끝난다. 출발지는 대역(`<네트워크 주소>/16` 형식)으로도 지정할 수 있다.
2. (5-D-02) 목적지도 지정할 때는 다음과 같이 입력한다: `iptables -I INPUT 1 -s <출발지 IP 주소> -d <목적지 IP 주소> -j DROP`
3. (5-D-03) 규칙이 들어갔는지 확인한다: `iptables -L INPUT --line-numbers` → 결과: `DROP` 줄이 `REJECT` 줄보다 위에 있다.
4. (5-D-04) 규칙을 파일에 저장한다: `service iptables save` → 결과: `/etc/sysconfig/iptables`에 규칙이 기록된다.

{% hint style="info" %}
NOTE: 프로토콜(`-p tcp`)도 지정할 수 있다. `-A`로 추가하면 규칙이 목록 맨 끝에 들어가 `REJECT` 뒤에서 적용되지 않는다(원본 예시도 `DROP`이 `REJECT` 뒤에 있다). 이 문서는 `-I INPUT 1`을 쓴다. 미검증이다.
{% endhint %}

### E. 규칙 삭제

1. (5-E-01) 줄 번호를 확인한다: `iptables -L INPUT --line-numbers`
2. (5-E-02) 번호로 삭제한다: `iptables -D INPUT <줄 번호>` → 결과: 해당 규칙이 목록에서 사라진다.
3. (5-E-03) 변경을 저장한다: `service iptables save`

규칙 파일 `/etc/sysconfig/iptables`를 직접 편집해 삭제한 뒤 `systemctl restart iptables`로 적용할 수도 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active iptables` | 실행 중이다 | `active` |
| 2 | `systemctl is-active firewalld` | 중지됐다 | `inactive` |
| 3 | 차단한 IP의 PC에서 접속 시도 | 접속되지 않는다 | 응답이 없다 |
| 4 | 다른 PC에서 `ssh <사용자명>@<IP 주소>` | 접속된다 | 로그인 프롬프트가 나온다 |

## 7. 복구

1. (7-01) 추가한 규칙을 삭제한다: 5-E-01~5-E-03을 수행한다.
2. (7-02) firewalld로 되돌린다: `systemctl stop iptables` 후 `systemctl disable iptables`, `systemctl enable --now firewalld`
3. (7-03) SSH 접속이 끊겼다면 콘솔에서 7-01 또는 7-02를 수행한다.

## 8. 참조: 설정 파일

| 경로 | 내용 |
|---|---|
| `/etc/sysconfig/iptables` | 방화벽 정책 파일 |
| `/etc/sysconfig/iptables-config` | 방화벽 환경 설정 파일 |

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본을 MP 형식으로 재작성. firewalld 중지 WARNING, 규칙 순서 CAUTION, 저장 단계, 복구를 추가했다. "추가 후 서비스 재시작" 안내를 "저장"으로 정정했다 |
