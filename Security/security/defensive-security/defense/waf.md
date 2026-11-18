# 웹 애플리케이션 방화벽 (WAF)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-009-MP |
| 목적 | Apache(httpd)에 ModSecurity를 설치하고 사용자 룰과 OWASP CRS로 위험한 웹 요청을 차단한다 |
| 적용 대상 | RHEL 계열 9, Apache httpd 실행 중인 서버(실습망), root 권한 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: WAF(Web Application Firewall)는 웹 서비스가 동작하는 서버에서 HTTP 요청을 검사해 SQL 인젝션, XSS, 경로 조작 같은 공격을 막는 방화벽이다. 원본의 `/etc/shadow` 시험, 로그 확인 절은 내용이 비어 있어 그대로 옮기지 못한 부분을 6절에 표시했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Kubernetes 환경의 WAF 구성](waf_in_kubernetes.md) | SEC-DEF-010-MP | 컨테이너 환경의 WAF |
| [침입 탐지 시스템 (IDS)](ids.md) | SEC-DEF-001-DO | 네트워크 계층 탐지와의 차이 |
| OWASP CRS | - | https://owasp.org/www-project-modsecurity-core-rule-set/ |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 웹 서버 | RHEL 계열 9, Apache httpd 실행 중 | 웹 서비스가 활성화되어 있어야 한다 |
| 2 | 다른 PC | 웹 브라우저 또는 `curl` | 시험 요청용 |
| 3 | 콘솔 접근 | 가상 머신 화면 | httpd 시작 실패에 대비한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 룰 문법이 틀리면 httpd가 시작되지 않아 웹 서비스가 중단된다. 설정을 바꾼 뒤에는 반드시 `apachectl configtest`로 검사하고 `Syntax OK`를 확인한 다음 재시작한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `SecRuleEngine On`에서 `deny` 룰이 정상 요청과 일치하면 정상 사용자가 차단된다. 처음에는 `SecRuleEngine DetectionOnly`(탐지만 하고 차단하지 않음)로 로그를 확인한 뒤 `On`으로 바꾸는 것이 안전하다(원본에 없던 보충, 미검증).
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | httpd가 실행 중이다: `systemctl is-active httpd` | `active`가 출력된다 |
| 2 | 로드된 모듈을 확인한다: `httpd -M` | 모듈 목록이 출력된다 |
| 3 | 현재 설정을 백업한다: `cp -a /etc/httpd /etc/httpd.bak` | `/etc/httpd.bak`이 생긴다 |

## 5. 절차

### A. ModSecurity 설치

1. (5-A-01) 설치한다: `dnf install -y mod_security` → 결과: 설치가 끝난다.
2. (5-A-02) 모듈이 로드됐는지 확인한다: `httpd -M | grep security` → 결과: `security2_module`이 보인다.
3. (5-A-03) 설정 파일 위치를 확인한다: `ls /etc/httpd/conf.d/mod_security.conf` → 결과: 파일이 있다. (원본은 경로를 적지 않고 `mod_security.conf`라고만 적었다. 확인 필요.)

### B. 기본 설정

1. (5-B-01) 설정 파일을 연다: `vi /etc/httpd/conf.d/mod_security.conf`
2. (5-B-02) 아래 항목을 확인하거나 설정한다.

```
SecRuleEngine On
SecRequestBodyAccess On
SecRule REQUEST_HEADERS:Content-Type "text/xml" \
     "id:'200000',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=XML"
SecRequestBodyLimit 13107200
SecRequestBodyNoFilesLimit 131072
SecRequestBodyInMemoryLimit 131072
SecRequestBodyLimitAction Reject
SecPcreMatchLimit 1000
```

→ 결과: 각 항목의 뜻은 아래 표와 같다. (원본은 줄 끝에 `//` 설명을 달았으나 설정 파일의 주석은 `#`이므로 표로 옮겼다.)

| 지시어 | 뜻 |
|---|---|
| `SecRuleEngine On` | 룰 적용 여부. `Off`면 비활성, `DetectionOnly`면 탐지만 한다 |
| `SecRequestBodyAccess On` | 요청 본문(body)도 검사한다 |
| `SecRequestBodyLimit` | 요청 본문의 최대 크기(바이트) |
| `SecRequestBodyNoFilesLimit` | 파일 업로드를 제외한 본문의 최대 크기 |
| `SecRequestBodyInMemoryLimit` | 메모리에 보관하는 본문의 최대 크기 |
| `SecRequestBodyLimitAction Reject` | 제한을 넘으면 요청을 거부한다 |
| `SecPcreMatchLimit` | 정규식 일치에 쓰는 시간·자원 제한 |

### C. 사용자 룰 작성

1. (5-C-01) 룰 디렉터리로 이동한다: `cd /etc/httpd/modsecurity.d` → 결과: 디렉터리가 있다.
2. (5-C-02) 룰 파일을 연다: `vi ./local_rules/modsecurity_localrules.conf`
3. (5-C-03) 기본 동작을 지정한다: `SecDefaultAction "phase:2,deny,log,status:406"` → 결과: 일치하는 요청은 차단하고 로그에 남기며 클라이언트에 406 응답을 준다.
4. (5-C-04) 룰을 추가한다.

```
SecRule REQUEST_URI "/etc/passwd" "id:'500001'"
SecRule REQUEST_URI "../../" "id:'500002'"
SecRule ARGS "<[Ss][Cc][Rr][Ii][Pp][Tt]>" "id:'500003'"
```

→ 결과: 각 룰의 의미는 아래와 같다. 룰의 `id`는 중복할 수 없다.

| id | 탐지 대상 |
|---|---|
| 500001 | 요청 주소에 `/etc/passwd`가 있는 경우 (시스템 파일 접근 시도) |
| 500002 | 요청 주소에 `../../`가 있는 경우 (디렉터리 이동 시도) |
| 500003 | 요청 인자에 `<script>`가 있는 경우 (XSS 시도) |

### D. 설정 검사와 적용

1. (5-D-01) 설정을 검사한다: `apachectl configtest` → 결과: `Syntax OK`가 출력된다.
2. (5-D-02) httpd를 재시작한다: `systemctl restart httpd` → 결과: 오류 없이 끝나고 `systemctl is-active httpd`가 `active`다.

### E. CRS(Core Rule Set) 설치

1. (5-E-01) 설치한다: `dnf install -y mod_security_crs` → 결과: 설치가 끝난다.
2. (5-E-02) 룰 위치를 확인한다: `ls /usr/share/mod_modsecurity_crs/rules` → 결과: `REQUEST-...conf` 형태의 룰 파일이 나열된다. 경로는 원본 기준이며 배포판에 따라 다르다(확인 필요).
3. (5-E-03) 필요한 룰 파일을 확인한다. 예: `vi ./REQUEST-903.9002-WORDPRESS-EXCLUSION-RULES.conf` → 결과: 워드프레스용 예외 룰이 보인다. CRS 룰은 오탐이 있을 수 있으므로 서비스에 맞는 예외를 따로 둔다.
4. (5-E-04) 5-D와 같이 설정을 검사하고 재시작한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `curl -i http://<서버 IP>/etc/passwd` | 룰 500001이 일치해 차단된다 | 응답 코드 `406` |
| 2 | `curl -i "http://<서버 IP>/../../"` | 룰 500002가 일치해 차단된다 | 응답 코드 `406`. `curl`은 `../`를 정리해 보낼 수 있으므로 `--path-as-is` 옵션을 쓴다(확인 필요) |
| 3 | `curl -i http://<서버 IP>/etc/shadow` | 룰이 없어 차단되지 않는다 | 응답 코드 `404`(파일이 없음). 룰을 만들지 않았기 때문이다 |
| 4 | `tail /var/log/httpd/modsec_audit.log` | 차단한 요청이 기록된다 | 룰 id `500001` 등이 보인다 |

로그: 경고는 감사(audit) 로그에 기록되고, 디버그 로그는 `SecDebugLog`로 켠다. 원본의 두 항목은 내용이 비어 있었다("아직 별 내용이 없다"). 경로는 배포판 기본값이며 확인 필요다.

## 7. 복구

1. (7-01) 룰 엔진을 끈다: `/etc/httpd/conf.d/mod_security.conf`에서 `SecRuleEngine Off`로 바꾼다.
2. (7-02) 설정을 검사하고 재시작한다: `apachectl configtest` 이어서 `systemctl restart httpd` → 결과: `Syntax OK`, 웹 서비스가 정상 응답한다.
3. (7-03) 전체를 되돌리려면 `rm -rf /etc/httpd && cp -a /etc/httpd.bak /etc/httpd` 이어서 `systemctl restart httpd`를 입력한다.
4. (7-04) 패키지를 제거하려면 `dnf remove -y mod_security mod_security_crs`를 입력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 소제목 나열이던 원본을 MP 형식으로 재작성. 설정 파일 주석 `//`를 `#` 기준 표로 정정하고, 구문 오류·오탐으로 인한 서비스 중단 CAUTION, 기능 확인, 복구 절을 추가했다. 깨진 이미지 참조 1건은 삭제했다 |
