# NFS 공유와 마운트 실습

> 상위: [12일차 · 리눅스 서버 구축](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-12-014-MP |
| 목적 | 같은 VM을 NFS 서버이자 클라이언트로 써서 폴더를 내보내고, 마운트해 같은 파일이 양쪽에 보이는 것을 확인한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(9일차 VM). 오늘 수업에서는 하지 않고 13일차에 한다 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 강의 노트와 실습 명령 대본을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-1.md](lesson-1.md) | LEC-N2-12-001-DO | 서버 구축의 공통 문법 |
| [lesson-4.md](lesson-4.md) | LEC-N2-12-004-DO | NFS |
| [commands.md](commands.md) | LEC-N2-12-010-REF | 12일차 실습 명령어(부록 B: 옆자리 VM과 NFS 공유) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Ubuntu Server VM | 24.04 LTS | 인터넷 연결(`apt`) 필요 |
| 2 | SSH 창 2개 | `ssh student@192.168.x.x` | `①` 서버 작업, `②` 클라이언트 |
| 3 | 패키지 | `nfs-kernel-server`, `nfs-common` | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `/etc/exports`의 허용 대상을 `*`나 공인 주소로 넓히지 않는다. NFS는 IP와 UID를 믿는 프로토콜이라 인터넷에 열면 누구나 폴더에 접근할 수 있다. 이 실습은 `127.0.0.1`만 허용한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `/etc/fstab`에는 줄을 넣지 않는다. 오타가 부팅 실패로 이어질 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | SSH 창 2개를 연다 | 창마다 프롬프트가 보인다 |
| 2 | 인터넷이 된다 | `sudo apt update`가 오류 없이 끝난다 |

## 5. 절차

### A. 설치와 공유 폴더 준비 (창 ①)

1. (5-A-01) 서버 패키지를 설치한다: `sudo apt install nfs-kernel-server -y` → 결과: 오류 없이 끝난다.
2. (5-A-02) 공유 폴더를 만든다: `sudo mkdir -p /srv/share`
3. (5-A-03) 테스트 파일을 만든다: `echo "NFS 로 공유되는 파일" | sudo tee /srv/share/hello.txt` → 결과: 같은 문장이 출력된다.
4. (5-A-04) 소유자를 바꾼다(수업용): `sudo chown nobody:nogroup /srv/share`

### B. 내보내기 설정 (창 ①)

1. (5-B-01) `/etc/exports`를 연다: `sudo nano /etc/exports`
2. (5-B-02) 맨 아래에 한 줄을 추가한다: `/srv/share  127.0.0.1(rw,sync,no_subtree_check)`
3. (5-B-03) 저장하고 나간다: `Ctrl+O`, `Enter`, `Ctrl+X`

### C. 기동과 확인 (창 ①)

1. (5-C-01) 내보내기를 적용한다: `sudo exportfs -ra` → 결과: 오류 없이 끝난다.
2. (5-C-02) 내주는 목록을 본다: `sudo exportfs -v` → 결과: `/srv/share`와 `127.0.0.1`이 보인다.
3. (5-C-03) 포트를 본다: `sudo ss -tulnp | grep 2049` → 결과: 2049 LISTEN이 보인다.
4. (5-C-04) 밖에서 본 공유 목록을 본다: `showmount -e 127.0.0.1` → 결과: `/srv/share`가 보인다.

### D. 방화벽 개방 (창 ①, ufw를 켠 경우만)

1. (5-D-01) 포트를 연다: `sudo ufw allow 2049/tcp` → 결과: `Rule added`.

### E. 마운트 검증 (창 ②)

1. (5-E-01) 마운트 지점을 만든다: `sudo mkdir -p /mnt/share`
2. (5-E-02) 마운트한다: `sudo mount -t nfs 127.0.0.1:/srv/share /mnt/share` → 결과: 오류 없이 끝난다.
3. (5-E-03) 목록을 확인한다: `df -h | grep share` → 결과: `127.0.0.1:/srv/share`가 보인다.
4. (5-E-04) 내용을 본다: `ls -l /mnt/share` 와 `cat /mnt/share/hello.txt` → 결과: `hello.txt`와 내용이 보인다.

### F. 같은 파일임을 확인 (창 ②)

1. (5-F-01) 클라이언트에서 줄을 추가한다: `echo "클라이언트가 추가한 줄" | sudo tee -a /mnt/share/hello.txt`
2. (5-F-02) 서버 쪽 원본을 본다: `cat /srv/share/hello.txt` → 결과: 추가한 줄이 즉시 보인다. 복사한 적이 없다.
3. (5-F-03) 마운트를 뺀다: `sudo umount /mnt/share`
4. (5-F-04) 비었는지 본다: `ls /mnt/share` → 결과: 아무것도 나오지 않는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `showmount -e 127.0.0.1` | 공유 목록 | `/srv/share`가 보인다 |
| 2 | 마운트 후 `df -h \| grep share` | 마운트됨 | 한 줄이 보인다 |
| 3 | 클라이언트에서 쓴 줄을 서버에서 `cat` | 즉시 반영 | 추가한 줄이 보인다 |
| 4 | `umount` 후 `ls /mnt/share` | 비어 있다 | 출력 없음 |

수업 종료 시 점검: 파일 전송과 공유의 차이를 한 문장으로 말할 수 있다.

## 7. 복구

1. (7-01) 마운트가 남아 있으면 뺀다: `sudo umount /mnt/share`
2. (7-02) `/etc/exports`에서 추가한 줄을 지운다: `sudo nano /etc/exports`
3. (7-03) 내보내기를 다시 적용한다: `sudo exportfs -ra`
4. (7-04) NFS 서버를 끈다: `sudo systemctl disable --now nfs-server` → 결과: `ss -tulnp | grep 2049`에 아무것도 나오지 않는다.
5. (7-05) ufw 규칙을 지운다(5-D를 했다면): `sudo ufw status numbered`로 번호를 확인하고 `sudo ufw delete <번호>`를 실행한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-4.md`의 구축 절과 `commands.md` STEP 4를 AMM 형식 MP로 분리 |
