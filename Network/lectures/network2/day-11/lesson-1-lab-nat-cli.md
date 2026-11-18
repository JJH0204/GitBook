# 부록 A. 공유기 속을 시스코 CLI로 열어보기

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-003-MP |
| 목적 | WRT300N이 GUI로 해준 일을 시스코 라우터에 CLI로 직접 설정해 NAT Overload(PAT)와 DHCP를 구성하고 변환표를 확인한다 |
| 적용 대상 | Cisco Packet Tracer, Cisco 2911 라우터 `GW`, 스위치, PC. CCNA 범위이며 시간이 남을 때 수행한다 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1-lab-router.md](lesson-1-lab-router.md) | LEC-N2-11-002-MP | 공유기 실습 (같은 토폴로지) |
| [lesson-1.md](lesson-1.md) | LEC-N2-11-001-DO | 1. 공유기 실습 (개념) |
| [lesson-4.md](lesson-4.md) | LEC-N2-11-007-DO | 4. ACL 표준 (같은 `access-list` 문법) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 수업 버전 | |
| 2 | 라우터 `GW` | 2911 | HomeRouter 대신 놓는다 |
| 3 | 스위치 | 2960 | PC를 스위치에 연결한다 |
| 4 | ISP 라우터, Internet 서버, PC | LEC-N2-11-002-MP와 같은 구성 | 주소도 같다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `ip nat inside`와 `ip nat outside`를 반대로 붙이면 변환이 일어나지 않는다. 안쪽(사설) 인터페이스가 `inside`, 바깥쪽(공인) 인터페이스가 `outside`다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | LEC-N2-11-002-MP의 ISP와 Internet 서버 구성을 만든다 | `ISP`에서 `show ip interface brief`가 `up/up` 2개 |
| 2 | HomeRouter 자리에 `GW` 라우터와 스위치를 놓고 PC를 스위치에 연결한다 | 링크 점이 초록이다 |

## 5. 절차

### A. GW 라우터 설정

1. (5-A-01) `GW`의 `CLI` 탭에서 다음 명령을 이어서 입력한다.

```
enable
configure terminal
no ip domain-lookup
hostname GW
interface g0/0
 ip address 192.168.0.1 255.255.255.0
 ip nat inside                                  # 안쪽 (사설)
 no shutdown
interface g0/1
 ip address 203.0.113.2 255.255.255.252
 ip nat outside                                 # 바깥쪽 (공인)
 no shutdown
exit
ip route 0.0.0.0 0.0.0.0 203.0.113.1            # 기본 경로 → ISP (5일차)
ip dhcp excluded-address 192.168.0.1 192.168.0.99
ip dhcp pool HOME                               # 8일차 DHCP 그대로
 network 192.168.0.0 255.255.255.0
 default-router 192.168.0.1
 dns-server 198.51.100.8
exit
access-list 1 permit 192.168.0.0 0.0.0.255      # 변환 대상 = 집 안 전체
ip nat inside source list 1 interface g0/1 overload   # PAT: 공인 IP 하나 + 포트
end
```

→ 결과: 오류 없이 프롬프트가 `GW#`로 돌아온다.

2. (5-A-02) PC를 `DHCP`로 설정한다. → 결과: `192.168.0.100`대 주소를 받는다.
3. (5-A-03) PC에서 `ping 198.51.100.8`을 입력한다. → 결과: 응답이 온다.

### B. 변환표 확인

1. (5-B-01) `GW`에서 `show ip nat translations`를 입력한다. → 결과: ping 직후 변환 줄이 생긴다.

```
Pro  Inside global       Inside local         Outside local   Outside global
icmp 203.0.113.2:1       192.168.0.100:1      198.51.100.8:1  198.51.100.8:1
tcp  203.0.113.2:1025    192.168.0.101:1025   198.51.100.8:80 198.51.100.8:80
```

| 용어 | 뜻 |
|---|---|
| Inside local | 안쪽 기기의 진짜(사설) 주소 |
| Inside global | 그 기기가 밖에 보이는(공인) 주소 |
| `overload` | PAT(공인 하나를 포트로 나눠 씀) |

### C. (참고) 포트포워딩 = Static NAT

1. (5-C-01) 안쪽 서버 `192.168.0.10`의 80번을 밖에 공개하려면 다음 명령을 입력한다.

```
ip nat inside source static tcp 192.168.0.10 80 interface g0/1 80
```

→ 결과: 밖에서 `203.0.113.2:80`으로 오는 통신이 `192.168.0.10:80`으로 전달된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | PC에서 `ping 198.51.100.8` | 응답이 온다 | 성공 |
| 2 | `show ip nat translations` | `Inside global`이 `203.0.113.2`다 | 변환 줄 존재 |

## 7. 복구

1. (7-01) 변환표를 비운다: `clear ip nat translation *` → 결과: `show ip nat translations`에 줄이 없다.
2. (7-02) 설정을 지우려면 새 파일에서 다시 만든다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md` 부록 A를 AMM 형식 MP로 분리. 인터넷 서버 주소를 문서용 `198.51.100.8`로 변경 |
