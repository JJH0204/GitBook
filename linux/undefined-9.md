# 그룹관리

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

## /etc/skel

* 사용자 계정을 만들 때 홈 디렉토리에 포함될 파일 또는 디렉토리가 저장된 디렉토리
