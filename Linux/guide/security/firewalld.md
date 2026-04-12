# firewalld

## 서비스 활성 여부

```sh
firewall-cmd --state
systemctl status firewalld
```

## 서비스 정책 확인

```sh
firewall-cmd --list-all
```

## default zone 확인

```sh
firewall-cmd --get-default-zone
```

* public으로 설정되어 있을 것이다.

## active zone 확인

```sh
firewall-cmd --get-active-zone
```

## all zone 확인

```sh
firewall-cmd --get-zones
```

## 특정 zone 정책 확인

```sh
firewall-cmd --zone=home --list-all
```

## 특정 정보만 확인

```sh
firewall-cmd --zone=public --list-services
# 또는 포트 정보
firewall-cmd --zone=public --list-ports
```

## permanent 설정만 확인

```sh
firewall-cmd --zone=public --list-services --permanent
```

## 인터페이스에 zone 할당

```sh
firewall-cmd --zone=home --change-interface=enp0s3
```

{% hint style="info" %}
zone을 할당하면 자동으로 활성 상태가 된다.
{% endhint %}

## default zone 변경

```sh
firewall-cmd --set-default-zone=home
```

## 서비스 목록 보기

```sh
firewall-cmd --get-services
```

## 서비스 방화벽 설정 파일 경로

```sh
/usr/lib/firewalld/services/
```

{% code title="/usr/lib/firewalld/services/ssh.xml" %}
```xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>SSH</short>
  <description>Secure Shell (SSH) is a protocol for logging into and executing commands on remote machines. It provides secure encrypted communications. If you plan on accessing your machine remotely via SSH over a firewalled interface, enable this option. You need the openssh-server package installed for this option to be useful.</description>
  <port protocol="tcp" port="22"/>
</service>
```
{% endcode %}

## zone 설정 파일 경로

```sh
/usr/lib/firewalld/zones/
```

예시:

```sh
block.xml      drop.xml       home.xml       nm-shared.xml  trusted.xml
dmz.xml        external.xml   internal.xml   public.xml     work.xml
```

{% code title="/usr/lib/firewalld/zones/public.xml" %}
```xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <service name="cockpit"/>
  <forward/>
</zone>
```
{% endcode %}

## zone 생성

```sh
firewall-cmd --permanent --new-zone=test
```

## 특정 zone에 서비스 설정

```sh
firewall-cmd --permanent --add-service=httpd --zone=test
```

## 소스 IP(네트워크 대역)를 기준으로 모든 패킷 허용

```sh
firewall-cmd --permanent --zone=test --add-source=192.168.1.8
firewall-cmd --permanent --zone=test --add-source=192.168.0.0/16
```

## 적용한 정책 제거

```sh
firewall-cmd --permanent --zone=test --remove-source=192.168.1.8
```

## 도움말

```sh
firewall-cmd --help
```

***

## rich rules

좀 더 세부 정책을 설정하기 위해 사용하는 rule

```sh
firewall-cmd --permanent --zone=public --add-rich-rule='룰'
firewall-cmd --reload
```

룰 문법 예시:

```sh
'rule family="ipv4" source address="192.168.1.8" service name="ssh" accept'
```

> 192.168.1.8에서 22port(ssh)로 접근하는 ipv4 패킷을 허용

```sh
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.8" service name="ssh" accept'
```

* address: 네트워크 대역도 가능
* accept: 허용
* drop: 차단
* reject: 차단하되 메세지 전달(접속하려는 대상에게)
