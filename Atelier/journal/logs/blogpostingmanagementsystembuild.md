# 블로그 포스팅 관리 시스템 구축

## git-ignore

```gitignore
# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Obsidian specific files
.obsidian
.obsidian/workspace
.space
.makemd
```

블로그 웹 페이지 소스

\=

파일 삭제시 즉시 반영 여부(선택)

파일 생성 시 Vault에 어느 위치에 저장할 지 설정(선택)

파일에 링크 설정 시 절대 경로로 할지 참조하는 파일 기준으로 상대 경로로 할지 (절대경로로 하는 것을 추천)

이미지 첨부 시 자동으로 생성되는 링크 값 표시 방식 설정

첨부파일을 저장할 별도 저장공간 지정

이정도 했을 때 고민해볼 사항

{% stepper %}
{% step %}
### 블로그 관리를 옵시디언으로 하는게 편할까 지킬(Jekyll)을 사용하는게 맞을까

* 현재 유지보수 비용이 많이 드는 것 같다. (블로그 페이지에 잔잔한 버그 들이 남아 있는데 이걸 수정하기에 시간이 많이 든다.)
* PC를 바꿔서 작업하기 힘들다(설정 환경을 공유해야 하는 불편함)
* obsidian 확장을 직접 개발하는게 의미가 있을지 (물론 자동화 방법을 구상하는 것도 도움이 될 것 같기는 한데 모르겠다.)
{% endstep %}

{% step %}
### 옵시디언 말고 마크다운 파일관리가 수월한 툴이 없을까?

* 문법이 블로그에서 사용하는 마크다운 문법과 조금씩 다른게 거슬린다.
* 블로그에서 사용하는 마크다운 문법을 옵시디언에 적용하든, 옵시디언 마크다운 문법을 블로그에 적용하든 둘중 하나는 해야 한다.
{% endstep %}
{% endstepper %}

### 참고 링크

* Excalidraw/블로그 포스팅 관리 시스템 구추.md#git-ignore
* https://velog.io/@shg4821/%EA%B9%83%ED%97%88%EB%B8%8C-%EB%B8%94%EB%A1%9C%EA%B7%B8-%EB%A7%8C%EB%93%A4%EA%B8%B0-1
