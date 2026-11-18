# 핵심 명령과 방화벽 대조 실습

> 상위: [14일차 · 도커 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-14-010-MP |
| 목적 | 컨테이너 핵심 명령을 12일차 명령과 짝지어 쓰고, 대조 실험으로 Docker가 `ufw`를 우회하는 것을 확인한 뒤 `127.0.0.1` 바인딩으로 닫는다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), Docker Engine 29.x, `ufw` 활성(22, 80만 허용) |
| 소요 시간 | 약 40분 |
| 확인 상태 | 미검증 (원본에 "직접 실행 아님, 자료 조사 기준"이라는 기록이 있으며, 이 문서도 실행해 확인하지 않았다. 특히 대조 실험의 실제 결과, 그중 mirrored 모드 PC는 교실에서 확인해야 한다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N2-14-003-DO | 핵심 명령과 포트 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-N2-14-009-MP | 설치와 첫 컨테이너 실습 |
| [commands.md](commands.md) | LEC-N2-14-008-REF | 14일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04, Docker 설치 완료 | |
| 2 | `web` 컨테이너 | `nginx`, 8080 | LEC-N2-14-009-MP의 구역 F에서 만든 것 |
| 3 | Windows 브라우저 | `localhost` 접속 | 대조 실험의 결과 확인 |
| 4 | `python3` | 10일차에 쓴 것 | 호스트 서비스(8000번)용 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 구역 C의 호스트 서비스(8000번)는 실습이 끝나면 반드시 종료한다(5-C-08). 종료하지 않으면 다음 STEP에서 포트가 겹친다.
{% endhint %}

{% hint style="warning" %}
CAUTION: mirrored 모드에서는 `127.0.0.1` 바인딩 후에도 Windows 브라우저의 `localhost:8080`이 열린다. 이것은 실패가 아니다. 검증은 구역 D의 `curl http://$MYIP:8080`으로 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `web` 컨테이너가 떠 있다 | `docker ps`에 `web`이 `Up`이다. 없으면 `docker run -d -p 8080:80 --name web nginx` |
| 2 | 방화벽이 켜져 있다 | `sudo ufw status numbered`에 22, 80만 있고 8000, 8080은 없다 |

## 5. 절차

### A. 12일차 명령과 짝 맞추기

1. (5-A-01) `docker ps`를 실행한다. → 결과: `web`이 보인다(`systemctl status`에 해당).
2. (5-A-02) `docker logs web`을 실행한다. → 결과: 접속 로그가 보인다(`journalctl -u`에 해당).
3. (5-A-03) `docker logs -f web`을 실행한다.
4. (5-A-04) Windows 브라우저에서 `http://localhost:8080`을 몇 번 새로고침한다. → 결과: `GET / HTTP/1.1" 200` 줄이 쌓인다.
5. (5-A-05) `Ctrl+C`로 나간다.
6. (5-A-06) `docker stop web && docker ps -a`를 실행한다. → 결과: `web`이 `Exited`이다.
7. (5-A-07) `docker start web && docker ps`를 실행한다. → 결과: `web`이 `Up`이다.

### B. 컨테이너 안에 들어가기

1. (5-B-01) 쉘을 연다: `docker exec -it web bash` → 결과: 프롬프트가 `root@<컨테이너 ID>:/#`이다.
2. (5-B-02) `ls /usr/share/nginx/html`을 실행한다. → 결과: `index.html`이 보인다.
3. (5-B-03) `cat /etc/nginx/conf.d/default.conf`를 실행한다. → 결과: 설정 파일이 보인다.
4. (5-B-04) `ps -ef`를 실행한다. → 결과: nginx 프로세스만 보인다.
5. (5-B-05) `hostname`을 실행한다. → 결과: 컨테이너 ID가 나온다.
6. (5-B-06) `exit`로 나간다.

### C. 방화벽 대조 실험

1. (5-C-01) 호스트 서비스를 띄운다: `cd /tmp && python3 -m http.server 8000 &`
2. (5-C-02) 컨테이너가 떠 있는지 확인한다: `docker ps | grep web` → 결과: `0.0.0.0:8080->80/tcp`가 보인다.
3. (5-C-03) `sudo ufw status numbered`를 실행한다. → 결과: 8000과 8080이 목록에 없다.
4. (5-C-04) Windows 브라우저에서 `http://localhost:8000`을 연다. → 결과: 열리지 않는다(`ufw`가 막았다).
5. (5-C-05) Windows 브라우저에서 `http://localhost:8080`을 연다. → 결과: 열린다.
6. (5-C-06) 원인을 확인한다: `sudo iptables -t nat -L DOCKER -n | head` → 결과: 8080을 컨테이너 IP의 80으로 보내는 DNAT 규칙이 보인다.
7. (5-C-07) `sudo iptables -L FORWARD -n --line-numbers | head`를 실행한다. → 결과: `DOCKER` 체인이 `ufw` 체인보다 앞에 있다.
8. (5-C-08) 호스트 서비스를 종료한다: `kill %1` → 결과: 8000번 서비스가 끝난다.

### D. 로컬에만 바인딩

1. (5-D-01) 컨테이너를 지운다: `docker rm -f web`
2. (5-D-02) 로컬 바인딩으로 다시 띄운다: `docker run -d -p 127.0.0.1:8080:80 --name web nginx`
3. (5-D-03) `sudo ss -tulnp | grep 8080`을 실행한다. → 결과: `127.0.0.1:8080`으로만 LISTEN한다.
4. (5-D-04) 내 IP를 변수에 담는다: `MYIP=$(ip route get 1.1.1.1 | awk '{print $7; exit}')`
5. (5-D-05) `curl -m 3 http://127.0.0.1:8080`을 실행한다. → 결과: nginx 환영 페이지가 나온다.
6. (5-D-06) `curl -m 3 http://$MYIP:8080`을 실행한다. → 결과: `Connection refused`. 닫혔다는 증거이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker logs web` | 브라우저 새로고침이 `200`으로 쌓인다 | `GET /` 줄이 보인다 |
| 2 | `ps -ef`(컨테이너 안) | nginx 프로세스만 있다 | 프로세스가 수 개 이하이다 |
| 3 | 대조 실험(5-C) | 8000은 막히고 8080은 열린다 | 두 결과가 다르다 |
| 4 | `curl http://$MYIP:8080`(5-D) | `Connection refused` | 응답 본문이 오지 않는다 |

## 7. 복구

1. (7-01) 호스트 서비스를 종료했는지 확인한다: `jobs` → 결과: 실행 중인 작업이 없다.
2. (7-02) 원래 상태(밖에 열린 `-p`)로 되돌리려면: `docker rm -f web && docker run -d -p 8080:80 --name web nginx`

{% hint style="warning" %}
CAUTION: 4번 절 이후 실습은 `web` 컨테이너를 쓴다. 7-02는 필요할 때만 실행한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-3.md`와 `commands.md`의 STEP 3 실습 항목을 AMM 형식으로 재작성 |
