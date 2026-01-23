# DockerTheory

\==⚠ Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠==\
You can decompress Drawing data with the command palette: 'Decompress current Excalidraw file'. For more info check in plugin settings under 'Saving'

## Code Block

```bash
vi docker.sh
```

## Code Block 1

```bash
#!/bin/bash

for i in $(seq 1 10)
do
docker container create nginx
done
```

## Excalidraw Data

### Text Elements (원문 그대로)

* 컨테이너 기반 클라우드 서비스 ^SekwLr25
* docker / docker hub ^nsWLLTQY
* system 위에 별도의 컨테이너를 이미지를 활용해 구축
  * 쉽고 간단하게 필요한 개발 환경을 가져오고 구축할 수 있게 된다.
  * 내가 구축한 이미지를 다른 사람에게 공유도 할 수 있다. ^WhsQWdFe
* private(유료) / public(무료) ^Cp3B1Cwp
* APP / APP/ APP
* VM1 / VM2 / VM3
* Hyper-v
* Host OS
* 인프라 ^M9sn2QmL
* VM 들은 인프라에 종속된다.
* 리소스를 나눠서 사용해야 된다.
* VM 을 삭제하지 않으면 점유한 리소스를 Host OS나 다른 VM에 분배할 수 없다.
* Host OS 의 여유 리소스가 중요 ^Qq7A3KRn
* APP(image) / APP(image) / APP(image)
* (링크/바인드 표현 생략)
* Docker Engine
* Host OS
* 인프라 ^45Uk380X
* VM 기준 ^LZtqO0oX
* Docker 기준 ^0gVmSIt2

#### Docker command (카테고리별)

* system\
  docker \[version / system info / system prune / system df / logout / login / 등]
* image\
  docker \[images / images ls / images inspect / image prune / pull / push / rm / 등]
* container\
  docker container \[ps / stats / logs / ls / port / 등]
* network\
  docker network \[ls / create / connect / disconnect / inspect / rm / 등]
* volumn (원문에 'volumn' 표기)

#### 컨테이너와 볼륨

* 컨테이너란? ^61iAqWe3\
  격리된 환경 (다른 컨테이너 끼리 서로 영향을 줄 수 없다.) ^lKLw5L58
* python 3.9 ^d0UJqndG
* python 2.1 ^sctS2pQs
* 볼륨이란? ^YE8fCHH3\
  이미지가 가진 내용(패키징된) ^0wqATx7P
* 파일(디렉터리)열거 뿐 아니라 공유가 필요할 때 사용 ^HzFhPXBQ
* 컨테이너-컨테이너
* 컨테이너-호스트 ^ceDYeXru
* "컨테이너의 데이터 관리를 위한 매커니즘" ^xhu9MK7c

### Docker install on Linux (원문 단계 요약)

경로 확인 > 설치 (repo) ^hQ8S3tnW

{% stepper %}
{% step %}
### 패키지 관리자 업데이트

1. 패키지 관리자 업데이트 ^JTko08o5
{% endstep %}

{% step %}
### Docker 리포지터리 추가

dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo ^TjyumGt9
{% endstep %}

{% step %}
### Docker 설치

dnf install -y docker-ce
{% endstep %}

{% step %}
### 버전 확인

docker --version
{% endstep %}

{% step %}
### Docker 서비스 활성화 및 시작

systemctl enable --now docker ^lRPtBopu
{% endstep %}
{% endstepper %}

* 설치 흐름: docker hub > image install > 컨테이너 구축 > 실행 ^rPRIdn74
* 설치한 이미지가 없더라도 실행하는 컨테이너에 이미지 이름과 같은 이미지를 docker hub 에서 pull 하여 실행한다. (이때 가장 최신 버전의 이미지를 가져옴) ^9IEyGK5u
* 원하는 버전의 이미지를 설치(관리)하기 위해서 태그를 사용 ^1aYzWg6a
* 태그로 이미지를 구분하여 구현한 app에 필요한 버전의 tool/IDE를 불러올 수 있다. ^wzrVLhLX

예시:

* 우분투를 실행할 때 함께 실행할 명령어를 지정할 수 있다. ^OTARizSv\
  docker container run ubuntu:latest /bin/echo "hello Ubuntu" ^HvTN5nB6
* 컨테이너를 삭제할 수 있다.(실행 중이면 불가능) ^zDGC1Kzk\
  단, 이미지가 삭제된 것은 아니다. ^mkcR11nJ
* nignx툴을 활용해 웹 서버를 구축할 때 ^fxUEOi1V\
  docker image pull nginx:latest ^Qn8vpCLq
* 도커 이미지 삭제 명령어 ^gDEm25Hq\
  docker image rm hello-world ^mJYlo1Pc
* 도커 관리 명령어 ^B01KtXrh\
  또는 docker image ls ^N0DE8kmr
* 컨테이너 실행 예시:\
  docker container run --name linux-web -d -p 80:80 nginx ^ag41Nlq1\
  설명: 실행할 컨테이너 이름 ^Lrc5aP21, 포트 설정 ^T6FgksuG, 실행 이미지 ^2UsE4ZAG, 백그라운드 실행 여부 ^fNxoNLE0
* 백그라운드 실행을 하지 않으면 해당 머신 안으로 들어가게 된다. ^SRFyxA6E
* 모니터링 / 제어
  * docker stats \[컨테이너 이름/컨테이너ID] ^RK2z8Onk
  * 종료: docker container stop \[컨테이너 이름/컨테이너ID] ^yGaFkqk8
  * 시작: docker container start linux-web ^IO3bAa4y
  * 실행중인 컨테이너 정보: docker container ls ^YFcGp4oO
  * 설치한 이미지 확인: docker image ls ^vmlem9e0
* 컨테이너를 생성한 후에는 중지/실행 해도 ID는 바뀌지 않음 ^IS8paTfY
* 권한 관련: 일반 사용자는 docker 명령어를 사용할 수 없다. docker도 docker를 설치하면 docker 사용자를 만든다. (http,apache 처럼) ^clMR1vBl\
  그룹에 추가하여 docker를 사용할 수 있도록 한다. ^Q9TvdOJk
* 이미지 조회/검색 팁: 즐겨찾기 필터 적용 ^P04XgUTJ (주로 공식 계정) 이미지 5종 필터 ^QR8oGS18
* 이미지 내려받기 예시:\
  docker pull ubuntu:bionic (이미지/태그) ^HRGwFBjL\
  docker run -it ubuntu:bionic bash ^XIWYtbZz\
  ubuntu 18.0.4 쉘에 접속하게 됨 ^lFoJhGR3
* 컨테이너에서 필요한 프로그램 설치, 작업 디렉터리 설명 등:
  * 필요한 프로그램 설치 ^4byFNqOZ
  * 이미지가 설치된 디렉터리 ^1o8IWdkR
  * 실제 작업이 진행되는 디렉터리 ^OlEsOrhy
* 이미지/컨테이너 관리 예시:
  * docker commit \[컨테이너ID] \[이미지이름]:\[태그] ^N3cuIeLY
  * docker image tag \[사용하는이미지이름] \[사용자이름]/\[이미지이름]:\[태그] ^22UWvRwI
* 도커 로그인:
  * docker login -u ^CeT8QaRA
  * 로그인 성공 시 설정 파일에 인증 키 값이 저장됨 ^mQS2g0CQ
* 일반 워크플로우: 생성 > 구동 > 시작 > 종료 > 삭제 ^QbAeZzpd
* 명령어 요약: docker \[run/create] ^IQwbgEcz
  * 뒤에 지정한 이미지를 담은 컨테이너를 생성 ^lgMZtGrg
  * 컨테이너를 생성하고 실행까지 진행 ^XDpglBov
* 사용이 중지된 모든 컨테이너 삭제: docker container prune ^bA83j8hI
* 컨테이너 ID만 출력: docker container ls -a -q (원문 참조)
* 모든 컨테이너 강제 삭제(실행중 포함): docker container rm -f $(docker container ls -a -q) ^dDxzidB1\
  (: prune와 달리 실행 중인 모든 컨테이너를 삭제 ^OujsIx8a)
* docker container \[options] ^Ru3fz6t0
  * -a: 추가
  * -i: 대화형으로 실행
  * -d: 백그라운드 실행
  * \--rm: 컨테이너 종료 시 자동 삭제
  * -it: 컨테이너 실행 시 컨테이너에 접속
  * \--name: 이름 설정 ^q0KtWyEF
* 도커 실행 없이 컨테이너만 생성 가능한 예:
  * docker create --name wordpress -p 80:80 wordpress ^OMq5oLtW (외부:내부 ^yb2Zm7se)
* 컨테이너 실행 후 바로 실행시킬 명령어 추가 가능:\
  docker run -it --name web nginx df -h ^h4spcNOE
* 프로세스 확인/강제종료:
  * docker top \[컨테이너 ID]: 프로세스 ID 확인가능 ^2lgmFg3A
  * docker kill \[컨테이너 ID]: 컨테이너 강제 종료 ^vmLLnetU

#### 볼륨 관련

* docker volume ls ^efZRiSdr
* docker volume create \[volume이름] ^emYlHrlh
* docker volume inspect \[volume이름] ^eyEFdHKQ\
  볼륨에 저장된 데이터를 확인\[마운트]할 수 있다. ^NX3Tbmj5

### 추가 노트 / 예시

* ex) nginx 이미지를 활용해 10개의 컨테이너를 생성하고 싶다. ^OkVS61E1
* 생성 관련 명령: docker create / docker run 등의 차이 설명이 원문에 다수 포함
* 컨테이너를 생성하고 실행까지 진행한다는 점 강조

***

### Element Links

* duIlPiXe: https://www.docker.com/
* U0RV7ULF: https://docs.docker.com/
* 4d53NfgG: https://download.docker.com/linux/rhel/
* LE80Aqlj: [Excalidraw/Docker\_이론.md#Code Block 1](file:///4956077/network/CloudSecurity.md)

### Embedded Files

(원문에 포함된 이미지/임베디드 파일 목록 — 파일명 및 참조 유지)

* 4f623271c18c9934ddfa995ce36acc4e3734f772: \[\[topics/assets/images/Pasted Image 20241202103410\_286.png]]
* f40654179d68c9729ec33aaaa55062e84dbec4ea: \[\[topics/assets/images/Pasted Image 20241202103447\_213.png]]
* 6026266027165e4ac93a59787bc3a92902d6959c: \[\[topics/assets/images/Pasted Image 20241202113831\_732.png]]
* f69fe707c6d34419765e068f3e842af9961935f3: \[\[topics/assets/images/Pasted Image 20241202114158\_225.png]]
* 4da3c4bb6445d82d5f79d962712ff705186faf82: \[\[topics/assets/images/Pasted Image 20241202114237\_305.png]]
* 92f00fa7d80ae9e3bb7dd551601dfff3051bac9d: \[\[topics/assets/images/Pasted Image 20241202114452\_100.png]]
* a533ad31b31f0a6857b08d531c512cee440411fe: \[\[topics/assets/images/Pasted Image 20241202115234\_454.png]]
* 9e9fed296cb1353759fbd6e86b440fbea8d6d8f9: \[\[topics/assets/images/Pasted Image 20241202115331\_585.png]]
* 20cb992c62ebd54a0b3ff49b03186c148ecedb70: \[\[topics/assets/images/Pasted Image 20241202120734\_450.png]]
* 0718818765042dd90d216d991cf7dfc0203207c1: \[\[topics/assets/images/Pasted Image 20241202120749\_984.png]]
* e01c56cd1a9f81d62d65afc07c510daf3251df5d: \[\[topics/assets/images/Pasted Image 20241202121054\_064.png]]
* 90e930a5386fc870de7e4a898eabd9188b0aeec8: \[\[topics/assets/images/Pasted Image 20241202121212\_453.png]]
* db1cda0adc1c3e8c722a8fc5a9750a152266e2a5: \[\[topics/assets/images/Pasted Image 20241202121255\_956.png]]
* e6ec83bc9e30153a13916d63bf943ebc161640e1: \[\[topics/assets/images/Pasted Image 20241202121702\_919.png]]
* d505bcc155edc64f0e16b291d2b58f04a00926c2: \[\[topics/assets/images/Pasted Image 20241202121826\_628.png]]
* 0e3f35f7c15d3dca34f9af50aac3a1cbf7af5fa6: \[\[topics/assets/images/Pasted Image 20241202121925\_177.png]]
* dcc5ed4f4d64249107dc289bbcc074d7e8ca5806: \[\[topics/assets/images/Pasted Image 20241202122546\_369.png]]
* b58342c732dad449209df7206353cc3915985f7c: \[\[topics/assets/images/Pasted Image 20241202122611\_842.png]]
* 3350fdc7b3d0f4bc4c37ca5ee3dfe41f2bc3bfcb: \[\[topics/assets/images/Pasted Image 20241202123233\_613.png]]
* 6e4ac5e209c0f61023f714357970687bb7c5f424: \[\[topics/assets/images/Pasted Image 20241202123519\_067.png]]
* 2bfb605194caa6da859a4ff672a849e92b165142: \[\[topics/assets/images/Pasted Image 20241202123643\_109.png]]
* da126d322bedd48fbf6b168b4e61da533286fe1c: \[\[topics/assets/images/Pasted Image 20241202123919\_879.png]]
* 7d48a4ab4127c177a0b57a923ed56061763f43b1: \[\[topics/assets/images/Pasted Image 20241202124544\_179.png]]
* 154c6e3506db56a952b03b1a05a29ae9efbe7a3f: \[\[topics/assets/images/Pasted Image 20241202124701\_158.png]]
* 3ce155e52c9838b41987f7545eaea3ef0441a352: \[\[topics/assets/images/Pasted Image 20241202124846\_356.png]]
* f1ba6c1e451ef82348fa138e1bb4475ca635136a: \[\[topics/assets/images/Pasted Image 20241202125029\_926.png]]
* efce5b1e02a8123d2d973618e56a629daf60bd2a: \[\[topics/assets/images/Pasted Image 20241202140402\_534.png]]
* 83255eb49722620797aae81fcb86f9d8e21d0e73: \[\[topics/assets/images/Pasted Image 20241202140454\_631.png]]
* 4118c5f709fa14edbdddcb7def9eff8aea05c612: \[\[topics/assets/images/Pasted Image 20241202140631\_130.png]]
* 73ba059dcb9df346f36481e71fde92e1a93b3931: \[\[topics/assets/images/Pasted Image 20241202140940\_295.png]]
* 8d9b969d5bc71546f71299d3f45c2e51c826746a: \[\[topics/assets/images/Pasted Image 20241202141128\_951.png]]
* f3f808eba969b62e54dd276f85d9ae3bef9bb013: \[\[topics/assets/images/Pasted Image 20241202141232\_337.png]]
* 32116f7da2e9523292bdc9dc9445a615027a7344: \[\[topics/assets/images/Pasted Image 20241202141424\_784.png]]
* 0d0942d09fb80822225e483f64205e7e75582186: \[\[topics/assets/images/Pasted Image 20241202141644\_786.png]]
* f232ad4950b93fa4af56a270d3b5f388d94e0879: \[\[topics/assets/images/Pasted Image 20241202141724\_865.png]]
* e8c6789bfa50678eb885e0848f243c1717f9c05d: \[\[topics/assets/images/Pasted Image 20241202141913\_442.png]]
* f2908b8db4cf4340b0ae65c6d5878a6ac0680743: \[\[topics/assets/images/Pasted Image 20241202141952\_771.png]]
* d342773fa9371c8ef9aa8f67b12bc1b5282ab299: \[\[topics/assets/images/Pasted Image 20241202142254\_970.png]]
* e1cc9c47351555abb5d84b24770b7e9d62dd1817: \[\[topics/assets/images/Pasted Image 20241202142332\_090.png]]
* a1bd6adeca0d0c97c8b7e267c384d2ed866a4731: \[\[topics/assets/images/Pasted Image 20241202142633\_129.png]]
* b2502788bf221b6694c130ce0f4c32425e9edcd1: \[\[topics/assets/images/Pasted Image 20241202142957\_229.png]]
* eb69fdc8dadbf6648a8ed4f2c2cf9e0d03ec6af7: \[\[topics/assets/images/Pasted Image 20241202144326\_527.png]]
* 4768b10fe55828fe2384a3f8ac37a7bb470bbdb0: \[\[topics/assets/images/Pasted Image 20241202144437\_766.png]]
* 030691fe9853b3c00f66f466835a3532de781be0: \[\[topics/assets/images/Pasted Image 20241202144947\_145.png]]
* ed44aab9ba739a1f5adde32e285f4606a626f517: \[\[topics/assets/images/Pasted Image 20241202150430\_020.png]]
* b48c863cb2b7f8451148c8d2af798f7248f6bda9: \[\[topics/assets/images/Pasted Image 20241202150603\_815.png]]
* 1ac7dbdd6a6c84026a1403f996a97c1b9308ec42: \[\[topics/assets/images/Pasted Image 20241202150641\_242.png]]
* 240b1f622166020fcee1f44292212cc7784e6cfb: \[\[topics/assets/images/Pasted Image 20241202151838\_593.png]]
* 0654d792fe31e99a41d059c3233349871c1f97d3: \[\[topics/assets/images/Pasted Image 20241202152515\_741.png]]
* 18d5f3de9a6954903435a1af2380fad4bc2c061f: \[\[topics/assets/images/Pasted Image 20241202152554\_747.png]]
* 65a0804af5a5138a600e9d994c581f3082a38b46: \[\[topics/assets/images/Pasted Image 20241202152701\_515.png]]
* 0174caf131a8d4e2f437e870770ad040e99925ea: \[\[topics/assets/images/Pasted Image 20241202153403\_867.png]]
* 9179772f937dea8c76eb237bcd725ebc735c82a0: \[\[topics/assets/images/Pasted Image 20241202154349\_549.png]]
* f9296b7d7e960bf58e5ad76423b684116069b46f: \[\[topics/assets/images/Pasted Image 20241202154718\_987.png]]
* f1fd9bdbda07892775877ac35234bb9cd3722ae5: \[\[topics/assets/images/Pasted Image 20241202154800\_707.png]]
* 67faf2d2fbb1ff84f7193a9f92da18da482a1286: \[\[topics/assets/images/Pasted Image 20241202154830\_247.png]]
* 1f71ee8b0704a00966d8ebdae8cc0b5bc9195743: \[\[topics/assets/images/Pasted Image 20241202154950\_508.png]]
* 968fcf4b94ffad735c87a7191a3424e0fe928046: \[\[topics/assets/images/Pasted Image 20241202155024\_259.png]]

(생략 없이 원문 Embedded Files 목록을 유지)
