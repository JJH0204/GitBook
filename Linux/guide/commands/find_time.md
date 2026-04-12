# find\_time

## 파일 시간 속성

* atime (access time):\
  vi, cat 등의 명령어를 통해 파일을 확인한 시간, 확인 명령: `ls -lu`
* mtime (modification time):\
  파일을 수정한 시간, 확인 명령: `ls -l`
* ctime (change time):\
  파일의 값(권한, 사이즈, 속성 등)을 수정한 시간, 확인 명령: `ls -lc`

{% hint style="info" %}
명령어 예시:
{% endhint %}

{% code title="ls 사용 예" %}
```bash
ls -lu   # atime 확인
ls -l    # mtime 확인
ls -lc   # ctime 확인
```
{% endcode %}

## find 시간 옵션

* mtime
  * `find ... -mtime -3` : 3일 전(72시간) \~ 현재 시간 (마지막 72시간 이내 수정된 파일)
  * `find ... -mtime 3` : 4일째(96시간) \~ 3일 전(72시간) (정확히 3일 전 하루 범위)
  * `find ... -mtime +3` : 4일(96시간) 전 모든 과거 (3일 이전에 수정된 파일)
* mmin
  * (원문에 예시 없음; 옵션 이름만 표기) `mmin`은 분 단위로 시간 범위를 지정할 때 사용합니다.

{% hint style="info" %}
`-n` (음수), `n`, `+n` (양수) 형식은 find의 시간 관련 비교 방식입니다:

* `-n` : n일(또는 n분) 이내
* `n` : 정확히 n일(또는 n분) 범위
* `+n` : n일(또는 n분) 이전
{% endhint %}
