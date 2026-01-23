# vi

`vi`는 많은 유닉스 및 리눅스 시스템에서 기본 텍스트 편집기로 사용되며, 강력한 기능과 효율성 때문에 널리 사용되고 있어.

#### vi의 주요 모드

{% stepper %}
{% step %}
### 명령 모드 (Command mode)

`vi`를 열면 기본적으로 명령 모드로 시작해. 이 모드에서는 파일을 편집하거나 탐색하는 다양한 명령을 입력할 수 있어. 예를 들어, `h`, `j`, `k`, `l` 키를 사용해 커서를 이동할 수 있고, `dd`로 줄을 삭제하거나, `yy`로 줄을 복사할 수 있어.
{% endstep %}

{% step %}
### 삽입 모드 (Insert mode)

텍스트를 입력하려면 삽입 모드로 전환해야 해. 명령 모드에서 `i` 키를 눌러 삽입 모드로 전환하고, `Esc` 키를 눌러 다시 명령 모드로 돌아올 수 있어.\
참고자료: [FreeCodeCamp](https://www.freecodecamp.org/news/vim-beginners-guide/) , [Red Hat](https://www.redhat.com/sysadmin/get-started-vi-editor) , [FOSS Linux](https://www.fosslinux.com/27013/how-to-use-the-vi-editor-in-linux-with-examples.htm)
{% endstep %}
{% endstepper %}

#### 기본 명령어

* 파일 열기: `vi filename`
* 삽입 모드 진입: `i`
* 파일 저장: `:w`
* 저장 후 종료: `:wq` 또는 `ZZ`
* 저장하지 않고 종료: `:q!`
* 특정 문자열 검색: `/string`
* 특정 라인으로 이동: `:num` (예: `:10`은 10번째 줄로 이동)\
  참고자료: [TutorialsPoint](https://www.tutorialspoint.com/unix/unix-vi-editor.htm) , [Red Hat](https://www.redhat.com/sysadmin/introduction-vi-editor)

#### 텍스트 편집

* 텍스트 추가: `a` (커서 뒤에 추가), `A` (라인 끝에 추가)
* 텍스트 삭제: `x` (문자 삭제), `dw` (단어 삭제), `dd` (줄 삭제)
* 텍스트 복사 및 붙여넣기: `yy` (라인 복사), `p` (붙여넣기)

#### 검색 및 치환

* 특정 문자열 검색: `/pattern`
* 문자열 치환: `:[range]s/pattern/replacement/[flags]` (예: 전체 파일에서 치환 `:%s/old/new/g`)\
  참고자료: [FreeCodeCamp](https://www.freecodecamp.org/news/vim-beginners-guide/)

`vi`는 강력한 기능과 효율성을 갖춘 텍스트 편집기이지만 처음 사용하기에는 약간 어려울 수 있어. 하지만 단축키와 명령어를 익히면 매우 빠르고 효율적으로 파일을 편집할 수 있게 돼. 더 자세한 정보는 Red Hat Enable Sysadmin과 [Tutorials Point](https://www.tutorialspoint.com/unix/unix-vi-editor.htm)에서 확인할 수 있어.

### vi 편집모드 명령어

```
a      : append
        커서의 뒤에서 부터 수정
i      : insert
        커서에서 수정
gg     : 맨 처음
40g    : 해당 라인으로
G      : 맨 마지막
dd     : 커서 줄 삭제
6dd    : 커서 위치 포함 아래 라인 삭제
yy     : 커서 라인 복사
5yy    : 커서 라인 포함 5줄 복사
p      : 커서 다음 라인에 붙여넣기
P      : 커서 라인에 붙여넣기
/find  : 내용에서 find 찾기
n      : 찾은 내용 스크롤(위에서 아래로)
N      : 찾은 내용 스크롤(아래에서 위로)
%s/a/b : a를 찾아서 b로 변경
```

* [링크](https://www.google.com/search?q=vi+%EC%82%AC%EC%9A%A9%EB%B2%95\&oq=vi+tkdyd\&gs_lcrp=EgZjaHJvbWUqBwgBEAAYgAQyBggAEEUYOTIHCAEQABiABDIHCAIQABiABDIKCAMQABiABBiiBDIKCAQQABiABBiiBNIBCDQ3NzhqMGo3qAIAsAIA\&sourceid=chrome\&ie=UTF-8)
