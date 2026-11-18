# [생성형 AI] 도커 볼륨과 데이터 보존

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-020-DO |
| 유형 | D&O (개념) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 목적 | 컨테이너 데이터를 보존하는 세 방식(볼륨, 바인드 마운트, tmpfs)과 백업 방법을 설명한다 |
| 확인 상태 | 미검증 (일반 지식과 도커 공식 문서의 알려진 동작을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-19) |

{% hint style="info" %}
NOTE: 이 쪽은 기존 쪽이 다루지 않은 공백을 생성형 AI가 채운 초안이다. 사람 검토 전이다.
{% endhint %}

## 1. 목적

컨테이너의 쓰기 가능한 계층은 컨테이너를 삭제하면 함께 사라진다. 이 문서는 데이터를 컨테이너 밖에 두는 방식을 비교하고, 볼륨을 만들고 백업하는 명령을 정리한다.

## 2. 구성 요소

| 번호 | 방식 | 저장 위치 | 관리 주체 | 용도 |
|---|---|---|---|---|
| 1 | 명명된 볼륨(named volume) | 도커 데이터 영역(Linux 기본 `/var/lib/docker/volumes/`) | 도커 | 데이터베이스 등 보존할 데이터 |
| 2 | 바인드 마운트(bind mount) | 호스트의 지정한 경로 | 사용자 | 소스 코드, 설정 파일을 컨테이너에 보여줄 때 |
| 3 | tmpfs 마운트 | 호스트 메모리 | 도커 | 디스크에 남기면 안 되는 임시 데이터 (Linux) |

| 명령 | 설명 |
|---|---|
| `docker volume create <볼륨명>` | 볼륨을 만든다 |
| `docker volume ls` | 볼륨 목록을 본다 |
| `docker volume inspect <볼륨명>` | 저장 위치(`Mountpoint`) 등을 본다 |
| `docker volume rm <볼륨명>` | 볼륨을 삭제한다. 사용 중인 볼륨은 삭제되지 않는다 |
| `docker volume prune` | 어떤 컨테이너도 쓰지 않는 볼륨을 삭제한다 |

## 3. 동작 원리

1. `-v <볼륨명>:<컨테이너 경로>`로 실행하면 이름의 볼륨이 없을 때 도커가 만들어 연결한다.
2. 명명된 볼륨이 비어 있으면 도커는 컨테이너 경로에 이미지가 가진 파일을 볼륨에 복사한다. 바인드 마운트는 복사하지 않고 호스트 경로의 내용이 컨테이너 경로를 가린다.
3. 컨테이너를 삭제해도 명명된 볼륨은 남는다. 볼륨은 `docker volume rm`으로 따로 지운다.
4. `--mount`는 `type=`, `source=`, `target=`를 이름으로 적어 `-v`보다 읽기 쉽다.

```bash
docker run -d --name db -v db-data:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=<비밀번호> mariadb:11
docker run -d --name web --mount type=bind,source="$PWD"/site,target=/usr/share/nginx/html,readonly nginx:stable
```

백업은 임시 컨테이너로 볼륨을 읽어 압축하는 방식이 일반적이다.

```bash
docker run --rm -v db-data:/data -v "$PWD":/backup busybox tar czf /backup/db-data.tgz -C /data .
```

{% hint style="warning" %}
CAUTION: 실행 중인 데이터베이스의 파일을 그대로 압축하면 일관되지 않은 백업이 될 수 있다. 데이터베이스는 중지하거나 해당 DB의 덤프 도구를 쓴다.
{% endhint %}

{% hint style="danger" %}
WARNING: `docker volume prune`과 `docker compose down -v`는 볼륨의 데이터를 삭제한다. 삭제 전에 백업을 확인한다.
{% endhint %}

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 볼륨(Volume) | 도커가 관리하는 컨테이너 밖 저장 영역 |
| 바인드 마운트(Bind mount) | 호스트의 경로를 컨테이너에 직접 연결하는 방식 |
| tmpfs | 메모리에 두는 임시 파일 시스템 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [도커 핵심 이론](dockertheory.md) | CLD-DKR-002-DO | 컨테이너와 볼륨 |
| [Docker Compose 파일 작성법](docker-compose-file.md) | CLD-DKR-021-REF | `volumes` 키 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 데이터베이스에는 명명된 볼륨과 바인드 마운트 중 무엇이 맞는가? 이유는?
- [ ] 컨테이너를 삭제했는데 볼륨이 남아 있는 것은 장점인가 단점인가?
