# Docker\_commend

자주 사용하는 도커 명령어를 소개합니다.\
더 많은 명령어와 옵션에 대한 자세한 설명은 [도커 공식 문서](https://docs.docker.com/engine/reference/commandline/docker/)에서 확인할 수 있습니다.

### [`docker build`](/broken/pages/3967193d0af3381c948781c85245cca5f5a71ac0)

Dockerfile을 이용하여 이미지를 생성합니다.

* 사용 예시
  * `docker build [옵션] <경로>`
  * `docker build -t <이미지명:태그> <경로>`

`-t` 옵션으로 이미지의 이름과 태그를 지정할 수 있습니다. 태그를 작성하지 않을 경우 ‘latest’로 지정됩니다.

예시:

* `docker build .` : 현재 디렉토리에 있는 Dockerfile로 이미지 생성
* `docker build -t my-image .` : 현재 디렉토리에 있는 Dockerfile로 ‘my-image:latest’ 이미지 생성

### `docker images`

도커 이미지 목록을 출력합니다.

아래는 미리 준비된 Dockerfile을 이용해서 `docker build` 명령어로 이미지를 빌드한 후, `docker images` 명령어로 출력하는 모습입니다.

```shell
user@user-VirtualBox:~/Desktop/ex-docker$ docker build .
[+] Building 27.1s (17/17) FINISHED                                             
 => [internal] load build definition from Dockerfile                       0.0s                                         
 => ...생략...
 => exporting to image                                                     0.0s
 => => exporting layers                                                    0.0s
 => => writing image sha256:08a83756c396b9ca5d83735153cf0176056fb23c3eb3c  0.0s
user@user-VirtualBox:~/Desktop/ex-docker$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
<none>       <none>    9d201c4de2b6   2 minutes ago   122MB
user@user-VirtualBox:~/Desktop/ex-docker$ docker build -t my-image:1 .
[+] Building 0.8s (17/17) FINISHED                                              
 => ...생략...
 => exporting to image                                                     0.0s
 => => exporting layers                                                    0.0s
 => => writing image sha256:9d201c4de2b62519383058265e31669b167c422502643  0.0s
 => => naming to docker.io/library/my-image:1                              0.0s
user@user-VirtualBox:~/Desktop/ex-docker$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED         SIZE
my-image     1         9d201c4de2b6   4 minutes ago   122MB
```

### `docker run`

도커 이미지로 컨테이너를 생성하고 실행합니다.

* 기본 사용법
  * `docker run [옵션] <이미지명|ID> [명령어]`
  * `docker run -p <호스트 PORT>:<컨테이너 PORT> <이미지명|ID>`

`-p` 옵션은 도커 컨테이너의 포트와 호스트의 포트를 매핑합니다. 컨테이너에서 리슨하고 있는 포트를 호스트의 특정 포트로 접속할 수 있도록 합니다.

* 인터랙티브 셸
  * `docker run -it <이미지명|ID> <명령어>`

`-it` 옵션으로 컨테이너에서 bash 셸을 사용할 수 있습니다. `-i (--interactive)`는 표준 입력을 활성화하고, `-t (--tty)`는 가상 터미널(tty)을 사용할 수 있도록 합니다.

예:

* `docker run -it my-image:1 /bin/bash` : `my-image:1` 이미지로 컨테이너를 생성하고 실행하여 bash 셸 열기

```shell
user@user-VirtualBox:~/Desktop/ex-docker$ docker run -it my-image:1 /bin/bash
chall@852bb2be037c:~$ 
```

### `docker ps`

실행 중인 컨테이너 목록을 출력합니다.

* `docker ps -a`\
  `-a` 옵션은 종료된 컨테이너까지 모두 출력합니다.

컨테이너를 실행한 상태로 다른 터미널 창을 열어 `docker ps`를 입력하면 아래와 같이 실행 중인 컨테이너 목록이 출력됩니다.

![](../../.gitbook/assets/f7d361dd3cc0390e75fec2fc65b0e1f986376b478013289f9389d80eaf62a536.png)

컨테이너 안에서 `exit` 명령어를 실행하여 컨테이너를 종료한 후 `docker ps`를 입력하면 컨테이너가 출력되지 않고, `docker ps -a`를 입력하면 종료된 컨테이너까지 출력됩니다.

![](../../.gitbook/assets/b2812d82aed386cfd28029ac818a183e6c819075180d245ae58999b6413e07c4.png)

`docker run` 대신, 컨테이너 생성과 실행을 따로 명령할 수도 있습니다.

### `docker create`

도커 이미지로 컨테이너를 생성합니다.

* `docker create [옵션] <이미지명|ID> [명령어]`

### `docker start`

중단된 컨테이너를 시작합니다.

* `docker start [옵션] <컨테이너명|ID>`

예:

```shell
user@user-VirtualBox:~$ docker images
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
my-image     1         9d201c4de2b6   2 hours ago   122MB
user@user-VirtualBox:~$ docker create my-image:1
eb01688504dc201d9f3a03bf3a27d84cdeafca4b2110766d52fc7551a7d9d05a
user@user-VirtualBox:~$ docker ps -a
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS    PORTS     NAMES
eb01688504dc   my-image:1   "/bin/sh -c 'socat -…"   4 seconds ago   Created             priceless_meninsky
user@user-VirtualBox:~$ docker start eb01688504dc
eb01688504dc
user@user-VirtualBox:~$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED          STATUS         PORTS      NAMES
eb01688504dc   my-image:1   "/bin/sh -c 'socat -…"   19 seconds ago   Up 4 seconds   2222/tcp   priceless_meninsky
```

### `docker exec`

실행 중인 컨테이너에 접속하여 명령을 수행합니다.

* `docker exec [옵션] <컨테이너명|ID> [명령어]`

`docker run`과 유사하게 `-it` 옵션으로 bash 셸을 실행할 수 있습니다.

예:

* `docker exec -it <컨테이너명|ID> /bin/bash` : 실행 중인 컨테이너에서 bash 셸 열기

```shell
user@user-VirtualBox:~$ docker exec -it eb01688504dc /bin/bash
chall@eb01688504dc:~$ 
```

### `docker stop`

실행 중인 컨테이너를 중단합니다.

* `docker stop [옵션] <컨테이너명|ID>`

### `docker pull`

레지스트리(Docker Hub)에 존재하는 도커 이미지를 다운받습니다.

* `docker pull [옵션] <이미지명>`

예:

* `docker pull ubuntu:18.04` : Docker hub에서 ubuntu:18.04 이미지를 다운받습니다.

```shell
user@user-VirtualBox:~$ docker pull ubuntu:18.04
18.04: Pulling from library/ubuntu
0c5227665c11: Pull complete 
Digest: sha256:8aa9c2798215f99544d1ce7439ea9c3a6dfd82de607da1cec3a8a2fae005931b
Status: Downloaded newer image for ubuntu:18.04
docker.io/library/ubuntu:18.04
```

### `docker rm`

도커 컨테이너를 삭제합니다.

* `docker rm [옵션] <컨테이너명|ID>`

### `docker rmi`

도커 이미지를 삭제합니다.

* `docker rmi [옵션] <이미지명|ID>`

### `docker inspect`

도커 이미지 혹은 컨테이너의 자세한 정보를 출력합니다.

* `docker inspect [옵션] <이미지 혹은 컨테이너명|ID>`

예 (ubuntu:18.04에 대한 출력):

```json
user@user-VirtualBox:~$ docker inspect ubuntu:18.04
[
    {
        "Id": "sha256:3941d3b032a8168d53508410a67baad120a563df67a7959565a30a1cb2114731",
        "RepoTags": [
            "ubuntu:18.04"
        ],
        "RepoDigests": [
            "ubuntu@sha256:8aa9c2798215f99544d1ce7439ea9c3a6dfd82de607da1cec3a8a2fae005931b"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2023-03-08T03:22:44.73196058Z",
        "Container": "ee3fcc8c88d3f3129f1236850de28a7eba0da7c548a7b23a6495905ebcf255ea",
        "ContainerConfig": {
            "Hostname": "ee3fcc8c88d3",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) ",
                "CMD [\"/bin/bash\"]"
            ],
            "Image": "sha256:b64649bc9d1a48300ec5a929146aa3c5ca80046f74c33aa5de65a7046f5177a6",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.opencontainers.image.ref.name": "ubuntu",
                "org.opencontainers.image.version": "18.04"
            }
        },
        "DockerVersion": "20.10.12",
        "Author": "",
        "Config": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/bash"
            ],
            "Image": "sha256:b64649bc9d1a48300ec5a929146aa3c5ca80046f74c33aa5de65a7046f5177a6",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.opencontainers.image.ref.name": "ubuntu",
                "org.opencontainers.image.version": "18.04"
            }
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 63146040,
        "VirtualSize": 63146040,
        "GraphDriver": {
            "Data": {
                "MergedDir": "/var/lib/docker/overlay2/0fe24c66cfaad338ccd55946d7734702a3575513fb2e697b409d3194c95c7e62/merged",
                "UpperDir": "/var/lib/docker/overlay2/0fe24c66cfaad338ccd55946d7734702a3575513fb2e697b409d3194c95c7e62/diff",
                "WorkDir": "/var/lib/docker/overlay2/0fe24c66cfaad338ccd55946d7734702a3575513fb2e697b409d3194c95c7e62/work"
            },
            "Name": "overlay2"
        },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:b7e0fa7bfe7f9796f1268cca2e65a8bfb1e010277652cee9a9c9d077a83db3c4"
            ]
        },
        "Metadata": {
            "LastTagTime": "0001-01-01T00:00:00Z"
        }
    }
]
```
