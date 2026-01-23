# cron

* 주기적(반복)으로 작업을 자동 실행하도록 설정하는 기능
* 관련 데몬(서비스) : crond

크론 스케줄 형식 (각 필드 순서) 분 시 일 월 요일 계정 명령어

예시 포맷:

```
* * * * * user-name command to be executed
```

필드 의미

* 분
* 시
* 일
* 월
* 요일 (0=일 \~ 6=토)
* 계정
* 실행할 명령어

예제

{% stepper %}
{% step %}
### 예제 1

```
0 0 1 * * root /home/test.sh
```

해석: 매달 1일 00시 00분에 root 계정으로 /home/test.sh 실행
{% endstep %}

{% step %}
### 예제 2

```
5 3 1 1 * root /home/test.sh
```

해석: 매년 1월 1일 03시 05분에 root 계정으로 /home/test.sh 실행
{% endstep %}
{% endstepper %}

cron으로 실행할 명령어가 저장되는 주요 디렉토리들(예: /etc/cron.hourly, /etc/cron.daily 등)을 확인하고 해당 디렉토리에 스크립트를 배치하면 run-parts가 이를 실행합니다.

힌트:

{% hint style="info" %}
run-parts: 지정한 디렉토리에 있는 모든 실행 가능한 파일(스크립트)을 순차적으로 실행하는 명령어입니다.
{% endhint %}

서비스 제어 예시

* 크론 설정 파일을 변경한 뒤 적용:

```
systemctl restart crond
```

* crond 실행 상태 확인:

```
systemctl status crond
```

크론 줄 반복 축약 예시 여러 줄로 되어 있는 같은 간격의 스케줄을 축약할 수 있습니다.

원래:

```
10 * * * * root run-parts /etc/cron.monthly
20 * * * * root run-parts /etc/cron.monthly
30 * * * * root run-parts /etc/cron.monthly
40 * * * * root run-parts /etc/cron.monthly
50 * * * * root run-parts /etc/cron.monthly
00 * * * * root run-parts /etc/cron.monthly
```

축약:

```
*/10 * * * * root run-parts /etc/cron.monthly
```

기타

* at 라는 명령어도 있으며, 단일 시점에 작업 예약에 사용됩니다.

참고 자료

* https://zerostarting.tistory.com/23
