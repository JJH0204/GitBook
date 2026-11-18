# 3-1. 정적 NAT 시연과 포트 포워딩 실습

> 상위: [9일차 NAT와 서비스 공개](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-09-007-MP |
| 목적 | 강사의 패킷트레이서에서 1:1 정적 NAT가 서버의 모든 문(FTP)을 여는 것을 확인하고, 포트 포워딩으로 쇼핑몰의 80, 443번만 열어 밖에서 확인한다 |
| 적용 대상 | 허가받은 격리 실습 환경. Cisco Packet Tracer의 `_실습/새봄상사.pkt` 안의 가상 장비만 대상이다. 구역 A는 강사 시연이고, 구역 B~C는 학생과 함께 한다 |
| 소요 시간 | 약 33분 (대본 6~8번: 10분, 10분, 13분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이번 재작성에서 다시 실행하지 않았다. 패킷트레이서의 FTP 기본 설정과 `static tcp` 지원 여부는 수업 전에 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-SN-09-003-DO | 서비스 공개: 고객을 쇼핑몰로 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-09-006-MP | 선행 실습. 인터넷 연결과 PAT 설정 |
| [commands.md](commands.md) | LEC-SN-09-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |
| [lesson-4.md](lesson-4.md) | LEC-SN-09-004-DO | 다음 노트. 공개와 보안 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Packet Tracer 파일 | `_실습/새봄상사.pkt` (2-1 실습을 마친 상태) | |
| 2 | HQ-R1, ISP-R1 | 2911 라우터 | ISP-R1에 203.0.113.8/29 경로가 있어야 한다 |
| 3 | Server1 | 쇼핑몰 서버 192.168.10.98 | Services 탭에서 HTTP와 FTP를 켠다 |
| 4 | NET-PC | 인터넷 쪽 PC 198.51.100.10 | 웹 브라우저와 Command Prompt를 쓴다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템에 이 절차를 수행하는 것은 불법이다. 격리된 실습망에서만 수행한다. 구역 A의 FTP 로그인은 강사의 패킷트레이서 안(시뮬레이터의 가상 서버)에서만 하고, 실제 서버나 실제 회사 망에 하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 구역 A의 1:1 정적 NAT 줄은 서버의 모든 포트를 연다. 시연이 끝나면 구역 B의 첫 단계로 반드시 지운다. 남아 있으면 포트 포워딩이 의미가 없어진다.
{% endhint %}

{% hint style="info" %}
NOTE: 구역 A는 강사 시연이다. 학생은 6번을 하지 않았으니 구역 B의 둘째 단계부터 입력한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 2-1 실습(LEC-SN-09-006-MP)이 끝나 있다 | NET-PC에서 Sales-PC1의 변환 줄이 `show ip nat translations`에 생긴다 |
| 2 | ISP-R1에 서버용 공인 주소 묶음 경로가 있다 | ISP-R1 `show ip route static`에 `203.0.113.8/29 via 203.0.113.2`가 있다 |
| 3 | Server1의 Services 탭에서 HTTP와 FTP가 켜져 있다 | 두 서비스가 On이다. FTP가 꺼져 있으면 강사가 켠다 |

## 5. 절차

### A. 1:1 정적 NAT와 FTP (강사만)

1. (5-A-01) 강사 화면의 HQ-R1에서 1:1 정적 NAT 줄을 입력한다.

```
HQ-R1(config)#ip nat inside source static 192.168.10.98 203.0.113.10
```

→ 결과: 오류 없이 끝난다.

2. (5-A-02) NET-PC의 Web Browser에서 `http://203.0.113.10`을 연다. → 결과: 쇼핑몰 화면이 나온다.
3. (5-A-03) NET-PC의 Command Prompt에서 `ftp 203.0.113.10`을 입력한다. → 결과: `Connected to 203.0.113.10`, `220- Welcome to PT Ftp server`가 나온다.
4. (5-A-04) Username에 `cisco`를 입력한다. → 결과: `331- Username ok, need password`가 나온다.
5. (5-A-05) Password에 서버의 기본 계정 비밀번호(`<password>`)를 입력한다. → 결과: `230- Logged in`이 나온다. 쇼핑몰만 열려고 했는데 서버의 파일 창고까지 인터넷에 열린 것이다.
6. (5-A-06) `quit`을 입력해 나온다.

### B. 포트 포워딩

1. (5-B-01) 강사는 구역 A의 1:1 줄을 지운다. 학생은 이 단계를 건너뛴다.

```
configure terminal
no ip nat inside source static 192.168.10.98 203.0.113.10
```

2. (5-B-02) HQ-R1에서 쇼핑몰의 80, 443번만 포워딩한다.

```
ip nat inside source static tcp 192.168.10.98 80 203.0.113.10 80
ip nat inside source static tcp 192.168.10.98 443 203.0.113.10 443
```

3. (5-B-03) HQ-R1에 받은 공인 주소 묶음의 null 경로를 넣고 `end`를 입력한다.

```
ip route 203.0.113.8 255.255.255.248 null0
 end
```

→ 결과: 오류 없이 끝난다. null 경로가 없으면 포워딩하지 않은 주소와 포트로 온 패킷이 HQ-R1과 ISP-R1 사이를 TTL이 다할 때까지 오간다.

4. (5-B-04) `show running-config | include nat`을 입력한다. → 결과: `static tcp` 두 줄만 보이고 1:1 정적 줄은 없다.

### C. 밖에서 확인

1. (5-C-01) NET-PC의 Web Browser에서 `http://203.0.113.10`을 연다. → 결과: 쇼핑몰 화면이 나온다.
2. (5-C-02) NET-PC의 Command Prompt에서 `ftp 203.0.113.10`을 입력한다. → 결과: 연결되지 않는다.
3. (5-C-03) NET-PC에서 `ping 203.0.113.10`을 입력한다. → 결과: Request timed out이 나온다. ICMP는 적어 두지 않았다. 쇼핑몰이 죽은 것이 아니므로 서비스 확인은 그 서비스의 포트로 한다.
4. (5-C-04) HQ-R1에서 `show ip nat translations`를 입력한다. → 결과: 정적 줄 두 개가 보인다.

```
HQ-R1#show ip nat translations
Pro  Inside global      Inside local       Outside local      Outside global
tcp  203.0.113.10:80    192.168.10.98:80   ---                ---
tcp  203.0.113.10:443   192.168.10.98:443  ---                ---
```

5. (5-C-05) HQ-R1에서 `copy running-config startup-config`를 입력해 저장한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | NET-PC 웹 브라우저 `http://203.0.113.10` | 쇼핑몰 화면 | 화면이 열린다 |
| 2 | NET-PC `ftp 203.0.113.10` | 연결되지 않음 | 로그인 프롬프트가 나오지 않는다 |
| 3 | NET-PC `ping 203.0.113.10` | Request timed out | 응답이 없다 |
| 4 | HQ-R1 `show ip nat translations` | 정적 줄 두 개 | `203.0.113.10:80`, `203.0.113.10:443` |
| 5 | HQ-R1 `show running-config \| include nat` | 1:1 정적 줄이 없다 | `static 192.168.10.98 203.0.113.10` 줄이 없다 |

## 7. 탐지·방어

확인 상태: 미검증 (일반 지식으로 짧게 정리했다).

| 항목 | 내용 |
|---|---|
| 원인 | 1:1 정적 NAT는 포트를 고르지 않고 주소를 통째로 넘긴다. 서버에 켜져 있는 모든 서비스(FTP, 관리 화면, 원격 접속, 데이터베이스 포트)가 밖에서 보이고, 기본 계정이 남아 있으면 그대로 로그인된다 |
| 완화 | 포트 포워딩으로 필요한 포트만 연다. 서버의 쓰지 않는 서비스를 끄고 기본 계정을 지우거나 비밀번호를 바꾼다. 공개한 서비스 앞에 방화벽(13, 14일차)을 두고 필요한 포트만 통과시킨다. 열어 둔 문을 `02_설계/공개_서비스.md`로 관리한다 |
| 로그에서 보이는 흔적 | 서버의 FTP 로그에 밖의 주소(198.51.100.x)로부터의 로그인 기록이 남는다. HQ-R1의 `show ip nat translations`에 밖의 주소가 채워진 줄이 생긴다. 인터넷에 열린 서버는 쉬지 않고 이런 문을 두드리는 스캔을 받으므로, 14일차 방화벽 로그에서 다시 확인한다 |

## 8. 복구

1. (8-01) 1:1 줄이 남아 있으면 지운다: `no ip nat inside source static 192.168.10.98 203.0.113.10`
2. (8-02) 포트 포워딩을 걷어 내려면 두 줄을 지운다: `no ip nat inside source static tcp 192.168.10.98 80 203.0.113.10 80`, `no ip nat inside source static tcp 192.168.10.98 443 203.0.113.10 443`
3. (8-03) 공인 주소 null 경로를 걷어 내려면 `no ip route 203.0.113.8 255.255.255.248 null0`을 입력한다.
4. (8-04) NAT 전체가 꼬이면 지우는 순서를 지킨다: `ip nat inside source` 줄, 포트의 `ip nat inside`/`outside`, ACL 순이다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 6~8번과 `lesson-3.md`의 설정 안내를 AMM 형식 MP로 분리. 격리 환경 WARNING과 탐지·방어 절 추가. FTP 기본 계정 비밀번호를 `<password>`로 교체 |
