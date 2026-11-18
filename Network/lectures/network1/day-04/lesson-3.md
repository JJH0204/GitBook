# 3. Cisco CLI 기초와 실습

> 상위: [4일차 · 스위치와 라우터](README.md)
> 실습 중에는 이 노트 대신 [4일차 실습 명령어 대본](commands.md)을 연다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N1-04-003-DO |
| 유형 | D&O (개념) |
| 목적 | Cisco IOS CLI의 모드, 입력 요령, 설정 저장 구조, 기본 설정과 자주 쓰는 명령을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 장비에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 실습(Lab 10~12)과 막힘 표가 이 페이지에 함께 있었다. 한 파일 한 유형 원칙에 따라 실습은 Lab별 MP 문서로, 막힘 표는 TS 문서로 분리했다. 원본에 중복으로 붙어 있던 "C. 정적 라우팅" 절과 막힘 표는 분리한 문서에 이미 있어 삭제했다. 원본의 콘솔 비밀번호 예시 `cisco`는 `<password>`로 바꿨다.
{% endhint %}

## 그림 목록

| 프레임 | 내용 | 대응 절 |
|---|---|---|
| 1 | CLI 4가지 모드 | 1. 구성 요소 > Cisco IOS CLI 기본 모드 |
| 2 | Tab · ? · 축약 / 함정 3가지 | 2. 동작 원리 > 손이 편해지는 3가지, 초보자가 겪는 3가지 함정 |
| 3 | running vs startup — 저장 | 2. 동작 원리 > 설정 저장 |
| 4 | Lab 10 · 11 — 두 테이블 열어보기 | 3. 실습 문서 |
| 5 | Lab 12 — 정적 라우팅 | 3. 실습 문서 |

(그림 파일은 없다. 수업 발표용 드로잉의 프레임 번호만 기록한다.)

## 학습 목표

- Cisco IOS CLI의 기본 모드를 구분한다.
- Tab, `?`, 축약으로 명령을 빠르게 입력한다.
- 자주 쓰는 확인·설정 명령을 익히고 설정을 저장한다.
- 스위치 MAC 테이블과 라우터 라우팅 테이블을 직접 확인한다.
- 정적 경로를 설정해 두 네트워크를 잇는다.

## 이전 학습과의 연결

스위치의 MAC 테이블([1_스위치_동작원리](lesson-1.md))과 라우터의 라우팅 테이블([2_라우터_동작원리](lesson-2.md))을 명령어로 직접 들여다본다. 3일차 실습([4_패킷트레이서_실습](../day-03/lesson-4.md))의 연장이다.

## 1. 구성 요소

### Cisco IOS CLI 기본 모드

| 모드 | 프롬프트 | 들어가는 명령 | 할 수 있는 일 |
|---|---|---|---|
| 사용자 모드 | `Switch>` | (접속 시 기본) | 기본 확인만 |
| 특권 모드 | `Switch#` | `enable` | 모든 확인 명령 |
| 전역 설정 | `Switch(config)#` | `configure terminal` | 장비 설정 변경 |
| 인터페이스 설정 | `Switch(config-if)#` | `interface g0/0` | 특정 포트 설정 |

- 빠져나오기: `exit`(한 단계), `end` 또는 `Ctrl+Z`(설정 모드 전체 종료)

{% hint style="info" %}
NOTE: 프롬프트로 현재 위치를 알 수 있다. `>`는 구경만, `#`은 모든 확인, `(config)#`은 장비 전체 설정, `(config-if)#`은 이 포트 설정이다.
{% endhint %}

### 설정 파일 두 개

| 이름 | 위치 | 특징 |
|---|---|---|
| running-config | 메모리(RAM) | 지금 동작 중인 설정. 전원을 끄면 사라진다 |
| startup-config | NVRAM | 켤 때 불러오는 설정. 전원을 꺼도 남는다 |

### 자주 쓰는 확인 명령

```bash
enable                       # 특권 모드로
show mac address-table       # 스위치: 학습된 MAC 테이블
show ip route                # 라우터: 라우팅 테이블
show running-config          # 현재 설정 전체
show ip interface brief      # 인터페이스 IP·상태 요약
```

## 2. 동작 원리

### 손이 편해지는 3가지

초보자와 숙련자의 속도 차이는 대부분 여기서 난다. 모두 외우지 않아도 된다.

| 기능 | 방법 | 예 |
|---|---|---|
| 자동완성 | `Tab` | `conf` + `Tab` → `configure` |
| 축약 | 헷갈리지 않을 만큼만 입력 | `conf t` = `configure terminal`, `sh ip int br` = `show ip interface brief` |
| 도움말 | `?` | `show ?`(뒤에 올 수 있는 것), `sh ip ro?`(ro로 시작하는 것) |

- 위·아래 방향키는 이전에 친 명령을 다시 불러온다.
- `no`를 앞에 붙이면 취소다. `shutdown`(끄기)과 `no shutdown`(켜기)이 그래서 그 이름이다.
- 화면이 `--More--`에서 멈추면 `Space`(다음 쪽), `Enter`(한 줄), `q`(중단)를 쓴다.

### 초보자가 겪는 3가지 함정

**1) 오타를 쳤더니 30초 동안 멈춘다**

```
Router# shw ip route
Translating "shw"...domain server (255.255.255.255)
```

- 장비가 오타를 호스트 이름으로 착각해 DNS 조회를 시도하는 것이다.
- `Ctrl + Shift + 6`으로 중단할 수 있다. 아예 꺼두는 편이 낫다.

```
Router(config)# no ip domain-lookup
```

**2) `% Invalid input detected at '^' marker.`**

- `^` 표시가 가리키는 위치가 틀린 지점이다. 그 자리부터 다시 본다.
- 명령 자체는 맞는데 이 오류가 나면 모드가 틀렸을 가능성이 크다. `>`에서 설정 명령을 쳤거나, `(config)#`에서 `show`를 쳤을 때다.

**3) 타이핑 중에 장비 메시지가 끼어들어 줄이 엉킨다**

```
Router(config)# line console 0
Router(config-line)# logging synchronous
```

- 메시지가 떠도 내가 치던 줄을 아래에 다시 그려준다.

### 설정 저장

시스코 장비에는 설정 파일이 두 개 있다. 이를 모르면 애써 한 작업이 사라진다.

```bash
show running-config                   # 지금 설정
copy running-config startup-config    # 저장 (running → startup)
write memory                          # 위와 같은 뜻 (짧은 옛 명령)
show startup-config                   # 저장된 설정 확인
```

{% hint style="danger" %}
WARNING: 저장 누락은 실무 사고 1순위다. 설정을 바꿨으면 습관적으로 `copy run start`를 친다. 저장하지 않으면 장비를 재부팅할 때 변경한 설정이 사라진다. 패킷트레이서 파일 자체는 별도로 `Ctrl+S`로 저장한다.
{% endhint %}

### 장비를 만나면 가장 먼저 하는 기본 설정

CCNA 기초이며 8일차 원격 접속의 밑바탕이 된다. → [1_원격접속_Telnet과SSH](../day-08/lesson-1.md)

```bash
enable
configure terminal
 hostname R1                  # 장비 이름 (프롬프트가 R1# 로 바뀜)
 no ip domain-lookup          # 오타 시 멈춤 방지
 enable secret <password>     # 특권 모드 비밀번호 (암호화되어 저장)
 banner motd #접속 시 표시할 경고 문구#
 line console 0
  logging synchronous         # 메시지가 입력을 방해하지 않게
  password <password>         # 콘솔 접속 비밀번호
  login                       # 비밀번호를 실제로 물어보게 함
 end
copy running-config startup-config
```

- `enable secret`과 `enable password` 중 secret을 쓴다. secret은 암호화해 저장하고, password는 설정 파일에 그대로 보인다.
- 여러 대를 다룰 때 `hostname`이 없으면 어느 장비에 명령을 치는지 헷갈린다. 실습에서 꼭 지정한다.

### 3일차 GUI 설정과 CLI 설정의 대응

3일차에는 라우터 인터페이스를 `Config` 탭(GUI)으로 설정했다. 같은 일을 명령어로 하면 아래와 같다. 오늘부터는 이쪽을 쓴다.

```bash
enable
configure terminal
interface gigabitEthernet 0/0
 ip address 192.168.10.254 255.255.255.0
 no shutdown                 # = 3일차의 Port Status On (기본은 꺼짐)
end
```

## 3. 실습 문서

3일차에 만든 파일을 그대로 이어 쓴다. Lab은 3일차 Lab 9에서 이어진다. → [3일차 본 실습 (Lab 7~9)](../day-03/lesson-4.md)

| Lab | Task ID | 문서 | 여는 파일 | 무엇을 보나 |
|---|---|---|---|---|
| 10 | LEC-N1-04-004-MP | [Lab 10. 스위치 MAC 테이블 보기](lesson-3-lab-10.md) | `03_스위치.pkt` | 스위치 MAC 테이블 |
| 11 | LEC-N1-04-005-MP | [Lab 11. 라우터 라우팅 테이블 보기](lesson-3-lab-11.md) | `03_라우터.pkt` | 라우터 라우팅 테이블 |
| 12 | LEC-N1-04-006-MP | [Lab 12. 정적 라우팅](lesson-3-lab-12.md) | `03_라우터.pkt`를 확장 | 정적 라우팅 |

실습 중 막히면 → [4일차 실습 문제 해결](lesson-3-troubleshooting.md)

## 4. 강의 메모

- 모드 이동(`enable` → `configure terminal` → `interface`)을 손에 익히도록 반복한다.
- Tab, `?`, 축약을 첫 10분에 알려준다. 이것을 모르면 학생이 타이핑에 지쳐 내용을 따라오지 못한다.
- `no ip domain-lookup`을 실습 시작 전에 다 같이 넣어 두면 오타 사고가 줄어든다.
- `show mac address-table`(2계층)과 `show ip route`(3계층)로 오늘의 두 주제를 마무리한다.
- Lab 12가 오늘의 목표점이다. Lab 10·11은 각 10분 안에 끝내고 시간을 몰아준다.
- Lab 12는 새로 만들지 않고 3일차 파일을 확장한다. "무엇이 바뀌는지" 표를 보며 진행한다.
- Lab 12는 먼저 실패를 보여주고 정적 경로를 넣어 성공시키는 순서가 효과적이다.
- "한쪽만 지워서 다시 실패시키기"까지 해봐야 왕복 개념이 남는다.
- 저장(`copy run start`)은 매 Lab 끝마다 습관화한다. 8일차까지 계속 쓴다.
- 다음 시간(5일차): 이 정적 경로를 자동으로 채워주는 동적 라우팅 → [5일차 · 라우팅 프로토콜](../day-05/README.md)
  - "라우터가 3대, 10대가 되면 이것을 손으로 다 넣을 수 있을까?"라는 질문으로 마무리하면 자연스럽게 연결된다.

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| CLI | Command Line Interface. 명령어 입력 방식의 장비 조작 화면 |
| IOS | Internetwork Operating System. 시스코 장비 운영체제 |
| running-config | 메모리에서 동작 중인 설정 |
| startup-config | NVRAM에 저장돼 부팅 때 불러오는 설정 |
| NVRAM | Non-Volatile RAM. 전원을 꺼도 남는 저장소 |
| MOTD | Message Of The Day. 접속 시 보이는 안내 문구 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] running-config와 startup-config의 차이를 장비를 껐다 켜는 상황에 맞춰 설명해 본다.
- [ ] CLI에서 `Invalid input detected` 오류를 만났던 경험이 있다면 어떤 원인이었는지 적어 본다.
- [ ] 장비 이름(`hostname`)을 먼저 정하라고 하는 이유를 내 말로 적어 본다.
