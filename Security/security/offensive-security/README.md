# 공격 보안 (Offensive Security)

공격 관점 학습 자료입니다.

공격 기법을 이해해 탐지와 방어에 쓰는 것이 이 그룹의 목적이다. 문서 번호(Task ID)는 `SEC-OFS-<번호>-<유형>` 형식이다. 이 페이지는 안내용이므로 번호를 갖지 않는다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 유형 | 그룹 README |
| 확인 상태 | 미검증 (기존 링크 목록에 그룹 안내를 보충했다) |
| 개정 | R1 (2026-11-19) |

{% hint style="danger" %}
WARNING: 이 그룹의 내용은 직접 소유·관리하거나 서면으로 허가받은 격리 실습 환경에서만 적용한다. 허가받지 않은 시스템에 대한 스캔, 접근 시도, 서비스 방해는 불법이다. 법적·윤리 기준은 [모의해킹의 법적·윤리 기준](pentest/legal-ethics.md)을 먼저 읽는다.
{% endhint %}

## 하위 그룹

| 그룹 | 용도 |
|---|---|
| [모의침투 테스트 (Pentest)](pentest/README.md) | 모의침투의 절차, 방법론, 법적·윤리 기준, 무차별 대입 공격, CVE 체계를 이해한다 |
| [시스템 취약점 분석 (System)](system/README.md) | 백도어, 버퍼 오버플로우, 포맷 스트링, DDoS, 포너블의 개념과 방어를 이해한다 |

## 읽는 순서

1. [모의해킹의 법적·윤리 기준](pentest/legal-ethics.md)으로 허용 범위를 확인한다.
2. [해킹 분야 분류](pentest/hacking.md)와 [해킹 절차](pentest/hackingprocess.md)로 전체 흐름을 본다.
3. [침투 테스트 방법론 개요](pentest/methodology.md)로 표준 절차와 보고서 구성을 본다.
4. 시스템 분야는 [포너블 개요](system/pwnable.md)와 [메모리 보호 기법](system/memory-protections.md)을 함께 읽는다.
5. 방어 관점은 [방어 보안](../defensive-security/README.md)에서 이어서 본다.
