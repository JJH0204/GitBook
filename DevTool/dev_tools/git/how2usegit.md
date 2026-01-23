# How2UseGit

{% tabs %}
{% tab title="GIT Desktop" %}
* 최근에 깃은 여러 펀의성 툴을 등장으로 사용이 간단해졌습니다.
* 원활한 팀 협업을 위해 간단 사용법이 필요한 당신에게 이 가이드를 바칩니다.
* Windows를 기준으로 git 사용법은 두 가지로 나뉩니다.
  * GIT Desktop
  * GIT Bash

## GIT Desktop

* 깃을 처음 사용하거나 다루는데 익숙하지 않다면 추천하는 Tool 입니다.
* Git Hub에서 자체 개발한 Tool 로 무료입니다.

### 준비물

* [git](https://git-scm.com/book/ko/v2/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-Git-%EC%84%A4%EC%B9%98)
* [github 계정](https://github.com/signup?ref_cta=Sign+up\&ref_loc=header+logged+out\&ref_page=%2F\&source=header-home)
* [github Desktop](https://github.com/apps/desktop?ref_cta=download+desktop\&ref_loc=installing+github+desktop\&ref_page=docs)
* [VS code](https://code.visualstudio.com/)/[subline Text](https://www.sublimetext.com/) 같은 코드 에디터(본인 취향껏)

### Github Desktop 실행

{% stepper %}
{% step %}
### 로그인

Windows: File > Accounts\
Mac: Github Desktop > Preferences

* Git 계정으로 로그인 합니다.
{% endstep %}

{% step %}
### Create a New Repository...

* 보유한 깃 레포지토리가 없다면 생성하여 깃 로컬 저장소를 만들 수 있습니다.
* 여기서 생성한 깃 레포지토리는 자동으로 github에도 생성됩니다.
{% endstep %}

{% step %}
### Clone a Repository...

* 보유한 깃 리포지토리가 있거나 불러올 리포지토리가 있을 경우 로컬 저장소와 깃 허브 저장소를 동기화 할 수 있습니다.
{% endstep %}

{% step %}
### Add an Existing Repository...

* 이미 깃 허브 저장소와 로컬 저장소의 동기화가 완료된 폴더(디렉터리)를 Git Desktop에 등록해 저장소 관리를 편하게 할 수 있습니다.
{% endstep %}
{% endstepper %}

### Git Desktop tool

#### Current repository

* 현재 Desktop에서 관리되는 리포지토리 리스트를 확인할 수 있습니다.
* 우 클릭 시 추가 도구를 사용할 수 있습니다.

#### Current Branch

* 현재 리포지토리의 브렌치를 확인할 수 있습니다.
* 브랜치에 대한 개념은 버전 관리를 위해 필요한 상위 개념임으로 현재는 이런 기능이 있다 정도만 이해하셔도 됩니다.

#### Fetch origin

* 현재 선택한 리포지토리에 깃 허브 리포지토리의 변경 사항을 동기화 하여 적용합니다.

#### Changes & History

* 현재 선택한 리포지토리와 깃 허브 저장소를 비교해 수정된 파일들을 표시합니다.
* 수정 사항 로그를 볼 수 있습니다.
* 수정 사항을 취소하거나 적용할 수 있습니다.

#### Commit & History

* 커밋 메시지를 작성하고 Commit을 누르면 Commit이 진행됩니다.
* commit의 대상의 수정 사항을 확인할 수 있습니다.

{% hint style="info" %}
### 정리

* Git Desktop은 깃 사용 숙련도가 부족할 때 사용하기 좋은 툴입니다.
* 다만, Windows/mac 에서만 지원한다는 점에서 Git 명령어를 몰라도 되는 것은 아닙니다.
{% endhint %}
{% endtab %}

{% tab title="Git Bash" %}
* Git을 사용하는 전통적인 방법으로 CMD 창에서 사용하는 명령어는 Git Bash 명령어입니다.

### Git 명령어

* 대부분의 깃 명령어 사용법은 잘 정리된 블로그 포스트가 많습니다.
* 그것을 참고하는 것이 더 도움이 될 것 같습니다.
* [링크](https://velog.io/@delilah/GitHub-Git-%EB%AA%85%EB%A0%B9%EC%96%B4-%EB%AA%A8%EC%9D%8C)
* 가장 자주 사용하게 될 명령어는 아래에 정리해 놓겠습니다.

#### clone

```bash
git clone <리포지토리 링크>
```

* `<>`는 값을 대입할 때 생략합니다.
* 클론을 원하는 리포지토리의 URL 경로가 필요합니다.
* 브라우저 또는 깃 저장소에서 Code 버튼을 눌러 확인할 수 있습니다.

예:

```bash
git clone https://github.com/JJH0204/MyNote.git
```

#### add

```bash
git add <커밋할 변경사항>
```

* 변경 사항을 커밋하기 전 커밋 리스트에 저장하는 명령어입니다.
* 커밋할 변경사항에 . 을 넣으면 변경 사항 모두 리스트에 등록됩니다.

```bash
git add .
```

* 주의 할 점은 git clone 과 git add . 를 동시에 사용할 때 입니다.
* git clone을 제외한 지금부터 소개하는 명령어는 리포지토리 디렉터리에서 실행해야 합니다.

예:

```bash
cd /github
git clone https://github.com/JJH0204/MyNote.git

cd /github/MyNote/
git add .
git commit -m "asdfasdf"
```

#### commit -m

```bash
git commit -m "커밋 메시지"
```

* 변경 사항 커밋 시 표시되는 메시지 입니다.
* 협업에서는 규칙을 갖고 메시지를 작성합니다.
* 대부분의 팀에서 아래와 같이 메시지를 작성합니다.

예:

```
[날짜][시간]_[작업내용]_[작업자]
241011_BuildTest_Jaeho
```

#### push

```bash
git push
```

* push 단독으로 사용하는 명령어입니다.
* 커밋 메시지가 등록된, 커밋 리스트의 모든 변경 사항을 지정된 브랜치에 적용합니다.
* 브랜치 관련 수정이 없다면 기본은 main입니다. (버전 관리/프로세스에 따라서 여려 브랜치가 만들어질 수 있습니다. 팀바팀)

#### pull

```bash
git pull
```

* 깃 허브 저장소(리포지토리)의 변경 사항을 로컬에 적용하는 명령어
* 대부분의 오류는 이 명령어를 사용하지 않아서 작업자 간의 동일한 파일을 수정하거나 커밋을 하려고 할 때 발생합니다.
* 따라서 작업을 하기 전에 꼭 이 명령어로 저장소와 동기화를 최신 상태로 유지하고 작업합니다.
* 변경 사항을 만들었다면 혹시 모를 충돌을 대비해 팀원에게 고지하면 에러를 만날 일이 줄어들 것입니다.

그 외 git 관련 사용법은 GPT나 블로그 포스팅을 참고하시면 도움될 것이라 생각합니다.
{% endtab %}
{% endtabs %}
