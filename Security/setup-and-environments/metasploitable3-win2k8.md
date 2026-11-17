# Metasploitable3 Windows 2008

nmap 192.168.56.0/24

nmap 192.168.56.144 -sV -p- -v -Pn

22/tcp - ssh: 브루트 포스 공격, OpenSSH 취약점 활용 가능\
135, 139, 445/tcp - RPC, SMB: SMB 취약점 활용 가능\
3000/tcp - WEBrick httpd 1.3.1 (Ruby 2.3.3) - Ruby 웹 서버: 취약한 플러그인 사용 시 침해 발생 가능\
3306/tcp - MySQL 5.5.20-log: 브루트 포스 공격\
3389/tcp - Windows RDP: BlueKeep(CVE-2019-0708)와 같은 RDP 취약점을 통한 공격 가능.\
4848/tcp, 8080/tcp, 8181/tcp - Oracle GlassFish 웹 애플리케이션 서버로, 다양한 웹 애플리케이션을 배포하는 데 사용됨. : 관리자 인터페이스를 통해 원격 코드 실행 가능성.\
8009/tcp - Apache Jserv (AJP): Ghostcat(AJP) 취약점을 악용해 파일 읽기 또는 코드 실행 가능.\
8443/tcp - SSL/HTTPS (추정): SSL/TLS 설정이 잘못된 경우 취약할 수 있음.\
8484/tcp - Jetty winstone-2.8: Jetty 버전 및 설정에 따라 원격 코드 실행 취약점이 있을 수 있음.\
49237/tcp - Jenkins TcpSlaveAgentListener: 인증되지 않은 Jenkins 설정의 경우 악의적인 에이전트가 등록될 수 있음.

취약점 공략 시 피해자 머신이 블루스크린이 현상이 발생하며 리부팅 됨

dirb http://192.168.56.144:8484/

검색 된 내용이 너무 많다.

gobuster dir -f -t 50 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://192.168.56.144:8484/

nikto -h http://192.168.56.144:8484/
