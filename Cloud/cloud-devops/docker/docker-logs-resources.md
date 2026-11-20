# [생성형 AI] 컨테이너 로그와 리소스 제한

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-025-REF |
| 유형 | REF (표) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 컨테이너 로그 조회·보관 옵션과 CPU·메모리 제한 옵션을 찾는다 |
| 확인 상태 | 미검증 (일반 지식과 도커 공식 문서의 알려진 동작을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 남은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 로그 조회

| 명령 | 설명 |
|---|---|
| `docker logs <컨테이너>` | 표준 출력과 표준 오류를 출력한다 |
| `docker logs -f <컨테이너>` | 새 로그를 계속 따라간다 |
| `docker logs --tail 100 <컨테이너>` | 마지막 100줄만 본다 |
| `docker logs --since 10m <컨테이너>` | 최근 10분 로그만 본다 |
| `docker logs -t <컨테이너>` | 줄마다 시각을 붙인다 |

컨테이너의 주 프로세스가 표준 출력(stdout)과 표준 오류(stderr)로 쓴 내용만 `docker logs`에 나온다. 파일로만 쓰는 로그는 나오지 않는다.

## 2. 로그 보관

기본 로그 드라이버는 `json-file`이다. 크기 제한을 따로 두지 않으면 로그 파일이 계속 커져 디스크를 채울 수 있다.

| 번호 | 옵션 | 설명 |
|---|---|---|
| 1 | `--log-opt max-size=10m` | 로그 파일 하나의 최대 크기 |
| 2 | `--log-opt max-file=3` | 보관할 로그 파일 수 (회전, rotation) |
| 3 | `--log-driver <이름>` | 로그 드라이버를 바꾼다 (`local`, `syslog`, `journald` 등) |

```bash
docker run -d --name web \
  --log-opt max-size=10m --log-opt max-file=3 \
  nginx:stable
```

호스트 전체 기본값은 `/etc/docker/daemon.json`의 `log-driver`, `log-opts`에 적는다. 이 설정은 이후 새로 만드는 컨테이너부터 적용된다. 변경 후 도커 데몬을 재시작한다.

## 3. 리소스 제한

| 번호 | 옵션 | 설명 |
|---|---|---|
| 1 | `--memory 512m` (`-m`) | 메모리 상한. 넘기면 커널이 프로세스를 종료할 수 있다 |
| 2 | `--memory-swap <값>` | 메모리와 스왑의 합계 상한 |
| 3 | `--cpus 1.5` | 사용할 수 있는 CPU 코어 수 상한 |
| 4 | `--cpu-shares <값>` | CPU가 부족할 때의 상대 가중치 |
| 5 | `--pids-limit <값>` | 컨테이너 안 프로세스 수 상한 |

```bash
docker run -d --name api --memory 512m --cpus 1.5 --pids-limit 200 myapp:1.0
docker update --memory 1g --memory-swap 1g api
```

## 4. 사용량과 종료 원인 확인

| 명령 | 설명 |
|---|---|
| `docker stats` | 컨테이너별 CPU, 메모리, 네트워크, 디스크 I/O를 실시간으로 본다 |
| `docker stats --no-stream` | 한 번만 출력한다 |
| `docker inspect -f '{{.State.OOMKilled}}' <컨테이너>` | 메모리 부족(OOM)으로 종료됐는지 확인한다 (`true`/`false`) |
| `docker inspect -f '{{.State.ExitCode}}' <컨테이너>` | 종료 코드를 확인한다. 137은 `SIGKILL`로 종료됐다는 뜻이며 OOM일 때 흔하다 |
| `docker system df` | 이미지, 컨테이너, 볼륨, 빌드 캐시의 디스크 사용량 |

{% hint style="warning" %}
CAUTION: 메모리 상한을 실제 필요량보다 낮게 주면 컨테이너가 반복해서 종료된다. `docker stats`로 평소 사용량을 본 뒤 여유를 두고 정한다.
{% endhint %}

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 필수 명령어](docker_commend.md) | CLD-DKR-007-REF | 기본 명령 |
| [컨테이너 장애 진단](docker-troubleshooting.md) | CLD-DKR-023-TS | 종료 코드, OOM |
| [Docker Compose 파일 작성법](docker-compose-file.md) | CLD-DKR-021-REF | Compose에서 제한 지정 |
