# 보안 툴박스 (Toolbox)

실습에서 자주 쓰는 도구의 개요, 옵션 표, 사용 절차를 모은다. 문서 번호(Task ID)는 `SEC-TBX-<번호>-<유형>` 형식이다.

{% hint style="danger" %}
WARNING: 이 그룹의 도구는 스캔, 요청 가로채기, 취약점 점검 기능을 가진다. 직접 소유·관리하거나 서면으로 허가받은 대상(격리된 실습 VM 포함)에서만 사용한다. 허가받지 않은 시스템에 쓰는 것은 불법이다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| SEC-TBX-001-DO | 개념 | [bee-box 환경 및 취약점 점검](bee-box.md) | 의도적 취약 VM bee-box의 용도와 점검 순서를 파악한다 |
| SEC-TBX-002-MP | 절차 | [ExifTool 메타데이터 분석](exiftool.md) | 파일 메타데이터를 확인하고 삭제한다 |
| SEC-TBX-003-DO | 개념 | [메타스플로잇 (Metasploit)](metasploit.md) | Metasploit 프레임워크의 구성과 콘솔 기본 개념을 파악한다 |
| SEC-TBX-004-REF | 표 | [넷캣 소켓 통신 (Netcat)](netcat.md) | `nc`의 기본 사용법과 주요 옵션을 찾는다 |
| SEC-TBX-005-DO | 개념 | [pfSense 방화벽 솔루션](pfsense.md) | pfSense의 용도를 파악한다 |
| SEC-TBX-006-REF | 표 | [Nmap 포트 스캐닝 도구](scaning-tool.md) | Nmap 스캔 방식, 타이밍, NSE 옵션을 찾는다 |
| SEC-TBX-007-DO | 개념 | [OWASP ZAP 진단 도구](zap.md) | ZAP의 기능과 스캔 방식을 파악한다 |

## 도구별 미작성 항목

| 도구 | 상태 |
|---|---|
| Setoolkit | 원본에 링크 없이 이름만 있었다. 문서가 없다 |

## 출력물

* [스캔 결과 모음 (Scan Results)](scan-results/README.md)
