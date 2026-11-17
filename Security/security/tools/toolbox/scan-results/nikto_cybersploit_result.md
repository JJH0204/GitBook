# Nikto 스캔: Cybersploit 1

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-SCN-001-REF |
| 유형 | REF (출력 읽는 법) |
| 목적 | Nikto 웹 서버 점검 출력의 줄을 읽는다 (Apache 2.2.22 대상) |
| 적용 대상 | 허가받은 격리 실습 환경(자신이 소유·관리하는 VM 또는 의도적 취약 앱) |
| 확인 상태 | 미검증 (원본 출력과 일반 지식을 정리한 것이며 스캔을 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="danger" %}
WARNING: 허가받지 않은 웹 서버를 스캔하는 것은 불법이다. 격리된 실습망의 소유·관리 대상에서만 수행한다.
{% endhint %}

## 1. 도구 개요

Nikto는 웹 서버의 알려진 위험 파일, 오래된 버전, 설정 미흡을 점검하는 스캐너다. 기본 호출은 `nikto -h <대상 IP>`이며 `-C all`은 모든 CGI 디렉터리를 검사한다. 이 출력은 포트 80에 대한 약 26,640개 요청을 54초 동안 보낸 결과다.

## 2. 출력 구조

| 줄 | 뜻 |
|---|---|
| `Target IP / Hostname / Port` | 점검 대상 |
| `Start Time` / `End Time` | 시작·종료 시각 |
| `+ Server:` | 응답 헤더의 서버 이름과 버전 |
| `+ <경로>: <내용>. See: <링크>` | 발견 항목. 경로가 앞에 오고 참조 링크가 뒤에 붙는다 |
| `N requests: M error(s) and K item(s)` | 보낸 요청 수, 오류 수, 보고된 항목 수 |

## 3. 이 출력에서 읽을 수 있는 정보

| 발견 항목 | 의미 | 위험 |
|---|---|---|
| Server: Apache/2.2.22 (Ubuntu) | 서버 이름과 버전이 헤더로 노출된다. 2.2 계열은 지원 종료(EOL)다 | 알려진 취약점 검색의 단서가 된다 |
| ETag에 inode 노출 (CVE-2003-1418) | `ETag` 헤더에 파일의 inode·크기·수정 시각이 들어간다 | 서버 내부 정보가 유출된다 |
| X-Frame-Options 헤더 없음 | 다른 사이트가 이 페이지를 프레임에 넣을 수 있다 | 클릭재킹 |
| X-Content-Type-Options 헤더 없음 | 브라우저가 MIME 유형을 추측해 렌더링할 수 있다 | 콘텐츠 유형 혼동 |
| mod_negotiation MultiViews 활성 | `/index`처럼 확장자 없는 요청이 `index.html`로 연결된다 | 파일 이름 추측이 쉬워진다 |
| 허용 HTTP 메서드: GET, HEAD, POST, OPTIONS | 위험한 메서드(PUT, DELETE, TRACE)는 없다 | 양호 |
| `/icons/README` 존재 | Apache 기본 파일이 남아 있다 | 버전 정보 노출 |
| `/#wp-config.php#` 존재 | 편집기 임시 백업 형태의 파일명이다. Nikto는 자격 증명 파일 가능성으로 보고한다 | 실제 내용은 열어 확인해야 한다. 이 출력만으로 자격 증명 존재가 확인되지는 않는다 |

## 4. 탐지·방어

| 항목 | 내용 |
|---|---|
| 서버 로그의 흔적 | `access_log`에 54초 안에 약 26,000건의 요청이 한 출발지에서 기록되고 대부분 404다. User-Agent에 `Nikto` 문자열이 기본으로 들어간다 (옵션으로 바꿀 수 있다). `/#wp-config.php#`, `/icons/README` 같은 점검용 경로 요청이 보인다 |
| 탐지 | User-Agent 문자열 규칙, 분당 요청 수·404 비율 임계값, WAF·IDS 규칙(Snort·Suricata의 Nikto 시그니처)으로 탐지한다 |
| 버전 노출 축소 | Apache `ServerTokens Prod`, `ServerSignature Off`를 설정한다. 지원 종료 버전(2.2)을 지원되는 버전으로 올린다 |
| 설정 보강 | `Header always set X-Frame-Options "SAMEORIGIN"`, `X-Content-Type-Options "nosniff"`를 설정한다. `Options -MultiViews`로 MultiViews를 끄고 `FileETag MTime Size`로 inode를 뺀다. `/icons/` 별칭과 README를 제거하고 웹 루트의 백업·임시 파일(`#*#`, `*~`, `*.bak`)을 삭제한다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [nikto_cybersploit2_result.md](nikto_cybersploit2_result.md) | SEC-SCN-002-REF | Nikto 스캔: Cybersploit 2 |
| [dirb_cybersploit_result.md](dirb_cybersploit_result.md) | SEC-SCN-005-REF | DIRB 스캔: Cybersploit 1 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식 REF로 재구성. 출력 원문을 요약 표로 대체하고 IP를 가림 |
