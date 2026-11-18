# 공유기 실습 — Packet Tracer로 집 네트워크 만들기

> 상위: [11일차 · 서버 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-002-MP |
| 목적 | Packet Tracer에서 WRT300N 공유기, ISP 라우터, 인터넷 서버를 유선으로 구성하고, PC가 DHCP로 사설 IP를 받아 인터넷에 나가는 것과 NAT가 출발지 IP를 바꾸는 구간을 확인한다 |
| 적용 대상 | Cisco Packet Tracer, WRT300N, Cisco 2911 라우터, Server, PC 2대 |
| 소요 시간 | 약 45분(STEP 1 30분, STEP 2 15분. 2-3은 선택) |
| 확인 상태 | 미검증 (원본 강의 노트의 명령 대본을 정리한 것이며 Packet Tracer에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-11-001-DO | 1. 공유기 실습 (개념) |
| [lesson-1-troubleshooting.md](lesson-1-troubleshooting.md) | LEC-N2-11-004-TS | 공유기 실습 문제 해결 |
| [commands.md](commands.md) | LEC-N2-11-018-REF | 0. 11일차 실습 명령어 |
| [lesson-1-lab-nat-cli.md](lesson-1-lab-nat-cli.md) | LEC-N2-11-003-MP | 부록 A. 공유기 속을 시스코 CLI로 열어보기 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer | 수업 버전 | WRT300N GUI는 버전마다 조금 다르다 |
| 2 | 공유기 | `Wireless Devices` > `WRT300N`, 이름 `HomeRouter` | 무선은 쓰지 않는다 |
| 3 | ISP 라우터 | `Routers` > `2911`, 이름 `ISP` | |
| 4 | 인터넷 서버 | `End Devices` > `Server`, 이름 `Internet` | |
| 5 | PC 2대 | `PC0`, `PC1` | |
| 6 | HomeServer (선택) | `Server` | 2-3에서 사용 |
| 7 | 새 `.pkt` 파일 | `11일차_공유기.pkt` | 앞 회차 파일을 고쳐 쓰지 않는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `Save Settings`를 화면마다 누른다. 누르지 않으면 설정이 저장되지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: WRT300N을 쓰지만 무선은 쓰지 않는다. `Wireless` 탭은 건드리지 않는다. Laptop과 Smartphone도 놓지 않는다. LAN 포트에 유선으로만 연결한다.
{% endhint %}

{% hint style="info" %}
NOTE: ISP에는 `192.168.0.0`으로 가는 경로가 없다. 일부러 그렇게 둔다. 인터넷은 사설 IP를 모른다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 새 Packet Tracer 파일을 연다 | 빈 작업 영역이 보인다 |
| 2 | 공유기 GUI 메뉴 이름을 수업 전에 리허설한다 | `Static DNS`, `Single Port Forwarding` 위치를 안다 |

## 5. 절차

### A. 장비 놓기와 연결 (마우스 조작)

1. (5-A-01) 위 장비 표대로 장비를 놓고 이름을 붙인다. → 결과: 5대(선택 시 6대)가 작업 영역에 놓인다.
2. (5-A-02) 모든 선을 Copper Straight-Through로 연결한다.
   - `HomeRouter` `Internet` 포트 ↔ `ISP` `G0/0`
   - `ISP` `G0/1` ↔ `Internet` `Fa0`
   - `PC0` `Fa0` ↔ `HomeRouter` `Ethernet 1`
   - `PC1` `Fa0` ↔ `HomeRouter` `Ethernet 2`
   → 결과: 링크 점이 초록이 된다.

### B. ISP 라우터 설정

1. (5-B-01) `ISP`의 `CLI` 탭에서 다음 명령을 이어서 입력한다.

```
enable
configure terminal
no ip domain-lookup
hostname ISP
interface g0/0
 ip address 203.0.113.1 255.255.255.252     # 우리 집 쪽 (공인)
 no shutdown
interface g0/1
 ip address 198.51.100.1 255.255.255.0      # 인터넷 서버 쪽
 no shutdown
end
```

→ 결과: 두 인터페이스가 `up`이 된다. `show ip interface brief`로 확인한다.

### C. Internet 서버 설정

1. (5-C-01) `Desktop` > `IP Configuration`에 IP `198.51.100.8`, 마스크 `255.255.255.0`, GW `198.51.100.1`, DNS `198.51.100.8`을 입력한다. → 결과: 값이 저장된다.
2. (5-C-02) `Services` > `DNS`에서 `On`, Name `www.student.test`, Type `A`, Address `198.51.100.8`을 입력하고 `Add`를 누른다. → 결과: 표에 레코드가 추가된다.
3. (5-C-03) `Services` > `HTTP`가 `On`인지 확인한다. → 결과: 기본값이 `On`이다. `index.html` 첫 줄을 `인터넷 웹서버입니다`로 고쳐 두면 확인이 쉽다.

### D. HomeRouter 설정 (`GUI` 탭, 공유기 관리자 페이지)

1. (5-D-01) `Setup` > `Basic Setup`에서 다음 값을 입력한다.

| 칸 | 값 |
|---|---|
| Internet Setup | `Static IP` |
| Internet IP Address | `203.0.113.2` |
| Subnet Mask | `255.255.255.252` |
| Default Gateway | `203.0.113.1` |
| DNS 1 | `198.51.100.8` |
| Router IP (Network Setup) | `192.168.0.1` / `255.255.255.0` (기본값) |
| DHCP Server | `Enabled`, Start `192.168.0.100`, Max `50` (기본값) |
| Static DNS 1 (DHCP 설정 칸) | `198.51.100.8` |

2. (5-D-02) 맨 아래 `Save Settings`를 누른다. → 결과: 설정이 저장된다.

### E. PC 설정과 확인

1. (5-E-01) `PC0`, `PC1` 각각 `Desktop` > `IP Configuration`에서 `DHCP`를 선택한다. → 결과: `192.168.0.100`, `192.168.0.101`, GW `192.168.0.1`, DNS `198.51.100.8`이 보인다.
2. (5-E-02) 각 PC의 `Command Prompt`에서 `ipconfig`를 입력한다. → 결과: 사설 `192.168.0.x` 주소가 보인다.
3. (5-E-03) `ping 198.51.100.8`을 입력한다. → 결과: 응답이 온다. ISP에 `192.168.0.0` 경로가 없는데도 된다. 원인은 NAT다.
4. (5-E-04) `ping www.student.test`를 입력한다. → 결과: 응답이 온다(DNS).
5. (5-E-05) `Web Browser`에서 `http://www.student.test`를 연다. → 결과: 인터넷 웹서버 페이지가 보인다.

### F. Simulation 모드: 주소가 바뀌는 순간 (STEP 2)

1. (5-F-01) 오른쪽 아래 `Simulation`을 선택하고 `Edit Filters`에서 `ICMP`만 체크한다. → 결과: ICMP만 표시된다.
2. (5-F-02) `PC0`에서 `ping 198.51.100.8`을 입력하거나 `Add Simple PDU`로 PC0 → Internet 패킷을 만든다. → 결과: 패킷이 생성된다.
3. (5-F-03) `Capture/Forward`로 한 칸씩 보내며 봉투를 클릭해 출발지 IP를 기록한다.
   - PC0 → HomeRouter 구간: Src IP `192.168.0.100`
   - HomeRouter → ISP 구간: Src IP `203.0.113.2` (바뀌었다 = NAT)
   - 돌아오는 응답: Dst `203.0.113.2`, 공유기 통과 후 Dst `192.168.0.100` (되돌리기)
4. (5-F-04) (선택) `PC0`과 `PC1`에서 동시에 보낸다. → 결과: 공인 IP는 하나인데 포트로 구분된다(PAT).

### G. Internet 서버에서 밖에서 먼저 보내기

1. (5-G-01) `Internet` 서버의 `Command Prompt`에서 `ping 192.168.0.100`을 입력한다. → 결과: 실패한다(인터넷은 사설 주소를 모른다).
2. (5-G-02) `ping 203.0.113.2`를 입력한다. → 결과: 공유기 자신은 응답할 수 있다. 안쪽 PC에게 먼저 말을 걸 방법은 없다.

### H. (선택) 포트포워딩: 집 안 서버를 밖에 공개

1. (5-H-01) `Server`를 하나 더 놓고 이름을 `HomeServer`로 한 뒤 `HomeRouter`의 `Ethernet 3`(비어 있는 LAN 포트)에 연결한다. IP는 고정 `192.168.0.10`/`255.255.255.0`, GW `192.168.0.1`로 입력한다. → 결과: 링크 점이 초록이다.
2. (5-H-02) HomeRouter `GUI` > `Applications & Gaming` > `Single Port Forwarding`(버전에 따라 `Port Range Forwarding`)을 연다.
3. (5-H-03) External Port `80`, Internal Port `80`, Protocol `TCP`, To IP `192.168.0.10`을 입력하고 `Enabled`를 체크한 뒤 `Save`를 누른다. → 결과: 규칙이 저장된다.
4. (5-H-04) `Internet` 서버의 `Web Browser`에서 `http://203.0.113.2`를 연다. → 결과: HomeServer의 페이지가 보인다.

10일차 VirtualBox에서 8080→8080으로 한 것과 같은 원리다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | PC0, PC1에서 `ipconfig` | 두 PC 모두 `192.168.0.x`를 받는다 | 두 대 모두 해당 |
| 2 | `http://www.student.test` | 인터넷 웹서버 페이지가 열린다 | 페이지 표시 |
| 3 | Simulation에서 출발지 IP 비교 | 공유기 통과 후 Src IP가 `203.0.113.2`로 바뀐다 | 바뀐 구간을 찾았다 |
| 4 | Internet 서버에서 `ping 192.168.0.100` | 실패한다 | 응답 없음 |

## 7. 복구

1. (7-01) 실습 파일은 새 파일이므로 저장하지 않고 닫으면 원상태다.
2. (7-02) 포트포워딩 규칙을 지우려면 `Enabled`를 해제하고 `Save`를 누른다.
3. (7-03) 설정이 꼬이면 새 파일에서 처음부터 다시 만든다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-1.md`의 실습 절과 `commands.md`의 STEP 1, 2를 AMM 형식 MP로 분리. 인터넷 서버 주소를 `8.8.8.x`에서 문서용 `198.51.100.x`로 변경 |
