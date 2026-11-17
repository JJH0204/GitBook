# 도커 허브 이미지 공유 실습

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-017-MP |
| 목적 | WordPress가 구동 중인 Ubuntu 컨테이너를 이미지로 저장해 Docker Hub에 올리고, 다른 사용자가 내려받아 쓰게 한다 |
| 적용 대상 | 도커 엔진이 설치된 환경, Docker Hub 계정, [Ubuntu 워드프레스 도커 배포](ubuntu-wordpress-docker.md)(CLD-DKR-018-MP)로 만든 컨테이너 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 페이지의 절차를 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Ubuntu 워드프레스 도커 배포](ubuntu-wordpress-docker.md) | CLD-DKR-018-MP | 공유할 컨테이너 만들기 |
| [도커 허브 활용 가이드](docker_hub.md) | CLD-DKR-015-MP | 로그인, 올리기, 내려받기 |
| [도커 컨테이너 이미지화와 Compose 공유](docker-hub-compose-share.md) | CLD-DKR-016-MP | 여러 컨테이너를 공유하는 경우 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 도커 엔진 | 설치 완료 | |
| 2 | Docker Hub 계정 | `<사용자명>` | [Docker Hub](https://hub.docker.com/)에서 만든다 |
| 3 | WordPress 컨테이너 | 실행 중 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `docker commit`은 컨테이너 안의 모든 파일을 이미지에 넣는다. 데이터베이스 비밀번호, `wp-config.php`, 관리자 계정 데이터, 작성한 글이 들어 있으면 공개 저장소에서 누구나 내려받을 수 있다. 올리기 전에 이를 제거하거나 비공개 저장소를 쓴다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | WordPress 컨테이너가 실행 중이다 | `docker ps`에 컨테이너가 `Up`으로 보인다 |
| 2 | 이미지 크기를 줄일 정리 작업을 마쳤다 | 컨테이너 안에서 5-A-01을 실행했다 |
| 3 | 이미지에 비밀값이 없다 | 컨테이너 안의 설정 파일에 실제 비밀번호가 없음을 확인했다 |

## 5. 절차

### A. 컨테이너 정리

1. (5-A-01) 컨테이너 안에서 캐시를 정리한다: `apt-get clean && rm -rf /var/lib/apt/lists/*` → 결과: 오류 없이 끝난다. 이미지 크기가 줄어든다.

### B. 로그인과 이미지 저장

1. (5-B-01) Docker Hub에 로그인한다: `docker login` → 결과: 사용자명 `<사용자명>`과 비밀번호 `<비밀번호>`를 입력하면 `Login Succeeded`가 출력된다.
2. (5-B-02) 실행 중인 컨테이너를 확인한다: `docker ps` → 결과: WordPress 컨테이너의 ID와 이름이 보인다.
3. (5-B-03) 컨테이너를 이미지로 저장한다: `docker commit <컨테이너 ID> <사용자명>/<이미지명>:<태그>` → 결과: 이미지 ID(sha256)가 출력된다. 예: `docker commit <컨테이너 ID> <사용자명>/ubuntu-wordpress:1.0`
4. (5-B-04) 이미지를 확인한다: `docker images` → 결과: `<사용자명>/<이미지명>`이 `<태그>`와 함께 보인다.

{% hint style="info" %}
NOTE: 원본은 태그를 `latest`로 썼다. `latest`는 버전 고정이 아니므로 `1.0`처럼 버전을 명시한 태그를 권장한다.
{% endhint %}

### C. 테스트 실행

1. (5-C-01) 새 컨테이너로 이미지를 테스트한다: `docker run -it -p 8080:80 <사용자명>/<이미지명>:<태그>` → 결과: 컨테이너 셸이 열린다.

{% hint style="warning" %}
CAUTION: `-p 8080:80`은 호스트의 8080번 포트를 모든 네트워크 인터페이스에 연다. 내 PC에서만 확인하려면 `-p 127.0.0.1:8080:80`을 쓴다.
{% endhint %}

{% hint style="info" %}
NOTE: `docker commit`은 실행 중이던 프로세스를 저장하지 않는다. 새 컨테이너에서는 MariaDB와 Apache가 자동으로 시작되지 않는다. 셸에서 `service mariadb start`와 `service apache2 start`를 실행해야 한다. 미검증이다.
{% endhint %}

2. (5-C-02) 컨테이너 셸에서 서비스를 시작한다: `service mariadb start && service apache2 start` → 결과: 두 서비스가 오류 없이 시작된다.
3. (5-C-03) 접속을 확인한다: 브라우저에서 `http://localhost:8080/wordpress`를 연다 → 결과: WordPress 화면이 열린다.

### D. Docker Hub에 올리기

1. (5-D-01) 이미지를 올린다: `docker push <사용자명>/<이미지명>:<태그>` → 결과: 마지막 줄에 `digest: sha256:...`이 출력된다.
2. (5-D-02) Docker Hub 웹에 로그인해 `Repositories`를 연다 → 결과: 올린 이미지가 목록에 보인다.

### E. 다른 사용자의 사용

1. (5-E-01) 이미지를 내려받는다: `docker pull <사용자명>/<이미지명>:<태그>` → 결과: `Status: Downloaded newer image`가 출력된다.
2. (5-E-02) 컨테이너를 실행한다: `docker run -it -p 8080:80 <사용자명>/<이미지명>:<태그>` → 결과: 컨테이너 셸이 열린다. 5-C-02와 같이 서비스를 시작한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker images` | 저장한 이미지가 있다 | `<사용자명>/<이미지명>`이 보인다 |
| 2 | 5-C-03 접속 | WordPress가 응답한다 | 화면이 열린다 |
| 3 | Docker Hub 저장소 목록 | 올린 이미지가 보인다 | 태그가 목록에 있다 |

## 7. 복구

1. (7-01) 테스트 컨테이너를 삭제한다: 컨테이너에서 `exit` 후 `docker rm <테스트 컨테이너 ID>`
2. (7-02) 로컬 이미지를 삭제한다: `docker rmi <사용자명>/<이미지명>:<태그>`
3. (7-03) 올린 이미지를 지우려면 Docker Hub 웹의 저장소 설정에서 삭제한다. 이미 내려받은 사람의 복사본은 지워지지 않는다.
4. (7-04) 로그아웃한다: `docker logout`

## 8. 참고

이미지 공유에는 이미지를 직접 올리는 방식보다 Dockerfile을 공유하는 방식이 일반적이다. Dockerfile을 쓰면 이미지 생성 과정을 재현할 수 있다. 절차는 [Dockerfile 작성법 및 실습](dockerfile.md)(CLD-DKR-010-REF)을 따른다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | stepper를 MP 형식으로 재작성. 대화체 문장과 이모지를 삭제하고 사용자명을 `<사용자명>`으로 바꿨다. 이미지 공개 WARNING, 서비스 자동 시작 NOTE, 포트 개방 CAUTION과 복구 절차를 추가했다 |
