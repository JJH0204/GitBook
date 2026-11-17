---
description: 파티셔닝, 마운트, 디스크 점검, 부트 로더, 런레벨, 디스크 용량 점검 문서
---

# 스토리지 및 부팅

디스크 파티션, 파일 시스템 마운트, 디스크 상태 점검, 부트 로더, 런레벨(systemd target), 디스크 용량 경보를 다룬다. 문서 번호(Task ID)는 `LNX-STB-<번호>-<유형>` 형식이다.

{% hint style="danger" %}
WARNING: 이 그룹의 문서 중 `/etc/fstab`, 부트 로더, 기본 런레벨(target)을 바꾸는 작업은 잘못되면 시스템이 부팅되지 않는다. 각 문서의 WARNING을 읽고, 복구 콘솔(설치 미디어 또는 rescue 부팅)을 확보한 뒤 작업한다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-STB-001-DO | 개념 | [디스크 드루이드 파티셔닝 도구](disk_druid.md) | 설치 프로그램의 파티셔닝 도구 개념을 이해한다 |
| LNX-STB-002-REF | 표 | [스마트몬툴즈 디스크 점검 도구](smarttool.md) | `smartctl` 옵션을 찾는다 |
| LNX-STB-003-MP | 절차 | [smartctl 디스크 상태 점검](smartctl-check.md) | 디스크 SMART 상태를 점검한다 |
| LNX-STB-004-DO | 개념 | [LILO 부트 로더](lilo.md) | 구형 부트 로더 LILO를 이해한다 |
| LNX-STB-005-DO | 개념 | [런레벨 정의표 (Runlevel)](runlevel.md) | 런레벨과 systemd target의 대응을 이해한다 |
| LNX-STB-006-MP | 절차 | [디스크 용량 확인 스크립트 (df)](df.md) | 디스크 사용률 경보 스크립트를 만든다 |
| LNX-STB-007-REF | 표 | [df 명령어 참조](df-command.md) | `df` 옵션과 출력 열을 찾는다 |
| LNX-STB-008-REF | 표 | [파일 시스템 마운트 (mount)](mount.md) | `mount`, `umount` 옵션과 `/etc/fstab` 필드를 찾는다 |
| LNX-STB-009-MP | 절차 | [파일 시스템 마운트와 fstab 등록](mount-fstab.md) | 장치를 마운트하고 부팅 때 자동 마운트하게 한다 |

## 읽는 순서

1. LNX-STB-001-DO로 파티셔닝 개념을 본다.
2. LNX-STB-008-REF와 LNX-STB-009-MP로 마운트를 익힌다.
3. LNX-STB-003-MP로 디스크 상태를, LNX-STB-006-MP로 용량을 점검한다.
4. LNX-STB-004-DO와 LNX-STB-005-DO로 부팅 과정을 이해한다.
