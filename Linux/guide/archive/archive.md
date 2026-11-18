# 아카이브 및 파일 압축 (tar, xz)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-ARC-001-MP |
| 목적 | `tar`로 여러 파일을 하나로 묶고 `xz`, `gzip`, `bzip2`로 압축하거나 푼다 |
| 적용 대상 | Linux 전반(RHEL 계열 실습 환경 포함), GNU tar, 일반 사용자 권한(대상 디렉터리에 쓰기 권한 필요) |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 아카이브는 여러 파일을 하나로 묶는 작업이고 압축은 용량을 줄이는 작업이다. 압축이 용량을 항상 줄이지는 않는다. 압축 도구에 따라 효율이 다르다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [tarreference.md](tarreference.md) | LNX-ARC-002-REF | tar·압축 명령 옵션 표 |
| [bzip2 사용법 (coding-panda)](https://coding-panda.com/linux-bzip2-%EB%AA%85%EB%A0%B9%EC%96%B4%EB%A1%9C-%EC%95%95%EC%B6%95-%ED%95%98%EA%B8%B0-%EC%95%95%EC%B6%95-%ED%95%B4%EC%A0%9C-%EB%B0%A9%EB%B2%95/) | | 외부 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | Linux 셸 | |
| 2 | `tar` | GNU tar | 대부분의 배포판에 기본 설치돼 있다 |
| 3 | `xz` | xz 패키지 | 기본 설치돼 있지 않으면 구역 D에서 설치한다 |
| 4 | 연습용 디렉터리 | `~/archive-test` | 구역 A에서 만든다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `xz`, `gzip`, `bzip2`는 기본적으로 원본 파일을 지우고 압축 파일만 남긴다. 원본이 필요하면 압축 명령에 `-k` 옵션을 붙인다. 중요한 파일은 먼저 복사본을 만든다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `tar`가 설치돼 있는지 확인한다: `tar --version` | `tar (GNU tar) <버전>`이 출력된다 |
| 2 | `xz`가 설치돼 있는지 확인한다: `xz --version` | 버전이 출력된다. 없으면 구역 D를 먼저 수행한다 |
| 3 | 현재 위치를 확인한다: `pwd` | 홈 디렉터리 등 쓰기 가능한 위치다 |

## 5. 절차

### A. 연습용 파일 만들기

1. (5-A-01) 연습 디렉터리를 만든다: `mkdir ~/archive-test` → 결과: 오류 없이 끝난다.
2. (5-A-02) 이동한다: `cd ~/archive-test`
3. (5-A-03) 연습 파일을 만든다: `echo hello > a.txt` 와 `echo world > b.txt` → 결과: `ls`에 `a.txt`, `b.txt`가 보인다.

### B. 파일 하나 압축과 해제 (xz)

1. (5-B-01) 파일을 압축한다: `xz a.txt` → 결과: `a.txt`가 사라지고 `a.txt.xz`가 생긴다.
2. (5-B-02) 압축을 푼다: `xz -d a.txt.xz` → 결과: `a.txt.xz`가 사라지고 `a.txt`가 생긴다.

### C. 여러 파일 묶기와 압축 (tar)

1. (5-C-01) 묶는다: `tar cvf files.tar a.txt b.txt` → 결과: 처리한 파일 이름이 출력되고 `files.tar`가 생긴다. 원본 `a.txt`, `b.txt`는 남는다.
2. (5-C-02) 묶음 내용을 확인한다: `tar tf files.tar` → 결과: `a.txt`, `b.txt`가 나열된다.
3. (5-C-03) 묶으면서 xz로 압축한다: `tar cJvf files.tar.xz a.txt b.txt` → 결과: `files.tar.xz`가 생긴다.
4. (5-C-04) gzip이나 bzip2를 쓰려면 `J` 대신 `z`(gzip, 확장자 `.tar.gz`) 또는 `j`(bzip2, 확장자 `.tar.bz2`)를 쓴다.

{% hint style="info" %}
NOTE: 압축 방식을 알 수 있도록 파일 이름에 `.tar.xz`, `.tar.gz`, `.tar.bz2` 확장자를 붙인다. 확장자가 없으면 다른 사용자가 어떤 도구로 압축했는지 알기 어렵다.
{% endhint %}

### D. bzip2 설치 (필요한 경우만)

1. (5-D-01) Debian/Ubuntu 계열: `sudo apt install bzip2` → 결과: 설치가 끝난다.
2. (5-D-02) RHEL 계열: `sudo dnf install bzip2` (구버전은 `yum`) → 결과: 설치가 끝난다. (RHEL 계열 명령은 원본에 없던 내용이다.)

### E. 묶음 풀기

{% hint style="danger" %}
WARNING: `tar x`는 대상 위치에 같은 이름의 파일이 있으면 경고 없이 덮어쓴다. 풀기 전에 5-E-01로 내용을 확인하고, 빈 디렉터리에 풀거나 `-C <대상 디렉터리>`로 위치를 지정한다.
{% endhint %}

1. (5-E-01) 풀 내용을 나열한다: `tar tf files.tar.xz` → 결과: 아카이브 안의 파일 목록이 출력된다.
2. (5-E-02) 풀 디렉터리를 만든다: `mkdir ~/archive-out` → 결과: 오류 없이 끝난다.
3. (5-E-03) 푼다: `tar xJvf files.tar.xz -C ~/archive-out` → 결과: `~/archive-out`에 `a.txt`, `b.txt`가 생긴다.

{% hint style="info" %}
NOTE: 풀 때는 생성할 때 쓴 옵션을 그대로 쓰는 것을 권장한다(`cJvf`로 만들었으면 `xJvf`). GNU tar는 압축 형식을 자동으로 인식하므로 `xvf`만으로 풀 수도 있다. 배포판과 tar 버전에 따라 다를 수 있어 미검증이다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ls ~/archive-out` | 풀린 파일이 보인다 | `a.txt`, `b.txt` 존재 |
| 2 | `cat ~/archive-out/a.txt` | 원래 내용이 출력된다 | `hello` 출력 |
| 3 | `diff ~/archive-out/a.txt ~/archive-test/a.txt` | 차이가 없다 | 출력 없음 |

## 7. 복구

1. (7-01) 연습 파일을 지운다: `rm -r ~/archive-test ~/archive-out`

{% hint style="danger" %}
WARNING: `rm -r`은 되돌릴 수 없다. 경로가 위 두 연습 디렉터리인지 확인한 뒤 실행한다.
{% endhint %}

2. (7-02) 실수로 덮어쓴 파일은 복구할 수 없다. 백업(버전 관리) 용도로 아카이브를 따로 보관한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지 `archive.md`를 AMM 형식으로 재작성. 옵션 목록은 LNX-ARC-002-REF로 분리. `tar tf`, `-C`, RHEL용 bzip2 설치를 추가 |
