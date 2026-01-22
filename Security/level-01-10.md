# Level 01\~10

## Bandit Level 0 → Level 1

### Level Goal

The password for the next level is stored in a file called **readme** located in the home directory. Use this password to log into bandit1 using SSH. Whenever you find a password for a level, use SSH (on port 2220) to log into that level and continue the game.

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

**TIP:** Create a file for notes and passwords on your local machine!

Passwords for levels are _not_ saved automatically. If you do not save them yourself, you will need to start over from bandit0.

Passwords also occassionally change. It is recommended to take notes on how to solve each challenge. As levels get more challenging, detailed notes are useful to return to where you left off, reference for later problems, or help others after you’ve completed the challenge.

The password you are looking for is: ZjLjTmM6FvvyRnrb2rfNWOZOTa6ip5If

***

## Bandit Level 1 → Level 2

### Level Goal

The password for the next level is stored in a file called **-** located in the home directory

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

### Helpful Reading Material

* [Google Search for “dashed filename”](https://www.google.com/search?q=dashed+filename)
* [Advanced Bash-scripting Guide - Chapter 3 - Special Characters](https://linux.die.net/abs-guide/special-chars.html)

263JGJPfgU6LtdEvgfWU1XP5yac29mFx

***

## Bandit Level 2 → Level 3

### Level Goal

The password for the next level is stored in a file called **spaces in this filename** located in the home directory

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

### Helpful Reading Material

* [Google Search for “spaces in filename”](https://www.google.com/search?q=spaces+in+filename)

MNk8KNH3Usiio41PRUEoDFPqfxLPlSmx

***

## Bandit Level 3 → Level 4

### Level Goal

The password for the next level is stored in a hidden file in the **inhere** directory.

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

2WmrDFRmJIq3IPxneAaMGhap0pFhF3NJ

***

## Bandit Level 4 → Level 5

### Level Goal

The password for the next level is stored in the only human-readable file in the **inhere** directory. Tip: if your terminal is messed up, try the “reset” command.

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

* 타입이 file 이며 타입을 출력하는 명령어

```sh
find . -type f -exec file {} +
```

4oQYVPkxZOOEOO5pTW81FB8j8lxXGUQw

***

## Bandit Level 5 → Level 6

### Level Goal

The password for the next level is stored in a file somewhere under the **inhere** directory and has all of the following properties:

* human-readable
* 1033 bytes in size
* not executable

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)

* 특정 문자열을 제외한 결과 출력

```sh
grep -v "with very long lines"
```

```sh
find . -type f -exec file {} + | grep -i "ASCII text" | grep -v "with very long"
```

```sh
find . -type f -size 1033c ! -perm /a=x -exec file {} + | grep -i "ASCII text" | grep -v "with very long"
```

```sh
find . -type f -size 1033c
```

HWasnPhtq9AVKe0dmk45nxy20cvUa6EG

***

## Bandit Level 6 → Level 7

### Level Goal

The password for the next level is stored **somewhere on the server** and has all of the following properties:

* owned by user bandit7
* owned by group bandit6
* 33 bytes in size

### Commands you may need to solve this level

[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html) , [cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1posix.html) , [cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html) , [file](https://manpages.ubuntu.com/manpages/noble/man1/file.1.html) , [du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html) , [find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html) , [grep](https://manpages.ubuntu.com/manpages/noble/man1/grep.1.html)

```sh
-user "사용자이름"
-group "그룹이름"
2>/dev/null # 출력 코드가 2(에러)이면 /dev/null로 보내(출력 x)
```

```sh
find / -type f -user bandit7 -group bandit6 -size 33c 2>/dev/null
```

morbNTDkSW6jIlUc0ymOdMaLnOlFVAaj

***

## Bandit Level 7 → Level 8

### Level Goal

The password for the next level is stored in the file **data.txt** next to the word **millionth**

### Commands you may need to solve this level

[man](https://manpages.ubuntu.com/manpages/noble/man1/man.1.html), grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd

```sh
cat ./data.txt | grep millionth
```

dfwvzFQi4mU0wfNbFOe9RoWskMLg7eEc

***

## Bandit Level 8 → Level 9

### Level Goal

The password for the next level is stored in the file **data.txt** and is the only line of text that occurs only once

### Commands you may need to solve this level

grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd

### Helpful Reading Material

* [Piping and Redirection](https://ryanstutorials.net/linuxtutorial/piping.php)

```sh
sort ./data.txt | uniq -u
```

* sort: 정렬(파일의 내용을 일정하게 정렬)
* uniq: -u 옵션을 통해 유일하게 등장하는 줄만 출력

4CKMh1JI91bUIZZPXDqGanal4xvAg0JM

***

## Bandit Level 9 → Level 10

### Level Goal

The password for the next level is stored in the file **data.txt** in one of the few human-readable strings, preceded by several ‘=’ characters.

### Commands you may need to solve this level

grep, sort, uniq, strings, base64, tr, tar, gzip, bzip2, xxd

```sh
strings ./data.txt
```

FGUW5ilLVJrxX9kMYMmlN4MgbpfMiqey
