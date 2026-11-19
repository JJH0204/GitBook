# [생성형 AI] 코드형 인프라 (IaC)와 Terraform 기본

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-CIC-005-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 인프라를 코드로 선언해 만들고 관리하는 IaC와 대표 도구 Terraform의 기본 흐름을 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 Terraform 공식 문서의 알려진 동작을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

콘솔에서 손으로 서버와 네트워크를 만들면 같은 환경을 다시 만들기 어렵고, 누가 무엇을 바꿨는지 남지 않는다. 코드형 인프라(IaC, Infrastructure as Code)는 인프라를 파일로 선언한다. 코드처럼 버전 관리, 리뷰, 자동 적용을 할 수 있다.

## 2. 구성 요소

| 번호 | 개념 | 설명 |
|---|---|---|
| 1 | 선언형(declarative) | 원하는 최종 상태를 적는다. 도구가 현재 상태와 비교해 필요한 변경만 계산한다 |
| 2 | 프로바이더(provider) | AWS 같은 대상 서비스의 API를 다루는 플러그인 |
| 3 | 리소스(resource) | 만들 인프라 하나 (예: S3 버킷, EC2 인스턴스) |
| 4 | 변수(variable) / 출력(output) | 입력 값 / 결과 값 |
| 5 | 상태(state) | 코드가 실제 어떤 리소스에 대응하는지 기록한 파일 |
| 6 | 모듈(module) | 여러 리소스를 묶어 재사용하는 단위 |

Terraform은 HCL(HashiCorp Configuration Language)로 이 구성을 적는 도구다. 같은 개념을 쓰는 다른 도구에는 OpenTofu(Terraform에서 갈라져 나온 오픈소스 포크), AWS CloudFormation, Pulumi가 있다.

## 3. 동작 원리

| 번호 | 명령 | 동작 |
|---|---|---|
| 1 | `terraform init` | 프로바이더를 내려받고 작업 폴더를 초기화한다 |
| 2 | `terraform fmt` / `terraform validate` | 서식을 맞추고 문법을 검사한다 |
| 3 | `terraform plan` | 코드와 상태를 비교해 만들 변경 목록을 보여 준다. 실제로는 바꾸지 않는다 |
| 4 | `terraform apply` | 변경을 실제로 적용하고 상태를 갱신한다 |
| 5 | `terraform destroy` | 상태에 기록된 리소스를 모두 삭제한다 |

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "<리전>"
}

resource "aws_s3_bucket" "logs" {
  bucket = "<전역에서 유일한 버킷 이름>"
}

output "bucket_arn" {
  value = aws_s3_bucket.logs.arn
}
```

## 4. 상태 파일 관리

상태 파일(`terraform.tfstate`)은 리소스의 속성을 평문으로 담는다. 비밀번호 같은 민감한 값도 들어갈 수 있다.

| 번호 | 규칙 | 이유 |
|---|---|---|
| 1 | 상태 파일과 `.terraform/` 폴더를 Git에 올리지 않는다 (`.gitignore`) | 민감 값 노출 방지 |
| 2 | 팀에서는 원격 백엔드(예: 암호화된 S3 버킷 등)에 상태를 저장하고 잠금(locking)을 켠다 | 동시 적용으로 상태가 깨지는 것을 막는다 |
| 3 | 적용 전에 항상 `plan` 결과를 읽는다 | 의도하지 않은 삭제·교체를 잡는다 |
| 4 | 비밀 값은 코드에 적지 않고 변수나 시크릿 관리 서비스로 넘긴다 | 저장소 유출 방지 |

{% hint style="danger" %}
WARNING: `terraform destroy`와 `plan`에서 `destroy` 또는 `replace`로 표시된 변경은 데이터를 지울 수 있다. 운영 환경에서는 적용 전에 변경 목록을 한 줄씩 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 콘솔에서 손으로 바꾼 설정은 코드와 어긋난다(드리프트, drift). 다음 `plan`에서 되돌려질 수 있다. 변경은 코드로 하는 규칙을 정한다.
{% endhint %}

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| IaC | Infrastructure as Code. 코드형 인프라 |
| HCL | Terraform 설정 언어 |
| 드리프트 | 코드와 실제 인프라가 어긋난 상태 |
| 멱등성 | 같은 코드를 여러 번 적용해도 결과가 같은 성질 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [CI/CD 기본 개념](cicd-basics.md) | CLD-CIC-003-DO | 인프라 변경도 파이프라인으로 |
| [AWS S3](../aws/aws-s3.md) | CLD-AWS-006-DO | 예제 리소스 |
| [AWS 계정 보안·비용 점검표](../aws/aws-account-checklist.md) | CLD-AWS-005-INS | 자격 증명 관리 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 선언형으로 인프라를 적는 방식이 스크립트로 명령을 순서대로 실행하는 방식보다 나은 점은 무엇인가?
- [ ] 상태 파일을 Git에 올리면 안 되는 이유를 내 말로 설명해 보자.
