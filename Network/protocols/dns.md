# DNS

### DNS 구축 자료

* [리눅스 서버에 구축](https://velog.io/@sherlockid8/Linux-CentOS-7-DNS-%EB%84%A4%EC%9E%84%EC%84%9C%EB%B2%84-%EA%B5%AC%EC%B6%95%ED%95%98%EA%B8%B0)
* [윈도우 서버에 구축](https://ast-216.tistory.com/14)

## Linux DNS

{% stepper %}
{% step %}
### 설치 및 초기 파일 열기

설치:

{% code title="설치" %}
```sh
dnf install bind bind-* -y # bind tool 설치
```
{% endcode %}

{% code title="/etc/named.conf 열기" %}
```sh
vi /etc/named.conf # name server 설정 파일 열기
```
{% endcode %}
{% endstep %}

{% step %}
### named.conf 수정 예시

파일 내 수정 예시:

{% code title="named.conf 예시" %}
```sh
listen-on port 53 { any; };
listen-on-v6 port 53 { none; }; 
allow-query { any; };
dnssec-validation no;
```
{% endcode %}
{% endstep %}

{% step %}
### 시스템 서비스 관리

```sh
systemctl restart named   # 재시작
systemctl enable named    # 부팅 시 활성화
systemctl status named    # 상태 확인 (또는 netstat -nlp)
```
{% endstep %}

{% step %}
### 방화벽 설정

```sh
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload
firewall-cmd --list-all
```
{% endstep %}

{% step %}
### DNS zone 설정 추가

named.conf에 zone 블록 추가 (큰 따옴표 필수):

{% code title="named.conf: zone 추가" %}
```sh
zone "도메인" IN { 
	type master;
	tile "도메인.zone";
	allow-update { none; };
};
```
{% endcode %}

구문 확인:

{% code title="named-checkconf" %}
```sh
named-checkconf named.conf
```
{% endcode %}
{% endstep %}

{% step %}
### 도메인(zone) 파일 생성 및 편집

기본 파일 복사 및 소유권 설정:

{% code title="zone 파일 복사" %}
```sh
cp /var/named/named.localhost /var/named/"도메인".zone
chown root.named /var/named/"도메인".zone
vi /var/named/"도메인".zone
```
{% endcode %}

zone 파일 예시:

{% code title="도메인.zone" %}
```zone
$TTL 1D
@    IN    SOA    @    rname.invalid.    ( 2    1D    1H    1W    1H )
           IN     NS   @
           IN     A    "IP"

www        IN     A    "IP"
ftp        IN     A    "IP"
```
{% endcode %}

{% code title="named-checkzone" %}
```sh
cd /var/named/
named-checkzone wolf.com wolf.com.zone
```
{% endcode %}

{% hint style="warning" %}
도메인 이름에 "\_" 같은 특수문자를 넣으면 에러가 발생합니다.
{% endhint %}
{% endstep %}

{% step %}
### DNS 작동 확인

```sh
nslookup
> server "DNS IP"
> www."찾을 도메인"
```
{% endstep %}

{% step %}
### 네트워크 및 DNS 클라이언트 설정 파일 위치

* 랜카드 설정 파일: /etc/NetworkManager/system-connections/
* DNS 설정 파일: /etc/resolv.conf (수정 후 재부팅 권장)
{% endstep %}
{% endstepper %}

### Master & Slave

* 주/보조 관계로 서로 동기화를 통해 DNS 서버를 이중화하는 기능입니다.
* 데이터 동기화는 Master 서버에서 관리하는 zone database에서만 가능합니다.
* Master에 생성되어 있는 zone 파일이 업로드되는 대로 Slave로 전송됩니다.
* Master: 도메인 관련 정보에 대한 zone 파일을 관리하는 주체
* Slave: Master로부터 zone 파일을 복제하여 미러링(백업) 역할 수행
* 관련자료: https://rlahjxx.tistory.com/15

{% stepper %}
{% step %}
### Master 구축

초기에는 기본 구축과 동일하게 진행합니다. 위의 설치/설정 단계들을 Master 서버에서 수행하세요.
{% endstep %}

{% step %}
### Slave 구축

Slave에서는 Master의 zone을 받을 수 있도록 named.conf에 Master 서버를 알리고, zone을 slave 타입으로 설정하여 복제하도록 구성합니다. (구체적 설정은 환경에 따라 다름)
{% endstep %}
{% endstepper %}
