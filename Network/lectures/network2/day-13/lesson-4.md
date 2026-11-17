# 4. 브랜치와 협업 — 충돌을 한 번 내 본다

> 상위: [13일차 · Git 과 GitHub](README.md) · 대본 [STEP 4](commands.md)

## 🎯 학습 목표

- **브랜치**가 무엇이고 왜 쓰는지 설명한다
- `branch` · `switch` · `merge` 로 갈라내고 합친다
- **충돌(conflict)** 을 **일부러 내고** 직접 푼다 ⭐
- GitHub 의 **Pull Request** 가 무엇인지 안다 (개념까지)

## 🌉 다리 놓기: "되는 걸 건드리기 무섭다"

[3번](lesson-3.md)까지 하면 **혼자 쓰는 Git** 은 끝났다. 그런데 이런 상황이 온다.

> 🗣 **"지금 사이트는 잘 돌아갑니다. 새 기능을 넣어보고 싶은데, 망가뜨리면 어쩌죠?"**

파일을 복사해서 `index_실험용.html` 을 만들 것인가? → 1번 절의 그 문제로 돌아간다.
**브랜치**가 답이다.

---

## 📖 ① 브랜치 — 평행 우주

```
                    ┌──● feature  "새 기능 실험"
                    │
 ●───●───●──────────┴──────●  main   "항상 동작하는 것"
 첫   둘   셋                 합침(merge)
```

> 📌 **브랜치 = 갈라진 작업 줄기.** 같은 폴더에서 **다른 버전**을 왔다 갔다 한다.

- `main` = **언제나 동작해야 하는** 줄기 (운영에 올리는 것)
- `feature/...` = **실험하는** 줄기. 망해도 **버리면 그만**이다

> 💡 **비유: 문서의 "사본 만들어 고치기"** 인데, **합칠 때 Git 이 알아서 섞어 준다**는 점이 다르다.

| 명령 | 뜻 |
|------|-----|
| `git branch` | 브랜치 목록 (별표가 지금 위치) |
| `git switch -c feature/login` | **만들고 이동** (옛 명령: `checkout -b`) |
| `git switch main` | 이동 |
| `git merge feature/login` | **지금 브랜치에** 저 브랜치를 합친다 |
| `git branch -d feature/login` | 다 쓴 브랜치 삭제 |

> ⚠️ **`merge` 는 "받는 쪽"에서 친다.** `main` 에 합치려면 **`main` 으로 이동한 뒤** `git merge feature/login`.
> 11일차 ACL 의 "받는 쪽에서 친다"와 같은 감각이다.

---

## 📖 ② 해보기 — 갈라서 합치기

```bash
cd ~/myweb
git switch -c feature/about          # 갈라진다
echo "<h2>소개</h2>" > about.html
git add about.html
git commit -m "소개 페이지 추가"

git switch main                      # 돌아오면
ls                                   # about.html 이 없다! (평행 우주)

git merge feature/about              # 합치면
ls                                   # about.html 이 생겼다
git log --oneline --graph --all
git branch -d feature/about          # 정리
```

> ⭐ **`ls` 로 파일이 사라졌다 나타나는 장면**이 브랜치 설명의 전부다. 말보다 이게 빠르다.
> 📌 여기서 합치기는 **`Fast-forward`** 라고 뜬다 — main 이 그동안 가만히 있었으니 **그림이 일직선**이다.
> 갈라진 그림(`|\`)은 ③ 충돌을 풀고 나서 보인다.

---

## 📖 ③ 충돌 — 일부러 내 본다 ⭐

**충돌은 고장이 아니다.** Git 이 **"둘 중 어느 쪽인지 나는 모르겠다"** 고 물어보는 것이다.

> 📌 **충돌 조건**: **같은 파일의 같은 줄**을 양쪽에서 다르게 고쳤을 때.
> 다른 파일이거나 다른 줄이면 Git 이 **알아서 합친다.**

> 🚨 **순서를 지켜야 충돌이 난다.** **먼저 갈라진 뒤** 양쪽에서 **각각** 커밋해야 한다.
> main 에 먼저 커밋하고 브랜치를 만들면 갈라진 게 아니라 **앞서 나간 것**이어서, Git 이 **Fast-forward** 로 조용히 합쳐 버린다.

```bash
git switch -c feature/title          # ① 먼저 갈라진다
echo "<h1>KoreaIT Academy</h1>" > index.html
git commit -am "제목 변경 (feature)"

git switch main                      # ② 돌아와서 같은 줄을 다르게 고친다
echo "<h1>코리아IT</h1>" > index.html
git commit -am "제목 변경 (main)"

git merge feature/title              # ③ CONFLICT!
```

```
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

**파일을 열면 이렇게 되어 있다.**

```
<<<<<<< HEAD
<h1>코리아IT</h1>              ← 지금 브랜치(main) 것
=======
<h1>KoreaIT Academy</h1>      ← 합치려는 브랜치(feature) 것
>>>>>>> feature/title
```

**푸는 법 — 세 줄만 기억한다**

1. 표시줄 세 종류를 **전부 지운다**
2. **남길 내용만 남긴다** (한쪽 · 양쪽 · 새로 쓰기 — 내 마음)
3. `git add` → `git commit`

```bash
nano index.html
git add index.html
git commit -m "제목 충돌 해결"
git log --oneline --graph --all
```

> 🆘 **포기하고 되돌리려면** `git merge --abort` — 합치기 전으로 깨끗이 돌아간다
> 🗣 **"충돌은 에러가 아니라 질문입니다. Git 이 여러분에게 물어보는 겁니다."**

---

## 📖 ④ Pull Request — 개념만

실무에서는 `main` 에 **바로 merge 하지 않는다.**

```
 feature 브랜치 push ──▶ GitHub 에서 Pull Request 생성
                       ──▶ 동료가 코드 리뷰 ──▶ 승인 ──▶ merge
```

- **PR(Pull Request)** = **"내 브랜치를 합쳐 주세요"** 라는 요청 + **리뷰하는 자리**
- 11일차 보안의 감각과 같다 — **바로 반영하지 않고 한 번 거른다**
- 📌 오늘은 **개념까지만.** 혼자 하는 실습에선 효과가 안 난다

---

## 🧪 실습 / 질문

- 브랜치를 만들었는데 `ls` 에 파일이 그대로다. 왜일까?
- 같은 파일의 **다른 줄**을 양쪽에서 고치면 충돌이 날까?
- 충돌 표시줄을 지우지 않고 커밋하면 어떻게 되나?
- `git merge --abort` 는 언제 쓰나?

## 📝 강의 메모

- ⭐ **`ls` 로 파일이 사라졌다 나타나는 장면**(②)을 꼭 보여준다 — 브랜치 이해의 90%
- ⭐ **충돌은 반드시 일부러 낸다.** 수업에서 안 내면 현업에서 처음 만나 멘붕한다
  - 충돌 표시 3종을 칠판에 크게 그려 두고 시작
  - **"표시줄을 지우는 것이 해결의 절반"** 을 강조 — 학생들은 표시줄을 남긴 채 커밋한다
- `checkout` 대신 **`switch`** 를 가르친다 (요즘 권장 · `checkout` 은 하는 일이 너무 많아 혼란)
- 🚨 **충돌 실습은 순서를 틀리면 안 난다** — 브랜치를 **먼저** 만들 것. 실측으로 확인했다(2026-10-16)
- PR 은 **개념만**. 시간 없으면 화면 한 장 보여주고 끝
- ⏱ 실습 25분. **시간이 모자라면 이 절을 통째로 줄인다** (필수는 2 · 3 · 5번)
