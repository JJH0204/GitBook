# [생성형 AI] 리눅스 부팅 과정과 GRUB2

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-STB-011-DO |
| 유형 | D&O (개념) |
| 목적 | 전원을 켠 뒤 로그인 화면까지의 부팅 단계와 GRUB2, systemd의 역할을 설명한다 |
| 확인 상태 | 일부 확인 (Ubuntu 26.04에서 `/boot`, `/boot/grub`, `/etc/default/grub`, `/etc/grub.d`, `/sys/firmware/efi`, `systemctl get-default`, `systemd-analyze`를 읽기 전용으로 확인했다. RHEL 계열 경로와 명령은 미검증) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 1. 목적

부팅 과정을 단계별로 알면 부팅 실패 때 어느 단계에서 멈췄는지 좁힐 수 있다. 구형 부트 로더 LILO는 [LILO 부트 로더](lilo.md)를 본다. 현재 대부분의 배포판은 GRUB2와 systemd를 쓴다.

## 2. 구성 요소

| 번호 | 구성 요소 | 역할 | 위치·확인 |
|---|---|---|---|
| 1 | 펌웨어(UEFI 또는 BIOS) | 하드웨어를 점검하고 부트 로더를 찾아 실행한다 | UEFI 여부: `/sys/firmware/efi` 디렉터리가 있으면 UEFI로 부팅한 것이다 |
| 2 | 부트 로더(GRUB2) | 커널과 initramfs를 메모리에 올리고 커널 매개변수를 넘긴다 | 설정 생성 결과 `/boot/grub/grub.cfg`(Debian 계열) |
| 3 | 커널 | 하드웨어를 초기화하고 루트 파일 시스템을 마운트한다 | `/boot/vmlinuz-<버전>` |
| 4 | initramfs | 루트 파일 시스템을 마운트하는 데 필요한 드라이버를 담은 임시 루트 | `/boot/initrd.img-<버전>` |
| 5 | systemd(PID 1) | 서비스를 시작하고 기본 target에 도달한다 | 기본 target: `systemctl get-default` |

EFI 시스템 파티션(ESP)은 vfat 파일 시스템이며 보통 `/boot/efi`에 마운트된다(실행 확인: `/dev/sda1 vfat /boot/efi`).

## 3. 동작 원리

1. 전원을 켜면 펌웨어가 하드웨어를 점검한다(POST).
2. 펌웨어가 부트 로더를 찾아 실행한다. UEFI는 ESP의 부트 로더 파일을, BIOS는 디스크 첫 섹터(MBR)를 읽는다.
3. GRUB2가 부팅 메뉴를 보여 주고 선택한 커널과 initramfs를 메모리로 읽는다.
4. 커널이 시작하고 initramfs를 임시 루트로 사용해 실제 루트 파일 시스템을 마운트한다.
5. 커널이 systemd를 PID 1로 실행한다.
6. systemd가 기본 target(예: `multi-user.target`, `graphical.target`)에 필요한 서비스를 병렬로 시작한다.
7. 로그인 프롬프트(또는 그래픽 로그인)가 나온다.

단계별 소요 시간은 `systemd-analyze`로 볼 수 있다(실행 확인 출력 형식: `Startup finished in <펌웨어> (firmware) + <로더> (loader) + <커널> (kernel) + <initrd> (initrd) + <사용자 공간> (userspace)`).

### GRUB2 설정 구조(Debian 계열 기준)

| 파일 | 역할 |
|---|---|
| `/etc/default/grub` | 기본 항목, 대기 시간, 커널 매개변수 같은 사람이 편집하는 설정 |
| `/etc/grub.d/` | 메뉴 항목을 만드는 스크립트 모음(`10_linux`, `40_custom` 등) |
| `/boot/grub/grub.cfg` | 위 설정으로 생성된 결과. 직접 편집하지 않는다 |

설정을 바꾼 뒤에는 `grub.cfg`를 다시 생성해야 한다. 명령은 배포판마다 다르다(Debian 계열 `update-grub`, RHEL 계열 `grub2-mkconfig -o <출력 경로>`). 이 문서의 환경에서는 실행하지 않았다.

{% hint style="danger" %}
WARNING: GRUB 설정이나 부트 로더를 잘못 바꾸면 시스템이 부팅되지 않는다. 변경 전에 `/etc/default/grub`을 백업하고, 복구용 설치 미디어 또는 rescue 부팅 수단을 확보한다.
{% endhint %}

{% hint style="info" %}
NOTE: 부팅 때 GRUB 메뉴에서 커널 매개변수를 일시적으로 바꿀 수 있다. 현재 부팅에 쓰인 매개변수는 `/proc/cmdline`에서 읽는다. 이 파일에는 루트 장치 UUID 등이 포함될 수 있으므로 공개 게시판에 그대로 붙여 넣지 않는다.
{% endhint %}

## 4. 관련 문서

| Task ID | 문서 | 용도 |
|---|---|---|
| LNX-STB-004-DO | [LILO 부트 로더](lilo.md) | 구형 부트 로더와 비교한다 |
| LNX-STB-005-DO | [런레벨 정의표 (Runlevel)](runlevel.md) | 런레벨과 target의 대응을 본다 |
| LNX-STB-009-MP | [파일 시스템 마운트와 fstab 등록](mount-fstab.md) | 루트 이후의 마운트를 설정한다 |

## 5. 약어·용어

| 용어 | 뜻 |
|---|---|
| UEFI, BIOS | 펌웨어 인터페이스(UEFI가 현행) |
| ESP | EFI System Partition |
| initramfs | 초기 RAM 파일 시스템 |
| GRUB | GRand Unified Bootloader |
| POST | Power-On Self-Test |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 전원을 켠 뒤 로그인 화면까지의 순서를 기억나는 대로 적어 보자
- [ ] 부팅이 멈췄던 경험이 있다면 어느 단계였을지 추측해 적어 보자
- [ ] initramfs가 왜 필요한지 내 말로 설명해 보자
