# 4-1. OSPF 보안 적용과 비교 기록 실습

> 상위: [6일차 OSPF와 Git 브랜치](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-06-008-MP |
| 목적 | 두 라우터에 `passive-interface default`와 OSPF 인증을 걸고, 내 회사 파일에서 같은 일을 되풀이한 뒤 비교 기록, 설정 텍스트, 브랜치 커밋과 병합까지 마친다 |
| 적용 대상 | Cisco Packet Tracer의 `_실습/새봄상사.pkt`와 `configs/network.pkt`, Windows PC의 Git Bash와 VS Code, `my-netsec-project` 저장소(ospf 브랜치). 격리된 가상 실습망이다 |
| 소요 시간 | 약 20분(passive와 인증, 함께) + 약 60분(개인 실습 17:00~18:00. 내 회사 파일에 반복 25분, 비교 기록 10분, 설정 텍스트와 커밋 10분, 병합과 push 10분) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-SN-06-004-DO | OSPF를 지키기와 고르기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-06-007-MP | RIP 제거와 OSPF 구성 (내 주소로 되풀이) |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-SN-06-006-MP | Git 브랜치 만들기와 병합 |
| [commands.md](commands.md) | LEC-SN-06-005-REF | 실습 명령어 모음 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | Git Bash, VS Code, Cisco Packet Tracer | 5일차까지와 같은 PC |
| 2 | 내 회사 설계표 | `02_설계/IP_설계표.md` | 장비 루프백 대역을 더한다 |
| 3 | 비교 기록 | `03_구축/라우팅_비교.md` | 5일차에 만든 파일 |
| 4 | 내 회사 패킷트레이서 파일 | `configs/network.pkt` | 5일차까지의 구성 |
| 5 | 작업 계획서 | `00_작업계획/06일차.md` | 결과 칸을 채운다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 설정 텍스트(`configs/*.txt`)를 커밋하기 전에 `enable secret`, `password` 줄의 비밀번호와 `ip ospf message-digest-key` 줄의 키를 `<password>`로 바꾼다. 공개 저장소에 올린 비밀번호와 키는 지워도 커밋 기록에 남는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 인증은 양쪽 라우터에 모두 걸어야 한다. 한쪽에만 걸면 이웃이 끊기고 통신이 멈춘다. 인증을 바꾸는 작업은 작업 계획서에 "잠시 끊김"을 적고 한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 브랜치를 옮기기 전에 패킷트레이서를 저장하고 닫고, `git status`로 바뀐 것을 확인해 커밋한다.
{% endhint %}

{% hint style="info" %}
NOTE: `<실습용 키>`는 수업에서 정한 값이다. 기록에는 실제 회사 이름, 개인 이메일, 실제 공인 IP를 쓰지 않는다. 주소는 사설 주소만 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 폴더로 이동한다: `cd ~/my-netsec-project` | `git status`가 정상 출력된다 |
| 2 | 브랜치가 ospf다 | `git branch`에 `* ospf` |
| 3 | OSPF 구성(LEC-SN-06-007-MP)을 마쳤다 | `show ip ospf neighbor`에 FULL 두 줄 |
| 4 | `03_구축/라우팅_비교.md`가 있다 | 5일차의 RIP 칸이 보인다 |

## 5. 절차

### A. passive-interface default

1. (5-A-01) 두 라우터에서 사무실 쪽을 닫고 이웃 쪽 포트만 연다.

```
configure terminal
router ospf 1
 passive-interface default
 no passive-interface gi0/1
 no passive-interface se0/0/0
 end
show ip ospf neighbor
```

→ 결과: 이웃 두 줄이 그대로 있다.

2. (5-A-02) `show ip protocols`를 입력한다. → 결과: Passive Interface(s) 목록에 사무실 쪽 포트가 보인다.

### B. OSPF 인증

1. (5-B-01) HQ-R1의 Gi0/1과 Se0/0/0에 인증을 건다. `<실습용 키>`는 수업에서 정한 값이다.

```
configure terminal
interface gi0/1
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 <실습용 키>
interface se0/0/0
 ip ospf authentication message-digest
 ip ospf message-digest-key 1 md5 <실습용 키>
 end
```

2. (5-B-02) 잠시 기다린 뒤 HQ-R1에서 `show ip ospf neighbor`를 입력한다. → 결과: 이웃이 사라진다. `%OSPF-5-ADJCHG ... FULL to DOWN` 알림이 뜬다. 한쪽에만 걸었기 때문이다.
3. (5-B-03) BR-R1의 Gi0/1과 Se0/0/0에 같은 인증을 건다. → 결과: 이웃이 다시 FULL이 된다.
4. (5-B-04) 세 장비(HQ-R1, BR-R1, BR-SW1)를 저장한다: `copy running-config startup-config`

### C. 내 회사 파일에 반복과 비교 기록 (개인 실습)

1. (5-C-01) `_실습/새봄상사.pkt`를 저장하고 닫은 뒤 `configs/network.pkt`를 연다. 브랜치는 그대로 ospf다.
2. (5-C-02) [3-1 실습](lesson-3-lab.md)과 이 문서 A, B 구역을 내 설계로 입력한다. 루프백 대역은 내 설계표에 새로 정한다(예: 192.168.255.0/24).
3. (5-C-03) 와일드카드 마스크는 내 연결 대역에 맞춰 계산한다.
4. (5-C-04) 장애 시험(3-1 실습 구역 E) 결과를 적어 둔다.
5. (5-C-05) `02_설계/IP_설계표.md`에 장비 루프백 대역을 더한다. → 결과: 설계표에 루프백 대역 줄이 생긴다.
6. (5-C-06) `03_구축/라우팅_비교.md`의 비교 표에 OSPF 칸을 더하고, 시험 결과 표에 OSPF 줄을 더한다.
7. (5-C-07) 결정 칸에 RIP과 OSPF 중 무엇을 고르는지와 이유를 쓴다. → 결과: 결정 칸에 선택과 이유 한 줄이 있다.

### D. 설정 텍스트, 브랜치 커밋, 병합

1. (5-D-01) `configs/`에 HQ-R1, BR-R1의 설정 텍스트를 저장한다. 비밀번호와 인증 키는 `<password>`로 바꾼다.
2. (5-D-02) 브랜치가 ospf인지 확인하고 커밋한다.

```bash
git status                                 # 브랜치가 ospf 인지 확인
git add .
git commit -m "6일차: RIP을 OSPF로 (실험), 비교 기록"
git diff main ospf -- configs/HQ-R1.txt
```

→ 결과: `router rip`이 빠지고 `router ospf 1`이 생긴 것이 보인다.

3. (5-D-03) `00_작업계획/06일차.md`의 결과 칸(한 일, 확인 결과, 막힌 곳, 결정, 다음 회차에 이어서 할 일)을 채운다.
4. (5-D-04) README 진행 현황에 한 줄을 더한다.

```markdown
| 6 | RIP을 OSPF로 (브랜치에서 실험 후 병합), passive와 인증 | [작업 계획서](00_작업계획/06일차.md), [라우팅 비교](03_구축/라우팅_비교.md), [설정](configs/) |
```

5. (5-D-05) ospf에 커밋하고 main에 병합한 뒤 push한다.

```bash
git add .
git commit -m "6일차: 결과 기록"
git switch main
git merge ospf
git branch -d ospf
git push
git log --oneline --graph
```

→ 결과: push가 오류 없이 끝나고, 기록 그림에 ospf 갈래가 main으로 병합된 모양이 남는다.

{% hint style="info" %}
NOTE: OSPF를 고르지 않기로 했다면 병합하지 않는다. `git push -u origin ospf`로 실험 브랜치만 올려 두고 `git switch main`으로 돌아온다. 17:45에 병합 전이면 병합은 미루고 ospf 브랜치에라도 커밋하고 push한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `show ip protocols` | Passive Interface(s)에 사무실 쪽 포트 | 이웃 쪽 포트는 목록에 없다 |
| 2 | `show ip ospf neighbor` | 인증 뒤에도 FULL | 이웃 두 줄 FULL |
| 3 | 내 파일에서 `show ip route ospf` | 지사 경로가 `O` 줄로 있다 | 해당 줄 존재 |
| 4 | 내 장애 시험 | `[110/65]` via Se0/0/0 | 예비 회선으로 전환 |
| 5 | `03_구축/라우팅_비교.md` | OSPF 칸과 결정이 있다 | 결정 칸에 이유 한 줄 |
| 6 | `configs/`의 설정 텍스트 | HQ-R1, BR-R1 | 비밀번호와 키가 `<password>`로 바뀌어 있다 |
| 7 | `git log --oneline --graph` | ospf 커밋이 main으로 병합되어 있다 | 병합하지 않았다면 이유가 결정 칸에 있다 |
| 8 | GitHub 저장소 | 새 파일이 보인다 | `03_구축/라우팅_비교.md`가 보인다 |

## 7. 복구

1. (7-01) passive를 잘못 걸어 지사 경로가 사라졌으면 이웃 쪽 포트를 `no passive-interface gi0/1`, `no passive-interface se0/0/0`으로 연다.
2. (7-02) 인증 뒤 이웃이 안 돌아오면 양쪽의 `ip ospf message-digest-key 1 md5` 값을 글자 하나까지 맞춘다. 급하면 인증 줄을 `no ip ospf authentication message-digest`로 지운다.
3. (7-03) 주 회선이 꺼진 채라면 HQ-R1의 Gi0/1에서 `no shutdown`을 입력한다.
4. (7-04) 커밋을 취소하려면 push 전에 `git reset --soft HEAD~1`을 쓴다. 이미 push했다면 새 커밋으로 고친다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 7, 8, 10~13번을 AMM 형식 MP로 분리. 설정 텍스트의 비밀번호·인증 키 치환 WARNING 추가 |
