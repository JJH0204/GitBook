# 6. 리눅스 방화벽 ufw — 내 서버의 현관문

> 상위: [11일차 · 서버 보안](README.md)
> 실습 절차는 [실습. ufw로 옆자리 막기](lesson-6-lab-ufw.md)(LEC-N2-11-012-MP)를 연다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-11-011-DO |
| 유형 | D&O (개념) |
| 목적 | `iptables`와 `ufw`의 관계, `ufw enable` 전에 22번을 열어야 하는 이유, 기본 명령, deny와 reject의 차이, 출발지 지정 규칙이 확장 ACL과 같은 생각임을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 서버에서 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 그림 목록

원본에 그림 프레임 표는 없다. 아래 텍스트 그림만 있다.

## 학습 목표

- `iptables`와 `ufw`의 관계를 한 줄로 설명한다.
- `ufw enable` 전에 `ufw allow 22/tcp`를 해야 하는 이유를 말한다.
- `allow`, `deny`, `status numbered`, `delete`로 규칙을 만들고 지운다.
- 출발지를 지정한 규칙(`allow from`)이 확장 ACL과 같은 생각임을 안다.
- 옆자리 PC에서 막히는 것을 직접 확인한다.

## 이전 학습과의 연결

[4. ACL 표준](lesson-4.md), [5. ACL 확장](lesson-5.md)에서 라우터에 검문소를 세웠다. 그런데 교실에는 시스코 라우터가 없다.

VM은 브릿지로 교실 공유기에 직접 붙어 있고, 그 공유기는 ACL을 걸 수 없는 가정용이다. [3. 왜 막아야 하나](lesson-3.md)의 3층 그림에서 ① 네트워크 장비 칸이 비어 있는 상태다.

```
 [ 교실 ] ──▶ ① 네트워크 장비 ──▶ ② 서버 자신 ──▶ ③ 서비스
                  (없음)            ufw            설정 파일
                                     ▲
                                  여기가 유일한 방어선
```

그래서 서버 스스로가 가진 문지기인 `ufw`가 주인공이다.

## 1. 구성 요소

### 1.1 iptables와 ufw: 엔진과 운전대

리눅스 커널에는 원래부터 패킷을 걸러 내는 기능이 있다. 그것을 다루는 전통적인 명령이 `iptables`인데 문법이 험하다.

```bash
# iptables — 22번 열기
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# ufw — 같은 일
sudo ufw allow 22/tcp
```

`ufw`는 Uncomplicated FireWall의 약어다. `iptables`를 쉽게 쓰도록 감싼 껍데기이며 우분투에 기본으로 들어 있다.

비유(9일차의 비유 그대로): `iptables`는 커널 쪽 엔진이고 `ufw`는 운전대다. 운전대를 돌리면 엔진이 돈다. 사용자는 운전대만 잡으면 된다.

### 1.2 기본 명령 여섯 개

```bash
sudo ufw allow 22/tcp               # 열기 (포트/프로토콜)
sudo ufw deny  23/tcp               # 막기
sudo ufw enable                     # 켜기   ← 22 를 연 뒤에!
sudo ufw disable                    # 끄기
sudo ufw status numbered            # 규칙을 번호와 함께 보기
sudo ufw delete 3                   # 3번 규칙 지우기
```

```
$ sudo ufw status numbered
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere
[ 2] 80/tcp                     ALLOW IN    Anywhere
[ 3] 23/tcp                     DENY IN     Anywhere
```

| 조각 | 뜻 |
|---|---|
| To | 어느 포트로 들어오는 것인가 |
| Action | `ALLOW IN` 허용, `DENY IN` 조용히 버림, `REJECT IN` 거부했다고 알려 줌 |
| From | 어디서 온 것인가(`Anywhere` = 아무 데서나) |

포트 범위는 콜론으로 쓴다. 예: `sudo ufw allow 40000:40010/tcp`. 12일차 FTP 패시브 데이터 포트에서 바로 쓴다.

### 1.3 deny와 reject: 실패하는 모양이 다르다

| | 상대가 보는 것 | 비유 |
|---|---|---|
| deny(기본) | 아무 대답이 없다. 한참 기다리다 타임아웃으로 실패한다 | 문을 두드려도 대답이 없다 |
| reject | 즉시 `Connection refused`가 나온다 | "안 됩니다" 하고 문을 닫는다 |

- 보안상 deny가 낫다. 대답을 하지 않으면 공격자는 서버가 있는지조차 모른다.
- 진단할 때는 헷갈린다. 10일차 FTP에서 "접속은 됐는데 목록이 안 나온" 것과 같은 상황이다.
- 12일차에 "밖에서만 안 되고 타임아웃이 난다"는 증상을 만나면 제일 먼저 ufw를 의심한다.

## 2. 동작 원리

### 2.1 지금 상태와 최대 함정

```bash
sudo ufw status
```

```
Status: inactive        ← 우분투 기본값. 방화벽이 꺼져 있다 = 아무것도 안 막힌다
```

그래서 [3. 왜 막아야 하나](lesson-3.md)에서 옆자리가 내 서버에 그냥 들어왔던 것이다.

{% hint style="danger" %}
WARNING: 순서를 바꾸면 내가 쫓겨난다. `ufw`의 기본 정책은 들어오는 것 전부 거부다. SSH도 "들어오는 것"이다. SSH로 원격 접속한 상태에서 22번을 열지 않고 방화벽을 켜면, 새 SSH 접속이 막혀 다시 들어올 수 없게 된다. 내가 앉은 의자를 내가 치우는 셈이다. `sudo ufw enable`을 먼저 입력하지 않는다.
{% endhint %}

```bash
sudo ufw allow 22/tcp        # ① 먼저 내 통로부터 연다
sudo ufw enable              # ② 그 다음에 켠다
```

{% hint style="info" %}
NOTE: 이미 끊겼다면 원격으로는 방법이 없다. VirtualBox 창(콘솔)으로 직접 들어가 `sudo ufw disable` 또는 `sudo ufw allow 22/tcp`로 복구한다. 콘솔 접근이 가능한 교실에서 미리 연습해 두는 이유다. 클라우드 서버에서 이 실수를 하면 서버를 다시 만들어야 할 수도 있다.
{% endhint %}

### 2.2 출발지를 지정한다: 확장 ACL과 같은 생각

```bash
# 교실 전체에 22번을 여는 대신 —
sudo ufw allow from 192.168.0.50 to any port 22 proto tcp     # 이 PC 에서만
sudo ufw allow from 192.168.0.0/24 to any port 80             # 이 대역에서만
```

[5. ACL 확장](lesson-5.md)과 나란히 놓으면 같은 말이다.

| | 시스코 확장 ACL | 리눅스 ufw |
|---|---|---|
| 허용 | `permit tcp host 192.168.0.50 host 서버 eq 22` | `ufw allow from 192.168.0.50 to any port 22 proto tcp` |
| 거부 | `deny tcp any host 서버 eq 22` | `ufw deny 22/tcp` |
| 기본 정책 | 암묵적 deny any | `default deny incoming` |
| 순서 | 위에서부터, 처음 맞는 줄 | 위에서부터, 처음 맞는 줄 |
| 적용 위치 | 인터페이스(`ip access-group`) | 서버 자신 |

이름만 다르고 생각은 하나다. 필요한 것만 열고 나머지는 막는다.

### 2.3 기본 정책 확인

```bash
sudo ufw status verbose
```

```
Default: deny (incoming), allow (outgoing), disabled (routed)
          │                 │
          │                 └── 나가는 것은 다 허용 (서버가 apt 로 패키지 받아야 하니까)
          └── 들어오는 것은 기본 거부 = 화이트리스트
```

이 한 줄이 [3. 왜 막아야 하나](lesson-3.md)의 기본 거부(Default Deny) 원칙 그 자체다.

### 2.4 AI로 방화벽 규칙을 받았을 때

10일차 [AI 검증 원칙](../day-10/lesson-5.md)을 그대로 따른다. 방화벽은 틀리면 내가 쫓겨나므로 검증이 특히 필요하다.

좋은 질문의 예: "Ubuntu 24.04에서 ufw를 쓴다. 192.168.0.0/24 대역에서만 8000번 TCP를 허용하고 나머지는 막고 싶다. 명령을 알려 달라."

받은 답은 세 가지를 확인한다.

1. 22번이 먼저 열려 있는가. `enable`이 포함된 답이면 특히 확인한다.
2. `deny`와 `allow`의 순서가 내 의도와 맞는가.
3. 포트 범위 표기가 맞는가. ufw와 iptables는 콜론(`40000:40010`), 시스코는 `range`로 서로 다르다.

{% hint style="danger" %}
WARNING: AI의 답에 `ufw reset`, `ufw disable`, `iptables -F`가 있으면 3초 멈춘다. 규칙이 전부 사라진다.
{% endhint %}

## 3. 약어와 용어

| 용어 | 뜻 |
|---|---|
| `iptables` | 리눅스 커널의 패킷 필터를 다루는 전통적 명령 |
| `ufw` | Uncomplicated FireWall. `iptables`를 쉽게 쓰게 감싼 도구 |
| `default deny incoming` | 들어오는 통신을 기본 거부하는 ufw 기본 정책 |
| `Anywhere` | `ufw status`의 From 칸에서 출발지 제한이 없음을 뜻하는 표기 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `sudo ufw enable`만 먼저 입력하면 무슨 일이 일어나고 어떻게 복구하는지 적어 본다.
- [ ] `deny`와 `reject` 중 공격자에게 정보를 덜 주는 것은 무엇이고, 대신 무엇이 불편해지는지 적어 본다.
- [ ] ufw를 켜도 VM 안에서 `curl localhost:8000`은 된다. 왜 그런지 생각을 적어 본다.
