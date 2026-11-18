# 노바 프로젝트 (Nova)

DevSecOps 도입 계획, CI/CD 프로세스, 쿠버네티스·ELK 인프라 구상을 기록한 프로젝트 그룹이다. 문서 번호(Task ID)는 `PRJ-NOV-<번호>-<유형>` 형식이다. 프로젝트의 기간, 역할, 결과는 원본에 없다. 확인 필요.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRJ-NOV-001-DO | 개념 | [데브섹옵스 프로세스 (DevSecOps)](devsecopsprocess.md) | 코드 변경부터 서비스 노출까지 파이프라인 단계를 확인한다 |
| PRJ-NOV-002-DO | 개념 | [애자일 개발 방법론 (Agile)](agiledevelopment.md) | 프로젝트가 채택한 애자일 개발의 특징을 확인한다 |
| PRJ-NOV-003-DO | 개념 | [데브섹옵스 도입 계획 (DevSecOps)](devsecopsplan.md) | 도입 목적, 범위, 도구, 리스크를 확인한다 |
| PRJ-NOV-004-REF | 표 | [환경 구축 작업 목록 (Task)](task.md) | 환경 구축에 쓴 명령과 설정 예시를 찾는다 |
| PRJ-NOV-005-MP | 절차 | [쿠버네티스 인프라 구상 (K8s)](kubernetesinfraidea.md) | kind로 로컬 쿠버네티스 클러스터를 만들고 삭제한다 |
| PRJ-NOV-006-DO | 개념 | [ELK 스택 구축 구상 (ELK)](elkstack.md) | 쿠버네티스 위 ELK와 보안 도구 구성 구상을 확인한다 |
| PRJ-NOV-007-DO | 개념 | [팀장 회의록 2025-01-15](teamleadmeeting.md) | 회의에서 논의한 보안 구성 안건을 확인한다 |

## 읽는 순서

1. PRJ-NOV-003-DO로 목적과 범위를 본다.
2. PRJ-NOV-001-DO와 PRJ-NOV-002-DO로 프로세스와 진행 방식을 본다.
3. PRJ-NOV-005-MP, PRJ-NOV-006-DO, PRJ-NOV-004-REF로 인프라 구상을 본다.
