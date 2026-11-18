# 보안 도구 (Tools)

실습 도구와 결과물(스캔 로그 등)을 모아둡니다.

* [Toolbox](toolbox/)

## 작업 식별

| 항목 | 내용 |
|---|---|
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 유형 | 그룹 README |
| 확인 상태 | 미검증 (기존 링크 한 줄에 용도 분류와 사용 원칙을 보충했다) |
| 개정 | R1 (2026-11-19) |

{% hint style="danger" %}
WARNING: 이 그룹의 도구는 스캔, 요청 가로채기, 취약점 점검 기능을 가진다. 직접 소유·관리하거나 서면으로 허가받은 대상(격리된 실습 VM 포함)에서만 사용한다. 허가받지 않은 시스템에 쓰는 것은 불법이다.
{% endhint %}

## 하위 그룹

| 그룹 | 용도 |
|---|---|
| [보안 툴박스 (Toolbox)](toolbox/README.md) | 도구별 개요, 옵션 표, 사용 절차를 찾는다 |
| [스캔 결과 모음](toolbox/scan-results/README.md) | 스캔 도구 출력을 읽는 방법을 확인한다 |

## 도구 용도 분류

| 용도 | 도구 문서 | 방어 측에서 남는 흔적 |
|---|---|---|
| 포트·서비스 탐색 | [Nmap](toolbox/scaning-tool.md) | 짧은 시간에 여러 포트로 접속 시도가 몰린다. [IDS](../defensive-security/defense/ids.md) 룰이 탐지한다 |
| 웹 취약점 진단 | [OWASP ZAP](toolbox/zap.md) | 웹 서버 로그에 짧은 시간의 대량 요청과 비정상 경로 요청이 남는다. [WAF](../defensive-security/defense/waf.md)가 차단한다 |
| 공격 프레임워크 | [Metasploit](toolbox/metasploit.md) | 취약한 서비스에 대한 비정상 접속과 프로세스 생성이 남는다. [HIDS](../defensive-security/defense/hids.md)가 감시한다 |
| 소켓 통신 유틸리티 | [Netcat](toolbox/netcat.md) | 비표준 포트로의 외부 연결이 남는다. 방화벽 로그에서 확인한다 |
| 파일 메타데이터 | [ExifTool](toolbox/exiftool.md) | 공개 파일에 위치·기기·작성자 정보가 남지 않게 배포 전 삭제한다 |
| 의도적 취약 환경 | [bee-box](toolbox/bee-box.md) | 실습 전용이다. 인터넷에 노출하지 않는다 |
| 방화벽 | [pfSense](toolbox/pfsense.md) | 실습망 경계 통제에 쓴다 |

## 사용 원칙

1. 대상 목록과 허용 시간을 정한 뒤 시작한다.
2. 실습 VM은 호스트 전용 또는 내부 네트워크에 두고 인터넷에 직접 연결하지 않는다.
3. 도구 출력에 실제 서비스의 주소나 계정이 섞이지 않게 한다. 문서에 옮길 때 `<대상 IP>`로 바꾼다.
4. 스캔 결과는 방어 조치(패치, 설정 변경, 룰 추가)로 이어질 때 의미가 있다.
