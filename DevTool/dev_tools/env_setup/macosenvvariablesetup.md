# MacOSEnvVariableSetup

{% stepper %}
{% step %}
### 환경 변수 확인

명령어:

{% code title="터미널" %}
```bash
printenv
```
{% endcode %}

출력:

{% code title="printenv 출력" %}
```
__CFBundleIdentifier=com.apple.Terminal

TMPDIR=/var/folders/h3/2rlty04j6qb4ctqgd1mfhks00000gn/T/

XPC_FLAGS=0x0

TERM=xterm-256color

SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.e3uPH3pqDZ/Listeners

XPC_SERVICE_NAME=0

TERM_PROGRAM=Apple_Terminal

TERM_PROGRAM_VERSION=453

TERM_SESSION_ID=9212E694-878A-433B-9959-10122DF85E0E

SHELL=/bin/zsh

HOME=/Users/admin

LOGNAME=admin

USER=admin

PATH=/opt/anaconda3/bin:/opt/homebrew/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/dotnet:/Users/admin/.dotnet/tools:/Library/Apple/usr/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin

SHLVL=1

PWD=/Users/admin

OLDPWD=/Users/admin

HOMEBREW_PREFIX=/opt/homebrew

HOMEBREW_CELLAR=/opt/homebrew/Cellar

HOMEBREW_REPOSITORY=/opt/homebrew

MANPATH=/opt/homebrew/share/man::

INFOPATH=/opt/homebrew/share/info:

LANG=ko_KR.UTF-8

_=/usr/bin/printenv
```
{% endcode %}
{% endstep %}

{% step %}
### 특정 환경 변수값 확인

명령어 형식:

{% code title="터미널" %}
```bash
echo $환경변수명
```
{% endcode %}

예시 — PATH 확인:

{% code title="터미널" %}
```bash
echo $PATH
```
{% endcode %}

출력:

{% code title="echo $PATH 출력" %}
```
/opt/anaconda3/bin:/opt/homebrew/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/dotnet:/Users/admin/.dotnet/tools:/Library/Apple/usr/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
```
{% endcode %}
{% endstep %}

{% step %}
### 새 환경 변수 설정

(원문에 설정 방법 내용이 없습니다.)
{% endstep %}
{% endstepper %}
