# 도커 핵심 이론 (Docker)

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

* 컨테이너 기반 클라우드 서비스
* docker / docker hub
* system 위에 별도의 컨테이너를 이미지를 활용해 구축
  * 쉽고 간단하게 필요한 개발 환경을 가져오고 구축할 수 있게 된다.
  * 내가 구축한 이미지를 다른 사람에게 공유도 할 수 있다.
* private(유료) / public(무료)
* APP / APP/ APP
* VM1 / VM2 / VM3
* Hyper-v
* Host OS
* 인프라
* VM 들은 인프라에 종속된다.
* 리소스를 나눠서 사용해야 된다.
* VM 을 삭제하지 않으면 점유한 리소스를 Host OS나 다른 VM에 분배할 수 없다.
* Host OS 의 여유 리소스가 중요
* APP(image) / APP(image) / APP(image)
* (링크/바인드 표현 생략)
* Docker Engine
* Host OS
* 인프라
* VM 기준
* Docker 기준

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

* 컨테이너란?\
  격리된 환경 (다른 컨테이너 끼리 서로 영향을 줄 수 없다.)
* python 3.9
* python 2.1
* 볼륨이란?\
  이미지가 가진 내용(패키징된)
* 파일(디렉터리)열거 뿐 아니라 공유가 필요할 때 사용
* 컨테이너-컨테이너
* 컨테이너-호스트
* "컨테이너의 데이터 관리를 위한 매커니즘"

### Docker install on Linux (원문 단계 요약)

경로 확인 > 설치 (repo)

{% stepper %}
{% step %}
### 패키지 관리자 업데이트

1. 패키지 관리자 업데이트
{% endstep %}

{% step %}
### Docker 리포지터리 추가

dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
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

systemctl enable --now docker
{% endstep %}
{% endstepper %}

* 설치 흐름: docker hub > image install > 컨테이너 구축 > 실행
* 설치한 이미지가 없더라도 실행하는 컨테이너에 이미지 이름과 같은 이미지를 docker hub 에서 pull 하여 실행한다. (이때 가장 최신 버전의 이미지를 가져옴)
* 원하는 버전의 이미지를 설치(관리)하기 위해서 태그를 사용
* 태그로 이미지를 구분하여 구현한 app에 필요한 버전의 tool/IDE를 불러올 수 있다.

예시:

* 우분투를 실행할 때 함께 실행할 명령어를 지정할 수 있다.\
  docker container run ubuntu:latest /bin/echo "hello Ubuntu"
* 컨테이너를 삭제할 수 있다.(실행 중이면 불가능)\
  단, 이미지가 삭제된 것은 아니다.
* nignx툴을 활용해 웹 서버를 구축할 때\
  docker image pull nginx:latest
* 도커 이미지 삭제 명령어\
  docker image rm hello-world
* 도커 관리 명령어\
  또는 docker image ls
* 컨테이너 실행 예시:\
  docker container run --name linux-web -d -p 80:80 nginx\
  설명: 실행할 컨테이너 이름 ^Lrc5aP21, 포트 설정 ^T6FgksuG, 실행 이미지 ^2UsE4ZAG, 백그라운드 실행 여부
* 백그라운드 실행을 하지 않으면 해당 머신 안으로 들어가게 된다.
* 모니터링 / 제어
  * docker stats \[컨테이너 이름/컨테이너ID]
  * 종료: docker container stop \[컨테이너 이름/컨테이너ID]
  * 시작: docker container start linux-web
  * 실행중인 컨테이너 정보: docker container ls
  * 설치한 이미지 확인: docker image ls
* 컨테이너를 생성한 후에는 중지/실행 해도 ID는 바뀌지 않음
* 권한 관련: 일반 사용자는 docker 명령어를 사용할 수 없다. docker도 docker를 설치하면 docker 사용자를 만든다. (http,apache 처럼)\
  그룹에 추가하여 docker를 사용할 수 있도록 한다.
* 이미지 조회/검색 팁: 즐겨찾기 필터 적용 ^P04XgUTJ (주로 공식 계정) 이미지 5종 필터
* 이미지 내려받기 예시:\
  docker pull ubuntu:bionic (이미지/태그)\
  docker run -it ubuntu:bionic bash\
  ubuntu 18.0.4 쉘에 접속하게 됨
* 컨테이너에서 필요한 프로그램 설치, 작업 디렉터리 설명 등:
  * 필요한 프로그램 설치
  * 이미지가 설치된 디렉터리
  * 실제 작업이 진행되는 디렉터리
* 이미지/컨테이너 관리 예시:
  * docker commit \[컨테이너ID] \[이미지이름]:\[태그]
  * docker image tag \[사용하는이미지이름] \[사용자이름]/\[이미지이름]:\[태그]
* 도커 로그인:
  * docker login -u
  * 로그인 성공 시 설정 파일에 인증 키 값이 저장됨
* 일반 워크플로우: 생성 > 구동 > 시작 > 종료 > 삭제
* 명령어 요약: docker \[run/create]
  * 뒤에 지정한 이미지를 담은 컨테이너를 생성
  * 컨테이너를 생성하고 실행까지 진행
* 사용이 중지된 모든 컨테이너 삭제: docker container prune
* 컨테이너 ID만 출력: docker container ls -a -q (원문 참조)
* 모든 컨테이너 강제 삭제(실행중 포함): docker container rm -f $(docker container ls -a -q)\
  (: prune와 달리 실행 중인 모든 컨테이너를 삭제 ^OujsIx8a)
* docker container \[options]
  * -a: 추가
  * -i: 대화형으로 실행
  * -d: 백그라운드 실행
  * \--rm: 컨테이너 종료 시 자동 삭제
  * -it: 컨테이너 실행 시 컨테이너에 접속
  * \--name: 이름 설정
* 도커 실행 없이 컨테이너만 생성 가능한 예:
  * docker create --name wordpress -p 80:80 wordpress ^OMq5oLtW (외부:내부 ^yb2Zm7se)
* 컨테이너 실행 후 바로 실행시킬 명령어 추가 가능:\
  docker run -it --name web nginx df -h
* 프로세스 확인/강제종료:
  * docker top \[컨테이너 ID]: 프로세스 ID 확인가능
  * docker kill \[컨테이너 ID]: 컨테이너 강제 종료

#### 볼륨 관련

* docker volume ls
* docker volume create \[volume이름]
* docker volume inspect \[volume이름]\
  볼륨에 저장된 데이터를 확인\[마운트]할 수 있다.

### 추가 노트 / 예시

* ex) nginx 이미지를 활용해 10개의 컨테이너를 생성하고 싶다.
* 생성 관련 명령: docker create / docker run 등의 차이 설명이 원문에 다수 포함
* 컨테이너를 생성하고 실행까지 진행한다는 점 강조

***

### 참고 링크

* https://www.docker.com/
* https://docs.docker.com/
* https://download.docker.com/linux/rhel/
* Excalidraw/Docker\_이론.md#Code Block 1
