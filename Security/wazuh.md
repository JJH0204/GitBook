# Wazuh

대표적인 보안 관제 솔루션 https://wazuh.com/

### 사전 정보

[Elastic Search](https://www.google.com/search?q=elasticsearch\&oq=Elastic\&gs_lcrp=EgZjaHJvbWUqCggBEAAYsQMYgAQyDwgAEEUYORiDARixAxiABDIKCAEQABixAxiABDINCAIQABiDARixAxiABDIHCAMQABiABDIHCAQQABiABDIHCAUQABiABDIHCAYQABiABDIHCAcQABiABDIHCAgQABiABDIHCAkQABiABNIBCTYxODZqMGoxNagCCLACAQ\&sourceid=chrome\&ie=UTF-8) [ELK Stack](https://velog.io/@holidenty/ELK-ELK-Stack-%EC%9D%B4%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%BC%EA%B9%8C)

### Server Install

최소 사양<br>

간편 설치 명령어

```sh
curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

{% hint style="warning" %}
설치 후 대시보드 접속 계정 정보를 꼭 기억하세요. 예시 출력: INFO: --- Summary --- INFO: You can access the web interface https:// User: admin Password: \<ADMIN\_PASSWORD> INFO: Installation finished.

예시(임의 비밀번호 출력) User: admin Password: ZfttyCjs+9pzjc9f4nlX.c86TJt4rslX
{% endhint %}

방화벽 허용 예시

```sh
[root@Linux1 ~]# firewall-cmd --permanent --add-service=http
success
[root@Linux1 ~]# firewall-cmd --permanent --add-service=https
success
[root@Linux1 ~]# firewall-cmd --reload
success
```

웹 접속 `https://<wazuh-dashboard-ip>`

### Install script

{% stepper %}
{% step %}
### 시스템 준비

업데이트 및 필수 패키지 설치:

```sh
dnf update -y
reboot
dnf install -y coreutils chkconfig tar libcap
```
{% endstep %}

{% step %}
### 인증서 도구 다운로드 및 설정 파일 작성

인증서 저장소 도구와 예제 구성 파일 다운로드:

```sh
curl -sO https://packages.wazuh.com/4.4/wazuh-certs-tool.sh
curl -sO https://packages.wazuh.com/4.4/config.yml
vi config.yml
```

config.yml 예시(핵심 항목):

```yaml
nodes:
  # Wazuh indexer nodes
  indexer:
    - name: wazuh-01
      ip: 192.168.1.220(본인 wazuh ip)

  # Wazuh server nodes
  server:
    - name: wazuh-01
      ip: 192.168.1.220(본인 wazuh ip)

  # Wazuh dashboard nodes
  dashboard:
    - name: dashboard
      ip: 192.168.1.220(본인 wazuh ip)
```

인증서 생성 및 패키징:

```sh
bash ./wazuh-certs-tool.sh -A
tar -cvf ./wazuh-certificates.tar -C ./wazuh-certificates/ .
rm -rf ./wazuh-certificates
```
{% endstep %}

{% step %}
### Wazuh 저장소 등록

GPG 키 가져오기 및 레포지토리 등록:

```sh
rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
echo -e '[wazuh]\ngpgcheck=1\ngpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://packages.wazuh.com/4.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh.repo
dnf makecache
```

(예시로 동일 내용이 반복 표기되어 있음)
{% endstep %}

{% step %}
### Wazuh Indexer 설치

설치:

```sh
dnf -y install wazuh-indexer
```

설정 파일 편집:

```sh
vi /etc/wazuh-indexer/opensearch.yml
```

opensearch.yml 예시 항목:

```
network.host: "192.168.1.220"
node.name: "wazuh-01"
cluster.initial_master_nodes:
- "wazuh-01"
plugins.security.nodes_dn:
- "CN=wazuh-01,OU=Wazuh,O=Wazuh,L=California,C=US"
```

indexer 보안 인증서 배포(예시):

```sh
export NODE_NAME=wazuh-01
# mkdir /etc/wazuh-indexer/certs
# tar -xf ./wazuh-certificates.tar -C /etc/wazuh-indexer/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./admin.pem ./admin-key.pem ./root-ca.pem
# mv -n /etc/wazuh-indexer/certs/$NODE_NAME.pem /etc/wazuh-indexer/certs/indexer.pem
# mv -n /etc/wazuh-indexer/certs/$NODE_NAME-key.pem /etc/wazuh-indexer/certs/indexer-key.pem
# chmod 500 /etc/wazuh-indexer/certs
# chmod 400 /etc/wazuh-indexer/certs/*
# chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs
systemctl enable --now wazuh-indexer
```

방화벽 포트 허용:

```sh
firewall-cmd --permanent --add-port=9200/tcp
firewall-cmd --reload
```

indexer 보안 초기화 스크립트 실행:

```sh
/usr/share/wazuh-indexer/bin/indexer-security-init.sh
```

설치 확인 예시:

```sh
# curl -k -u admin:admin https://wazuh-01.centlinux-com.com:9200
{
  "name" : "wazuh-01",
  "cluster_name" : "wazuh-cluster",
  ...
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
```
{% endstep %}

{% step %}
### Wazuh Manager 설치

설치 및 서비스 시작:

```sh
dnf install -y wazuh-manager
systemctl enable --now wazuh-manager
```

방화벽 포트 허용:

```sh
firewall-cmd --permanent --add-port={1514,1515}/tcp
firewall-cmd --reload
```
{% endstep %}

{% step %}
### Filebeat 설치 및 설정

Filebeat 설치:

```sh
dnf install -y filebeat
```

샘플 filebeat 구성 다운로드:

```sh
curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/4.4/tpl/wazuh/filebeat/filebeat.yml
vi /etc/filebeat/filebeat.yml
# hosts: ["192.168.1.220:9200"]
```

Filebeat keystore에 인증정보 추가:

```sh
filebeat keystore create
echo admin | filebeat keystore add username --stdin --force
echo admin | filebeat keystore add password --stdin --force
```

Alert 템플릿 다운로드 및 권한 설정:

```sh
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/4.4/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json
```

Filebeat 모듈 설치:

```sh
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.2.tar.gz | tar -xvz -C /usr/share/filebeat/modulesd
```

Wazuh 서버에 보안 인증서 배포(예시):

```sh
export NODE_NAME=wazuh-01
# mkdir /etc/filebeat/certs
# tar -xf ./wazuh-certificates.tar -C /etc/filebeat/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
# mv -n /etc/filebeat/certs/$NODE_NAME.pem /etc/filebeat/certs/filebeat.pem
# mv -n /etc/filebeat/certs/$NODE_NAME-key.pem /etc/filebeat/certs/filebeat-key.pem
# chmod 500 /etc/filebeat/certs
# chmod 400 /etc/filebeat/certs/*
# chown -R root:root /etc/filebeat/certs
```

Filebeat 실행 및 출력 테스트:

```sh
systemctl enable --now filebeat
filebeat test output
# 예시 출력:
# elasticsearch: https://192.168.1.220:9200...
#   parse url... OK
#   connection...
#     parse host... OK
#     dns lookup... OK
#     addresses: 192.168.18.83
#     dial up... OK
#   TLS...
#     security: server's certificate chain verification is enabled
#     handshake... OK
#     TLS version: TLSv1.3
#     dial up... OK
#   talk to server... OK
#   version: 7.10.2
```
{% endstep %}

{% step %}
### Wazuh Dashboard 설치

설치:

```sh
dnf install -y wazuh-dashboard
```

설정 파일 편집:

```sh
vi /etc/wazuh-dashboard/opensearch_dashboards.yml
# server.host: 192.168.1.220
# opensearch.hosts: https://192.168.1.220:9200
```

Dashboard에 보안 인증서 배포(예시):

```sh
export NODE_NAME=wazuh-01
# mkdir /etc/wazuh-dashboard/certs
# tar -xf ./wazuh-certificates.tar -C /etc/wazuh-dashboard/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
# mv -n /etc/wazuh-dashboard/certs/$NODE_NAME.pem /etc/wazuh-dashboard/certs/dashboard.pem
# mv -n /etc/wazuh-dashboard/certs/$NODE_NAME-key.pem /etc/wazuh-dashboard/certs/dashboard-key.pem
# chmod 500 /etc/wazuh-dashboard/certs
# chmod 400 /etc/wazuh-dashboard/certs/*
# chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs
```

서비스 시작 및 방화벽 설정:

```sh
systemctl enable --now wazuh-dashboard
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

웹 접속 완료 -> 기본 계정: admin / admin (예시)
{% endstep %}
{% endstepper %}
