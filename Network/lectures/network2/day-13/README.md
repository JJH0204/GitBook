# 13일차 · Git 과 GitHub

> 2단계 · 서버 구축 및 활용. 상위: [네트워크 2](../README.md)
> 이전: [12일차 · 리눅스 서버 구축](../day-12/README.md) · 다음: [14일차 · 도커 기초](../day-14/README.md)

## 개요

12일차까지 서버를 세우는 법을 배웠다. 설치, 설정, 기동, 확인, 개방, 검증이다. 그런데 그 서버에 무엇을 올릴 것인가? 올릴 코드는 어디에 두고, 어떻게 관리하고, 어떻게 서버로 보낼까?

오늘부터 네 번은 "내가 만든 것을 세상에 올리는" 한 편이다.

```
 13일차 Git/GitHub ──▶ 14일차 Docker ──▶ 15일차 클라우드·API ──▶ 16일차 배포 종합
   코드를 관리한다        한 덩어리로 묶는다    남의 서버를 빌린다(개념)   내 서버에 올린다
```

| 질문 | 오늘의 답 | 노트 |
|---|---|---|
| `최종_진짜_최종_v3.zip`을 왜 그만둬야 하나? | 버전 관리. 변경 이력을 도구가 기억한다 | 1 |
| 내 컴퓨터에서 먼저 | `init`, `add`, `commit`, `log` | 2 |
| 다른 PC나 다른 사람과 나누려면? | GitHub, `push`, `pull`. SSH 키는 12일차 그것 | 3 |
| 여럿이 같은 파일을 고치면? | 브랜치, `merge`, 충돌 한 번 겪기 | 4 |
| 서버에는 어떻게 올리나? | 서버에서 `git clone`, 웹으로 확인 | 5 |

## 오늘의 목표

- 버전 관리가 무엇이고 왜 필요한지 설명한다.
- Git의 세 자리(작업 디렉터리, 스테이지, 저장소)를 구분하고 `add`, `commit`을 이해한다.
- `git log`로 이력을 읽고, `git diff`로 무엇이 바뀌었는지 본다.
- GitHub에 SSH 키로 인증하고 `push`, `pull`한다(12일차 키 인증 회수).
- 브랜치를 만들고 합치며, 충돌을 한 번 내고 직접 푼다.
- 서버에서 `git clone`으로 코드를 받아 웹으로 띄운다.

## 문서 목록과 읽는 순서

실습 중에는 0번(명령어 대본)을 화면에 띄워 둔다.

| 순서 | Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|---|
| 1 | LEC-N2-13-007-REF | REF | [0. 13일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)](commands.md) | STEP 0~5 명령 대본, 안 될 때 점검표 |
| 2 | LEC-N2-13-001-DO | D&O | [1. 버전 관리란 — `최종_진짜_최종.zip` 을 그만두는 법](lesson-1.md) | 버전 관리, Git의 세 자리, 커밋, 용어 |
| 3 | LEC-N2-13-002-DO | D&O | [2. 로컬 Git — 내 컴퓨터 안에서 먼저](lesson-2.md) | `init`, `add`, `commit`, `log`, `diff`, `.gitignore`, 되돌리기 |
| 4 | LEC-N2-13-008-MP | MP | [로컬 Git 실습](lesson-2-lab.md) | Git 설정, 저장소 만들기, 커밋, `.gitignore` |
| 5 | LEC-N2-13-003-DO | D&O | [3. GitHub 와 원격 저장소 — SSH 키는 12일차 그것](lesson-3.md) | Git과 GitHub, HTTPS와 SSH, 공개키 재사용, `push`, `pull`, `clone` |
| 6 | LEC-N2-13-009-MP | MP | [GitHub 연결 실습](lesson-3-lab.md) | 공개키 등록, `ssh -T`, 저장소 생성, `push`, `clone` |
| 7 | LEC-N2-13-004-DO | D&O | [4. 브랜치와 협업 — 충돌을 한 번 내 본다](lesson-4.md) | 브랜치, `merge`, 충돌의 조건과 해결, Pull Request |
| 8 | LEC-N2-13-010-MP | MP | [브랜치와 충돌 실습](lesson-4-lab.md) | 브랜치 합치기, 충돌 내기, 충돌 풀기 |
| 9 | LEC-N2-13-005-DO | D&O | [5. 서버에 배포해 보기 — `git clone` 한 줄](lesson-5.md) | 배포, 80번 충돌, `clone`과 `pull` 흐름, 여섯 단계 |
| 10 | LEC-N2-13-011-MP | MP | [nginx 배포 실습](lesson-5-lab.md) | nginx 기동, `clone`, `root` 변경, `push`와 `pull` 반영 |
| 11 | LEC-N2-13-006-INS | INS | [6. 오늘의 문제](lesson-6.md) | 문제 7문항 |

## 오늘의 실습 환경

환경은 WSL이다(12일차 VM에서 전환).

| 항목 | 내용 |
|---|---|
| WSL(Ubuntu) | Git은 WSL 안에서 CLI로 한다. 서버에서 쓰는 모습 그대로 |
| 브라우저 | GitHub 가입, 저장소 생성, 결과 확인 |
| Windows | 브라우저와 터미널만 쓴다 |

```bash
sudo apt install -y git         # 보통 이미 깔려 있다
git --version
```

{% hint style="danger" %}
WARNING: 수업 시작 전에 WSL 네트워크 모드를 확인한다. 5번 절(배포 확인)이 여기에 걸린다.
{% endhint %}

```powershell
# Windows PowerShell
Get-Content $env:USERPROFILE\.wslconfig    # networkingMode 줄이 있는가
```

```bash
# WSL
ip route get 1.1.1.1 | head -1     # src 뒤가 내 WSL 주소(가장 정확)
ip -br a | grep eth0               # 참고. VPN이 깔려 있으면 eth0가 엉뚱할 수 있다
```

| 보이는 주소 | 모드 | 내 Windows에서 `localhost` | 옆자리에서 |
|---|---|---|---|
| `172.x.x.x` | NAT(기본) | 된다(WSL 자동 포워딩) | 안 된다 |
| `192.168.x.x`(Windows와 같음) | mirrored | 된다 | 된다 |

{% hint style="info" %}
NOTE: 검증은 "내 Windows 브라우저와 `localhost`"를 기본으로 한다. 두 모드 모두에서 동작하기 때문이다. 옆자리에서 보여 주는 것은 mirrored일 때만 보너스로 한다.
{% endhint %}

mirrored로 바꾸고 싶다면 다음과 같이 한다(선택, Windows 11 22H2 이상만).

```powershell
notepad $env:USERPROFILE\.wslconfig
```

```ini
[wsl2]
networkingMode=mirrored
```

```powershell
wsl --shutdown        # 끄고 다시 시작하면 적용
```

{% hint style="warning" %}
CAUTION: Windows 10에서는 mirrored가 동작하지 않는다. 학생 PC 버전이 섞여 있으면 전환하지 말고 NAT 기준으로 진행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: GitHub 계정이 필요하다. 수업 전에 공지해서 미리 가입해 오게 한다. 이메일 인증에 시간이 걸린다.
{% endhint %}

## 오늘의 진행: 4시간(240분)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|---|---|---|---|---|
| 0 | 몸풀기: WSL 주소, 12일차 서버 살아 있나 | 5분 | 5분 | 10분 |
| 1 | 버전 관리란, Git의 세 자리 | 20분 | 5분 | 35분 |
| 2 | 로컬 Git: init, add, commit, log, diff | 15분 | 30분 | 80분 |
| | 쉬는 시간 10분 | | | 90분 |
| 3 | GitHub: 계정, SSH 키, push, pull | 15분 | 30분 | 135분 |
| 4 | 브랜치, merge, 충돌 한 번 | 15분 | 25분 | 175분 |
| | 쉬는 시간 10분 | | | 185분 |
| 5 | 서버에서 `git clone`, 웹으로 확인 | 10분 | 20분 | 215분 |
| 6 | 오늘의 문제 | 15분 | | 230분 |

{% hint style="info" %}
NOTE: 필수는 2, 3, 5번이다. 시간이 모자라면 4(브랜치), 1(이론 압축) 순으로 줄인다. 3번(SSH 키로 GitHub 인증)이 오늘의 하이라이트이다. 12일차에 만든 키를 그대로 쓴다.
{% endhint %}

## AI 활용

- 커밋 메시지 초안과 README.md 작성 보조는 10일차 [AI 검증 원칙](../day-10/lesson-5.md)을 그대로 따른다.

{% hint style="danger" %}
WARNING: `git reset --hard`, `git push --force`, `rm -rf .git`이 AI의 답에 있으면 3초 멈춘다. 되돌릴 수 없다.
{% endhint %}

## 강의 메모

- 도입 질문은 "12일차까지 서버를 세웠다. 그런데 그 서버에 무엇을 올리는가?"이다.
- 오늘의 회수는 다음과 같다.
  1. 12일차 SSH 키 인증(`ssh-keygen`, `authorized_keys`)을 GitHub 공개키 등록에 쓴다. "지난주에 만든 그 키를 오늘 또 쓴다."
  2. 10일차 `nano`를 커밋 메시지 편집과 `.gitignore` 작성에 쓴다.
  3. 10일차 파이프와 `grep`을 `git log --oneline | head`에 쓴다.
  4. 12일차 여섯 단계를 5번에서 "코드만 바꿔 넣으면 끝"으로 체감한다.
- 최대 병목은 세 가지이다.
  1. GitHub 가입과 이메일 인증. 반드시 사전 공지한다.
  2. `git commit`이 에디터(vim)를 띄워 빠져나오지 못한다. `git config --global core.editor nano`를 STEP 1에서 먼저 설정한다.
  3. 충돌(conflict)에서 당황한다. 충돌 표시 `<<<<<<<`를 칠판에 그려 두고 시작한다.
- 발표용 Excalidraw 그림은 아직 없다. 세 자리 그림과 브랜치 그림은 판서로 그린다.
- 명령 실측 검증(2026-10-16, WSL Ubuntu 24.04, git 2.43.0): STEP 1~4를 전부 실행해 확인했고 다음을 고쳤다.
  1. STEP 4-2 충돌 실습 순서. 원래 순서(main 커밋 후 브랜치)는 Fast-forward로 끝나 충돌이 나지 않는다. 브랜치를 먼저 만드는 순서로 수정했다.
  2. `apt install nginx`는 80번이 막혀 있어도 에러 없이 끝난다(설치 스크립트가 기동 실패를 삼킨다). `is-active`와 `journalctl`로 확인하게 수정했다.
  3. 주소 확인은 `ip route get 1.1.1.1`로 한다. `ip -br a | grep eth0`는 VPN 환경에서 엉뚱한 주소를 준다.
  4. nginx 1.24와 `/etc/nginx/sites-available/default` 경로가 유효함을 확인했다.
- 남은 미검증: nginx 실제 설치와 기동, `git clone` 후 브라우저 확인은 교실 PC에서 한다(검증용 WSL은 실서버라 설치하지 않았다).
