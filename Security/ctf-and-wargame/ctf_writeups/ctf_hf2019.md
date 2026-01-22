# CTF\_HF2019

{% stepper %}
{% step %}
### IP 탐색

* 피해자 PC를 찾았다.

#### health scan
{% endstep %}

{% step %}
### 포트 탐색

* 인증 관련 정보를 몰라도 접속 가능한 웹 페이지를 우선 탐색한다.
* wordpress로 제작된 페이지인 것을 바로 알 수 있다.

#### 80/tcp (http)

**dirb**

* 자주 사용하는 `http://ip/wordpress/` 또는 `http://ip/admin/`은 403 에러로 찾을 수 없다.

**nikto**

* 워드프레스로 작성된 웹 페이지임을 인지하고 nikto 명령어로 분석
* 별다른 의미 있는 결과는 찾지 못함.
* wpscan 진행.
{% endstep %}

{% step %}
### wpscan

* 명령:

```
wpscan --url 192.168.56.115 --enumerate p,u
```

```
[+] XML-RPC seems to be enabled: http://192.168.56.115/xmlrpc.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
 | References:
 |  - http://codex.wordpress.org/XML-RPC_Pingback_API
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_ghost_scanner/
 |  - https://www.rapid7.com/db/modules/auxiliary/dos/http/wordpress_xmlrpc_dos/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_xmlrpc_login/
 |  - https://www.rapid7.com/db/modules/auxiliary/scanner/http/wordpress_pingback_access/
```

```
[+] WordPress readme found: http://192.168.56.115/readme.html
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
```

```
[+] Upload directory has listing enabled: http://192.168.56.115/wp-content/uploads/
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 100%
```

```
[+] The external WP-Cron seems to be enabled: http://192.168.56.115/wp-cron.php
 | Found By: Direct Access (Aggressive Detection)
 | Confidence: 60%
 | References:
 |  - https://www.iplocation.net/defend-wordpress-from-ddos
 |  - https://github.com/wpscanteam/wpscan/issues/1299
```

```
[+] wp-google-maps
 | Location: http://192.168.56.115/wp-content/plugins/wp-google-maps/
 | Latest Version: 9.0.40
 | Last Updated: 2024-07-12T06:29:00.000Z
 |
 | Found By: Urls In Homepage (Passive Detection)
 |
 | The version could not be determined.
```

* wp-google-maps: 구글 지도 관련 플러그인 정보인 것 같다.
{% endstep %}

{% step %}
### Google Maps 플러그인 검사

* README.md
* Readme.md 파일에서 플러그인의 버전을 확인했다.
* 해당 버전에 대한 정보를 검색한 결과 SQL Injection 취약점이 있는 것으로 보인다.
* 관련 정보:
  * CVE-2019-10692: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-10692/
  * exploit-db: https://www.exploit-db.com/exploits/48918/
* 취약점 정보는 얻었지만, 웹 서버에서 어떻게 실행할지에 대한 정보는 없음. Metasploit에서 시도해 보기로 함.
{% endstep %}

{% step %}
### Metasploit

* 출력에서 Wordpress table prefix 등 정보가 보임.
* rhosts만 채워 공격 시도.
* 일부 정보를 얻었고, 아이디와 암호화된 비밀번호로 보이는 항목을 확인함.
* 암호는 암호화되어 있으므로 복호화/크래킹 필요.
* john으로 크래킹 시도:

```
john --wordlist=/usr/share/wordlists/rockyou.txt ./hf2019.txt
```

* rockyou.txt가 없는 경우, 경로로 이동하여 rockyou.tar.gz를 압축 해제 후 사용.
* ./hf2019.txt에 암호화된 비밀번호를 저장 후 john 실행하여 비밀번호를 얻음:
* 복호화된 비밀번호: kittykat1
{% endstep %}

{% step %}
### SSH 접속 및 권한 상승

* ssh 접속에 성공했다.
* 이제 root 권한을 탈취하여 root\_flag를 찾으면 된다.
{% endstep %}
{% endstepper %}

{% hint style="info" %}
원문 출처: https://medium.com/@andr3w\_hilton/hacker-fest-2019-vulnhub-com-b1a92417c8b5
{% endhint %}
