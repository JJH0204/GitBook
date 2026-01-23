# GroupManagement

## /etc/group

```
[root@localhost jaeho]# cat /etc/group
...
jaeho:x:1000:
```

* jaeho: 그룹이름
* x: 암호화된 그룹 비밀번호
* 1000: 그룹 id
* (공백): 소속 인원

관련 문서:

* [사용자 생성 명령어](/broken/pages/4b9bd3f57b92103117f47d3cf8289a4996e7c1b3)
* [사용자 계정 관리 명령어](/broken/pages/3d74b08ba6f3ad0b334776b14f9594e3a992ec04)
* [사용자 조회 명령어](/broken/pages/b3453768630352a6ccd1943e2042822e170f6a0c)
* [그룹 관리 명령어](/broken/pages/3d60e8d4afc7b6aa5690baccfc3b0073aebdc9ca)

## /etc/skel

* 사용자 계정을 만들 때 홈디렉토리에 포함될 파일 또는 디렉토리가 저장된 디렉토리
