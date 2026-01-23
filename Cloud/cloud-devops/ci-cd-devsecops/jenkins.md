# Jenkins

{% hint style="warning" %}
Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document.\
You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'
{% endhint %}

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

## Excalidraw Data

### Text Elements

DevSecOps ^0C5o8NyC

개발자 (IDE) ^x70lGmiK

GitHub ^yyo1pCWp

Jenkins (CI/CD) ^3aqajq3Y

SonarQube (SAST) ^BMWvOdYk

Maven ^lSFBFy00

Gradle ^GMxQiYqY

Docker Grafana/Promethenus/ELK Stack ^Y3w68U5D

취약점을 가진 웹 소스 ^xkN5BQN1

소스 커밋/푸시 ^3jZYYuFv

변경 사항 모니터링 ^rVeWCETT

포크를 통해 내 깃 저장소에 WebGoat 소스를 가져올 수 있다. ^dAvHEf2M

Docker hub에서 Jenkins 이미지를 찾는다. ^D7GOVdMQ

비밀번호 ^Ct0QMHAh

비밀번호 입력 ^eV5YO2Gn

젤 왼쪽에 버튼 클릭 (Jenkins 기본 플러그인 설치) ^Z0x0A4IP

대기 ^YxpO80Oh

admin/admin ^eH74CZ0I

생성형 AI 처럼 동작하지 않는다. = 패턴 기반으로 동작한다. ^66wMbEFT

Rule 기반으로 동작하며 직접 작성하거나 / 외부의 룰을 가져와서 적용할 수 있다. ^qZB8lQlv

Rule 기반으로 동작 직접 작성 or 가져오기 ^17EgcM4k

접근 제어/접근 권한/인증 설정 필요 ^YCTpMStb

인증 ^vvqrGL8l

인증 ^mCm07UgW

인증 ^3MKb3r9k

빌드 툴 설치 ^lqBz7eo2

SonarQube 와 Jenkins 연동을 도와주는 플러그인 ^QBxtlaht

Pipeline(파이프라인)

* 개발/빌드/테스트/배포 과정을 자동화하고 관리하는 일련의 과정(단계) ^juom5HSZ

또는 ^Pn0mgyRX

pipeline script / pipeline script from SCM(github) ^JYSNOHn5

브렌치 설정 ^zDOY6taJ

Global Trusted Pipeline Libraries

> Library Name: Jenkins-lib Default version: main

> Allow \~\~\~ check Include \~\~\~ check

Retrieval method

> Modern SCM GIT Project Repository: Jenkins-lib repo URL

save ^tUyhl6lT

SAST-SonarQube item 생성 프리스타일 ^ojwwG3fW

이 빌드는 매개변수가 있습니다 - check string parameter 매개변수 명 > GIT\_REPONAME

Build Steps

> Execute SonarQube Scanner

> Analysis properties : sonar.projectKey=${GIT\_REPONAME} sonar.java.binaries=.

^b7vmiLNq

jenkins ssh-agent 컨테이너 실행 ^kui9KRsu

키 생성 ^3W9AEi1Y

복사 ^b2alctx7

ssh-agent에 복사 ^WeAd0rqI

cat > <파일이름> ssh-key ctrl + C ^DMAM11D3

노드 추가 ^82HCPEzB

### Element Links

DNkOaH4y: https://github.com/WebGoat

lCpIpwOp: [Excalidraw/DevSecOps\_실습.md#Code Block](/broken/pages/bab91893396be675327562653d753b40ff021a78)

2WpSohfG: [Excalidraw/DevSecOps\_실습.md#Code Block 1](/broken/pages/94fd538abae8b4a36dbe98b1877405924db38095)

### Embedded Files

ced07650a16444afd92197a66db432113c54d756: \[\[topics/assets/images/Pasted Image 20241217091015\_889.png]]

3783f7cf583d4b41856d6c5e6822b70e6d4c7fc3: \[\[topics/assets/images/Pasted Image 20241217091031\_201.png]]

31a8f3034ea68f153c473a98ea172c4b3a624f10: \[\[topics/assets/images/Pasted Image 20241217091222\_567.png]]

8f4344a30a1275b31489b58d0c8dae5d659c50d5: \[\[topics/assets/images/Pasted Image 20241217094554\_855.png]]

5510b59fbf04d293f0f31735e29cfc362999f516: \[\[topics/assets/images/Pasted Image 20241217094645\_731.png]]

489b252d7ccb56a3b3b31e42d4192b666d3aa526: \[\[topics/assets/images/Pasted Image 20241217094907\_944.png]]

e36dac8f1f74832332543162a10bf246c9db1fcb: \[\[topics/assets/images/Pasted Image 20241217094924\_402.png]]

5bfa30c1f5237b8acd0ddee9ecbf34f23007d1c2: \[\[topics/assets/images/Pasted Image 20241217095130\_658.png]]

eaefbb31e7a3383c57b946a904710bca08b355a0: \[\[topics/assets/images/Pasted Image 20241217100819\_378.png]]

b26b6b9aead912312075e71470d178661c73acb8: \[\[topics/assets/images/Pasted Image 20241217100834\_983.png]]

a264efcd98691c77af3f5f35e916eb0f80566ed0: \[\[topics/assets/images/Pasted Image 20241217100915\_936.png]]

56f0dff297a917a8977f62da89b1d9329fcc6c7f: \[\[topics/assets/images/Pasted Image 20241217101109\_513.png]]

ca485939ed918c360fb29ffb7fbf5d9aa62cbb47: \[\[topics/assets/images/Pasted Image 20241217101251\_026.png]]

f64761e671d25bacdd2dabc1c2f52ba6f0d9fb57: \[\[topics/assets/images/Pasted Image 20241217101356\_681.png]]

5afab79329e713eff3b5dc3bdbfcec7fd8e995ea: \[\[topics/assets/images/Pasted Image 20241217101523\_747.png]]

b2716dd6cecfbfa012f8aa6db525a49f8d26b618: \[\[topics/assets/images/Pasted Image 20241217101626\_198.png]]

bc54547c7d46b58564231fe027325381696c3d41: \[\[topics/assets/images/Pasted Image 20241217101847\_093.png]]

9511fa165df463ef362846a2dd35cfbf8db56324: \[\[topics/assets/images/Pasted Image 20241217102112\_329.png]]

0ad8116a1b021a5732077b3ade15cfca193ea59a: \[\[topics/assets/images/Pasted Image 20241217102231\_092.png]]

80825c087f9c38ec489756fff77e82ecf675f64f: \[\[topics/assets/images/Pasted Image 20241217102519\_070.png]]

02b0e02742bea817fef225cdb4760aafa9198d6d: \[\[topics/assets/images/Pasted Image 20241217102656\_797.png]]

0020fc88da2829cb32a52060d90c6741b9422491: \[\[topics/assets/images/Pasted Image 20241217103109\_843.png]]

093f5d45df273724b06fb54971d89ad306366199: \[\[topics/assets/images/Pasted Image 20241217103142\_421.png]]

37391957d03bf8f273bd27193efe87577c76f578: \[\[topics/assets/images/Pasted Image 20241217103213\_601.png]]

b5d24190d4237dce8c4939dc0323842116d2cc75: \[\[topics/assets/images/Pasted Image 20241217103258\_959.png]]

4d1dfbaba778d1f12f845a18e36a9e9e6790e81a: \[\[topics/assets/images/Pasted Image 20241217103355\_606.png]]

f886d26e16c6af5abbfc136486ad5ee8afc9f5db: \[\[topics/assets/images/Pasted Image 20241217103707\_693.png]]

804191053e3a727c8577f5b068cdc9226a16eefc: \[\[topics/assets/images/Pasted Image 20241217104321\_042.png]]

cd5dce66219fc77e7b2c64f5118947d8e1a4dc93: \[\[topics/assets/images/Pasted Image 20241217104357\_833.png]]

488cd1695da221c148ac8c2a09b06de0cfaf7412: \[\[topics/assets/images/Pasted Image 20241217104615\_570.png]]

b476426689867886becde14e7c68bbe92ade71d6: \[\[topics/assets/images/Pasted Image 20241217104853\_915.png]]

b94e8d89db43f487003e6d8f2021aa95bcff62ae: \[\[topics/assets/images/Pasted Image 20241217105047\_634.png]]

a7ab69dd0cf3bbfa27a3a3a0e68a6313883cdd44: \[\[topics/assets/images/Pasted Image 20241217105148\_516.png]]

76561a344d6b07a105b8c65782a549edc6f61192: \[\[topics/assets/images/Pasted Image 20241217105257\_117.png]]

19cec84a409954cb22192a6933384ac6eb5ef9c5: \[\[topics/assets/images/Pasted Image 20241217105349\_323.png]]

21ef3a1c08d71b65e2ccb9ad920a4f3b0d7beb80: \[\[topics/assets/images/Pasted Image 20241217105433\_755.png]]

8af07e230980692562d774de50c604d4ee6c3a1e: \[\[topics/assets/images/Pasted Image 20241217105526\_823.png]]

e9b97bda6a786a82a5e3afaa4e045ea285502542: \[\[topics/assets/images/Pasted Image 20241217105617\_039.png]]

82bcc62fe86aacfbb245b430efb81d7e1b6a4ce2: \[\[topics/assets/images/Pasted Image 20241217105712\_640.png]]

492a546faf0fdb4c18249758119618526e41b4bd: \[\[topics/assets/images/Pasted Image 20241217110029\_020.png]]

e4a00ea045eb7b8563198393bb8c999dfdb94c6a: \[\[topics/assets/images/Pasted Image 20241217111108\_036.png]]

1b956d11dccb8b1f4c170c33584c2a97e7a5f16b: \[\[topics/assets/images/Pasted Image 20241217111843\_869.png]]

67ef0f84937dc9bdda6d40033087b70bffbd39e2: \[\[topics/assets/images/Pasted Image 20241217112311\_597.png]]

3f4ef031ea433f1196aeab34bfaa9a104e207f95: \[\[topics/assets/images/Pasted Image 20241217112744\_350.png]]

f99319d05b8cc64dbbd14f88c530e61f07cdc02a: \[\[topics/assets/images/Pasted Image 20241217113910\_255.png]]

10ed8e8e3ff04db6326452cc1981118db55698a0: \[\[topics/assets/images/Pasted Image 20241217113943\_228.png]]

7cfd4d6460cb84f55212476befe986a0daaa0b91: \[\[topics/assets/images/Pasted Image 20241217114155\_541.png]]

d35826341b78076c75fde1a48bddf60a3cf5baca: \[\[topics/assets/images/Pasted Image 20241217114238\_296.png]]

a3c8a486260f6d2b216f3fca0175ba77d0d14b6d: \[\[topics/assets/images/Pasted Image 20241217114253\_848.png]]

dabc321898ec26f64e971dd4e31538934c109c63: \[\[topics/assets/images/Pasted Image 20241217114353\_007.png]]

901a331db024f83cb82c9d7a56d35fa3507e4d0a: \[\[topics/assets/images/Pasted Image 20241217114437\_791.png]]

f27aa88827eafd58cc47dad0a60d4b40ecf8cb7c: \[\[topics/assets/images/Pasted Image 20241217114618\_938.png]]

5731829e92717d9602e8b9ce9b350d1c5bf8c8d3: \[\[topics/assets/images/Pasted Image 20241217114849\_772.png]]

b6c4d5ec5dba828a6c2ad091f159ce166209697f: \[\[topics/assets/images/Pasted Image 20241217114902\_086.png]]

0b102f672977b0aa80747da883e2ab8326b23283: \[\[topics/assets/images/Pasted Image 20241217115015\_869.png]]

a142f4a6160d58587e9d88226633cafb477acf8a: \[\[topics/assets/images/Pasted Image 20241217122536\_173.png]]

ccf6e3d47049a9ea59dd60d8f1642aa6c0dedc8d: \[\[topics/assets/images/Pasted Image 20241217123504\_526.png]]

33283df18e33ca7934cf7ed528ebe5a906cac98d: \[\[topics/assets/images/Pasted Image 20241217123545\_344.png]]

### Drawing

```compressed-json
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

... (truncated for brevity in this view; original compressed JSON continues)
```

(Note: The drawing block above contains compressed Excalidraw JSON data. Keep the block intact when importing or decompressing in the Excalidraw plugin.)
