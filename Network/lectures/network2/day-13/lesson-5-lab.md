# nginx 배포 실습

> 상위: [13일차 · Git 과 GitHub](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-13-011-MP |
| 목적 | nginx를 세워 80번 포트 충돌을 확인하고 해결한 뒤, GitHub 저장소를 서버 폴더로 `clone`해 웹으로 띄우고, 수정 사항을 `push`와 `pull`로 반영한다 |
| 적용 대상 | WSL(Ubuntu 24.04, systemd 사용), nginx 1.24, 12일차에 구축한 Apache(`apache2`)와 `ufw`, GitHub 공개 저장소 `myweb` |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본에 "nginx 실제 설치·기동과 `git clone` 후 브라우저 확인은 교실 PC에서 검증 필요"라는 기록이 있으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N2-13-005-DO | 서버에 배포해 보기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-N2-13-009-MP | GitHub 연결 실습(`myweb` 저장소를 만든다) |
| [commands.md](commands.md) | LEC-N2-13-007-REF | 13일차 실습 명령어 |
| [12일차 · 리눅스 서버 구축](../day-12/README.md) | | 서버 구축의 여섯 단계, Apache, `ufw` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | `sudo` 권한 필요 |
| 2 | nginx | 1.24 | `sudo apt install -y nginx` |
| 3 | GitHub 공개 저장소 `myweb` | `index.html`이 있다 | 서버에서 HTTPS로 읽기만 한다 |
| 4 | 웹 브라우저 | Windows | `http://localhost`로 확인 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 A에서 Apache(`apache2`)를 중지한다. 삭제하지 않는다. 12일차 서버 설정은 그대로 남는다. 복구는 7절을 따른다.
{% endhint %}

{% hint style="danger" %}
WARNING: 서버 폴더(`/var/www/mysite`)의 파일은 직접 고치지 않는다. 고치면 다음 `git pull`에서 충돌이 난다. 고치는 곳은 `~/myweb` 하나이다.
{% endhint %}

{% hint style="info" %}
NOTE: WSL이 NAT 모드(`172.x.x.x`)이면 옆자리 PC에서는 접속되지 않는다. 정상이다. 검증은 내 Windows 브라우저의 `localhost`로 한다. mirrored 모드(`192.168.x.x`)이면 `http://<내 Windows IP>`로 옆자리에서도 열린다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 80번 포트를 쓰는 프로그램을 안다 | `sudo ss -tulnp \| grep ':80 '`에 `apache2`가 보인다 |
| 2 | `ufw`가 켜져 있다 | `sudo ufw status`가 `active`를 출력한다 |
| 3 | GitHub `myweb`에 `index.html`이 있다 | 브라우저에서 저장소 화면에 파일이 보인다 |
| 4 | WSL 네트워크 모드를 안다 | `ip route get 1.1.1.1 \| head -1`의 `src` 뒤 주소가 `172.x`(NAT)인지 `192.168.x`(mirrored)인지 적는다 |

## 5. 절차

### A. nginx 설치와 80번 충돌 확인

1. (5-A-01) 80번 사용 프로그램을 확인한다: `sudo ss -tulnp | grep ':80 '` → 결과: `apache2`가 보인다.
2. (5-A-02) nginx를 설치한다: `sudo apt install -y nginx` → 결과: 에러 없이 끝난다.
3. (5-A-03) 상태를 확인한다: `sudo systemctl is-active nginx` → 결과: `failed`가 출력된다. 설치는 되었으나 기동은 실패한 상태이다.
4. (5-A-04) 원인을 확인한다: `sudo journalctl -u nginx -n 5 --no-pager` → 결과: `bind() to 0.0.0.0:80 failed (98: Address already in use)`가 보인다.
5. (5-A-05) Apache를 중지한다: `sudo systemctl disable --now apache2` → 결과: 오류 없이 끝난다.
6. (5-A-06) 80번이 비었는지 확인한다: `sudo ss -tulnp | grep ':80 '` → 결과: 출력이 없다.
7. (5-A-07) nginx를 기동한다: `sudo systemctl enable --now nginx` → 결과: 오류 없이 끝난다.
8. (5-A-08) 확인한다: `sudo ss -tulnp | grep ':80 '` → 결과: `nginx`가 LISTEN 중이다.
9. (5-A-09) 방화벽을 확인한다: `sudo ufw status numbered | grep 80` → 결과: 80번 규칙이 있으면 그대로 둔다. 없으면 `sudo ufw allow 80/tcp`를 실행한다.
10. (5-A-10) 브라우저에서 `http://localhost`를 연다. → 결과: `Welcome to nginx!`가 보인다.

### B. 내 코드 받아 보여 주기

1. (5-B-01) 이동한다: `cd /var/www`
2. (5-B-02) 복제한다: `sudo git clone https://github.com/<아이디>/myweb.git mysite` → 결과: `mysite` 폴더가 생긴다.
3. (5-B-03) 내용을 확인한다: `ls /var/www/mysite` → 결과: `index.html`(과 `about.html`)이 보인다.
4. (5-B-04) 설정 파일을 연다: `sudo nano /etc/nginx/sites-available/default`
5. (5-B-05) `root /var/www/html;`을 `root /var/www/mysite;`로 바꾸고 저장한다.
6. (5-B-06) 문법을 검사한다: `sudo nginx -t` → 결과: `syntax is ok`와 `test is successful`이 출력된다.
7. (5-B-07) 설정을 다시 읽는다: `sudo systemctl reload nginx`
8. (5-B-08) 브라우저에서 `http://localhost`를 새로고침한다. → 결과: 내가 만든 페이지가 보인다.

### C. 고치고 반영하기

1. (5-C-01) 작업 폴더로 이동한다: `cd ~/myweb`
2. (5-C-02) 파일을 고친다: `nano index.html`(문구를 한 줄 수정한다)
3. (5-C-03) 커밋한다: `git commit -am "환영 문구 수정"`
4. (5-C-04) 올린다: `git push`
5. (5-C-05) 서버 폴더로 이동한다: `cd /var/www/mysite`
6. (5-C-06) 반영한다: `sudo git pull` → 결과: 변경된 파일이 표시된다.
7. (5-C-07) 브라우저에서 `http://localhost`를 새로고침한다. → 결과: 바뀐 문구가 보인다.

### D. 연 문 점검

1. (5-D-01) 열린 포트를 확인한다: `sudo ss -tulnp | grep LISTEN` → 결과: 22, 80 등 서비스 포트가 보인다.
2. (5-D-02) 방화벽 규칙을 확인한다: `sudo ufw status numbered` → 결과: 의도한 규칙만 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `sudo systemctl is-active nginx` | `active` | 문자열이 `active`이다 |
| 2 | `http://localhost` | 내가 만든 페이지 | 기본 nginx 화면이 아니다 |
| 3 | 수정 후 `git push`, 서버 `git pull`, 새로고침 | 바뀐 문구 | 브라우저에 새 내용이 보인다 |
| 4 | (mirrored 모드만) 옆자리에서 `http://<내 Windows IP>` | 같은 페이지 | NAT 모드에서는 접속되지 않아도 정상이다 |

{% hint style="warning" %}
CAUTION: 증상별 조치는 다음과 같다. `localhost`가 타임아웃이면 `sudo ufw status`로 80번을 확인하고 연다. `Welcome to nginx`만 보이면 `root` 수정과 `reload`를 확인한다(`sudo nginx -t`, `sudo systemctl reload nginx`). `sudo git pull`이 충돌이면 서버에서 직접 고친 것이므로 `sudo git checkout -- .`로 수정분을 버린 뒤 다시 `pull`한다(수정분은 사라진다). `Address already in use`이면 5-A-05부터 다시 한다.
{% endhint %}

## 7. 복구

1. (7-01) nginx를 내린다: `sudo systemctl disable --now nginx` → 결과: 80번이 비어 있다.
2. (7-02) Apache를 되살린다: `sudo systemctl enable --now apache2` → 결과: `systemctl is-active apache2`가 `active`이다.
3. (7-03) nginx 설정을 되돌린다: `sudo nano /etc/nginx/sites-available/default`에서 `root /var/www/mysite;`를 `root /var/www/html;`로 바꾼다.
4. (7-04) 서버 폴더를 지우려면: `sudo rm -rf /var/www/mysite`

{% hint style="danger" %}
WARNING: `rm -rf`는 되돌릴 수 없다. 경로가 `/var/www/mysite`인지 확인한 뒤 실행한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-5.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. 복구 절(7)을 추가 |
