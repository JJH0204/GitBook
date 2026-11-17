# Jenkins CI/CD 파이프라인

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-CIC-002-MP |
| 목적 | Jenkins에서 GitHub 소스를 빌드하고 SonarQube로 SAST를 수행하는 파이프라인을 설정한다 |
| 적용 대상 | Docker 실행 가능한 서버, Jenkins(도커 이미지), SonarQube, Maven 기반 프로젝트 |
| 소요 시간 | 약 90분 |
| 확인 상태 | 미검증 (원본 메모와 코드를 절차로 재구성한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 화면 라벨을 나열한 메모였다. 순서와 일부 연결은 문맥으로 재구성했다. 원본에 없던 SonarQube 서버 준비와 토큰 설정은 추가하지 않고 준비 절에 전제로만 적었다. Jenkins 화면 이름은 버전에 따라 다를 수 있다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [devsecops-overview.md](devsecops-overview.md) | CLD-CIC-001-DO | DevSecOps 파이프라인 개요 |
| [docker_install.md](../docker/docker_install.md) | - | Ubuntu 환경 도커 설치 |

외부 참조: WebGoat 저장소 `https://github.com/WebGoat` (점검 대상 샘플 앱)

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Docker | 설치된 상태 | |
| 2 | Jenkins 이미지 | 도커 허브 공식 이미지 | |
| 3 | SonarQube 서버 | 실행 중, 접속 가능 | 이 문서에서 설치 절차는 다루지 않는다 |
| 4 | GitHub 계정 | | WebGoat 포크용 |
| 5 | 공유 라이브러리 저장소 | `jenkins-lib` | 코드 블록 2의 함수를 담는다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: Jenkins 초기 관리자 비밀번호와 기본 계정은 반드시 변경하거나 별도 계정으로 바꾼다. 원본에 적힌 단순한 기본 계정 값을 그대로 쓰지 않는다. 인터넷에 노출된 서버에서는 인증 없는 Jenkins가 원격 코드 실행 경로가 된다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 클라우드 서버(EC2 등)에서 실습하면 인스턴스 과금이 발생한다. 실습 후 7절로 정리한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Docker가 동작한다 | `docker --version`에 버전이 출력된다 |
| 2 | SonarQube에 접속한다 | 로그인 화면이 보인다 |
| 3 | WebGoat를 내 GitHub로 포크한다 | 내 계정에 `WebGoat` 저장소가 보인다 |

## 5. 절차

### A. Jenkins 설치

1. (5-A-01) 도커 허브에서 Jenkins 이미지를 찾는다.
2. (5-A-02) Jenkins 컨테이너를 실행한다. → 결과: 웹 화면에 접속할 수 있다.
3. (5-A-03) 초기 비밀번호를 컨테이너 로그 또는 안내된 파일에서 확인한다.
4. (5-A-04) 화면에 초기 비밀번호를 입력한다.
5. (5-A-05) 왼쪽 버튼(기본 플러그인 설치)을 누른다. → 결과: 설치가 끝날 때까지 대기한 뒤 관리자 계정 생성 화면이 나온다.
6. (5-A-06) 관리자 계정을 만든다. 비밀번호는 `<관리자 비밀번호>`로 직접 정한다.

### B. 도구와 플러그인

1. (5-B-01) Maven 등 빌드 도구를 Jenkins에 설치한다. → 결과: 도구 설정에 빌드 도구가 등록된다.
2. (5-B-02) SonarQube와 Jenkins 연동 플러그인을 설치한다.
3. (5-B-03) SonarQube 접근 제어(인증)를 설정한다. → 결과: Jenkins가 SonarQube에 인증해 접속한다.

### C. 공유 라이브러리 등록

1. (5-C-01) `jenkins-lib` 저장소에 코드 블록 2(`getGitRepoName`)를 올린다.
2. (5-C-02) Jenkins에서 `Global Trusted Pipeline Libraries`를 연다.
3. (5-C-03) Library Name을 `jenkins-lib`, Default version을 `main`으로 입력한다.
4. (5-C-04) `Allow default version to be overridden`과 `Include @Library changes in job recent changes`를 체크한다.
5. (5-C-05) Retrieval method를 `Modern SCM`, `Git`으로 고르고 Project Repository에 `jenkins-lib` 저장소 URL(`<저장소 URL>`)을 입력한다.
6. (5-C-06) `Save`를 누른다. → 결과: 설정이 저장된다.

{% hint style="info" %}
NOTE: 5-C-04의 체크 항목 이름은 원본에 `Allow ~~~`, `Include ~~~`로만 적혀 있어 Jenkins의 표준 항목명으로 보충했다. 확인이 필요하다.
{% endhint %}

### D. SonarQube 작업(SAST-SonarQube) 생성

1. (5-D-01) 새 항목을 만든다. 이름은 `SAST-SonarQube`, 유형은 `프리스타일`이다.
2. (5-D-02) `이 빌드는 매개변수가 있습니다`를 체크한다.
3. (5-D-03) `String Parameter`를 추가하고 이름을 `GIT_REPONAME`으로 입력한다.
4. (5-D-04) Build Steps에서 `Execute SonarQube Scanner`를 추가한다.
5. (5-D-05) Analysis properties에 아래를 입력한다.

```
sonar.projectKey=${GIT_REPONAME}
sonar.java.binaries=.
```

6. (5-D-06) `Save`를 누른다. → 결과: 작업이 목록에 보인다.

### E. 파이프라인 작업 생성

1. (5-E-01) 파이프라인(Pipeline) 항목을 새로 만든다.
2. (5-E-02) Definition을 `Pipeline script` 또는 `Pipeline script from SCM`(GitHub)으로 고른다.
3. (5-E-03) SCM을 쓰면 저장소 URL과 브랜치를 입력한다.
4. (5-E-04) 코드 블록 1을 `Jenkinsfile`로 저장하거나 스크립트 칸에 붙여 넣는다.
5. (5-E-05) 저장 후 `지금 빌드`를 누른다. → 결과: Checkout, Build, Deploy, SAST 단계가 순서대로 실행된다.

**코드 블록 1: Jenkinsfile**

```groovy
#!groovy
// 공유 라이브러리를 설정한다.
@Library('jenkins-lib') _

pipeline {
    agent any

    environment {
        // 공유 라이브러리의 getGitRepoName() 함수를 호출한다. 저장소 이름을 파싱한다.
        gitRepoName = getGitRepoName()
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Checkout SCM!'
                // Jenkins 프로젝트에 설정된 저장소에서 현재 브랜치의 소스 코드를 가져온다.
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    // Maven 래퍼에 실행 권한을 부여한다.
                    sh "chmod u+x ./mvnw"
                    sh "./mvnw clean package"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploy is not yet implemented!'
            }
        }

        stage('SAST') {
            steps {
                script {
                    // SonarQube 작업을 호출한다.
                    build job: 'SAST-SonarQube', parameters: [
                        string(name: 'GIT_REPONAME', value: gitRepoName)
                    ], wait: false
                }
            }
        }
    }
}
```

{% hint style="info" %}
NOTE: 원본 코드의 `sh "./mvnw clean package`는 따옴표가 닫히지 않아 닫았다. 들여쓰기만 정리했고 단계 구성은 원본과 같다.
{% endhint %}

**코드 블록 2: 공유 라이브러리 `vars/getGitRepoName.groovy`**

```groovy
def call() {
    def gitRepoUrl = scm.getUserRemoteConfigs()[0].getUrl()
    def gitRepoName = gitRepoUrl.tokenize('/').last().replaceAll(/\.git$/, '')

    return gitRepoName
}
```

{% hint style="info" %}
NOTE: 공유 라이브러리의 함수 파일은 보통 `vars/<함수 이름>.groovy` 위치에 둔다. 원본은 파일 위치를 적지 않았다. 확인이 필요하다.
{% endhint %}

### F. 빌드 에이전트(ssh-agent) 노드 추가

1. (5-F-01) Jenkins ssh-agent 컨테이너를 실행한다.
2. (5-F-02) 호스트에서 SSH 키를 만든다: `ssh-keygen -t ed25519 -f <키 파일 이름>`
3. (5-F-03) 공개 키 파일의 내용을 복사한다.
4. (5-F-04) 복사한 공개 키를 ssh-agent 컨테이너에 등록한다. → 결과: 컨테이너가 해당 키로 접속을 허용한다.
5. (5-F-05) Jenkins에서 `노드 추가`를 열고 접속 정보(`<IP 주소>`, 개인 키 자격 증명)를 입력한다. → 결과: 노드가 온라인으로 표시된다.

{% hint style="danger" %}
WARNING: 개인 키는 Jenkins 자격 증명(Credentials)에만 등록한다. 파이프라인 코드나 저장소에 넣지 않는다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 파이프라인 `지금 빌드` | 4개 단계 실행 | 빌드 결과가 성공(파란색/초록색) |
| 2 | `SAST-SonarQube` 실행 이력 | 호출된 빌드 존재 | `GIT_REPONAME`에 저장소 이름이 들어 있다 |
| 3 | SonarQube 프로젝트 목록 | 프로젝트 생성 | `sonar.projectKey`와 같은 이름이 보인다 |
| 4 | 노드 목록 | 노드 상태 | 온라인 |

## 7. 복구

1. (7-01) 파이프라인 작업과 `SAST-SonarQube` 작업을 삭제한다.
2. (7-02) 추가한 노드를 삭제한다.
3. (7-03) Jenkins와 ssh-agent 컨테이너를 중지하고 삭제한다: `docker stop <컨테이너 이름>` 후 `docker rm <컨테이너 이름>`
4. (7-04) 만든 SSH 키 파일을 삭제하고 Jenkins 자격 증명에서 해당 키를 제거한다.
5. (7-05) 클라우드 서버를 썼다면 CLD-AWS-003-MP의 복구 절차로 인스턴스를 종료한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 메모를 AMM 절차 형식으로 재구성. 개념 설명은 CLD-CIC-001-DO로 분리. 코드의 따옴표 오류 정정. 원본의 기본 계정 값과 도구 내부 참조 문자열 삭제 |
