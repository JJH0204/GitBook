# Service Management

### Remote Access Management

## Service Management

* 내가 사용하지 않는 서비스, 프로토콜 삭제하는 것이 기본
  * nfs-server, tftp, telnet

ls -l /etc/exports

* 파일 자체 접근 권한 확인
* 자체 설정 관리

`ps -ef`를 사용해 실행 중인 서비스 확인 후 불필요한 서비스 삭제 진행

{% hint style="warning" %}
불필요한 서비스가 활성화되어 있으면 원격에서 공격자가 접근할 수 있는 공격 표면이 늘어납니다. 반드시 사용하지 않는 서비스는 제거하거나 비활성화하세요.
{% endhint %}

### Auto Mount / print

* auto mount는 로컬에서 공격자가 원하면 언제든지 원하는 장치를 연결할 수 있어 취약한 서버가 될 수 있음.
* 관련 패키지 검사:

{% code title="패키지 검사" %}
```bash
rpm -qa | grep autofs
```
{% endcode %}

* 설치되어 있다면 삭제 또는 비활성화 할 것

### cron

* 해당 파일을 수정할 수 있는 권한을 가진 경우 취약해질 수 있으므로 확인 필요
* 일반 사용자도 crontab을 사용할 수 있으므로 내부 권한을 확인해야 함

{% code title="crontab 권한 변경 예시" %}
```bash
chmod o-x '/usr/bin/crontab' # other에서 실행 권한을 제거 (+는 추가)
# 기타 사용자의 cron 사용 권한 제거
```
{% endcode %}

#### cron.deny

* 기타 사용자가 crontab을 사용할 수 있는 상황에서 특정 사용자의 권한을 제거할 때 사용

### at

* (1회성) 예약된 작업 실행
* cron과 같이 관리자 권한을 조절하거나 내부 권한을 조정해 관리

{% code title="at 차단 사용자 확인" %}
```bash
ls -l /etc/at.deny # at 차단 사용자 등록
```
{% endcode %}
