# STEP 10. DNS 와 DHCP 리눅스판

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-024-MP |
| 목적 | 리눅스가 DNS 서버를 찾는 방법, `dig` 조회, `/etc/hosts` 우선 적용, DHCP 임대 확인을 실습하고 VM을 종료한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(브릿지, DHCP), SSH 창 ①②, 인터넷 연결 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 대본을 정리한 것이며 VM에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-10.md](lesson-10.md) | LEC-N2-10-010-DO | 10. DNS와 DHCP 다시 보기 |
| [lesson-6-lab.md](lesson-6-lab.md) | LEC-N2-10-020-MP | STEP 6 (8080 웹서버) |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-N2-10-016-MP | STEP 2 (`nano` 사용) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | SSH 창 ①② | 같은 VM | ① 웹서버, ② 조회 |
| 2 | `dig` | `bind9-dnsutils` | STEP 6에서 설치 |
| 3 | `sudo` 자격 | `<password>` | `/etc/hosts` 수정에 필요 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `/etc/hosts`를 고치기 전에 반드시 백업한다(5-C-01). 오타가 있으면 이름 해석이 깨질 수 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: netplan 파일(`/etc/netplan/*.yaml`)은 읽기만 한다. 지금 바꾸면 SSH가 끊길 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 인터넷과 DNS가 된다 | `ping -c 2 google.com` |
| 2 | `dig`가 설치되어 있다 | `which dig` |

## 5. 절차

### A. 누구에게 묻나

1. (5-A-01) 창 ②에서 `cat /etc/resolv.conf | grep nameserver`를 입력한다. → 결과: `nameserver 127.0.0.53`. 내 안의 도우미다.
2. (5-A-02) 창 ②에서 `resolvectl status | grep "DNS Servers"`를 입력한다. → 결과: 도우미가 실제로 묻는 DNS 서버 주소가 나온다.

### B. `dig`로 레코드 조회

1. (5-B-01) 창 ②에서 `dig www.google.com`을 입력한다. → 결과: ANSWER, TTL, SERVER 줄이 나온다. SERVER 줄에 `#53 ... (UDP)`가 보인다.
2. (5-B-02) 창 ②에서 `dig www.google.com | grep "Query time"`을 입력한다. → 결과: 이전보다 Query time이 짧다(캐시).
3. (5-B-03) 창 ②에서 `dig +short www.naver.com`을 입력한다. → 결과: CNAME 별명을 거쳐 IP가 나온다.
4. (5-B-04) 창 ②에서 `dig +short MX gmail.com`을 입력한다. → 결과: 메일 서버 이름이 나온다(12일차).
5. (5-B-05) 창 ②에서 `dig +short -x 8.8.8.8`을 입력한다. → 결과: 역방향 조회로 이름이 나온다.

### C. `/etc/hosts`가 DNS보다 먼저

1. (5-C-01) 창 ②에서 `sudo cp /etc/hosts /etc/hosts.bak`을 입력한다. 설정을 고치기 전 백업이다. → 결과: 오류 없이 끝난다.
2. (5-C-02) 창 ②에서 `sudo nano /etc/hosts`를 입력한다. → 결과: 편집 화면이 열린다.
3. (5-C-03) 맨 아래에 다음 한 줄을 추가한다.

```
127.0.0.1   myserver.local
```

4. (5-C-04) Ctrl+O, Enter, Ctrl+X를 차례로 누른다. → 결과: 저장하고 나온다.
5. (5-C-05) 창 ①에서 `cd ~/www && python3 -m http.server 8080`을 입력한다. → 결과: 웹서버가 떠 있다.
6. (5-C-06) 창 ②에서 `ping -c 2 myserver.local`을 입력한다. → 결과: `127.0.0.1`로 간다.
7. (5-C-07) 창 ②에서 `curl myserver.local:8080`을 입력한다. → 결과: 웹서버가 이름으로 접속된다.
8. (5-C-08) 창 ②에서 `dig +short myserver.local`을 입력한다. → 결과: 답이 없다. `dig`는 `/etc/hosts`를 보지 않고 DNS에만 묻는다.

### D. DHCP 임대 확인

1. (5-D-01) 창 ②에서 `ip a show enp0s3 | grep -A1 "inet "`를 입력한다. → 결과: `dynamic`과 `valid_lft`(임대 남은 시간)가 보인다.
2. (5-D-02) 창 ②에서 `sudo cat /etc/netplan/*.yaml`을 입력한다. → 결과: `dhcp4: true`가 보인다.
3. (5-D-03) 창 ①에서 Ctrl + C를 눌러 웹서버를 끈다. 이제 VM 실습이 끝났다.

### E. 마무리 — VM 종료

1. (5-E-01) 창 ②에서 `sudo poweroff`를 입력한다. → 결과: VM이 종료되고 SSH 연결이 끊긴다. 정상이다.

{% hint style="info" %}
NOTE: VM은 지우지 않는다. 11, 12일차에도 이 VM을 계속 쓴다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `curl myserver.local:8080` | 웹 페이지가 나온다 | 이름으로 접속된다 |
| 2 | `ip a show enp0s3` | `valid_lft`가 보인다 | 임대 시간을 찾았다 |
| 3 | `dig`를 두 번 실행 | 두 번째 Query time이 짧다 | 캐시를 확인했다 |

## 7. 복구

1. (7-01) `/etc/hosts`를 원래대로 되돌린다: `sudo cp /etc/hosts.bak /etc/hosts`. → 결과: `myserver.local` 줄이 사라진다.
2. (7-02) 웹서버가 떠 있으면 Ctrl + C로 끈다.
3. (7-03) 확인한다: `ping -c 1 myserver.local`. → 결과: 이름을 찾지 못한다는 오류가 나온다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 STEP 10과 마무리를 AMM 형식 MP로 분리. 원본에 없던 `/etc/hosts` 복구 단계(7-01)를 추가 |
