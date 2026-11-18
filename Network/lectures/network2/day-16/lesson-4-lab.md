# 롤링 업데이트와 롤백 실습

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-012-MP |
| 목적 | 코드를 고쳐 `mysite:1.1`을 굽고, `set image`로 끊김 없이 바꾸고, `rollout undo`로 되돌린 뒤, 매니페스트를 Git에 커밋한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), 포트 매핑 설정으로 만든 kind 클러스터 `student`, NodePort로 열린 `mysite` Deployment, 터미널 두 개 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 클러스터에서 실행해 확인하지 않았다. `set image`의 롤링 순서와 `rollout undo`는 원본에서도 교실 리허설 대상으로 남아 있다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N2-16-004-DO | 고치고 되돌리기 |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-N2-16-011-MP | NodePort 공개 실습 |
| [commands.md](commands.md) | LEC-N2-16-007-REF | 16일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 두 개 | Ubuntu 24.04 | 터미널 A는 관찰, 터미널 B는 명령 |
| 2 | 13일차 저장소 `~/myweb` | `site/index.html`, `Dockerfile`, `k8s/` | |
| 3 | 브라우저 | Windows | 선택 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `mysite:1.0` 이미지를 노드와 Docker에서 지우지 않는다. 지우면 5-C의 롤백이 실패한다. 이미지를 `latest` 하나로 덮어쓰지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `replicas: 1`이면 교체 중에 순간적으로 끊길 수 있다. 5-A-01에서 `replicas`를 2로 올려 둔다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | NodePort로 접속된다 | `curl http://localhost:8080`이 내 포트폴리오를 출력한다 |
| 2 | 1.0 이미지가 노드에 있다 | `docker exec student-control-plane crictl images \| grep mysite`가 `1.0`을 출력한다 |

## 5. 절차

### A. 준비와 새 이미지

1. (5-A-01) 터미널 B에서 복제본을 2개로 늘린다: `kubectl scale deployment mysite --replicas=2` → 결과: `deployment.apps/mysite scaled`.
2. (5-A-02) 폴더로 이동한다: `cd ~/myweb`
3. (5-A-03) `nano site/index.html`로 제목을 바꾸고 저장한다. → 결과: 바뀐 제목이 파일에 있다.
4. (5-A-04) 새 태그로 굽는다: `docker build -t mysite:1.1 .` → 결과: 빌드가 오류 없이 끝난다.
5. (5-A-05) 파일로 뜬다: `docker image save --platform linux/amd64 -o /tmp/mysite-1.1.tar mysite:1.1` → 결과: `/tmp/mysite-1.1.tar`가 생긴다.
6. (5-A-06) 노드에 넣는다: `kind load image-archive /tmp/mysite-1.1.tar --name student` → 결과: 오류 없이 끝난다.
7. (5-A-07) 두 태그를 확인한다: `docker images | grep mysite` → 결과: `1.0`과 `1.1`이 모두 보인다.

### B. 롤링 업데이트

1. (5-B-01) 터미널 A에서 지켜본다: `kubectl get pods -w`
2. (5-B-02) 터미널 B에서 이미지를 바꾼다: `kubectl set image deployment/mysite mysite=mysite:1.1` → 결과: `deployment.apps/mysite image updated`.
3. (5-B-03) 진행을 기다린다: `kubectl rollout status deployment/mysite` → 결과: `successfully rolled out`.
4. (5-B-04) 터미널 A의 순서를 읽는다. → 결과: 새 Pod가 `Running`이 된 뒤에 옛 Pod가 `Terminating`이 된다.
5. (5-B-05) 접속한다: `curl http://localhost:8080` → 결과: 바뀐 제목이 보인다.

### C. 롤백

1. (5-C-01) 이력을 본다: `kubectl rollout history deployment/mysite` → 결과: 리비전이 두 개 이상 보인다.
2. (5-C-02) 되돌린다: `kubectl rollout undo deployment/mysite` → 결과: `deployment.apps/mysite rolled back`.
3. (5-C-03) 진행을 기다린다: `kubectl rollout status deployment/mysite` → 결과: `successfully rolled out`.
4. (5-C-04) 접속한다: `curl http://localhost:8080` → 결과: 1.0의 제목으로 돌아온다.

### D. Git에 적어 둔다

1. (5-D-01) 매니페스트를 커밋하고 올린다: `cd ~/myweb && git add k8s/ && git commit -m "쿠버네티스 배포 매니페스트" && git push` → 결과: 커밋이 만들어지고 `push`가 끝난다.

{% hint style="danger" %}
WARNING: `k8s/` 폴더에 Secret의 실제 값을 담은 파일이 없는지 `git status`와 `git diff --staged`로 확인한 뒤 커밋한다. 커밋하면 지워도 이력에 남는다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 5-B-04의 터미널 A | 새 Pod `Running` 후 옛 Pod `Terminating` | 순서가 맞다 |
| 2 | 5-B-05의 `curl` | 바뀐 제목 | 1.1의 내용이다 |
| 3 | 5-C-04의 `curl` | 1.0의 제목 | 1.0의 내용이다 |
| 4 | `git log --oneline \| head -3` | 방금 커밋 | 커밋 메시지가 보인다 |

## 7. 복구

1. (7-01) 복제본 수를 되돌린다: `kubectl scale deployment mysite --replicas=1` → 결과: `deployment.apps/mysite scaled`.
2. (7-02) 이미지 파일을 지운다: `rm /tmp/mysite-1.1.tar`
3. (7-03) 클러스터와 저장소는 지우지 않는다. 오늘 만든 저장소는 16일의 결과물이다. 집에서 다시 해보려면 클러스터도 남겨 둔다. 지우려면 `kind delete cluster --name student`를 실행한다.

{% hint style="danger" %}
WARNING: `kind delete cluster`는 되돌릴 수 없다. 실행 전 3초 멈춘다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-4.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. 복구 절을 추가했다. 커밋 전 비밀 확인 경고를 추가했다 |
