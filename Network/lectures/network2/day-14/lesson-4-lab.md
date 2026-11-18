# 볼륨과 DB 실습

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-011-MP |
| 목적 | 컨테이너를 지우면 데이터가 사라지는 것을 확인하고, 바인드 마운트로 13일차 포트폴리오를 연결하며, 볼륨으로 MariaDB 데이터를 살려 둔다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x, 13일차의 `/var/www/mysite` |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N2-14-004-DO | 데이터와 볼륨 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-N2-14-010-MP | 핵심 명령과 방화벽 대조 실습 |
| [commands.md](commands.md) | LEC-N2-14-008-REF | 14일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04, Docker 설치 완료 | |
| 2 | `/var/www/mysite` | 13일차에 `git clone`한 포트폴리오 | `ls`로 존재를 확인한다 |
| 3 | `mariadb` 이미지 | 공식 이미지 | 처음 실행할 때 받는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 구역 C의 `docker volume rm dbdata`(7-02)는 DB 데이터를 영구 삭제한다. 실습이 끝난 뒤에만 실행한다.
{% endhint %}

{% hint style="danger" %}
WARNING: 비밀번호는 명령줄에 쓰지 않는 것이 원칙이다. 이 실습은 `<password>` 자리에 수업용 값을 쓰며, 그 값을 문서나 저장소에 남기지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: DB 컨테이너는 `-p 127.0.0.1:3306:3306`으로만 띄운다. `-p 3306:3306`은 Docker가 `ufw`를 우회해 교실 전체에 DB를 공개한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `web` 컨테이너가 떠 있다 | `docker ps`에 `web`이 보인다. 없으면 `docker run -d -p 127.0.0.1:8080:80 --name web nginx` |
| 2 | 13일차 폴더가 있다 | `ls /var/www/mysite`에 `index.html`이 보인다 |

## 5. 절차

### A. "고쳤는데 사라졌어요" 체험

1. (5-A-01) 컨테이너 안의 파일을 고친다: `docker exec -it web bash -c 'echo "<h1>내가 고침</h1>" > /usr/share/nginx/html/index.html'`
2. (5-A-02) `curl localhost:8080`을 실행한다. → 결과: `<h1>내가 고침</h1>`이 보인다.
3. (5-A-03) 컨테이너를 지운다: `docker rm -f web`
4. (5-A-04) 같은 이미지로 다시 띄운다: `docker run -d -p 127.0.0.1:8080:80 --name web nginx`
5. (5-A-05) `curl localhost:8080`을 실행한다. → 결과: 원래의 nginx 환영 페이지로 돌아와 있다.

### B. 바인드 마운트: 13일차 포트폴리오 연결

1. (5-B-01) 컨테이너를 지운다: `docker rm -f web`
2. (5-B-02) 호스트 폴더를 읽기 전용으로 연결해 띄운다.

```bash
docker run -d -p 8080:80 \
  -v /var/www/mysite:/usr/share/nginx/html:ro \
  --name web nginx
```

3. (5-B-03) `curl localhost:8080`을 실행한다. → 결과: 13일차 내 포트폴리오가 나온다.
4. (5-B-04) Windows 브라우저에서 `http://localhost:8080`을 연다. → 결과: Pages에 올린 그 페이지가 컨테이너에서 보인다.
5. (5-B-05) 폴더만 갱신한다: `cd /var/www/mysite && sudo git pull` → 결과: 컨테이너를 건드리지 않았는데 브라우저 새로고침에서 내용이 바뀐다(변경이 있을 때).

### C. 볼륨과 DB(12일차 MariaDB 회수)

1. (5-C-01) 볼륨을 만든다: `docker volume create dbdata`
2. (5-C-02) `docker volume ls`와 `docker volume inspect dbdata`를 실행한다. → 결과: 호스트의 실제 경로(`Mountpoint`)가 보인다.
3. (5-C-03) DB 컨테이너를 띄운다.

```bash
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=<password> \
  -e MARIADB_DATABASE=testdb \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 \
  mariadb
```

4. (5-C-04) 초기화를 기다린다: `docker logs -f db` → 결과: `ready for connections`가 보이면 `Ctrl+C`로 나온다.
5. (5-C-05) 데이터베이스를 확인한다: `docker exec -it db mariadb -uroot -p<password> -e "SHOW DATABASES;"` → 결과: `testdb`가 보인다.
6. (5-C-06) 테이블을 만든다.

```bash
docker exec -it db mariadb -uroot -p<password> testdb \
  -e "CREATE TABLE t(id INT); INSERT INTO t VALUES(1); SELECT * FROM t;"
```

→ 결과: `id` 열에 `1`이 보인다.

### D. 컨테이너를 지워도 살아남나

1. (5-D-01) 컨테이너를 통째로 지운다: `docker rm -f db`
2. (5-D-02) `docker ps -a | grep db`를 실행한다. → 결과: 아무것도 나오지 않는다.
3. (5-D-03) 같은 볼륨으로 다시 띄운다.

```bash
docker run -d --name db \
  -e MARIADB_ROOT_PASSWORD=<password> \
  -v dbdata:/var/lib/mysql \
  -p 127.0.0.1:3306:3306 mariadb
```

4. (5-D-04) `docker logs -f db`로 `ready for connections`를 기다린다. → 결과: 첫 기동보다 빠르다(초기화를 건너뛴다).
5. (5-D-05) `docker exec -it db mariadb -uroot -p<password> testdb -e "SELECT * FROM t;"`를 실행한다. → 결과: `id` 열에 `1`이 그대로 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-A-05의 `curl` | 고친 내용이 사라지고 원래 페이지 | `내가 고침`이 보이지 않는다 |
| 2 | 5-B-03의 `curl` | 13일차 포트폴리오 | 내 `index.html` 내용이 보인다 |
| 3 | 5-D-05의 조회 | 행이 살아 있다 | `1`이 출력된다 |
| 4 | `sudo ss -tulnp \| grep 3306` | `127.0.0.1:3306`으로만 LISTEN | `0.0.0.0:3306`이 없다 |

## 7. 복구

1. (7-01) 실습 컨테이너를 지운다: `docker rm -f db web`
2. (7-02) DB 볼륨을 지운다(데이터가 사라진다): `docker volume rm dbdata`
3. (7-03) 멈춘 컨테이너를 정리한다: `docker rm $(docker ps -aq -f status=exited)`

{% hint style="danger" %}
WARNING: `docker system prune -a`는 쓰지 않는다. 이미지, 컨테이너, 네트워크, 캐시를 전부 지운다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-4.md`와 `commands.md`의 STEP 4 실습 항목을 AMM 형식으로 재작성. 예제 비밀번호를 `<password>`로 바꿈 |
