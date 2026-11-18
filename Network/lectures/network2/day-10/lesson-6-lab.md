# STEP 6. 서버와 LISTEN 관찰 — 오후 준비 포함

> 상위: [10일차 · 서버 기초](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-10-020-MP |
| 목적 | 오후용 창 3개와 도구를 준비하고, `ss`로 LISTEN 중인 프로그램을 보고, 1분 웹서버를 켜고 꺼 보며 LISTEN이 생겼다 사라지는 것을 확인한다 |
| 적용 대상 | Ubuntu Server 24.04 LTS VM(브릿지), Windows PowerShell 탭 3개, Windows 브라우저 |
| 소요 시간 | 약 30분(오후 준비 10분 포함) |
| 확인 상태 | 미검증 (원본 강의 노트의 대본을 정리한 것이며 VM에서 다시 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-6.md](lesson-6.md) | LEC-N2-10-006-DO | 6. 서버란 무엇인가 |
| [commands.md](commands.md) | LEC-N2-10-013-REF | 창 ①②③의 역할 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PowerShell 탭 3개 | 각각 `ssh student@<VM IP>` | 창 ①②③ |
| 2 | Windows 브라우저 | | |
| 3 | 설치할 패키지 | `netcat-openbsd`, `tcpdump`, `bind9-dnsutils`, `curl` | 5-A-04 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 브릿지라서 포트포워딩 설정이 필요 없다. 오후 웹서버도 `<VM IP>:8080`으로 바로 열린다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-B-03에서 웹서버를 띄운 창 ①은 서버가 점유한다. 그 창에서 다른 명령을 입력하지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 웹서버는 `~/www`의 파일만 보여 주지만, 같은 동네의 누구나 접속할 수 있다. 실습이 끝나면 5-B-09에서 반드시 끈다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM이 켜져 있고 오전 실습 창이 하나 있다 | 프롬프트가 보인다 |
| 2 | 인터넷이 된다 | `ping -c 2 8.8.8.8` |

## 5. 절차

### A. 오후 준비 — 창 3개와 도구

1. (5-A-01) Windows PowerShell에서 탭을 2개 더 연다. → 결과: 탭이 3개가 된다.
2. (5-A-02) 각 탭에서 `ssh student@<VM IP>`를 입력한다. → 결과: 창 ①②③ 모두 `student@ubuntu:~$`가 나온다.
3. (5-A-03) 창 ①에서 `sudo apt update`를 입력한다. → 결과: 목록이 갱신된다.
4. (5-A-04) 창 ①에서 다음 명령을 입력한다.

```bash
sudo apt install -y netcat-openbsd tcpdump bind9-dnsutils curl
```

→ 결과: 설치된다. 이미 있으면 "already"가 나오며 괜찮다.

5. (5-A-05) 창 번호를 칠판에 적는다: ① 서버, ② 클라이언트, ③ 관찰.

### B. 서버와 LISTEN 관찰

1. (5-B-01) 창 ③에서 `sudo ss -tulnp`를 입력한다. `t`=TCP, `u`=UDP, `l`=LISTEN, `n`=숫자, `p`=프로그램이다. → 결과: `:22 LISTEN`(SSH, 9일차에 들어온 문)과 `127.0.0.53:53`(DNS 도우미)이 보인다.
2. (5-B-02) 창 ①에서 다음 명령으로 웹 페이지를 만든다.

```bash
mkdir -p ~/www && cd ~/www
echo "<h1>Hello from Ubuntu - student</h1>" > index.html
```

→ 결과: `~/www/index.html`이 만들어진다.

3. (5-B-03) 창 ①에서 `python3 -m http.server 8080`을 입력한다. → 결과: 서버가 시작되고 창 ①이 점유된다. 그대로 둔다.
4. (5-B-04) 창 ③에서 `ss -tln | grep 8080`을 입력한다. → 결과: `LISTEN ... 0.0.0.0:8080 ...`이 보인다.
5. (5-B-05) 창 ②에서 `curl localhost:8080`을 입력한다. → 결과: `<h1>Hello ...`가 출력된다. 창 ①에 `127.0.0.1 - - "GET / HTTP/1.1" 200` 로그가 찍힌다(VM 안에서 불렀으므로 루프백이다).
6. (5-B-06) Windows 브라우저에서 `http://<VM IP>:8080`을 연다. → 결과: Hello 페이지가 열린다. 창 ①의 로그에 찍힌 접속자 주소가 내 Windows IP 그대로다. 브릿지라서 중간에 바뀌지 않는다. `ipconfig`와 대조한다.
7. (5-B-07) 창 ①에서 Ctrl + C를 누른다. → 결과: 서버가 종료되고 프롬프트가 돌아온다.
8. (5-B-08) 창 ②에서 `curl localhost:8080`을 입력한다. → 결과: `Connection refused`
9. (5-B-09) 창 ③에서 `ss -tln | grep 8080`을 입력한다. → 결과: 출력이 없다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 서버를 켤 때 `ss -tln \| grep 8080` | LISTEN 줄이 보인다 | 생겼다 |
| 2 | 서버를 끌 때 `ss -tln \| grep 8080` | 출력이 없다 | 사라졌다 |
| 3 | 서버가 꺼진 상태의 `curl localhost:8080` | `Connection refused` | 거절된다 |

## 7. 복구

1. (7-01) 서버가 떠 있으면 창 ①에서 Ctrl + C를 누른다.
2. (7-02) 웹 페이지를 지우려면 `rm -r ~/www`를 입력한다. STEP 9에서 `~/www`를 다시 쓰므로 STEP 10까지 둔다.
3. (7-03) 창 ②③은 STEP 7~10에서 계속 쓴다. 닫지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `commands.md`의 "오후 준비"와 STEP 6을 AMM 형식 MP로 분리 |
