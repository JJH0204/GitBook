# 2-1. Git 브랜치 만들기와 병합 실습

> 상위: [6일차 OSPF와 Git 브랜치](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-SN-06-006-MP |
| 목적 | 작업 계획서를 main에 커밋한 뒤 ospf 브랜치를 만들고, 실험을 마친 뒤 두 브랜치를 비교해 main에 병합한다 |
| 적용 대상 | Windows PC의 Git Bash(Git 2.23 이상), 1~5일차 산출물이 있는 `my-netsec-project` 저장소. 격리된 가상 실습망이며 저장소는 본인 소유다 |
| 소요 시간 | 약 5분(브랜치 만들기, 14:45) + 약 25분(비교와 병합 강사 시연, 16:25) |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 이 환경에서 Git을 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-SN-06-002-DO | Git 브랜치로 실험하기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-SN-06-007-MP | 다음 실습. RIP 제거와 OSPF 구성 |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-SN-06-008-MP | 개인 실습의 병합과 push (명령 13번) |
| [commands.md](commands.md) | LEC-SN-06-005-REF | 실습 명령어 모음 (자주 막히는 곳 포함) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Git Bash | Git 2.23 이상 | 이전 버전이면 `git checkout -b ospf`, `git checkout main`으로 대신한다 |
| 2 | 저장소 | `~/my-netsec-project` | 5일차까지의 커밋이 있다 |
| 3 | 작업 계획서 | `00_작업계획/06일차.md` | 1~5번 칸을 main에 커밋한 상태 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 브랜치를 옮기기 전에 `git status`로 바뀐 것을 확인하고, 있으면 커밋한다. 패킷트레이서로 `.pkt`를 연 채 브랜치를 옮기지 않는다. 저장하고 닫은 뒤 옮긴다.
{% endhint %}

{% hint style="info" %}
NOTE: 출력 예시의 해시와 파일 수는 학생 화면과 다르다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 저장소 폴더로 이동한다: `cd ~/my-netsec-project` | `git status`가 정상 출력된다 |
| 2 | 작업 계획서 1~5번 칸을 main에 커밋하고 push했다 | `git log --oneline`의 맨 위가 `6일차: 작업 계획서`다 |
| 3 | 현재 브랜치가 main이다 | `git branch`에서 `* main`이 보인다 |

## 5. 절차

### A. ospf 브랜치 만들기 (14:45)

1. (5-A-01) 바뀐 것이 없는지 확인한다: `git status` → 결과: `nothing to commit, working tree clean`이 보인다.
2. (5-A-02) ospf 브랜치를 만들고 옮긴다: `git switch -c ospf` → 결과: `Switched to a new branch 'ospf'`가 보인다.
3. (5-A-03) 브랜치 목록을 확인한다: `git branch` → 결과: `* ospf`에 별표가 있다.

```
  main
* ospf
```

{% hint style="info" %}
NOTE: 지금부터 패킷트레이서에서 바꾸는 것은 모두 ospf 브랜치의 판이다.
{% endhint %}

### B. 비교와 병합 (16:25, 강사 시연)

강사가 새봄상사 저장소로 보여 준다. 학생은 LEC-SN-06-008-MP 구역 D에서 자기 저장소로 한다.

1. (5-B-01) 실험 변경을 커밋한다.

```bash
git add .
git commit -m "6일차: RIP을 OSPF로 (실험)"
```

→ 결과: ospf 브랜치에 커밋이 생긴다.

2. (5-B-02) 모든 브랜치의 기록을 그림으로 본다: `git log --oneline --graph --all` → 결과: ospf 브랜치에 커밋이 보인다.
3. (5-B-03) 두 브랜치의 설정 차이를 본다: `git diff main ospf -- configs/HQ-R1.txt` → 결과: `-router rip`과 `+router ospf 1` 줄이 보인다.
4. (5-B-04) main으로 옮긴다: `git switch main` → 결과: `Switched to branch 'main'`이 보인다.
5. (5-B-05) ospf를 병합한다: `git merge ospf` → 결과: `Fast-forward`와 바뀐 파일 목록이 보인다.
6. (5-B-06) 병합이 끝난 브랜치를 지운다: `git branch -d ospf` → 결과: `Deleted branch ospf`가 보인다.
7. (5-B-07) 올린다: `git push` → 결과: 오류 없이 끝난다.

{% hint style="info" %}
NOTE: OSPF가 기대만 못해 병합하지 않기로 했다면 5-B-04 이후를 하지 않고 복구 절의 7-02를 따른다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | A 구역 뒤 `git branch` | `* ospf` | 현재 브랜치가 ospf |
| 2 | B 구역 뒤 `git log --oneline --graph` | ospf에서 한 커밋이 main에 들어와 있다 | 실험 커밋이 main 기록에 보인다 |
| 3 | main에서 `git diff HEAD~1 -- configs/HQ-R1.txt` | OSPF 줄이 보인다 | `router ospf 1` 줄 존재 |

## 7. 복구

1. (7-01) 커밋하지 않고 main으로 옮겨 커밋했다면 `git log --oneline --graph --all`로 상태를 확인하고, 강사와 함께 정리한다.
2. (7-02) 병합하지 않고 실험 브랜치만 남기려면 `git push -u origin ospf`로 올린 뒤 `git switch main`으로 돌아온다. → 결과: main에는 RIP 판이 그대로 있다.
3. (7-03) 병합 중 충돌(`<<<<<<<`)이 나면 파일에서 `<<<<<<<`와 `>>>>>>>` 사이의 줄 중 남길 것을 고르고 표시를 지운 뒤 커밋한다. 강사와 함께 푼다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 1번(브랜치 만들기), 9번(비교와 병합)을 AMM 형식 MP로 분리 |
