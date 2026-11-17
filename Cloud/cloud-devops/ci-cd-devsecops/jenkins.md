# Jenkins CI/CD 파이프라인

## Code Block

```etc
#!groovy
// 공유 라이브러리를 설정한다.
@Library('jenkins-lib') _

pipeline {
	agent any

	environment {
    	// 공유 라이브리의 getGitRepoName() 함수를 호출한다. Repository 이름 파싱
		gitRepoName = getGitRepoName()
	}

	stages{
		stage('Checkout SCM') {
			steps {
				echo 'Checkout SCM!'
				// Jenkins 프로젝트에 설정된 Repository로 부터 현재 브랜치의 소스코드를 가져오는데 사용한다.
				checkout scm
			}
		}

		stage('Build') {
			steps {
				script {
                	// Maven Build Tool에 실행 권한을 부여한다.
					sh "chmod u+x ./mvnw"
                    sh "./mvnw clean package
				}
			}
		}

		stage('Deploy') {
			steps {
				echo 'Deploy is not yet implemented!'
			}
		}

		stage('SAST') {
			steps{
				script{
                	// SonarQube 작업을 호출한다.
					build job: 'SAST-SonarQube', parameters:[
						string(name: 'GIT_REPONAME', value: gitRepoName)
					], wait: false
				}
			}
		}
	}
}
```

## Code Block 1

```groovy
def call() {
    def gitRepoUrl = scm.getUserRemoteConfigs()[0].getUrl()
    def gitRepoName = gitRepoUrl.tokenize('/').last().replaceAll(/\.git$/, '')
	
    return gitRepoName
}
```

DevSecOps

개발자 (IDE)

GitHub

Jenkins (CI/CD)

SonarQube (SAST)

Maven

Gradle

Docker Grafana/Promethenus/ELK Stack

취약점을 가진 웹 소스

소스 커밋/푸시

변경 사항 모니터링

포크를 통해 내 깃 저장소에 WebGoat 소스를 가져올 수 있다.

Docker hub에서 Jenkins 이미지를 찾는다.

비밀번호

비밀번호 입력

젤 왼쪽에 버튼 클릭 (Jenkins 기본 플러그인 설치)

대기

admin/admin

생성형 AI 처럼 동작하지 않는다. = 패턴 기반으로 동작한다.

Rule 기반으로 동작하며 직접 작성하거나 / 외부의 룰을 가져와서 적용할 수 있다.

Rule 기반으로 동작 직접 작성 or 가져오기

접근 제어/접근 권한/인증 설정 필요

인증

인증

인증

빌드 툴 설치

SonarQube 와 Jenkins 연동을 도와주는 플러그인

Pipeline(파이프라인)

* 개발/빌드/테스트/배포 과정을 자동화하고 관리하는 일련의 과정(단계)

또는

pipeline script / pipeline script from SCM(github)

브렌치 설정

Global Trusted Pipeline Libraries

> Library Name: Jenkins-lib Default version: main

> Allow \~\~\~ check Include \~\~\~ check

Retrieval method

> Modern SCM GIT Project Repository: Jenkins-lib repo URL

save

SAST-SonarQube item 생성 프리스타일

이 빌드는 매개변수가 있습니다 - check string parameter 매개변수 명 > GIT\_REPONAME

Build Steps

> Execute SonarQube Scanner

> Analysis properties : sonar.projectKey=${GIT\_REPONAME} sonar.java.binaries=.

jenkins ssh-agent 컨테이너 실행

키 생성

복사

ssh-agent에 복사

cat > <파일이름> ssh-key ctrl + C

노드 추가

### 참고 링크

* https://github.com/WebGoat

lCpIpwOp: Excalidraw/DevSecOps\_실습.md#Code Block

2WpSohfG: Excalidraw/DevSecOps\_실습.md#Code Block 1
