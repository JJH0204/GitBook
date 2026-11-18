# 개발 및 배포 개요

올반 프로젝트의 개발과 배포 기록 모음이다. 문서 번호(Task ID)는 `PRJ-ALB-<번호>-<유형>` 형식이다.

> 기존 PC방 관리 프로그램(레거시 시스템)의 폐쇄적인 환경을 극복하려고, 역공학 기반의 데이터 스니핑 모델을 도입했다. IT에 익숙하지 않은 사용자도 바로 쓸 수 있는 독립 실행(Standalone) 환경을 만들어 배포 안정성을 확보하는 것이 목표다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRJ-ALB-005-DO | D&O | [큐 기반 비동기 데이터 동기화 (Queue)](queue.md) | 수집과 전송을 분리한 이유와 구조를 안다 |
| PRJ-ALB-006-DO | D&O | [대시보드 실시간 로깅 및 가시성 개선](ui.md) | 3단계 로깅 구조와 도입 계기를 안다 |
| PRJ-ALB-007-DO | D&O | [네트워크 패킷 분석 및 MySQL 디코딩](mysql/README.md) | 패킷에서 주문 데이터를 추출하는 방식을 안다 |
| PRJ-ALB-008-REF | REF | [루프백 어댑터 자동 탐색 구현 (Npcap)](mysql/get_tshark_interfaces.md) | 어댑터 탐색 함수 코드를 찾는다 |
| PRJ-ALB-009-TS | TS | [스니퍼 실시간 출력 지연 해결](mysql/realtime-output-delay.md) | 로그가 늦게 나오는 증상을 해결한다 |
| PRJ-ALB-010-DO | D&O | [임베디드 파이썬 환경 구축 (Python)](embeddable-python.md) | 파이썬 미설치 PC에서 동작시키는 방식을 안다 |
| PRJ-ALB-011-DO | D&O | [프로세스 통합 및 생명주기 관리 (Dart-Python)](dart-python.md) | 자식 프로세스 종료와 로그 전달 방식을 안다 |
| PRJ-ALB-012-REF | REF | [인스톨러 구축 및 배포 자동화 (Inno Setup)](inno-setup/README.md) | 설치 프로그램 요구사항과 설정 항목을 찾는다 |
| PRJ-ALB-013-DO | D&O | [NSSM 서비스 관리 전환 (NSSM)](inno-setup/neem.exe.md) | NSSM을 제외한 결정 이유를 안다 |

## 읽는 순서

1. PRJ-ALB-007-DO로 데이터가 어떻게 수집되는지 본다.
2. PRJ-ALB-005-DO로 수집한 데이터를 서버로 보내는 구조를 본다.
3. PRJ-ALB-010-DO, PRJ-ALB-011-DO로 실행 환경과 프로세스 관리를 본다.
4. PRJ-ALB-012-REF, PRJ-ALB-013-DO로 설치 프로그램과 서비스 관리 결정을 본다.

{% hint style="info" %}
NOTE: 기존 PC방 관리 프로그램의 제품명은 공개 저장소 규칙에 따라 "레거시 시스템"으로 일반화했다. 대상 프로그램의 이용 약관과 계약 조건 확인은 원본에 없다. 확인이 필요하다.
{% endhint %}
