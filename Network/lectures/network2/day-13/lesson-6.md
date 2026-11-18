# 6. 오늘의 문제

> 상위: [13일차 · Git 과 GitHub](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-006-INS |
| 유형 | INS (점검) |
| 목적 | 13일차 내용(세 자리, 공개키와 개인키, 비밀 유출, clone과 pull, 충돌, merge 방향, 배포 진단)을 문제 7문항으로 점검한다 |
| 확인 상태 | 미검증 (원본 문제의 정답과 해설을 다시 읽고 확인했으며 명령을 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 점검 방법

- 각자 먼저 푼 뒤 정답 및 해설 알림을 펼쳐 함께 확인한다.
- 합격 기준: 7문항 중 6문항 이상 정답이다. Q2(공개키와 개인키)와 Q3(비밀 유출)은 반드시 맞힌다.

## 점검 항목

### Q1. 세 자리 — [1. 버전 관리란](lesson-1.md), [2. 로컬 Git](lesson-2.md)

You edited `index.html` and ran `git commit -m "fix"` **without** `git add`.
What happens to your change?
(`git add` 없이 `git commit`을 했다. 수정한 내용은 어떻게 되는가?)

- A. 커밋에 포함된다
- B. 커밋되지 않는다. 스테이지가 비어 있다
- C. 파일이 삭제된다
- D. 자동으로 add된다

{% hint style="info" %}
정답 및 해설

정답: B

- 커밋은 스테이지(②)에 담긴 것만 묶는다. 담지 않았으면 담을 것이 없다.
- 추적 중인 파일을 고쳤다면 `no changes added to commit`, 새 파일이면 `nothing added to commit but untracked files present` 같은 메시지가 나온다.
- 비유: 장바구니에 담지 않고 계산대에 간 것이다.
- `git commit -am`은 이미 추적 중인 파일만 자동으로 담는다. 새 파일은 담지 않는다.
{% endhint %}

### Q2. 공개키와 개인키 — [3. GitHub와 원격 저장소](lesson-3.md), 12일차

Which file do you paste into GitHub's "New SSH key" screen?
(GitHub의 SSH key 등록 화면에 붙여 넣는 것은?)

- A. `~/.ssh/id_ed25519`
- B. `~/.ssh/id_ed25519.pub`
- C. `~/.ssh/known_hosts`
- D. `~/.ssh/config`

{% hint style="info" %}
정답 및 해설

정답: B

- 정답은 `.pub`가 붙은 공개키이다.
- 공개키는 자물쇠이다. 남에게 줘도 된다. 개인키는 열쇠이다. 절대 밖으로 내보내지 않는다.
- 12일차에 서버의 `~/.ssh/authorized_keys`에 넣은 것과 같은 파일이다. 자물쇠를 하나 더 다는 것이다.
- WARNING: A(개인키)를 올리면 그 키로 열리는 모든 서버가 뚫린다.
{% endhint %}

### Q3. 비밀이 커밋됐다 — [2. 로컬 Git](lesson-2.md)

You committed `secret.conf` containing a password, then deleted the file and committed again.
Is the password safe?
(비밀번호가 든 파일을 커밋한 뒤, 파일을 지우고 다시 커밋했다. 안전한가?)

- A. 안전하다. 파일이 없으니까
- B. 안전하지 않다. 이력에 그대로 남아 있다
- C. 안전하다. `.gitignore`에 추가하면 된다
- D. GitHub가 자동으로 지워 준다

{% hint style="info" %}
정답 및 해설

정답: B

- Git은 이력을 지우지 않는다. `git log`로 과거 커밋을 열면 그대로 보인다.
- 이미 공개 저장소에 올라갔다면 그 비밀번호와 키는 유출된 것으로 보고 즉시 교체한다.
- 예방: `.gitignore`를 먼저 만든다. `.env`, `*.key`, `id_rsa`, `*.conf`를 넣는다.
- `.gitignore`는 아직 추적하지 않는 파일에만 적용된다. 이미 커밋한 것은 `git rm --cached`로 뺀다.
{% endhint %}

### Q4. clone과 pull — [3. GitHub와 원격 저장소](lesson-3.md)

You already have the repository on your machine and want the latest changes. Which command?
(이미 저장소가 있고 최신 변경만 받고 싶다. 무엇을 쓰는가?)

- A. `git clone`
- B. `git pull`
- C. `git push`
- D. `git init`

{% hint style="info" %}
정답 및 해설

정답: B

- `clone`은 처음 한 번 저장소를 통째로 복제하고 새 폴더를 만든다.
- `pull`은 이미 있는 저장소를 최신으로 만든다(= `fetch` + `merge`).
- `push`는 올리기이고 `init`은 새 저장소 만들기이다.
- CAUTION: 다른 곳에서 고쳤다면 `push` 전에 `pull`을 한다. 하지 않으면 `rejected`가 난다.
{% endhint %}

### Q5. 충돌 — [4. 브랜치와 협업](lesson-4.md)

When does Git report a merge conflict?
(Git이 충돌을 알리는 경우는?)

- A. 브랜치를 만들 때마다
- B. 두 브랜치가 서로 다른 파일을 고쳤을 때
- C. 두 브랜치가 같은 파일의 같은 줄을 다르게 고쳤을 때
- D. 커밋 메시지가 같을 때

{% hint style="info" %}
정답 및 해설

정답: C

- 다른 파일이거나 같은 파일의 다른 줄이면 Git이 알아서 합친다.
- 같은 줄이 겹치면 Git은 고를 수 없으므로 사람에게 묻는다. 그것이 충돌이다.
- 푸는 법: 표시줄 3종(`<<<<<<<`, `=======`, `>>>>>>>`)을 전부 지우고 남길 내용만 남긴 뒤 `add`, `commit`을 한다.
- 포기하려면 `git merge --abort`를 실행한다.
{% endhint %}

### Q6. merge 방향 — [4. 브랜치와 협업](lesson-4.md)

You want to merge `feature/login` **into** `main`. Where do you run `git merge`?
(`feature/login`을 `main`에 합치려면 어디서 `merge`를 치는가?)

- A. `feature/login`에서 `git merge main`
- B. `main`으로 이동한 뒤 `git merge feature/login`
- C. 어디서 쳐도 같다
- D. GitHub에서만 가능하다

{% hint style="info" %}
정답 및 해설

정답: B

- 받는 쪽에서 친다.
- `git merge X`는 지금 있는 브랜치에 X를 끌어온다는 뜻이다. 그래서 합쳐 넣을 곳(`main`)으로 먼저 이동한다.
- A를 치면 반대로 `feature/login`에 `main`이 합쳐진다.
- 11일차 ACL 재분배의 "받는 쪽에서 친다"와 같은 감각이다.
{% endhint %}

### Q7. 배포가 안 된다 — [5. 서버에 배포해 보기](lesson-5.md), 11일차, 12일차

On your server, `curl localhost` returns the page, but a classmate's browser times out.
What should you check **first**?
(서버에서 `curl localhost`는 되는데 옆자리 브라우저는 타임아웃이다. 먼저 볼 것은?)

- A. `git pull`을 다시 한다
- B. nginx를 재설치한다
- C. `sudo ufw status`로 80번이 열려 있는지 본다
- D. GitHub 저장소 권한을 본다

{% hint style="info" %}
정답 및 해설

정답: C

- 로컬은 되는데 밖에서만 안 되면 거의 확실히 방화벽이다(12일차 진단 그대로).
- `sudo ufw allow 80/tcp`를 빠뜨린 것이다. 여섯 단계의 ⑤ 개방이다.
- 타임아웃은 조용히 버려졌다는 뜻(`deny`)이다. `Connection refused`이면 서비스가 떠 있지 않은 쪽을 본다.
- NOTE: WSL이 NAT 모드이면 옆자리에서 접속되지 않는 것이 정상이다. 방화벽을 확인하기 전에 모드를 먼저 확인한다.
- 네 단계로 좁힌다: ① `ss -tulnp`, ② `curl localhost`, ③ `ufw status`, ④ `ip a`와 `ping`.
{% endhint %}

## 합격 판정

| 번호 | 항목 | 기준 | 합격/불합격 |
|---|---|---|---|
| 1 | 정답 수 | 7문항 중 6문항 이상 | |
| 2 | Q2, Q3 | 모두 정답 | |

## 강의 메모

- Q2(공개키와 개인키)와 Q3(비밀 유출)은 무슨 일이 있어도 다룬다. 실제 사고가 가장 많은 두 지점이다.
- Q7은 11일차, 12일차와 오늘을 한 줄로 꿰는 문제이다. 오늘 배운 것이 지난주와 어떻게 이어지는지 보여 준다.
- 4번 절을 건너뛰었다면 Q5, Q6도 같이 건너뛴다.
