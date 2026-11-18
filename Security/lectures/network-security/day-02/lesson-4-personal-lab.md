# 4-2. 내 주소로 바꾸기와 설정 파일 커밋 실습

> 상위: [2일차 주소 설계와 장비 접근 보안](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-02-008-MP |
| 목적 | 함께 만든 패킷트레이서 파일을 `configs/network.pkt`로 따로 저장해 내 회사의 주소로 바꾸고, 설정 텍스트를 저장소에 커밋한다 |
| 적용 대상 | Cisco Packet Tracer, Git Bash, VS Code, 1일차 저장소 `my-netsec-project`. 개인 실습 (17:00~18:00) |
| 소요 시간 | 약 32분 (내 주소로 바꾸고 확인 12, 저장과 설정 텍스트 10, 결과 기록과 커밋 10) |
| 확인 상태 | 미검증 (원본 강의 노트와 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-02-006-MP | 내 회사 주소 설계표 작성 (이 실습의 주소 출처) |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-02-007-MP | 새봄상사 본사 라우터·스위치 접근 보안 (이 실습의 출발 파일) |
| [lesson-4.md](lesson-4.md) | LEC-SN-02-004-DO | 시스코 CLI와 장비 접근 보안 (10절 설정 파일을 저장소로) |
| [lesson-0-plan-lab.md](lesson-0-plan-lab.md) | LEC-SN-02-009-MP | 작업 계획서 작성 (결과 칸을 채운다) |
| [1일차 명령어 모음](../day-01/commands.md) | | 자격 증명 지우기(7번) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `_실습/새봄상사.pkt` | 4-1 실습의 결과 파일 | 새봄상사 주소 그대로 둔다 |
| 2 | `02_설계/IP_설계표.md` | 3-1 실습의 결과 파일 | 주소를 모두 이 표에서 가져온다 |
| 3 | Git Bash, VS Code | | 저장소 폴더 `my-netsec-project` |
| 4 | 실습용 비밀번호 | 수업에서 정한 값 | 문서에서는 `<password>` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 설정 텍스트에는 enable secret의 해시와 7번 문자열이 그대로 들어간다. 실습용 비밀번호만 쓴 파일만 공개 저장소에 올린다. 실제 장비의 설정 파일은 공개 저장소에 올리지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `_실습/새봄상사.pkt`를 덮어쓰지 않는다. 3일차 함께 하는 실습이 이 파일을 새봄상사 주소 그대로 쓴다. 주소를 바꾸기 전에 반드시 Save As로 `configs/network.pkt`를 만든다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 4-1 실습을 마쳤다 | `_실습/새봄상사.pkt`가 있고 HQ-R1과 PC 두 대가 ping된다 |
| 2 | `02_설계/IP_설계표.md`가 있다 | 내 영업팀의 대역, 게이트웨이, 장비에 줄 주소가 적혀 있다 |
| 3 | `configs/` 폴더가 있다 | 없으면 `mkdir configs` |

## 5. 절차

### A. 내 주소로 바꾸고 확인

1. (5-A-01) 패킷트레이서에서 File, Save As로 `configs/network.pkt`로 저장한다. → 결과: 이후 바꾸는 것은 내 회사 파일이고, `_실습/새봄상사.pkt`는 새봄상사 그대로 남는다.
2. (5-A-02) HQ-R1의 CLI 탭을 연다. → 결과: 콘솔 비밀번호를 묻는다. 4-1 실습에서 건 잠금이 작동한 것이다.
3. (5-A-03) 콘솔 비밀번호 `<password>`, `enable`, enable secret `<password>`를 차례로 입력한다. → 결과: `HQ-R1#`가 보인다.
   ```
   User Access Verification

   Password:
   HQ-R1>enable
   Password:
   HQ-R1#
   ```
4. (5-A-04) 영업팀 게이트웨이 주소를 내 설계표의 값으로 바꾼다. `ip address`를 다시 입력하면 이전 주소를 덮어쓴다.
   ```
   configure terminal
   interface gi0/0
    ip address <내 영업팀 게이트웨이> <내 마스크>
    end
   show ip interface brief
   ```
   → 결과: GigabitEthernet0/0의 IP-Address가 내 게이트웨이이고 Status, Protocol이 up이다.
5. (5-A-05) 두 PC의 주소를 아래 표대로 바꾼다. → 결과: 입력 칸에 내 설계표의 값이 들어간다.

| PC | IP 주소 | 서브넷 마스크 | 기본 게이트웨이 |
|---|---|---|---|
| Sales-PC1 | 내 영업팀의 둘째 주소 | 내 마스크 | 내 영업팀 게이트웨이 |
| Sales-PC2 | 내 영업팀의 셋째 주소 | 내 마스크 | 내 영업팀 게이트웨이 |

6. (5-A-06) 4-1 실습의 확인을 내 주소로 다시 한다. Sales-PC1의 Command Prompt에서 입력한다.
   ```
   ping <내 영업팀 게이트웨이>
   ping <Sales-PC2 의 주소>
   telnet <내 영업팀 게이트웨이>
   ```
   → 결과: 두 ping에 `Reply`가 오고, 텔넷은 배너, VTY 비밀번호, enable secret을 차례로 묻는다. 텔넷은 패킷트레이서 안의 내 라우터에만 한다.
7. (5-A-07) 작업 계획서 4번 칸의 확인 방법을 하나씩 해 보고, 결과를 6번 칸에 적어 둔다. → 결과: 6번 칸의 "확인 결과"가 채워진다.

### B. 저장하고 설정 텍스트 뽑기

1. (5-B-01) HQ-R1에서 저장하고 출력을 한 번에 보이게 한다.
   ```
   copy running-config startup-config
   terminal length 0
   show running-config
   ```
   → 결과: 설정 전체가 `--More--` 없이 끝까지 출력된다. `terminal length 0`은 `--More--`에서 멈추지 않고 끝까지 출력하라는 명령이다.
2. (5-B-02) CLI 탭 아래의 Copy 버튼을 누른다. → 결과: 출력이 복사된다.
3. (5-B-03) VS Code에서 `configs/HQ-R1.txt`를 만들고 붙여 넣는다. → 결과: 설정 텍스트가 파일에 들어간다.
4. (5-B-04) `Building configuration...` 위의 줄과 끝의 프롬프트를 지우고 저장한다. → 결과: 파일이 `Building configuration...`부터 `end`까지로 이루어진다.
5. (5-B-05) 패킷트레이서에서 Ctrl+S를 누른다. → 결과: `configs/network.pkt`가 저장된다.

### C. 결과 기록과 커밋

1. (5-C-01) `00_작업계획/02일차.md`의 6번 결과 칸을 채운다. → 결과: 한 일, 확인 결과, 막힌 곳과 푼 방법, 다음 회차에 이어서 할 일이 적힌다.
2. (5-C-02) `README.md`의 진행 현황 표에 한 줄을 더한다. → 결과: 2일차 줄이 보인다.
   ```markdown
   | 2 | 주소 설계표, 본사 라우터 접근 보안 | [작업 계획서](00_작업계획/02일차.md), [IP 설계표](02_설계/IP_설계표.md), [HQ-R1 설정](configs/HQ-R1.txt) |
   ```
3. (5-C-03) Git Bash에서 상태를 확인한다: `git status` → 결과: 아래와 같이 나온다.
   ```
   Changes not staged for commit:
   	modified:   00_작업계획/02일차.md
   	modified:   README.md

   Untracked files:
   	02_설계/
   	_실습/
   	configs/
   ```
4. (5-C-04) 커밋하고 올린다.
   ```bash
   git add .
   git commit -m "2일차: 주소 설계표, 본사 라우터 접근 보안 설정"
   git push
   ```
   → 결과: push가 오류 없이 끝난다.
5. (5-C-05) 기록을 확인한다: `git log --oneline` → 결과: 맨 위 두 줄이 오늘의 계획과 결과다.
6. (5-C-06) 교실 PC를 같이 쓴다면 [1일차 명령어 모음](../day-01/commands.md) 7번처럼 자격 증명을 지우고 간다. → 결과: 다음 사람이 내 계정으로 push할 수 없다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `02_설계/IP_설계표.md`를 연다 | 내 회사의 대역, 프리픽스, 범위, 게이트웨이가 있다 | 해당 |
| 2 | HQ-R1 Gi0/0과 두 PC의 주소를 설계표와 비교한다 | 영업팀 주소가 일치하고 ping이 된다 | Reply |
| 3 | `configs/HQ-R1.txt`를 연다 | enable secret, 콘솔과 VTY의 login, 배너가 보인다 | 세 가지 모두 있다 |
| 4 | `configs/network.pkt`가 있다 | 파일이 보인다 | 해당 |
| 5 | `00_작업계획/02일차.md`의 결과 칸을 본다 | 채워져 있다 | 해당 |
| 6 | README 진행 현황을 본다 | 2일차 줄이 있다 | 해당 |
| 7 | GitHub에서 위 파일들을 본다 | 보인다 | push 완료 |

## 7. 복구

1. (7-01) 주소를 잘못 바꿨다면 `configs/network.pkt`를 닫고 다시 열어 마지막으로 저장한 상태로 돌아간다. 장비 설정은 HQ-R1에서 `reload`, 저장 여부 `no`로 되돌린다.
2. (7-02) 새봄상사 파일은 `_실습/새봄상사.pkt` 그대로 있는지 확인한다. 덮어썼다면 4-1 실습을 다시 한다.
3. (7-03) 잘못 커밋한 파일은 파일을 고치고 새 커밋을 만든다. 과거 커밋은 고치지 않는다.

## 8. 더 해 볼 것

- 내 회사의 인사팀 대역 주소로 다른 대역 실험을 다시 해 보고, 답한 쪽이 라우터인지 확인한다.
- HQ-SW1의 설정도 `configs/HQ-SW1.txt`로 뽑아 커밋한다.
- [3번 노트](lesson-3.md) 7절의 연습 문제 중 못 푼 것을 푼다.
- 설계표의 지사 대역과 본사와 지사의 연결 구간(/30)을 빠짐없이 채운다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 8~10번과 README의 개인 실습 안내를 AMM 형식 MP로 분리 |
