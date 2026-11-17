# 0. 실습 명령어 모음

> 상위: [6일차 OSPF와 Git 브랜치](README.md)

수업 흐름 순서대로 적은 대본입니다. 1~9번은 `_실습/새봄상사.pkt` 에서 새봄상사의 주소로 강사와 함께 치고, 10~13번은 개인 실습에서 `configs/network.pkt` 를 열어 같은 일을 내 회사의 설계로 합니다. 오늘의 모든 작업은 ospf 브랜치에서 합니다. 장비 화면의 출력 예시는 IOS 15 형식을 따라 적었고, 패킷트레이서 버전에 따라 조금 다를 수 있습니다.

| 단계 | 내용 | 언제 | 노트 |
|------|------|------|------|
| 0 | 작업 계획서 (main에서) | 14:00 (20분) | README |
| 1 | ospf 브랜치 만들기 | 14:45 함께 (5분) | 2 |
| 2 | RIP과 그 흔적 걷어 내기 | 15:00 함께 (8분) | 3 |
| 3 | 루프백과 라우터 ID | 함께 (5분) | 3 |
| 4 | OSPF 켜기 | 함께 (12분) | 3 |
| 5 | 확인, 창고 루프백 | 15:35 함께 (15분) | 3 |
| 6 | 장애 시험 | 함께 (10분) | 3 |
| 7 | passive-interface default | 16:00 함께 (8분) | 4 |
| 8 | OSPF 인증 | 함께 (12분) | 4 |
| 9 | 비교와 병합 (강사 시연) | 16:25 (25분) | 2, 4 |
| 10 | 내 회사 파일에 2~8번 | 17:00 개인 (25분) | 3, 4 |
| 11 | 비교 기록에 OSPF 칸 | 개인 (10분) | 4 |
| 12 | 설정 텍스트와 브랜치 커밋 | 개인 (10분) | |
| 13 | 병합과 push | 개인 (10분) | 2 |

## 0. 작업 계획서 (14:00~14:20, main에서)

```bash
cd ~/my-netsec-project
git pull
git branch                                 # * main 인지 확인
```

`00_작업계획/06일차.md` 를 만들고 1~5번 칸을 채워 main에 커밋합니다.

```bash
git add .
git commit -m "6일차: 작업 계획서"
git push
```

## 1. ospf 브랜치 만들기

```bash
git status                                 # 바뀐 것이 없어야 한다
git switch -c ospf
git branch
```

```
  main
* ospf
```

지금부터 패킷트레이서에서 바꾸는 것은 모두 ospf 브랜치의 판입니다.

## 2. RIP과 그 흔적 걷어 내기

HQ-R1입니다.

```
configure terminal
no router rip
no ip route 192.168.20.0 255.255.255.0 192.168.99.6 250
interface gi0/1
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.10
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.20
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.30
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.40
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0.99
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
 exit
no key chain RIPKEY
```

BR-R1입니다.

```
configure terminal
no router rip
no ip route 0.0.0.0 0.0.0.0 192.168.99.5 250
interface gi0/1
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
interface gi0/0
 no ip rip authentication mode md5
 no ip rip authentication key-chain RIPKEY
 exit
no key chain RIPKEY
```

`do show ip route` 에 C와 L만 남으면 됩니다. 지사와 본사가 서로를 모르는 상태입니다.

## 3. 루프백과 라우터 ID

HQ-R1입니다.

```
interface loopback 0
 description Router ID
 ip address 192.168.255.1 255.255.255.255
router ospf 1
 router-id 192.168.255.1
```

BR-R1은 192.168.255.2로 같은 줄을 칩니다.

## 4. OSPF 켜기

HQ-R1입니다(3번에 이어서 `router ospf 1` 안에서).

```
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.99.0 0.0.0.7 area 0
 network 192.168.255.1 0.0.0.0 area 0
 end
```

BR-R1입니다.

```
 network 192.168.20.0 0.0.0.255 area 0
 network 192.168.99.0 0.0.0.7 area 0
 network 192.168.255.2 0.0.0.0 area 0
 end
```

`%OSPF-5-ADJCHG: ... from LOADING to FULL, Loading Done` 알림이 뜨면 이웃이 맺어진 것입니다.

## 5. 확인, 창고 루프백

```
show ip ospf neighbor
show ip route ospf
show ip ospf interface gi0/1
show ip ospf interface se0/0/0
```

| 볼 것 | 기대하는 결과 |
|-------|---------------|
| 이웃 | 192.168.255.2가 Gi0/1(FULL/DR 또는 BDR)과 Se0/0/0(FULL/ -)에 |
| 지사 경로 | `O 192.168.20.0/27 [110/2] via 192.168.99.2` 한 줄 |
| 포트 비용 | Gi0/1은 Cost 1, Se0/0/0은 Cost 64 |

창고 네트워크가 `192.168.20.33/32` 로 보이면 BR-R1에서 고칩니다.

```
configure terminal
interface loopback 1
 ip ospf network point-to-point
 end
```

## 6. 장애 시험

BR-PC1에서 `ping -t 192.168.10.98` 을 걸고 HQ-R1에서 칩니다.

```
configure terminal
interface gi0/1
 shutdown
 end
show ip route ospf
```

`[110/65] via 192.168.99.6, Serial0/0/0` 이 보이면 됩니다. 빠진 ping 개수를 세고, `no shutdown` 으로 되살립니다.

## 7. passive-interface default

두 라우터 모두입니다.

```
configure terminal
router ospf 1
 passive-interface default
 no passive-interface gi0/1
 no passive-interface se0/0/0
 end
show ip ospf neighbor
```

이웃 두 줄이 그대로 있으면 됩니다. `show ip protocols` 의 Passive Interface(s) 목록에 사무실 쪽 포트가 보입니다.

## 8. OSPF 인증

두 라우터의 Gi0/1과 Se0/0/0, 네 곳에 겁니다. `<실습용 키>` 는 수업에서 정한 값입니다.

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

HQ-R1에만 걸었을 때 잠시 뒤 이웃이 끊기는 것을 확인하고(`%OSPF-5-ADJCHG ... FULL to DOWN`), BR-R1에도 걸면 다시 FULL이 됩니다. 세 장비를 모두 저장합니다.

## 9. 비교와 병합 (강사 시연)

강사가 새봄상사 저장소로 보여 줍니다. 학생은 13번에서 자기 저장소로 합니다.

```bash
git add .
git commit -m "6일차: RIP을 OSPF로 (실험)"
git log --oneline --graph --all
git diff main ospf -- configs/HQ-R1.txt
git switch main
git merge ospf
git branch -d ospf
git push
```

## 10. 내 회사 파일에 2~8번 (개인 실습)

브랜치는 그대로 ospf입니다. `_실습/새봄상사.pkt` 를 저장하고 닫은 뒤 `configs/network.pkt` 를 엽니다.

1. 2~8번을 내 설계로 칩니다. 루프백 대역은 내 설계표에 새로 정합니다(예: 192.168.255.0/24).
2. 와일드카드 마스크는 내 연결 대역에 맞춰 계산합니다.
3. 6번의 장애 시험 결과를 적어 둡니다.

## 11. 비교 기록에 OSPF 칸

`03_구축/라우팅_비교.md` 의 비교 표에 OSPF 칸을 더하고, 시험 결과 표에 OSPF 줄을 더합니다. 결정 칸에 RIP과 OSPF 중 무엇을 고르는지와 이유를 씁니다. `02_설계/IP_설계표.md` 에 장비 루프백 대역을 더합니다.

## 12. 설정 텍스트와 브랜치 커밋

```bash
git status                                 # 브랜치가 ospf 인지 확인
git add .
git commit -m "6일차: RIP을 OSPF로 (실험), 비교 기록"
git diff main ospf -- configs/HQ-R1.txt
```

## 13. 병합과 push

`00_작업계획/06일차.md` 의 결과 칸을 채우고 README 진행 현황에 한 줄을 더해 ospf에 커밋한 뒤 병합합니다.

```markdown
| 6 | RIP을 OSPF로 (브랜치에서 실험 후 병합), passive와 인증 | [작업 계획서](00_작업계획/06일차.md), [라우팅 비교](03_구축/라우팅_비교.md), [설정](configs/) |
```

```bash
git add .
git commit -m "6일차: 결과 기록"
git switch main
git merge ospf
git branch -d ospf
git push
git log --oneline --graph
```

OSPF를 고르지 않기로 했다면 병합하지 않고 `git push -u origin ospf` 로 실험 브랜치만 올려 두고, `git switch main` 으로 돌아옵니다.

## 자주 막히는 곳

| 보이는 것 | 원인 | 해결 |
|-----------|------|------|
| `git switch` 가 거절된다 | 커밋하지 않은 변경이 옮겨 갈 브랜치의 파일과 부딪힌다 | 패킷트레이서 저장, 닫기, 커밋, 옮기기 |
| 실험 변경이 main에 커밋됐다 | 커밋하지 않고 main으로 옮겨 커밋했다 | `git log --oneline --graph --all` 로 확인하고 강사와 함께 정리한다 |
| 패킷트레이서 화면과 파일이 다르다 | 패킷트레이서를 연 채 브랜치를 옮겼다 | 닫고 다시 연다 |
| 이웃이 안 생긴다 | 양쪽 에어리어나 연결 구간 주소가 다르다 | `show ip ospf interface`, area mismatch 알림 |
| `network 192.168.10.0 255.255.255.0 area 0` 이 엉뚱하게 동작한다 | 서브넷 마스크를 썼다 | 와일드카드 마스크 0.0.0.255 |
| `passive-interface default` 뒤 지사 경로가 사라졌다 | 이웃 쪽 포트를 열지 않았다 | `no passive-interface gi0/1`, `se0/0/0` |
| 인증 뒤 이웃이 안 돌아온다 | 키 번호나 값이 다르다 | 양쪽 `ip ospf message-digest-key 1 md5` 를 글자 하나까지 맞춘다 |
| 창고가 /32로 보인다 | OSPF가 루프백을 /32로 알린다 | `ip ospf network point-to-point` |
| `git merge` 에서 충돌이 났다 | main에서도 같은 파일을 고쳤다 | 파일에서 `<<<<<<<` 와 `>>>>>>>` 사이의 줄 중 남길 것을 고르고 표시를 지운 뒤 커밋한다. 강사와 함께 푼다 |
