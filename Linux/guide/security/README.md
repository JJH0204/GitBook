---
description: firewalld, iptables, SELinux, TCP 래퍼
---

# 리눅스 보안

방화벽(firewalld, iptables), SELinux, TCP 래퍼로 서버의 접근을 제어하는 방법을 다룬다. 문서 번호(Task ID)는 `LNX-SEC-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차)다. 이 폴더의 명령은 실습용 가상 환경(RHEL 계열 9)을 전제로 한다.

{% hint style="danger" %}
WARNING: 이 폴더의 절차는 방화벽 규칙과 접근 제어를 바꾼다. 잘못 설정하면 SSH 접속이 끊긴다. 변경 전에 설정 파일을 백업하고 콘솔(가상 머신 화면, IPMI 등) 접근을 확보한다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-SEC-001-MP | 절차 | [firewalld 방화벽 관리](firewalld.md) | zone, 서비스, 소스, rich rule을 확인하고 설정한다 |
| LNX-SEC-002-MP | 절차 | [iptables 방화벽 규칙](iptables.md) | iptables로 규칙을 추가하고 저장한다 |
| LNX-SEC-003-DO | 개념 | [SELinux 보안 모듈](selinux.md) | SELinux 모드, 컨텍스트, 로그를 이해한다 |
| LNX-SEC-004-MP | 절차 | [SELinux 모드 변경](selinux-mode.md) | SELinux 모드를 임시 또는 영구로 바꾼다 |
| LNX-SEC-005-MP | 절차 | [SELinux 파일 컨텍스트 변경](selinux-context.md) | 파일 유형(type) 레이블을 바꾸고 복원한다 |
| LNX-SEC-006-MP | 절차 | [TCP 래퍼 접근 제어](tcpwrapper.md) | hosts.allow, hosts.deny로 접근을 제어한다 |

## 읽는 순서

1. LNX-SEC-001-MP 또는 LNX-SEC-002-MP로 방화벽을 설정한다. 둘 중 하나만 사용한다.
2. LNX-SEC-003-DO로 SELinux 개념을 익힌다.
3. LNX-SEC-004-MP, LNX-SEC-005-MP로 SELinux 모드와 레이블을 다룬다.
4. LNX-SEC-006-MP는 TCP 래퍼를 지원하는 구버전 환경에서 쓴다.
