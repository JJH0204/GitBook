# 1-1. DHCP 풀 만들기와 PC 주소 받기 실습

> 상위: [8일차 DHCP와 게이트웨이 이중화](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-08-006-MP |
| 목적 | 패킷트레이서에서 HQ-R1에 제외 주소와 DHCP 풀 네 개를 만들고, 직원 PC 다섯 대가 DHCP로 주소를 받게 한다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt` (7일차까지의 구성, 2911 라우터 HQ-R1). 격리된 가상 실습망이며 실제 장비와 연결하지 않는다 |
| 소요 시간 | 약 10분 (제외 주소와 풀 6분, PC와 현황 확인 4분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 패킷트레이서를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-SN-08-001-DO | DHCP: 주소를 나눠 주는 서버 |
| [commands.md](commands.md) | LEC-SN-08-005-REF | 실습 명령어 모음 (1~2번, 자주 막히는 곳 포함) |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-08-007-MP | 다음 실습. 지사 DHCP 릴레이 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Cisco Packet Tracer | `_실습/새봄상사.pkt` 파일 | 7일차까지의 본사·지사 구성이 들어 있다 |
| 2 | 라우터 | 2911 (HQ-R1) | DHCP 서버가 된다 |
| 3 | PC | Sales-PC1, Sales-PC2, Sales-PC3, HR-PC1, Dev-PC1 | DHCP로 바꾼다 |
| 4 | 고정 주소 장비 | Server1, Admin-PC | 바꾸지 않는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 제외 주소는 풀 안이 아니라 전역 설정(`configure terminal` 바로 아래)에 넣는다. 제외 주소를 빠뜨리면 DHCP가 게이트웨이와 장비의 고정 주소를 다른 PC에 빌려줘 주소가 겹친다.
{% endhint %}

{% hint style="info" %}
NOTE: 서버 VLAN(40)과 장비 관리 VLAN(99)에는 풀을 만들지 않는다. 두 VLAN의 장비는 고정 주소다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시는 IOS 15 형식이다. 패킷트레이서 버전에 따라 줄 구성이 조금 다를 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 오늘의 작업 계획서 1~5번 칸을 커밋했다 | `git log`에 8일차 작업 계획서 커밋이 있다 |
| 2 | `_실습/새봄상사.pkt`를 연다 | 본사, 지사 장비와 서버가 보인다 |
| 3 | HQ-R1의 서브인터페이스 주소가 3일차 값(.1, .33, .65, .97)이다 | `show ip interface brief` |

## 5. 절차

### A. 제외 주소와 풀

1. (5-A-01) HQ-R1 CLI를 열고 전역 설정 모드로 들어간다: `enable`, `configure terminal`
2. (5-A-02) 제외 주소를 입력한다. → 결과: 오류 없이 프롬프트가 돌아온다.

```
ip dhcp excluded-address 192.168.10.1 192.168.10.9
ip dhcp excluded-address 192.168.10.21 192.168.10.30
ip dhcp excluded-address 192.168.10.33 192.168.10.41
ip dhcp excluded-address 192.168.10.53 192.168.10.62
ip dhcp excluded-address 192.168.10.65 192.168.10.73
ip dhcp excluded-address 192.168.10.85 192.168.10.94
ip dhcp excluded-address 192.168.20.1 192.168.20.9
ip dhcp excluded-address 192.168.20.21 192.168.20.30
```

3. (5-A-03) 풀 네 개를 만든다. → 결과: 프롬프트가 `HQ-R1#`로 돌아온다.

```
ip dhcp pool SALES
 network 192.168.10.0 255.255.255.224
 default-router 192.168.10.1
ip dhcp pool HR
 network 192.168.10.32 255.255.255.224
 default-router 192.168.10.33
ip dhcp pool DEV
 network 192.168.10.64 255.255.255.224
 default-router 192.168.10.65
ip dhcp pool BR-SALES
 network 192.168.20.0 255.255.255.224
 default-router 192.168.20.1
 end
```

4. (5-A-04) 풀 설정을 확인한다: `show running-config | include dhcp` → 결과: 제외 주소 여덟 줄과 풀 이름 네 개가 보인다.

### B. PC를 DHCP로 바꾸기

1. (5-B-01) Sales-PC1의 Desktop에서 IP Configuration을 연다.
2. (5-B-02) `DHCP`를 고른다. → 결과: "DHCP request successful"이 뜨고 IP 주소, 서브넷 마스크, 기본 게이트웨이 칸이 채워진다.
3. (5-B-03) Sales-PC2, Sales-PC3, HR-PC1, Dev-PC1에도 같은 방법을 적용한다. Server1과 Admin-PC는 고정 주소 그대로 둔다.
4. (5-B-04) 받은 주소를 아래 표와 비교한다.

| PC | 받는 주소 | 게이트웨이 |
|---|---|---|
| Sales-PC1~3 | 192.168.10.10부터 받는 순서대로 | 192.168.10.1 |
| HR-PC1 | 192.168.10.42 | 192.168.10.33 |
| Dev-PC1 | 192.168.10.74 | 192.168.10.65 |

### C. 빌려준 현황 확인

1. (5-C-01) HQ-R1에서 `show ip dhcp binding`을 입력한다. → 결과: 주소 다섯 개와 각 PC의 MAC 주소가 보인다.
2. (5-C-02) Sales-PC1에서 `ping 192.168.10.98`을 입력한다. → 결과: Reply가 온다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Sales-PC1~3, HR-PC1, Dev-PC1의 IP Configuration | "DHCP request successful" | 다섯 대 모두 성공 |
| 2 | HQ-R1에서 `show ip dhcp binding` | 빌려준 주소 목록 | 다섯 줄 |
| 3 | Sales-PC1에서 `ping 192.168.10.98` | Reply | 응답 수신 |
| 4 | Server1, Admin-PC의 주소 | 고정 주소 그대로 | 바뀌지 않음 |

## 7. 복구

1. (7-01) PC가 169.254 주소를 받았으면 IP Configuration에서 `Static`으로 바꿨다가 `DHCP`로 다시 바꾼다.
2. (7-02) 풀을 잘못 만들었으면 `no ip dhcp pool <풀 이름>`으로 지우고 다시 만든다.
3. (7-03) 제외 주소를 잘못 넣었으면 같은 줄 앞에 `no`를 붙여 지운다.
4. (7-04) 실습을 처음 상태로 돌리려면 `_실습/새봄상사.pkt`를 저장하지 않고 닫고 다시 연다. 본사 주소표는 3일차 대본 7번에 있다.
5. (7-05) 다음 실습(LEC-SN-08-007-MP)으로 넘어가기 전에 `copy running-config startup-config`로 HQ-R1을 저장한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1~2번을 AMM 형식 MP로 분리. 번호(1~2)는 다른 문서의 참조 때문에 `commands.md`에 유지 |
