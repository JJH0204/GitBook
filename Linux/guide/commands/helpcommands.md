# HelpCommands

| 명령어 | 설명            | 옵션             | 사용 방법 | 예제 |
| --- | ------------- | -------------- | ----- | -- |
| man | 명령어 사용 매뉴얼 출력 | - `-h`: 사용법 출력 |       |    |

* `-k`: apropos와 동일
* `-w`: man 실행 시 호출되는 '메뉴얼 페이지' 파일의 위치 출력 (`--path`) | `man '옵션' '명령어'` | 아래 예제 참조 | | info | 명령어 사용법, 옵션 등 표시 (man과 유사) | — | `info '명령어'` | 아래 예제 참조 | | whatis | 명령어에 대한 기능을 간략히 출력\
  (yum install man 으로 패키지 설치 후 사용) | — | `whatis '명령어'` | 아래 예제 참조 | | manpath| man 명령이 참조할 매뉴얼 페이지 경로 표시 | — | `manpath` | 아래 예제 참조 | | whereis| 찾는 명령어의 실행파일 절대 경로, 소스, 설정파일 및 매뉴얼 페이지를 찾아 출력 | — | `whereis '명령어'` | 아래 예제 참조 | | apropos| man 페이지 설정에서 지정한 키워드를 포함하고 있는 명령어 목록 출력 | — | `apropos '찾는 키워드'` | 아래 예제 참조 |

예제

{% code title="man 예제" %}
```bash
man -h ls
man -w ls
man -k ls
```
{% endcode %}

{% code title="info 예제" %}
```bash
info cal
```
{% endcode %}

{% code title="whatis 예제" %}
```bash
whatis cal
```
{% endcode %}

{% code title="manpath 예제" %}
```bash
manpath
```
{% endcode %}

{% code title="whereis 예제" %}
```bash
whereis ls
```
{% endcode %}

{% code title="apropos 예제" %}
```bash
apropos system
```
{% endcode %}
