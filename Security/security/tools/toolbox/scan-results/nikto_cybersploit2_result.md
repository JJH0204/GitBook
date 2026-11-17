# Nikto 스캔: Cybersploit 2

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-SCN-002-REF |
| 유형 | REF (출력 읽는 법) |
| 목적 | Nikto 출력의 줄을 읽는다 (Apache 2.4.37 CentOS 대상) |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱) |
| 확인 상태 | 미검증 (원본 출력과 일반 지식을 정리한 것이며 스캔을 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="danger" %}
WARNING: 허가받지 않은 웹 서버를 스캔하는 것은 불법이다. 격리된 실습망의 소유·관리 대상에서만 수행한다.
{% endhint %}

## 1. 도구 개요

실행한 명령은 `nikto -h <대상 IP> -C all`이다. `-h`는 대상, `-C all`은 모든 CGI 디렉터리 검사다. 출력 줄의 구조는 [SEC-SCN-001-REF](nikto_cybersploit_result.md)의 2절과 같다. 이 스캔은 포트 80에 26,639개 요청을 79초 동안 보냈다.

## 2. 이 출력에서 읽을 수 있는 정보

| 발견 항목 | 의미 | 위험 |
|---|---|---|
| Server: Apache/2.4.37 (centos) | 서버 이름, 버전, 배포판이 헤더로 노출된다. Nikto가 오래된 버전으로 보고했다 | 버전 기반 취약점 검색의 단서 |
| X-Frame-Options 헤더 없음 | 프레임 삽입 방지 헤더가 없다 | 클릭재킹 |
| X-Content-Type-Options 헤더 없음 | MIME 유형 추측 방지 헤더가 없다 | 콘텐츠 유형 혼동 |
| 허용 메서드에 TRACE 포함 | HTTP TRACE가 켜져 있다 | XST(Cross-Site Tracing) 가능성 |
| `/icons/` 디렉터리 인덱싱 | 디렉터리 파일 목록이 공개된다 | 내부 파일 이름 노출 |
| `/icons/README` 존재 | Apache 기본 파일이 남아 있다 | 버전 정보 노출 |

{% hint style="info" %}
NOTE: 원본의 보고 문구 "Apache 2.2.34 is the EOL for the 2.x branch"는 Nikto 고정 문구이며 2.4.37이 2.2 계열이라는 뜻이 아니다. 2.4.37은 2.4 계열의 구버전이다.
{% endhint %}

Cybersploit 1과 비교하면 ETag inode 노출, MultiViews, 백업 파일 항목은 없고 TRACE와 디렉터리 인덱싱이 새로 나왔다. 항목 수는 9개에서 7개로 줄었다.

## 3. 탐지·방어

| 항목 | 내용 |
|---|---|
| 서버 로그의 흔적 | `access_log`에 79초 안에 약 26,000건의 요청이 한 출발지에서 기록되고 대부분 404다. User-Agent에 `Nikto`가 들어가며 `TRACE` 메서드 요청이 한 건 보인다 |
| 탐지 | [SEC-SCN-001-REF](nikto_cybersploit_result.md)의 탐지 방법과 같다 |
| 완화 | `TraceEnable off`로 TRACE를 끈다. `Options -Indexes`로 디렉터리 인덱싱을 끄고 `/icons/` 별칭과 README를 제거한다. `ServerTokens Prod`, `ServerSignature Off`로 버전 노출을 줄이고 보안 헤더(`X-Frame-Options`, `X-Content-Type-Options`)를 설정한다. Apache를 지원되는 최신 패치 버전으로 올린다 |

## 4. 원본 출력

원본 Nikto 전체 출력은 위 표와 같은 내용이므로 이 문서에서 제거했다. 필요하면 같은 명령을 허가받은 실습 환경에서 다시 실행한다.

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식 REF로 재구성. 요약과 원문이 중복이어서 원문 접기 블록을 삭제하고 IP를 가림. "Apache 2.2.34 EOL" 문구 오해를 NOTE로 정정 |
