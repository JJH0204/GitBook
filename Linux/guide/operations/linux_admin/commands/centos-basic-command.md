# CentOS 기본 명령어 모음

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-LAC-005-REF |
| 유형 | REF (명령 표) |
| 목적 | RHEL 계열(CentOS 포함) 서버에서 자동 업데이트 끄기, IP 설정 변경, 경로 표기, 텍스트 편집기 명령을 참조한다 |
| 적용 대상 | RHEL 계열 리눅스(CentOS Stream, Rocky Linux, AlmaLinux 등) |
| 확인 상태 | 미검증 (원본 페이지와 systemd, NetworkManager 문서 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: CentOS Linux는 지원이 끝난 배포판이다. CentOS Linux 8은 2021-12-31에, CentOS Linux 7은 2024-06-30에 지원이 끝났다. 이후에는 CentOS Stream, Rocky Linux, AlmaLinux 같은 RHEL 계열 배포판을 쓴다. 이 문서의 명령은 RHEL 계열 공통 명령이다. 버전에 따라 설정 파일 위치가 다르며 해당 항목에 표시했다.
{% endhint %}

## 1. 다른 문서에 있는 명령

원본에 있던 아래 항목은 같은 스페이스의 [리눅스 기본 필수 명령어](../../../commands/linuxcommand.md)(LNX-CMD-002-REF)에 정리돼 있다. 중복을 피하려고 이 문서에서는 위치만 안내한다.

| 항목 | 명령 | 상세 |
|---|---|---|
| 전원 끄기와 재부팅 | `halt`, `shutdown`, `reboot` | LNX-CMD-002-REF 1절 |
| 런레벨 확인과 변경 | `init`, `systemctl get-default`, `systemctl set-default` | LNX-CMD-002-REF 2절 |
| 화면 지우기, 가상 콘솔 | `clear`, `Ctrl + Alt + F1`~`F6`, `chvt` | LNX-CMD-002-REF 3절 |
| 이동·목록·출력·기록 | `cd`, `ls`, `cat`, `history` | LNX-CMD-002-REF 3절 |

{% hint style="info" %}
NOTE: 원본의 `init 1` 설명("비밀번호를 잊었을 때 재설정")과 `ln -sf /usr/lib/systemd/system/multi-user.target` 명령의 정정 내용은 LNX-CMD-002-REF에 있다. `init 2`, `init 4`는 systemd에서 `multi-user.target`에 대응하며 별도 구분하지 않는다. 미검증이다.
{% endhint %}

## 2. 자동 업데이트 끄기

{% hint style="warning" %}
CAUTION: 자동 업데이트를 끄면 보안 패치가 자동으로 내려오지 않는다. 운영 서버에서는 끄지 않고, 끈 경우 정기적으로 수동 갱신한다([패키지 관리 도구](../../linuxpackagemanagementtool.md)).
{% endhint %}

| 목적 | 명령 | 권한 |
|---|---|---|
| GNOME 소프트웨어의 업데이트 다운로드 끄기 | `gsettings set org.gnome.software download-updates false` | 해당 사용자 (GUI 세션) |
| 메타데이터 캐시 갱신 서비스 비활성화 | `systemctl disable dnf-makecache.service` | root |
| 메타데이터 캐시 갱신 타이머 비활성화 | `systemctl disable dnf-makecache.timer` | root |

{% hint style="info" %}
NOTE: `dnf-makecache`는 DNF 계열(CentOS 8 이상)의 서비스다. CentOS 7은 `yum`을 쓰므로 해당 서비스가 없을 수 있다. 미검증이다.
{% endhint %}

## 3. IP 설정 변경

| 항목 | 값 |
|---|---|
| 설정 파일 (NetworkManager keyfile 방식) | `/etc/NetworkManager/system-connections/<인터페이스 이름>.nmconnection` |
| 인터페이스 이름 예 | `enp0s3` (VirtualBox 가상 머신의 기본 이름이며 환경마다 다르다) |

{% hint style="warning" %}
CAUTION: 원격(SSH)으로 접속한 상태에서 랜카드를 끄면 접속이 끊긴다. 이 상태에서는 다시 켜는 명령을 실행할 수 없다. 서버 콘솔에서 작업한다.
{% endhint %}

| 목적 | 명령 | 권한 |
|---|---|---|
| 인터페이스 이름 확인 | `nmcli device status` | 일반 사용자 |
| 랜카드 끄기 | `nmcli connection down <인터페이스 이름>` | root |
| 랜카드 켜기 | `nmcli connection up <인터페이스 이름>` | root |
| 수정한 설정 파일 다시 읽기 | `nmcli connection reload` | root |

{% hint style="info" %}
NOTE: 설정 파일 경로는 NetworkManager keyfile 방식(RHEL 9 계열 기본) 기준이다. RHEL 8 이하는 `/etc/sysconfig/network-scripts/ifcfg-<인터페이스 이름>`을 쓸 수 있다. `nmcli device status`와 `nmcli connection reload`는 원본에 없던 보충이며 미검증이다.
{% endhint %}

## 4. 절대 경로와 상대 경로

| 종류 | 설명 | 예 |
|---|---|---|
| 절대 경로 | `/`부터 대상까지 전체를 쓴다 | `cd /etc` |
| 상대 경로 | 현재 디렉터리를 기준으로 쓴다 | `cd ../etc` (현재 위치가 `/home`이면 `/etc`로 이동한다) |

{% hint style="info" %}
NOTE: 원본 예 `cd /etc/passwd`, `cd ../passwd`는 `passwd`가 파일이라 `cd`가 실패한다. 디렉터리 `/etc`로 바꿔 정정했다. 파일 내용을 보려면 `cat /etc/passwd`를 쓴다. 미검증이다.
{% endhint %}

## 5. 텍스트 편집기

| 편집기 | 종류 | 비고 |
|---|---|---|
| `vi` | 터미널 | 대부분의 배포판에 설치돼 있다 |
| `nano` | 터미널 | 설치돼 있지 않을 수 있다 |
| `gedit` | GUI | 그래픽 환경에서만 쓴다 |

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [linuxcommand.md](../../../commands/linuxcommand.md) | LNX-CMD-002-REF | 리눅스 기본 필수 명령어 |
| [linuxpackagemanagementtool.md](../../linuxpackagemanagementtool.md) | | 패키지 관리 도구 (RPM, DNF) |
| [directorycommands.md](directorycommands.md) | LNX-LAC-003-REF | 디렉터리 조작 명령어 |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | REF 형식으로 재작성. CentOS 지원 종료 NOTE를 추가하고 LNX-CMD-002-REF와 겹치는 명령은 링크로 대체했다. `cd /etc/passwd` 예를 정정하고 자동 업데이트와 네트워크 명령에 CAUTION을 추가했다 |
