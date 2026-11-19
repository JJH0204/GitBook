# 보안 방어 기술 (Defense)

침입 탐지, 모니터링, 방화벽, 로그 분석, 침해사고 분석 도구의 설치·설정 방법과 개념을 정리한다. 문서 번호(Task ID)는 `SEC-DEF-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), REF(표)다. 이 폴더의 절차는 실습용 가상 환경을 전제로 한다. 모든 절차는 아직 실행해 확인하지 않았다(미검증).

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| SEC-DEF-001-DO | 개념 | [침입 탐지 시스템 (IDS)](ids.md) | IDS 개념과 종류를 이해한다 |
| SEC-DEF-002-MP | 절차 | [호스트 침입 탐지 시스템 (HIDS)](hids.md) | OSSEC 서버와 에이전트를 설치한다 |
| SEC-DEF-003-DO | 개념 | [보안 정보 이벤트 관리 (SIEM)](siem.md) | 로그 통합 관제 개념을 이해한다 |
| SEC-DEF-004-REF | 표 | [Snort 룰 문법 (Snort Rule)](snort-rule.md) | Snort 룰 문법을 찾는다 |
| SEC-DEF-005-MP | 절차 | [Snort 설치 및 침입 탐지 구축](snort.md) | Snort 3를 설치하고 탐지한다 |
| SEC-DEF-006-MP | 절차 | [Suricata 설치 및 설정](suricata.md) | Suricata를 설치하고 룰을 적용한다 |
| SEC-DEF-007-MP | 절차 | [Wazuh 보안 관제 시스템 구축](wazuh.md) | Wazuh 서버를 설치한다 |
| SEC-DEF-008-DO | 개념 | [존 기반 정책 방화벽 (ZFW)](zfw.md) | 존 기반 방화벽 개념을 이해한다 |
| SEC-DEF-009-MP | 절차 | [웹 애플리케이션 방화벽 (WAF)](waf.md) | httpd에 ModSecurity를 설정한다 |
| SEC-DEF-010-MP | 절차 | [Kubernetes 환경의 WAF 구성](waf_in_kubernetes.md) | 인그레스 컨트롤러에 WAF를 켠다 |
| SEC-DEF-011-REF | 표 | [와이어샤크 패킷 분석 (Wireshark)](wireshark.md) | 표시 필터와 통계 메뉴를 찾는다 |
| SEC-DEF-012-MP | 절차 | [Zabbix 모니터링 시스템 구축](zabbix.md) | Zabbix 서버와 에이전트를 설치한다 |
| SEC-DEF-013-REF | 표 | [Linux 침해 분석 아티팩트](linuxintrusionanalysis.md) | Linux 점검 명령을 찾는다 |
| SEC-DEF-014-MP | 절차 | [침해사고 이벤트 분석 절차](intrusioneventanalysis.md) | Windows 아티팩트를 수집·분석한다 |
| SEC-DEF-015-DO | 개념 | [침해사고 분석 및 대응 절차](securityincidentanalysisresponse.md) | 분석 환경과 대응 흐름을 이해한다 |
| SEC-DEF-016-INS | 점검 | [[생성형 AI] 웹 취약점 방어 점검표](web-defense-checklist.md) | 웹 취약점별 방어 조치를 점검한다 |
| SEC-DEF-017-DO | 개념 | [[생성형 AI] 취약점 관리와 패치 절차](vulnerability-management.md) | 취약점 관리 순환과 우선순위를 이해한다 |
| SEC-DEF-018-DO | 개념 | [[생성형 AI] 사회공학과 피싱 방어](social-engineering-defense.md) | 사회공학 유형과 방어를 이해한다 |
| SEC-DEF-019-DO | 개념 | [[생성형 AI] 보안 로깅 설계](security-logging-design.md) | 기록 대상과 운영 기준을 이해한다 |
| SEC-DEF-020-DO | 개념 | [[생성형 AI] 백업과 랜섬웨어 방어](backup-ransomware-defense.md) | 랜섬웨어 예방·탐지·복구를 이해한다 |
| SEC-DEF-021-INS | 점검 | [[생성형 AI] Linux 서버 기본 하드닝 점검표](linux-hardening-checklist.md) | Linux 서버 기본 보안 설정을 점검한다 |

## 읽는 순서

1. SEC-DEF-001-DO, SEC-DEF-003-DO로 탐지와 관제 개념을 익힌다.
2. 네트워크 탐지는 SEC-DEF-005-MP 또는 SEC-DEF-006-MP, 호스트 탐지는 SEC-DEF-002-MP, 통합 관제는 SEC-DEF-007-MP를 따른다.
3. 웹 서비스 보호는 SEC-DEF-009-MP, 장비 모니터링은 SEC-DEF-012-MP를 따른다.
4. 사고가 의심되면 SEC-DEF-015-DO로 흐름을 확인하고 SEC-DEF-013-REF 또는 SEC-DEF-014-MP로 아티팩트를 수집한다.
