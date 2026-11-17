# Wazuh 보안 관제 시스템 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-DEF-007-MP |
| 목적 | Wazuh 서버(indexer, manager, Filebeat, dashboard)를 한 대에 설치하고 대시보드에 접속한다 |
| 적용 대상 | RHEL 계열 9(Alma, Rocky 등, `dnf` 사용) 가상 머신(실습망), root 권한, 인터넷 연결 |
| 소요 시간 | 간편 설치 약 20분, 단계 설치 약 60분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 설치·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본에는 설치 방법이 두 가지 있었다. 구역 A는 4.9 버전의 간편 설치 스크립트, 구역 B는 4.4 버전 기준의 단계 설치다. 두 구역은 서로 대체할 수 있으므로 하나만 수행한다. 구역 B의 주소(`4.4`)는 오래된 버전일 수 있으므로 Wazuh 공식 문서의 현재 버전 절차와 대조한다(확인 필요). 원본의 "최소 사양" 항목은 이미지뿐이어서 수치를 쓰지 못했다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [보안 정보 이벤트 관리 (SIEM)](siem.md) | SEC-DEF-003-DO | SIEM 개념과 Wazuh의 위치 |
| [호스트 침입 탐지 시스템 (HIDS)](hids.md) | SEC-DEF-002-MP | OSSEC 에이전트 방식 |
| [firewalld 방화벽 관리](../../../../Linux/guide/security/firewalld.md) | LNX-SEC-001-MP | 방화벽 포트 허용 |
| Wazuh 공식 사이트 | - | https://wazuh.com/ |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Wazuh 서버 | RHEL 계열 9 가상 머신. 최소 사양은 공식 문서를 확인한다(확인 필요) | indexer가 메모리를 많이 쓴다 |
| 2 | 콘솔 접근 | 가상 머신 화면 | 재부팅, 방화벽 변경 시 필요 |
| 3 | 브라우저 | 서버에 접속 가능한 PC | 대시보드 접속 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 대시보드와 indexer의 관리자 계정·비밀번호는 서버 전체의 보안 로그에 접근하는 열쇠다. 문서, 채팅, 저장소에 쓰지 않는다. 설치 출력에 나오는 비밀번호는 비밀번호 관리 도구에 보관한다. 이 문서는 계정과 비밀번호를 `<기본 계정>`, `<관리자 비밀번호>`로 표기한다. 기본값을 쓰는 설치 방식이면 설치 직후 바꾼다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-B-01의 `reboot`은 서버를 재시작한다. 같은 서버에서 도는 다른 서비스가 중단된다. 재부팅 전에 콘솔 접근을 확보한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 포트 9200(indexer)은 모든 구성 요소를 한 대에 설치한 경우 외부에 열 필요가 없다. 원본은 9200을 영구 허용했으나 노출 범위를 넓히므로, 에이전트용 1514·1515와 대시보드용 443만 허용하고 9200은 구성 요소를 다른 서버로 나눌 때만 대상 IP로 제한해 연다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 권한을 확인한다: `id -u` | 출력이 `0`이다 |
| 2 | 서버 IP를 확인한다: `ip -br addr` | `<서버 IP>`를 메모한다 |
| 3 | 방화벽 상태를 확인한다: `firewall-cmd --state` | `running`이다 |
| 4 | 설치할 구역을 하나 고른다 | 구역 A 또는 구역 B |

## 5. 절차

### A. 간편 설치 (설치 스크립트)

1. (5-A-01) 설치 스크립트를 받아 실행한다: `curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh && sudo bash ./wazuh-install.sh -a` → 결과: 설치가 끝나면 `INFO: --- Summary ---` 아래에 접속 주소, 계정(`User:`), 비밀번호(`Password:`)가 출력되고 `INFO: Installation finished.`가 나온다.
2. (5-A-02) 출력된 계정과 비밀번호를 비밀번호 관리 도구에 보관한다 → 결과: 화면을 닫아도 다시 찾을 수 있다.
3. (5-A-03) 대시보드용 방화벽을 허용한다:

```bash
firewall-cmd --permanent --add-service=https
firewall-cmd --reload
```

→ 결과: 각 명령이 `success`를 출력한다. (원본은 `http`도 허용했으나 대시보드는 https를 쓰므로 `http`는 뺐다. 확인 필요.)
4. (5-A-04) 에이전트 통신 포트를 허용한다: `firewall-cmd --permanent --add-port={1514,1515}/tcp` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다. (원본은 구역 B에만 있던 단계다.)
5. (5-A-05) 브라우저에서 `https://<서버 IP>`에 접속한다 → 결과: Wazuh 로그인 화면이 나온다. 자체 서명 인증서 경고는 실습 환경이므로 예외로 진행한다.
6. (5-A-06) `<기본 계정>`과 `<관리자 비밀번호>`로 로그인한다 → 결과: 대시보드가 열린다.

### B. 단계 설치 (구성 요소별)

#### B-1. 시스템 준비

1. (5-B-01) 시스템을 갱신하고 재부팅한다: `dnf update -y` 이어서 `reboot` → 결과: 서버가 다시 시작된다.
2. (5-B-02) 필수 패키지를 설치한다: `dnf install -y coreutils chkconfig tar libcap` → 결과: 오류 없이 끝난다.

#### B-2. 인증서 생성

1. (5-B-03) 도구와 예제 설정 파일을 받는다:

```bash
curl -sO https://packages.wazuh.com/4.4/wazuh-certs-tool.sh
curl -sO https://packages.wazuh.com/4.4/config.yml
```

2. (5-B-04) `config.yml`을 연다: `vi config.yml`
3. (5-B-05) 세 구성 요소(indexer, server, dashboard)의 `ip`를 `<서버 IP>`로 바꾼다.

```yaml
nodes:
  indexer:
    - name: wazuh-01
      ip: <서버 IP>
  server:
    - name: wazuh-01
      ip: <서버 IP>
  dashboard:
    - name: dashboard
      ip: <서버 IP>
```

→ 결과: 세 항목의 `ip`가 같은 서버 IP다.
4. (5-B-06) 인증서를 만들고 묶는다: `bash ./wazuh-certs-tool.sh -A`, `tar -cvf ./wazuh-certificates.tar -C ./wazuh-certificates/ .`, `rm -rf ./wazuh-certificates` → 결과: `wazuh-certificates.tar` 파일이 생긴다.

#### B-3. 저장소 등록

1. (5-B-07) GPG 키를 가져온다: `rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH`
2. (5-B-08) 저장소 파일을 만든다:

```bash
echo -e '[wazuh]\ngpgcheck=1\ngpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH\nenabled=1\nname=EL-$releasever - Wazuh\nbaseurl=https://packages.wazuh.com/4.x/yum/\nprotect=1' | tee /etc/yum.repos.d/wazuh.repo
```

3. (5-B-09) 캐시를 만든다: `dnf makecache` → 결과: 저장소 메타데이터가 내려받아진다.

#### B-4. Wazuh indexer

1. (5-B-10) 설치한다: `dnf -y install wazuh-indexer` → 결과: 설치가 끝난다.
2. (5-B-11) 설정 파일을 백업한다: `cp /etc/wazuh-indexer/opensearch.yml /etc/wazuh-indexer/opensearch.yml.bak`
3. (5-B-12) 설정 파일을 연다: `vi /etc/wazuh-indexer/opensearch.yml`
4. (5-B-13) 아래 항목을 환경에 맞게 설정한다.

```
network.host: "<서버 IP>"
node.name: "wazuh-01"
cluster.initial_master_nodes:
- "wazuh-01"
plugins.security.nodes_dn:
- "CN=wazuh-01,OU=Wazuh,O=Wazuh,L=California,C=US"
```

→ 결과: `node.name`이 `config.yml`의 indexer 노드 이름과 같다.
5. (5-B-14) 인증서를 배치한다:

```bash
export NODE_NAME=wazuh-01
mkdir /etc/wazuh-indexer/certs
tar -xf ./wazuh-certificates.tar -C /etc/wazuh-indexer/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./admin.pem ./admin-key.pem ./root-ca.pem
mv -n /etc/wazuh-indexer/certs/$NODE_NAME.pem /etc/wazuh-indexer/certs/indexer.pem
mv -n /etc/wazuh-indexer/certs/$NODE_NAME-key.pem /etc/wazuh-indexer/certs/indexer-key.pem
chmod 500 /etc/wazuh-indexer/certs
chmod 400 /etc/wazuh-indexer/certs/*
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs
```

→ 결과: `/etc/wazuh-indexer/certs`에 `indexer.pem`, `indexer-key.pem`, `admin.pem`, `admin-key.pem`, `root-ca.pem`이 있다.
6. (5-B-15) 서비스를 켠다: `systemctl enable --now wazuh-indexer` → 결과: 오류 없이 시작된다.
7. (5-B-16) 보안 초기화를 실행한다: `/usr/share/wazuh-indexer/bin/indexer-security-init.sh` → 결과: 초기화가 오류 없이 끝난다.
8. (5-B-17) indexer 응답을 확인한다: `curl -k -u <기본 계정>:<관리자 비밀번호> https://<서버 IP>:9200` → 결과: `"cluster_name" : "wazuh-cluster"`와 `"tagline" : "The OpenSearch Project: https://opensearch.org/"`이 포함된 JSON이 출력된다.

{% hint style="warning" %}
CAUTION: 5-B-17의 `-k` 옵션은 인증서 검증을 건너뛴다. 실습용 확인에만 쓰고, 운영에서는 `--cacert`로 `root-ca.pem`을 지정한다.
{% endhint %}

#### B-5. Wazuh manager

1. (5-B-18) 설치하고 시작한다: `dnf install -y wazuh-manager` 이어서 `systemctl enable --now wazuh-manager` → 결과: 오류 없이 끝난다.
2. (5-B-19) 에이전트 통신 포트를 허용한다: `firewall-cmd --permanent --add-port={1514,1515}/tcp` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다.

#### B-6. Filebeat

1. (5-B-20) 설치한다: `dnf install -y filebeat`
2. (5-B-21) 샘플 설정을 받는다: `curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/4.4/tpl/wazuh/filebeat/filebeat.yml`
3. (5-B-22) 설정을 열어 `hosts`를 `["<서버 IP>:9200"]`로 바꾼다: `vi /etc/filebeat/filebeat.yml` → 결과: `hosts`가 indexer 주소다.
4. (5-B-23) 인증 정보를 keystore에 넣는다:

```bash
filebeat keystore create
echo <기본 계정> | filebeat keystore add username --stdin --force
echo <관리자 비밀번호> | filebeat keystore add password --stdin --force
```

→ 결과: 각 명령이 `Successfully` 메시지를 출력한다. 비밀번호를 명령줄에 입력하면 셸 기록(`history`)에 남으므로 입력 후 `history -d`로 해당 줄을 지운다(원본에 없던 보충).
5. (5-B-24) 경고 템플릿을 받고 권한을 준다: `curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/4.4/extensions/elasticsearch/7.x/wazuh-template.json` 이어서 `chmod go+r /etc/filebeat/wazuh-template.json`
6. (5-B-25) Wazuh 모듈을 설치한다: `curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.2.tar.gz | tar -xvz -C /usr/share/filebeat/module` → 결과: 모듈 파일이 풀린다. (원본은 `modulesd`로 적었으나 Filebeat의 모듈 디렉터리 이름은 `module`이다. 확인 필요.)
7. (5-B-26) 인증서를 배치한다:

```bash
export NODE_NAME=wazuh-01
mkdir /etc/filebeat/certs
tar -xf ./wazuh-certificates.tar -C /etc/filebeat/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
mv -n /etc/filebeat/certs/$NODE_NAME.pem /etc/filebeat/certs/filebeat.pem
mv -n /etc/filebeat/certs/$NODE_NAME-key.pem /etc/filebeat/certs/filebeat-key.pem
chmod 500 /etc/filebeat/certs
chmod 400 /etc/filebeat/certs/*
chown -R root:root /etc/filebeat/certs
```

8. (5-B-27) 서비스를 켜고 출력을 시험한다: `systemctl enable --now filebeat` 이어서 `filebeat test output` → 결과: `parse url... OK`, `connection... dial up... OK`, `TLS... handshake... OK`, `talk to server... OK`가 출력된다.

#### B-7. Wazuh dashboard

1. (5-B-28) 설치한다: `dnf install -y wazuh-dashboard`
2. (5-B-29) 설정 파일을 연다: `vi /etc/wazuh-dashboard/opensearch_dashboards.yml`
3. (5-B-30) 두 항목을 설정한다: `server.host: <서버 IP>`, `opensearch.hosts: https://<서버 IP>:9200` → 결과: 두 항목이 저장된다.
4. (5-B-31) 인증서를 배치한다:

```bash
export NODE_NAME=wazuh-01
mkdir /etc/wazuh-dashboard/certs
tar -xf ./wazuh-certificates.tar -C /etc/wazuh-dashboard/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./root-ca.pem
mv -n /etc/wazuh-dashboard/certs/$NODE_NAME.pem /etc/wazuh-dashboard/certs/dashboard.pem
mv -n /etc/wazuh-dashboard/certs/$NODE_NAME-key.pem /etc/wazuh-dashboard/certs/dashboard-key.pem
chmod 500 /etc/wazuh-dashboard/certs
chmod 400 /etc/wazuh-dashboard/certs/*
chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs
```

5. (5-B-32) 서비스를 켠다: `systemctl enable --now wazuh-dashboard` → 결과: 오류 없이 시작된다.
6. (5-B-33) 방화벽을 허용한다: `firewall-cmd --permanent --add-service=https` 이어서 `firewall-cmd --reload` → 결과: `success`가 출력된다.
7. (5-B-34) 브라우저에서 `https://<서버 IP>`에 접속하고 `<기본 계정>`으로 로그인한다 → 결과: 대시보드가 열린다. 설치 직후의 기본 비밀번호는 바로 바꾼다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `systemctl is-active wazuh-indexer wazuh-manager filebeat wazuh-dashboard` (구역 A는 `wazuh-indexer wazuh-manager wazuh-dashboard`) | 구성 요소가 모두 실행 중이다 | 모두 `active` |
| 2 | `filebeat test output` (구역 B) | indexer와 통신한다 | 마지막 줄이 `OK` |
| 3 | 브라우저에서 `https://<서버 IP>` | 로그인 화면이 나온다 | 로그인에 성공한다 |
| 4 | 다른 PC에서 서버의 1514, 443 포트 접속 시험 | 포트가 열려 있다 | 연결에 성공한다 |

## 7. 복구

1. (7-01) 구성 요소를 중지한다: `systemctl disable --now wazuh-dashboard filebeat wazuh-manager wazuh-indexer` (구역 A는 `filebeat`을 빼고 입력한다) → 결과: 모두 `inactive`가 된다.
2. (7-02) 추가한 방화벽 규칙을 제거한다: `firewall-cmd --permanent --remove-port={1514,1515}/tcp`, `firewall-cmd --permanent --remove-service=https`, `firewall-cmd --reload`
3. (7-03) 구역 A로 설치했다면 제거 스크립트를 쓴다: `bash ./wazuh-install.sh -u` (공식 제거 옵션이며 확인 필요) → 결과: Wazuh 구성 요소가 제거된다.
4. (7-04) 구역 B는 `dnf remove -y wazuh-dashboard filebeat wazuh-manager wazuh-indexer`로 제거하고 `/etc/yum.repos.d/wazuh.repo`를 지운다.
5. (7-05) 5-B-11에서 만든 백업이 필요하면 `opensearch.yml.bak`을 되돌린다.

## 8. 참조: 사전 지식

Wazuh는 ELK(Elasticsearch, Logstash, Kibana) 계열 구조와 비슷한 수집·저장·시각화 구성을 쓴다. 배경은 SIEM 문서(SEC-DEF-003-DO)를 따른다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 단계형 원본을 MP 형식으로 재작성. 원본에 노출돼 있던 임의 비밀번호와 기본 계정(`admin`/`admin`), 내부 IP, 개인 도메인을 `<관리자 비밀번호>`, `<기본 계정>`, `<서버 IP>`로 바꿨다. 데이터 손실·노출 WARNING, 재부팅·9200 포트 CAUTION, 기능 확인, 복구 절을 추가했다. 두 설치 방식(4.9 스크립트, 4.4 수동)을 구역 A, B로 나눠 서로 대체 가능하다고 명시했다. 검색·블로그 링크 2건은 삭제했다 |
