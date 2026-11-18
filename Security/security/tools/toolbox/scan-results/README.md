# 스캔 결과 모음 (Scan Results)

의도적 취약 VM(Cybersploit)에 대해 실습 중 실행한 스캔 도구(nmap, nikto, dirb, searchsploit)의 출력을 읽는 방법을 정리한다. 문서 번호(Task ID)는 `SEC-SCN-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 REF(출력 읽는 법)다.

{% hint style="danger" %}
WARNING: 허가받지 않은 시스템을 스캔하는 것은 불법이다. 이 그룹의 스캔은 자신이 소유·관리하는 격리된 실습망(VirtualBox 호스트 전용 네트워크)의 VM에서만 수행한다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| SEC-SCN-001-REF | 출력 | [Nikto 스캔: Cybersploit 1](nikto_cybersploit_result.md) | Nikto 출력 줄을 읽는다 (Apache 2.2.22 대상) |
| SEC-SCN-002-REF | 출력 | [Nikto 스캔: Cybersploit 2](nikto_cybersploit2_result.md) | Nikto 출력 줄을 읽는다 (Apache 2.4.37 대상) |
| SEC-SCN-003-REF | 출력 | [Nmap 스캔: Cybersploit 1](nmap_cybersploit.md) | 포트 스캔 출력의 열과 상태를 읽는다 |
| SEC-SCN-004-REF | 출력 | [Nmap 네트워크 스캔 로그](nmap_cybersploit_d.md) | 서브넷 전체 스캔 출력과 서비스 버전 열을 읽는다 |
| SEC-SCN-005-REF | 출력 | [DIRB 스캔: Cybersploit 1](dirb_cybersploit_result.md) | 디렉터리 무차별 탐색 출력의 코드와 크기를 읽는다 |
| SEC-SCN-006-REF | 출력 | [Searchsploit 검색 로그](searchsploit_cybersploit_result.md) | 취약점 검색 결과의 제목 구조를 읽는다 (단편) |

## 읽는 순서

1. SEC-SCN-004-REF로 서브넷 전체에서 대상 호스트를 찾는다.
2. SEC-SCN-003-REF로 대상의 열린 포트를 읽는다.
3. SEC-SCN-005-REF와 SEC-SCN-001-REF로 웹 서버의 노출 항목을 읽는다.
4. SEC-SCN-006-REF로 서비스 버전과 관련된 알려진 취약점 이름을 읽는다.

## 공통 사항

- 모든 문서의 확인 상태는 미검증이다. 원본 출력과 일반 지식을 정리한 것이며 이 환경에서 스캔을 실행하지 않았다.
- 대상 IP·MAC 주소는 `<대상 IP>`, `<MAC 주소>`로 바꿨다.
- 스캔 도구 사용 절차는 [도구 상자](../README.md)를 먼저 확인한다.
