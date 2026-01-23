# GIT

* [깃 과 옵시디언 연동 방법](https://alive-wong.tistory.com/65)
* [깃 저장소 병합 방법](https://velog.io/@jisuuuu/Git-Repository%EB%93%A4-%ED%95%98%EB%82%98%EB%A1%9C-%ED%95%A9%EC%B9%98%EA%B8%B0)
* [커밋 버전 이전으로 되돌리는 방법](https://medium.com/@kwoncharles/git-%EC%9D%B4%EC%A0%A0-commit%EC%9C%BC%EB%A1%9C-%EB%8F%8C%EC%95%84%EA%B0%80%EA%B8%B0-cf6caed43ed5)
* https://ittrue.tistory.com/91 깃 클론

### 사용하지 않는 PC에서 git 연결 해제하기

Git을 더 이상 사용하지 않는 PC에서 계정이나 접근을 중지하려면 다음 단계를 따르세요. 각 항목은 독립적인 조치이며, 필요에 따라 모두 수행하거나 일부만 실행할 수 있습니다.

{% stepper %}
{% step %}
### Git 글로벌 설정에서 사용자 정보 삭제하기

글로벌 설정에서 사용자 이름과 이메일을 제거합니다.

```bash
git config --global --unset user.name
git config --global --unset user.email
```
{% endstep %}

{% step %}
### SSH 키 삭제하기

SSH 키를 사용하고 있다면 해당 키 파일을 삭제하거나 백업/비활성화합니다. 일반적으로 SSH 키는 `~/.ssh` 디렉토리에 위치합니다.

```bash
rm ~/.ssh/id_rsa
rm ~/.ssh/id_rsa.pub
```

(키 이름이 다르면 해당 파일명을 사용하세요.)
{% endstep %}

{% step %}
### 캐시된 자격 증명 삭제하기

Git 자격 증명 헬퍼(credential helper)를 사용 중이라면 캐시된 자격 증명을 삭제합니다.

```bash
git credential-cache exit
```
{% endstep %}

{% step %}
### Windows: 자격 증명 관리자에서 삭제하기

Windows를 사용하는 경우 "자격 증명 관리자"에서 Git 관련 자격 증명을 찾아 삭제합니다.

* 제어판 > 사용자 계정 > 자격 증명 관리자
* "Windows 자격 증명" 또는 "일반 자격 증명"에서 Git 관련 항목을 찾아 삭제
{% endstep %}
{% endstepper %}

***

추가 참고 링크:

* [git\_pull\_error](https://goddaehee.tistory.com/253)
* [git\_stash\_clear](https://iiii.tistory.com/156)
* [git\_commant\_add](https://hygge-wavy.tistory.com/m/94)
* [git\_team\_add](https://velog.io/@gmlstjq123/%EB%82%B4-Github-Repository%EB%A1%9C-%ED%8C%80%EC%9B%90-%EC%B4%88%EB%8C%80%ED%95%98%EA%B8%B0)
* [git\_web](https://brunch.co.kr/@everiwon/42)
* [GIT 간단 사용법](/broken/pages/36b6037936aaf3cbfe40bcd8538e713a17cc198d)

git\_LF\_commit 관련:

* https://guide.ncloud-docs.com/docs/sourcecommit-use-lfs
* https://sbjjsurfing.tistory.com/110
