# 브랜치와 충돌 실습

> 상위: [13일차 · Git 과 GitHub](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-010-MP |
| 목적 | 브랜치를 만들어 합치고, 충돌을 일부러 낸 뒤 직접 풀어 `push`한다 |
| 적용 대상 | WSL(Ubuntu 24.04), Git 2.43, `~/myweb` 저장소(원격 `origin` 연결 완료) |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본에 "2026-10-16 STEP 4 실측"이라는 기록이 있으나, 이 문서는 이번 재작성에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N2-13-004-DO | 브랜치와 협업 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-N2-13-009-MP | GitHub 연결 실습 |
| [commands.md](commands.md) | LEC-N2-13-007-REF | 13일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 |
| 2 | `~/myweb` 저장소 | `main` 브랜치, 원격 연결 완료 | [GitHub 연결 실습](lesson-3-lab.md)의 결과물 |
| 3 | nano | 기본 설치 | 충돌 파일 편집 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 B는 순서가 생명이다. 먼저 브랜치를 만든 뒤 양쪽에 각각 커밋한다. `main`에 먼저 커밋하고 브랜치를 만들면 `Fast-forward`로 합쳐져 충돌이 나지 않는다.
{% endhint %}

{% hint style="info" %}
NOTE: 충돌을 풀다가 막히면 `git merge --abort`로 합치기 전 상태로 돌아간다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `~/myweb`의 작업 트리가 깨끗하다 | `cd ~/myweb && git status`가 `working tree clean`을 출력한다 |
| 2 | 현재 브랜치가 `main`이다 | `git branch`에서 `* main`이 보인다 |

## 5. 절차

### A. 갈라서 합치기

1. (5-A-01) 브랜치를 만들고 이동한다: `git switch -c feature/about` → 결과: `Switched to a new branch 'feature/about'`
2. (5-A-02) 파일을 만든다: `echo "<h2>소개</h2>" > about.html`
3. (5-A-03) 커밋한다: `git add about.html && git commit -m "소개 페이지 추가"`
4. (5-A-04) `main`으로 돌아간다: `git switch main`
5. (5-A-05) `ls`를 실행한다. → 결과: `about.html`이 없다.
6. (5-A-06) 합친다: `git merge feature/about` → 결과: `Fast-forward`가 표시된다.
7. (5-A-07) `ls`를 실행한다. → 결과: `about.html`이 생겼다.
8. (5-A-08) 이력을 본다: `git log --oneline --graph --all` → 결과: 이력이 일직선이다.
9. (5-A-09) 다 쓴 브랜치를 지운다: `git branch -d feature/about` → 결과: `Deleted branch feature/about`

### B. 충돌 일부러 내기

1. (5-B-01) 먼저 갈라진다: `git switch -c feature/title`
2. (5-B-02) 제목을 고친다: `echo "<h1>KoreaIT Academy</h1>" > index.html`
3. (5-B-03) 커밋한다: `git commit -am "제목 변경 (feature)"`
4. (5-B-04) `main`으로 돌아간다: `git switch main`
5. (5-B-05) 같은 줄을 다르게 고친다: `echo "<h1>코리아IT</h1>" > index.html`
6. (5-B-06) 커밋한다: `git commit -am "제목 변경 (main)"`
7. (5-B-07) 합친다: `git merge feature/title` → 결과: `CONFLICT (content): Merge conflict in index.html`
8. (5-B-08) 파일을 본다: `cat index.html` → 결과: `<<<<<<<`, `=======`, `>>>>>>>` 세 종류의 표시줄이 보인다.
9. (5-B-09) 상태를 본다: `git status --short` → 결과: `UU index.html`

### C. 충돌 풀기

1. (5-C-01) 파일을 연다: `nano index.html`
2. (5-C-02) 표시줄 세 종류를 모두 지운다.
3. (5-C-03) 남길 내용만 남긴다. → 결과: `<h1>` 줄이 하나만 남는다.
4. (5-C-04) 저장하고 나온다(`Ctrl+O`, Enter, `Ctrl+X`).
5. (5-C-05) 담는다: `git add index.html`
6. (5-C-06) 커밋한다: `git commit -m "제목 충돌 해결"` → 결과: 합치기 커밋이 만들어진다.
7. (5-C-07) 이력을 본다: `git log --oneline --graph --all` → 결과: 갈라졌다 합쳐지는 그림이 보인다.
8. (5-C-08) 올린다: `git push` → 결과: 오류 없이 올라간다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `git status` | `working tree clean` | 충돌 상태(`UU`)가 없다 |
| 2 | `grep -n '<<<<<<<\|>>>>>>>' index.html` | 출력 없음 | 표시줄이 남아 있지 않다 |
| 3 | `git log --oneline --graph --all` | 갈라졌다 합쳐진 그림 | 합치기 커밋이 보인다 |
| 4 | GitHub 웹 저장소 | 최신 커밋 | `제목 충돌 해결`이 보인다 |

## 7. 복구

1. (7-01) 충돌을 푸는 도중 포기하려면: `git merge --abort` → 결과: 합치기 전 상태로 돌아간다.
2. (7-02) 다 쓴 브랜치를 정리한다: `git branch -d feature/title`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-4.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성 |
