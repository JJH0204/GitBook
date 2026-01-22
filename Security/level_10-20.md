# Level\_10\~20

## Bandit Level 10 → Level 11

### Level Goal

The password for the next level is stored in the file **data.txt**, which contains base64 encoded data

### Commands you may need to solve this level

grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd

### Helpful Reading Material

* [Base64 on Wikipedia](https://en.wikipedia.org/wiki/Base64)

```sh
cat ./data.txt | base64 -d
```

The password is dtR173fZKb0RRsDFSGsg2RWnpNVj3qRr

***

## Bandit Level 11 → Level 12

### Level Goal

The password for the next level is stored in the file **data.txt**, where all lowercase (a-z) and uppercase (A-Z) letters have been rotated by 13 positions

### Commands you may need to solve this level

grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd

### Helpful Reading Material

* [Rot13 on Wikipedia](https://en.wikipedia.org/wiki/ROT13)

The password is 7x16WNeHIi5YkIhWsfFIqoognUTyj9Q4

***

## Bandit Level 12 → Level 13

### Level Goal

The password for the next level is stored in the file **data.txt**, which is a hexdump of a file that has been repeatedly compressed. For this level it may be useful to create a directory under /tmp in which you can work. Use mkdir with a hard to guess directory name. Or better, use the command “mktemp -d”. Then copy the datafile using cp, and rename it using mv (read the manpages!)

> \[!번역] 다음 레벨의 비밀번호는 반복적으로 압축된 파일의 헥스덤프인 data.txt 파일에 저장됩니다. 이 레벨의 경우 /tmp 아래에 작업할 수 있는 디렉토리를 만드는 것이 유용할 수 있습니다. 디렉토리 이름을 추측하기 어려운 mkdir를 사용합니다. 또는 "mktemp -d" 명령을 사용하는 것이 좋습니다. 그런 다음 cp를 사용하여 데이터 파일을 복사하고 mv를 사용하여 이름을 변경합니다(매뉴얼 페이지 읽기!)

### Commands you may need to solve this level

grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd, mkdir, cp, mv, file

### Helpful Reading Material

* [Hex dump on Wikipedia](https://en.wikipedia.org/wiki/Hex_dump)
* [매직넘버](file:///5659318/cs_basics/MagicNumber.md)

{% stepper %}
{% step %}
### Dump -> Restore original file

```sh
xxd -r data.txt origin.gz
```
{% endstep %}

{% step %}
### Decompress gzip

```sh
gzip -d ./origin.gz
```
{% endstep %}

{% step %}
### Check file
{% endstep %}

{% step %}
### Decompress bzip2 after renaming

```sh
mv ./origin ./origin.bz2
bzip2 -d ./origin.bz2
```
{% endstep %}

{% step %}
### Check file type

```sh
file origin
# origin: gzip compressed data, was "data4.bin", last modified: Thu Sep 19 07:08:15 2024, max compression, from Unix, original size modulo 2^32 20480
```
{% endstep %}

{% step %}
### Decompress gzip again

```sh
mv ./origin ./origin.gz
gzip -d ./origin.gz
```
{% endstep %}

{% step %}
### Check file type

```sh
file origin
# origin: POSIX tar archive (GNU)
```
{% endstep %}

{% step %}
### Extract tar archive

```sh
mv ./origin ./origin.tar
tar -xf ./origin.tar
```
{% endstep %}

{% step %}
### Check extracted file

```sh
file ./data5.bin
# ./data5.bin: POSIX tar archive (GNU)
```
{% endstep %}

{% step %}
### Extract nested tar

```sh
mv ./data5.bin ./data5.bin.tar
tar -xf ./data5.bin.tar
```
{% endstep %}

{% step %}
### Check next file

```sh
file ./data6.bin
# ./data6.bin: bzip2 compressed data, block size = 900k
```
{% endstep %}

{% step %}
### Decompress bzip2
{% endstep %}

{% step %}
### Repeat decompression steps as needed
{% endstep %}

{% step %}
### Continue repeating until you get the final file
{% endstep %}

{% step %}
### Final result / password

The password is FO5dwFsc0cbaIiH0h8J2eUks2vdTDwAn
{% endstep %}
{% endstepper %}

***

## Bandit Level 13 → Level 14

### Level Goal

The password for the next level is stored in **/etc/bandit\_pass/bandit14 and can only be read by user bandit14**. For this level, you don’t get the next password, but you get a private SSH key that can be used to log into the next level. **Note:** **localhost** is a hostname that refers to the machine you are working on

> \[!번역] 다음 레벨의 비밀번호는 /etc/bandit\_pass/bandit14에 저장되며 사용자 밴디트14만 읽을 수 있습니다. 이 레벨의 경우 다음 비밀번호를 얻지는 못하지만 다음 레벨에 로그인하는 데 사용할 수 있는 개인 SSH 키를 얻습니다. 참고: localhost는 작업 중인 시스템을 가리키는 호스트 이름입니다

### Commands you may need to solve this level

ssh, telnet, nc, openssl, s\_client, nmap

### Helpful Reading Material

* [SSH/OpenSSH/Keys](https://help.ubuntu.com/community/SSH/OpenSSH/Keys)

```sh
ssh -i ./sshkey.private bandit14@localhost -p 2220
```

***

## Bandit Level 14 → Level 15

### Level Goal

The password for the next level can be retrieved by submitting the password of the current level to **port 30000 on localhost**.

> \[!번역] 다음 레벨의 비밀번호는 현재 레벨의 비밀번호를 로컬 호스트의 포트 30000에 제출하여 검색할 수 있습니다.

### Commands you may need to solve this level

ssh, telnet, nc, openssl, s\_client, nmap

### Helpful Reading Material

* [How the Internet works in 5 minutes (YouTube)](https://www.youtube.com/watch?v=7_LPdttKXPc) (Not completely accurate, but good enough for beginners)
* [IP Addresses](https://computer.howstuffworks.com/web-server5.htm)
* [IP Address on Wikipedia](https://en.wikipedia.org/wiki/IP_address)
* [Localhost on Wikipedia](https://en.wikipedia.org/wiki/Localhost)
* [Ports](https://computer.howstuffworks.com/web-server8.htm)
* [Port (computer networking) on Wikipedia](https://en.wikipedia.org/wiki/Port_\(computer_networking\))

```sh
cat /etc/bandit_pass/bandit14
```

Output:

MU4VWeTyJk8ROof1qqmcBPaLh7lDCPvS

Resulting password: 8xCjnmgoKbGLhHFAZlGE5Tmu4M2tKJQo

***

## Bandit Level 15 → Level 16

### Level Goal

The password for the next level can be retrieved by submitting the password of the current level to **port 30001 on localhost** using SSL/TLS encryption.

**Helpful note: Getting “DONE”, “RENEGOTIATING” or “KEYUPDATE”? Read the “CONNECTED COMMANDS” section in the manpage.**

> \[!번역] 다음 레벨의 비밀번호는 SSL/TLS 암호화를 사용하여 로컬호스트의 포트 30001에 현재 레벨의 비밀번호를 제출하면 검색할 수 있습니다.
>
> 유용한 참고 사항: "완료", "재협상" 또는 "키업데이트"를 받으시겠습니까? 맨페이지의 "연결된 명령" 섹션을 읽어보세요.

### Commands you may need to solve this level

ssh, telnet, nc, ncat, socat, openssl, s\_client, nmap, netstat, ss

### Helpful Reading Material

* [Secure Socket Layer/Transport Layer Security on Wikipedia](https://en.wikipedia.org/wiki/Transport_Layer_Security)
* [OpenSSL Cookbook - Testing with OpenSSL](https://www.feistyduck.com/library/openssl-cookbook/online/testing-with-openssl/index.html)
