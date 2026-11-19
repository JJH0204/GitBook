---
description: AWS 구성도, 주요 서비스 개념, EC2 인스턴스 생성 절차
---

# AWS

AWS(Amazon Web Services) 계정 구성, 주요 서비스, EC2 인스턴스 생성을 다룬다. 문서 번호(Task ID)는 `CLD-AWS-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| CLD-AWS-001-DO | D&O | [AWS 아키텍처 다이어그램](aws.md) | 계정, IAM, 보안 그룹, 네트워크 ACL의 관계를 이해한다 |
| CLD-AWS-002-DO | D&O | [AWS 주요 서비스 정리](aws_services.md) | S3, EC2, Lambda, DB 서비스의 역할을 구분한다 |
| CLD-AWS-003-MP | 절차 | [AWS EC2 가이드 (EC2)](aws_ec2.md) | EC2 인스턴스를 만들고 접속한다 (과금 발생) |
| CLD-AWS-004-DO | D&O | [[생성형 AI] AWS VPC — 서브넷과 라우팅](aws-vpc.md) | VPC, 서브넷, 라우팅, 게이트웨이의 관계를 이해한다 |
| CLD-AWS-005-INS | 점검 | [[생성형 AI] AWS 계정 보안·비용 점검표](aws-account-checklist.md) | 계정 보안과 과금 항목을 점검한다 |
| CLD-AWS-006-DO | D&O | [[생성형 AI] AWS S3 — 버킷과 객체 저장소](aws-s3.md) | 버킷, 객체, 접근 제어, 보호 기능을 이해한다 |
| CLD-AWS-007-DO | D&O | [[생성형 AI] AWS CloudWatch — 지표·로그·알람](aws-cloudwatch.md) | 지표, 로그, 알람으로 모니터링하는 방법을 이해한다 |

## 읽는 순서

1. CLD-AWS-001-DO로 전체 구조를 본다.
2. CLD-AWS-002-DO로 서비스를 구분한다.
3. CLD-AWS-003-MP를 수행한다.

{% hint style="warning" %}
CAUTION: AWS 리소스는 만들면 과금이 시작된다. 실습 후 CLD-AWS-003-MP의 복구 절로 리소스를 삭제한다.
{% endhint %}
