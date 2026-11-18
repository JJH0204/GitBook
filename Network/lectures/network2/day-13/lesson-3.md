# 3. GitHub 와 원격 저장소 — SSH 키는 12일차 그것

> 상위: [13일차 · Git 과 GitHub](README.md) · 절차는 [GitHub 연결 실습](lesson-3-lab.md), 대본은 [STEP 3](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-003-DO |
| 유형 | D&O (개념) |
| 목적 | Git과 GitHub의 차이, HTTPS와 SSH 인증의 차이, 12일차 SSH 키를 GitHub에 재사용하는 원리, `remote`, `push`, `pull`, `clone`을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- Git과 GitHub의 차이를 설명한다.
- 12일차에 만든 SSH 키를 GitHub에 등록해 인증한다.
- `remote add`, `push`, `pull`, `clone`을 구분해서 쓴다.
- HTTPS와 SSH 두 방식의 차이를 안다.

## 1. 목적

12일차에 비밀번호 없이 SSH로 들어가는 법을 배웠다. 개인키와 공개키를 만들고, 공개키를 서버의 `~/.ssh/authorized_keys`에 넣었다. 그때 만든 공개키를 오늘은 GitHub에 넣는다. 하는 일은 완전히 같다.

| | 12일차(내 서버) | 오늘(GitHub) |
|---|---|---|
| 개인키 | 내 WSL `~/.ssh/id_ed25519` | 같은 것 |
| 공개키를 어디에 | 서버의 `~/.ssh/authorized_keys` | GitHub 설정 화면 |
| 결과 | 비밀번호 없이 `ssh` | 비밀번호 없이 `push` |

열쇠와 자물쇠 비유 그대로다. 자물쇠(공개키)를 하나 더 다는 것뿐이다.

## 2. 구성 요소

### Git과 GitHub

| | Git | GitHub |
|---|---|---|
| 정체 | 프로그램(내 컴퓨터) | 웹 서비스(남의 서버) |
| 없으면 | 버전 관리를 못 한다 | 불편할 뿐, 버전 관리는 된다 |
| 비슷한 것 | — | GitLab, Bitbucket, 사내 Git 서버 |

비유: Git은 카메라이고 GitHub는 사진 공유 앱이다. 카메라만 있어도 사진은 찍힌다.

원격 저장소를 두는 이유는 세 가지이다.

1. 백업: 내 WSL이 사라져도 코드는 남는다.
2. 협업: 여럿이 같은 저장소에 모인다.
3. 배포: 서버에서 `git clone`으로 받는다. → [5. 서버에 배포해 보기](lesson-5.md)

### 인증: HTTPS와 SSH

| | HTTPS | SSH |
|---|---|---|
| 주소 | `https://github.com/<아이디>/<저장소>.git` | `git@github.com:<아이디>/<저장소>.git` |
| 인증 | 토큰(비밀번호 아님)을 매번 | 키를 한 번 등록하면 끝 |
| 포트 | 443 | 22(10일차 포트표) |
| 수업에서 | 사내망이 22번을 막을 때만 | 이쪽으로 한다 |

{% hint style="info" %}
NOTE: GitHub는 비밀번호 인증을 폐지했다. HTTPS를 쓰려면 Personal Access Token을 따로 만들어야 한다. 그래서 SSH가 더 간단하다. 이미 키가 있기 때문이다.
{% endhint %}

### 원격 연결 명령

| 명령 | 뜻 |
|---|---|
| `remote add origin <주소>` | `origin`이라는 별명으로 이 원격을 등록한다 |
| `origin` | 관례적인 별명일 뿐이다(다른 이름도 된다) |
| `push -u origin main` | 올리고, 앞으로 `git push`만 쳐도 되게 기억시킨다 |
| `git clone <주소>` | 처음 한 번. 저장소를 통째로 복제한다(폴더가 새로 생긴다) |
| `git pull` | 이미 있는 저장소를 최신으로 만든다(= `fetch` + `merge`) |

`clone`은 복사가 아니라 이력째 복제이다. 그래서 복제본에서도 과거로 돌아갈 수 있다.

{% hint style="warning" %}
CAUTION: 다른 PC나 웹에서 고쳤다면 `push` 전에 `pull`을 먼저 한다. 하지 않으면 `rejected`가 난다.
{% endhint %}

## 3. 동작 원리

SSH 키로 GitHub에 인증하는 순서는 다음과 같다.

1. WSL에서 `ssh-keygen -t ed25519`로 키 한 쌍을 만든다(12일차에 이미 만들었으면 재사용한다).
2. 공개키(`.pub`)의 내용만 GitHub 설정의 `SSH and GPG keys`에 등록한다.
3. `git push`를 하면 Git이 SSH로 `git@github.com`에 접속한다.
4. GitHub가 등록된 공개키로 도전 값을 보내고, 내 개인키가 서명해 응답한다. 비밀번호는 오가지 않는다.
5. 인증이 성공하면 `ssh -T git@github.com`이 "does not provide shell access"를 출력한다. GitHub는 로그인용 서버가 아니므로 정상이다.

{% hint style="danger" %}
WARNING: 등록하는 것은 `.pub`가 붙은 공개키뿐이다. `id_ed25519`(개인키, `.pub` 없는 쪽)는 절대 올리지 않는다. [2. 로컬 Git](lesson-2.md)의 `.gitignore`를 따른다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| `origin` | 원격 저장소에 관례적으로 붙이는 별명 |
| 공개키 / 개인키 | 자물쇠 / 열쇠. 공개키는 남에게 줘도 되고 개인키는 내보내지 않는다 |
| Personal Access Token | HTTPS 인증용 토큰. 비밀번호 대신 쓴다 |
| `rejected` | 원격이 더 최신이라 `push`가 거부된 상태 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 12일차 열쇠와 자물쇠 그림 | 12일차 그림을 다시 그리고 자물쇠 하나만 GitHub로 바꿔 그린다 |

## 강의 메모

- 이 절이 오늘의 하이라이트다. 12일차 키 인증을 그대로 재사용하는 장면에서 "그게 이거였구나"가 나온다.
- 개인키와 공개키 혼동이 1번 사고다. `.pub`가 붙은 것만 올린다는 말을 세 번 한다.
- 저장소를 만들 때 "Add a README" 체크를 해제하도록 강조한다. 체크하면 첫 push가 거부되고 수습에 10분이 걸린다.
- `ssh -T` 성공 메시지의 "does not provide shell access"를 미리 설명한다. 에러로 착각한다.
- GitHub 화면은 강사 화면을 띄워 놓고 같이 클릭한다. 영문 UI라 헤맨다.
- 실습 30분 중 키 등록에 15분은 잡아 둔다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 공개키와 개인키 중 GitHub에 올리는 것은 무엇이고, 나머지 하나는 어디에 있어야 하는가?
- [ ] `clone`과 `pull`은 각각 언제 쓰는가?
- [ ] GitHub가 내일 문을 닫으면 내 코드는 사라지는가? 왜 그런가?
