# LinuxPackageManagementTool

## RPM (Redhat package manager)

* rpm 옵션 대상파일(프로그램)
  * -U: 업데이트 없으면 다운로드
  * -v: 다운로드 과정 로그 출력
  * -h: 다운로드 과정 상세 출력
  * -e: 삭제
  * -qa: rpm 툴로 설치 여부 확인

{% hint style="warning" %}
Failed dependencies

* RPM 방식으로 설치 시 의존성 문제가 발생할 수 있다.
{% endhint %}

{% hint style="info" %}
yum = dnf
{% endhint %}

다음은 dnf (yum과 동일 동작)에서 자주 사용하는 명령어들입니다:

{% code title="dnf 명령어 예" %}
```bash
dnf install [프로그램이름]     # 지정된 서버에서 다운받아 설치
dnf localinstall [파일.rpm]    # 로컬 RPM 파일을 설치
dnf list [패키지명]            # 패키지 목록/정보 조회
dnf remove [프로그램이름]      # 제거
dnf grouplist                  # 그룹 목록 조회
dnf groupinstall [그룹이름]    # 그룹 단위로 설치
```
{% endcode %}

## 바이너리
