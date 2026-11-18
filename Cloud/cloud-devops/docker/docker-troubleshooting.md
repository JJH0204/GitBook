# [생성형 AI] 컨테이너 장애 진단

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-023-TS |
| 유형 | TS (문제 해결) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 컨테이너가 시작되지 않거나 접속되지 않을 때 원인을 좁히는 순서를 정리한다 |
| 확인 상태 | 미검증 (일반 지식을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 증상과 가능 원인

| 번호 | 증상 | 가능 원인 | 확인 |
|---|---|---|---|
| 1 | `docker ps`에 컨테이너가 없고 `docker ps -a`에는 `Exited`로 있다 | 메인 프로세스가 종료됐다. 명령 오류, 설정 오류 | `docker logs <컨테이너>`, 종료 코드 |
| 2 | 종료 코드 137 | SIGKILL. 메모리 부족(OOM) 또는 `docker kill` | `docker inspect -f '{{.State.OOMKilled}}' <컨테이너>` |
| 3 | 종료 코드 126 또는 127 | 126은 실행 권한 없음, 127은 명령을 찾을 수 없음 | `CMD`·`ENTRYPOINT` 경로와 권한 |
| 4 | `port is already allocated` 또는 `address already in use` | 호스트 포트를 다른 프로세스나 컨테이너가 쓴다 | `ss -tln`, `docker ps` |
| 5 | 컨테이너끼리 이름으로 접속되지 않는다 | 기본 브리지를 쓴다. 서로 다른 네트워크에 있다 | `docker network inspect <네트워크>` |
| 6 | 호스트에서 포트로 접속되지 않는다 | `-p`를 빼먹었다. 앱이 `127.0.0.1`에만 바인드한다 | `docker port <컨테이너>`, 앱의 바인드 주소 |
| 7 | `permission denied ... docker.sock` | 현재 사용자가 `docker` 그룹이 아니다 | `id` |
| 8 | 이미지 내려받기 실패 (`pull access denied`, `toomanyrequests`) | 이미지 이름 오타, 비공개 이미지, Docker Hub 요청 한도 | 이름 확인, `docker login` |
| 9 | `no space left on device` | 이미지·볼륨·로그가 디스크를 채웠다 | `docker system df` |

## 2. 격리 절차

1. (2-01) 상태를 확인한다: `docker ps -a` → 결과: 컨테이너의 `STATUS`가 보인다.
2. (2-02) 로그를 확인한다: `docker logs --tail 100 <컨테이너>` → 결과: 앱의 오류 메시지가 보인다.
3. (2-03) 종료 코드와 OOM 여부를 확인한다: `docker inspect -f '{{.State.ExitCode}} {{.State.OOMKilled}}' <컨테이너>` → 결과: 두 값이 출력된다.
4. (2-04) 설정을 확인한다: `docker inspect <컨테이너>`에서 `Config.Cmd`, `Config.Env`, `NetworkSettings`를 본다.
5. (2-05) 컨테이너 안에서 직접 확인한다: `docker exec -it <컨테이너> sh` → 결과: 셸이 열린다. 컨테이너가 종료되어 있으면 `docker run -it --rm --entrypoint sh <이미지>`로 같은 이미지를 셸로 연다.
6. (2-06) 네트워크를 확인한다: 호스트에서 `docker port <컨테이너>`, 컨테이너 사이는 `docker network inspect <네트워크>` → 결과: 게시된 포트와 연결된 컨테이너가 보인다.

## 3. 시정 조치

| 원인 | 조치 |
|---|---|
| 메인 프로세스 종료 | 로그의 오류를 고치고 컨테이너가 포그라운드로 도는 명령을 `CMD`로 둔다 |
| OOM | `--memory` 상한을 올리거나 앱의 메모리 사용을 줄인다 |
| 포트 충돌 | 다른 호스트 포트로 게시한다(`-p 8081:80`) |
| 이름 접속 불가 | 사용자 정의 네트워크를 만들어 같은 네트워크에 붙인다 ([도커 네트워크](docker-network.md), CLD-DKR-019-DO) |
| 소켓 권한 | 사용자를 `docker` 그룹에 넣는다. 다시 로그인해야 적용된다 |
| 디스크 부족 | `docker system df`로 확인하고 사용하지 않는 것만 정리한다 |

{% hint style="danger" %}
WARNING: `docker system prune -a --volumes`는 사용하지 않는 이미지와 볼륨을 모두 삭제한다. 볼륨의 데이터는 복구되지 않는다. 실행 전에 `docker volume ls`로 대상을 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `docker` 그룹의 사용자는 사실상 호스트의 root 권한을 가진다. 신뢰하는 사용자만 넣는다.
{% endhint %}

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 필수 명령어](docker_commend.md) | CLD-DKR-007-REF | 명령 옵션 |
| [도커 컨테이너 실행과 관리](docker-container-run.md) | CLD-DKR-008-MP | 실행 절차 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 컨테이너가 시작하자마자 종료될 때 가장 먼저 무엇을 확인하는가?
- [ ] 직접 겪은 컨테이너 장애가 있다면 원인과 해결을 적는다.
