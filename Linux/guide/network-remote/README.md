---
description: 네트워크 진단, SSH 보안, 원격 접속, VPN, VLAN
---

# 네트워크 및 원격 접속

네트워크 진단 명령, `sshd` 보안 설정, VS Code 원격 SSH, 스위치·라우터 원격 접속, OpenVPN, VLAN 구성을 다룬다. 문서 번호(Task ID)는 `LNX-NRM-<번호>-<유형>` 형식이다. 유형은 MP(절차), REF(표)다. 네트워크 장비 설정과 `sshd_config` 변경은 원격 접속이 끊길 수 있으므로 각 문서의 WARNING을 먼저 읽는다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-NRM-001-REF | 표 | [네트워크 진단 명령어](networkcommands.md) | `ping`, `traceroute`, `nslookup`, `dig`, `host`, `hostname`을 참조한다 |
| LNX-NRM-002-MP | 절차 | [원격 접속 보안 관리 (sshd)](remote-access-management.md) | root 원격 로그인을 막고 `telnet-server`를 제거한다 |
| LNX-NRM-003-MP | 절차 | [VS Code 원격 SSH 연결](remote-ssh.md) | VS Code로 서버에 SSH 접속해 직접 편집한다 |
| LNX-NRM-004-MP | 절차 | [스위치 및 라우터 원격 접속 설정](remoteterminalaccess.md) | VTY 라인과 관리 IP를 설정해 `telnet`으로 접속한다 |
| LNX-NRM-005-MP | 절차 | [pfSense 기반 OpenVPN](open-vpn.md) | pfSense 가상 머신을 준비한다 (작성 중) |
| LNX-NRM-006-MP | 절차 | [스위치 기반 VLAN 구성](switch-based.md) | 포트 기반 VLAN, 트렁크, 라우터 게이트웨이를 설정한다 |
| LNX-NRM-007-MP | 절차 | [[생성형 AI] SSH 키 인증 설정](ssh-key-auth.md) | SSH 키 쌍을 만들고 키로 로그인한다 |
| LNX-NRM-008-REF | 표 | [[생성형 AI] 네트워크 설정 명령어 (ip, ss, nmcli)](ip-nmcli.md) | 주소, 경로, 소켓을 조회하고 nmcli로 설정한다 |
| LNX-NRM-009-REF | 표 | [[생성형 AI] scp·rsync 파일 전송](scp-rsync.md) | SSH로 파일을 복사하고 동기화한다 |

## 읽는 순서

1. LNX-NRM-001-REF로 네트워크 상태를 확인하는 명령을 익힌다.
2. LNX-NRM-002-MP로 서버의 원격 접속을 안전하게 설정한다.
3. LNX-NRM-003-MP로 개발 환경에서 서버에 접속한다.
4. LNX-NRM-004-MP, LNX-NRM-006-MP로 네트워크 장비를 설정한다.
5. LNX-NRM-005-MP로 VPN 실습 환경을 준비한다.
