# 패키지 관리 도구 (RPM, DNF)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-OPS-002-REF |
| 유형 | REF (표·명령) |
| 목적 | RHEL 계열 Linux의 `rpm`, `dnf` 명령과 패치 갱신 명령을 찾는다 |
| 적용 대상 | RHEL 계열 Linux 8 이상, root 권한 |
| 확인 상태 | 미검증 (원본 페이지와 man 문서 지식을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. RPM (Red Hat Package Manager)

형식: `rpm <옵션> <대상>`

| 옵션 | 뜻 | 예 |
|---|---|---|
| `-i` | 설치한다 | `rpm -ivh <파일>.rpm` |
| `-U` | 갱신한다. 설치되어 있지 않으면 새로 설치한다 | `rpm -Uvh <파일>.rpm` |
| `-v` | 진행 내용을 출력한다 | |
| `-h` | 진행 상황을 `#` 기호로 표시한다 | |
| `-e` | 삭제한다. 대상은 패키지 이름이다 | `rpm -e <패키지명>` |
| `-qa` | 설치된 패키지 전체를 조회한다 | `rpm -qa \| grep <패키지명>` |

{% hint style="warning" %}
CAUTION: `rpm`으로 설치하면 의존성 오류(`Failed dependencies`)가 날 수 있다. `rpm`은 의존 패키지를 자동으로 받지 않는다. 의존성은 `dnf`가 해결한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `rpm -e`로 삭제한 패키지가 실행 중인 서비스에 필요하면 서비스가 중단된다. 삭제 전에 `rpm -q --whatrequires <패키지명>`으로 이 패키지에 의존하는 패키지를 확인한다.
{% endhint %}

## 2. DNF

`dnf`는 의존성을 자동으로 해결하는 패키지 관리자이다. RHEL 8 이상에서 `yum` 명령은 `dnf`의 별칭이다.

| 명령 | 뜻 |
|---|---|
| `dnf install <패키지명>` | 저장소에서 내려받아 설치한다 |
| `dnf install ./<파일>.rpm` | 로컬 RPM 파일을 설치한다. 의존 패키지는 저장소에서 받는다 |
| `dnf localinstall <파일>.rpm` | 위와 같은 동작이다(`install`의 별칭) |
| `dnf list <패키지명>` | 패키지 목록과 정보를 조회한다 |
| `dnf remove <패키지명>` | 패키지를 제거한다 |
| `dnf group list` | 패키지 그룹 목록을 조회한다 (`dnf grouplist`도 같은 동작) |
| `dnf group install <그룹명>` | 그룹 단위로 설치한다 (`dnf groupinstall`도 같은 동작) |

{% hint style="warning" %}
CAUTION: `dnf remove`는 대상에 의존하는 패키지도 함께 제거한다. 실행 전에 출력되는 제거 목록을 확인하고, 운영 중인 서비스 패키지가 목록에 있으면 `N`을 입력해 취소한다.
{% endhint %}

## 3. 패치 관리

### 패치 버전 관리

패치는 새 버전 패키지로 갱신하는 방식으로 적용한다.

| 대상 | 명령 |
|---|---|
| RPM 파일로 갱신 | `rpm -Uvh <패키지명>-<버전>.rpm` |
| 저장소에서 한 패키지 갱신 | `dnf update <패키지명>` |
| 갱신 가능한 패키지 조회 | `dnf check-update` |

{% hint style="warning" %}
CAUTION: 갱신하면 실행 중인 서비스의 버전이 바뀌고 재시작이 필요할 수 있다. 운영 서버에서는 점검 시간에 갱신하고, 갱신 전에 현재 버전을 `rpm -q <패키지명>`으로 기록한다.
{% endhint %}

## 4. 참조

| 참조 | 용도 |
|---|---|
| [Exploit-DB](https://www.exploit-db.com/) | 공개된 취약점 공격 코드 데이터베이스(악성코드 공유 플랫폼이 아니다) |
| [CVE 정리](https://krjaeh0.gitbook.io/j-log/security/security/offensive-security/pentest/cve) | 취약점 식별 번호(CVE) 설명 |

## 5. 원본 정정 내역

| 원본 | 정정 |
|---|---|
| `-U`: "업데이트 없으면 다운로드" | 갱신, 없으면 설치로 정정 |
| `-h`: "다운로드 과정 상세 출력" | 진행 상황을 `#`로 표시로 정정 |
| `-e`: 삭제 | 대상이 패키지 이름임을 명시 |
| `rpm -Uvh httpd` | 파일명 형식 `<패키지명>-<버전>.rpm`으로 정정 |
| 빈 절 "바이너리" | 내용이 없어 삭제 |
| Exploit-DB를 "악성코드 공유 플랫폼"으로 설명 | 취약점 공격 코드 데이터베이스로 정정 |
