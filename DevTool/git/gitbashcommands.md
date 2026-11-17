# Git Bash 기본 명령어

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-GIT-005-REF |
| 유형 | REF (명령어 표) |
| 목적 | 자주 쓰는 Git 명령(clone, add, commit, push, pull)과 사용 예를 참조한다 |
| 확인 상태 | 미검증 (원본 페이지의 내용을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본 `how2usegit.md`의 Git Bash 탭을 분리한 문서다. GitHub Desktop 절차는 DEV-GIT-004-MP를 따른다. 그 외 Git 명령은 [Git 명령어 모음](https://velog.io/@delilah/GitHub-Git-%EB%AA%85%EB%A0%B9%EC%96%B4-%EB%AA%A8%EC%9D%8C)을 참조한다.
{% endhint %}

{% hint style="info" %}
NOTE: 명령어의 `<>`는 값을 넣을 자리다. 값을 넣을 때 `<>`는 쓰지 않는다. `git clone`을 제외한 명령은 저장소 폴더 안에서 실행한다.
{% endhint %}

## 1. 명령어 표

| 명령 | 역할 | 사용 시점 |
|---|---|---|
| `git clone <저장소 주소>` | 원격 저장소를 로컬에 복제한다 | 처음 한 번 |
| `git add <파일>` | 변경 사항을 커밋 대기 목록에 올린다. `git add .`은 변경 전체를 올린다 | 커밋 전 |
| `git commit -m "<메시지>"` | 대기 목록의 변경 사항을 커밋으로 기록한다 | 작업 단위가 끝났을 때 |
| `git push` | 로컬 커밋을 원격 브랜치에 올린다. 브랜치를 따로 만들지 않았다면 기본은 `main`이다 | 커밋 후 |
| `git pull` | 원격 저장소의 변경 사항을 로컬에 적용한다 | 작업 시작 전 |

## 2. 사용 예

저장소 주소는 브라우저에서 저장소의 `Code` 버튼을 눌러 확인한다.

```bash
cd <작업 폴더>
git clone https://github.com/<사용자명>/<저장소 이름>.git

cd <저장소 이름>
git add .
git commit -m "<메시지>"
git push
```

## 3. 커밋 메시지 규칙 예

협업에서는 팀이 정한 규칙으로 메시지를 쓴다. 한 예는 다음과 같다.

```
[날짜][시간]_[작업내용]_[작업자]
241011_BuildTest_<작업자>
```

## 4. pull 사용 지침

{% hint style="warning" %}
CAUTION: 같은 파일을 여러 사람이 고칠 때 대부분의 오류는 `git pull`을 하지 않고 작업해서 생긴다. 작업을 시작하기 전에 `git pull`로 저장소와 동기화한다. 충돌이 걱정되면 변경 사항을 만든 뒤 팀원에게 알린다.
{% endhint %}

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `how2usegit.md`의 Git Bash 탭을 REF 문서로 분리하고 개인 저장소 주소와 이름을 일반화 |
