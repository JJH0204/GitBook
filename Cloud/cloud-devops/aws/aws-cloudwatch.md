# [생성형 AI] AWS CloudWatch — 지표·로그·알람

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-AWS-007-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | AWS 리소스를 모니터링하는 CloudWatch의 지표, 로그, 알람을 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 AWS 공식 문서의 알려진 동작을 정리한 것이며 AWS 콘솔·CLI에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다. 수집 주기와 요금은 바뀔 수 있으므로 AWS 공식 문서로 다시 확인한다.
{% endhint %}

## 1. 목적

서버가 느려졌는지, 오류가 늘었는지를 사용자보다 먼저 알려면 상태를 계속 수집하고 기준을 넘을 때 알림을 받아야 한다. CloudWatch는 AWS 서비스의 수치(지표)와 애플리케이션 로그를 모으고, 알람으로 알림이나 자동 조치를 연결한다.

## 2. 구성 요소

| 번호 | 요소 | 설명 |
|---|---|---|
| 1 | 지표(Metric) | 시간순으로 기록되는 수치. 예: EC2의 `CPUUtilization` |
| 2 | 네임스페이스(Namespace) | 지표를 묶는 이름 공간. 예: `AWS/EC2` |
| 3 | 차원(Dimension) | 지표를 구분하는 이름·값 쌍. 예: `InstanceId` |
| 4 | 로그 그룹 / 로그 스트림 | 로그를 모으는 단위. 그룹 아래에 스트림(출처별 줄기)이 있다 |
| 5 | 알람(Alarm) | 지표가 기준을 넘는지 평가해 상태를 바꾸고 동작을 실행한다 |
| 6 | 대시보드 | 지표를 한 화면에 모아 보는 화면 |
| 7 | CloudWatch 에이전트 | 인스턴스 안에서 메모리, 디스크 같은 지표와 로그 파일을 보낸다 |

## 3. 동작 원리

### 3.1 지표

1. 대부분의 AWS 서비스가 지표를 자동으로 보낸다. EC2 기본 모니터링은 5분 간격이고, 상세 모니터링을 켜면 1분 간격이다.
2. EC2의 기본 지표에는 CPU, 네트워크, 디스크 I/O가 있다. 인스턴스 안의 메모리 사용량과 디스크 사용률은 기본으로 수집되지 않는다. CloudWatch 에이전트를 설치해서 보낸다.

### 3.2 알람

| 상태 | 뜻 |
|---|---|
| `OK` | 지표가 기준 안에 있다 |
| `ALARM` | 지표가 기준을 넘었다 |
| `INSUFFICIENT_DATA` | 데이터가 부족해 판단할 수 없다 |

알람은 통계(평균·최댓값 등), 평가 기간(period), 임계값, 연속 횟수로 정의한다. 상태가 바뀌면 SNS(Simple Notification Service) 주제로 알림을 보내거나 Auto Scaling 같은 동작을 실행한다.

### 3.3 로그

로그 그룹에는 보관 기간(retention)을 설정할 수 있다. 설정하지 않으면 로그가 삭제되지 않고 계속 쌓여 요금이 늘어난다. Logs Insights로 쿼리를 써서 로그를 검색·집계할 수 있다.

```bash
aws cloudwatch describe-alarms --state-value ALARM
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<인스턴스ID> \
  --start-time <시작시각> --end-time <종료시각> --period 300 --statistics Average
aws logs describe-log-groups
aws logs tail <로그그룹명> --follow
aws logs put-retention-policy --log-group-name <로그그룹명> --retention-in-days 30
```

{% hint style="warning" %}
CAUTION: 로그와 사용자 지정 지표, 상세 모니터링은 사용한 만큼 과금된다. 로그 그룹 보관 기간을 설정하고, 쓰지 않는 알람과 대시보드를 정리한다.
{% endhint %}

{% hint style="info" %}
NOTE: CloudWatch는 리소스의 상태와 성능을 본다. 누가 어떤 API를 호출했는지의 감사 기록은 별도 서비스인 CloudTrail이 맡는다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| SNS | Simple Notification Service. 알림 전달 서비스 |
| 통계(Statistic) | 평균, 합계, 최댓값 등 기간 안의 집계 방식 |
| 보관 기간 | 로그 그룹이 로그를 유지하는 일수 |
| Logs Insights | CloudWatch 로그용 쿼리 기능 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [AWS EC2 가이드](aws_ec2.md) | CLD-AWS-003-MP | 모니터링 대상 인스턴스 |
| [AWS 계정 보안·비용 점검표](aws-account-checklist.md) | CLD-AWS-005-INS | 비용 알람 |
| [AWS 주요 서비스 정리](aws_services.md) | CLD-AWS-002-DO | 서비스 개요 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 지표와 로그는 무엇이 다르며, 각각 어떤 질문에 답하는가?
- [ ] 웹 서버의 어떤 지표에 알람을 걸고 싶은가? 임계값은 어떻게 정하겠는가?
