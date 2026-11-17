# 클라우드 보안 시스템 관리 실습 과제

Rocky Linux에 Docker 서비스를 활용하여 Ubuntu Linux에 FTP Server를 구축하여 접속 가능한지 테스트한 뒤 Docker Hub에 이미지를 업로드 가능한지 확인하시오. (직접 또는 Dockerfile)

Vmware ESXi 서비스에서 Private Cloud 구축을 위해 2대의 VM(Ubuntu)을 생성한 후 Kubernetes Clustering을 구축하여 서비스 및 노드 연결을 확인하고 Worker 노드에 웹서버를 구축하여 접속 가능 여부를 확인하고 Master 노드로의 웹 대시보드 접속이 가능한지 확인하시오.

***

## 채점 기준

* Docker Container 실행 및 이미지 업로드 시 20점(각 10점) | 미 실행 시 0점
* Vmware ESXi 구축 및 대시보드 실행 시 10점 | 미 실행 시 0점
* Kubernetes Clustering 구축 확인 시 30점 | 미 확인 시 0점
* Master Node로의 웹 대시보드 접속 시 10점 | 미 접속 시 0점

구축된 클라우드 환경에서 보안 설정과 모니터링을 통해 클라우드 서비스를 원활하게 운영할 수 있도록 하시오.

* 클라우드 환경에서 구축된 웹서버에 대해 192.168.0.0/16 네트워크에서만 접근이 가능하도록 보안 설정을 하시오. (Vmware ESXi)
* 서비스되고 있는 클라우드 시스템에 대해 모니터링을 진행하여 확인하시오.

추가 채점 기준:

* 보안 설정 시 10점 | 미 설정 시 0점
* 모니터링 가능 시 10점 | 미 가능 시 0점

***

## 환경 정보

* 172.16.153.129 = master
* 172.16.153.130 = worker01

***

## Kubernetes 설치 / 구성 (요약)

{% stepper %}
{% step %}
### Install Containerd

(설치 및 설정 과정을 수행)
{% endstep %}

{% step %}
### Install Kubernetes Components

(예: kubeadm, kubelet, kubectl 설치)
{% endstep %}

{% step %}
### Initialize the Kubernetes Cluster

예시 플래그:

\--discovery-token-ca-cert-hash sha256:cbefc54235df9b1f4ea822c68b017ed950f0862be025feb1b5a64db91df8104c
{% endstep %}

{% step %}
### Join Worker Nodes

예시 명령 (worker에서 실행):

kubeadm join k8s-control-node:6443 --token r7y2zt.v86audwr6t7ii132\
(적절한 --discovery-token-ca-cert-hash 값과 함께)
{% endstep %}

{% step %}
### Install Calico Network Plugin

(네트워크 플러그인 설치)
{% endstep %}

{% step %}
### Kubernetes Installation Web Service & Dashboard

* Kube\_webDashboard (Kubernetes 대시보드 설치 및 접근 확인)
{% endstep %}
{% endstepper %}

***

## Docker / FTP 서버 구축 (요약 및 주요 명령)

* Rocky Linux 환경에서 docker 설치
* docker 설정 디렉터리 생성
* Dockerfile 생성
* vsftpd 관련 설정 파일 생성
* ubuntu-ftp 라는 이름의 이미지 빌드 (생성한 설정 파일들 활용)
* 21 포트로 ubuntu-ftp 이미지로 Ubuntu-FTP 서비스를 백그라운드로 구동
* 방화벽(포트 범위) 허용 및 리로드
* FTP 접속 및 파일 전송 확인

주요 명령 예시:

sudo firewall-cmd --permanent --add-port=30000-30010/tcp\
sudo firewall-cmd --reload

컨테이너 실행 예시:

docker run -d --name Ubuntu-FTP -p 21:21 -p 30000-30010:30000-30010 ubuntu-ftp

컨테이너 내부 접속 예시:

docker exec -it Ubuntu-FTP bash

FTP 디렉토리 예시:

cd /home/ftpuser/ftp/files/

***

### vsftpd 구성 예시 (1차, 2차, 3차 수정 내역 포함)

기본으로 사용된 설정 항목(예시, 원문에서 사용된 항목들을 그대로 유지):

* listen=YES
* anonymous\_enable=NO
* local\_enable=YES
* write\_enable=YES
* dirmessage\_enable=YES
* use\_localtime=YES
* xferlog\_enable=YES
* connect\_from\_port\_20=YES
* chroot\_local\_user=YES
* allow\_writeable\_chroot=YES
* pam\_service\_name=vsftpd
* rsa\_cert\_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
* rsa\_private\_key\_file=/etc/ssl/private/ssl-cert-snakeoil.key

Passive 모드 관련(초기 설정 예시):

* pasv\_enable=YES
* pasv\_min\_port=30000
* pasv\_max\_port=30010
* pasv\_address=192.168.1.100 (호스트 IP에 따라 값 변경 필요)

참고: 호스트의 IP가 변경되면 빌드한 도커 이미지의 설정을 수정해야 함. 컨테이너 실행 시 호스트의 IP를 인자로 전달해 pasv\_address로 설정하도록 조정 가능.

컨테이너 실행 예시(호스트 IP를 /etc/hosts로 추가):

docker run -d\
\--name Ubuntu-FTP\
-p 21:21 -p 30000-30010:30000-30010\
\--add-host=ftp.local:$(hostname -I | awk '{print $1}')\
ubuntu-ftp

***

### Dockerfile (예시)

{% code title="Dockerfile" %}
```dockerfile
# 최신 Ubuntu 이미지 사용
FROM ubuntu:latest

# 필요한 패키지 설치
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# FTP 사용자 계정 생성 및 디렉토리 설정
RUN useradd -m ftpuser && \
    echo "ftpuser:password123" | chpasswd && \
    mkdir -p /home/ftpuser/ftp/files && \
    chown -R ftpuser:ftpuser /home/ftpuser/ftp && \
    chmod a-w /home/ftpuser/ftp

# vsftpd 설정 복사
COPY vsftpd.conf /etc/vsftpd.conf

# 데이터 포트 및 명령 포트 노출
EXPOSE 21 20

# vsftpd 실행
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]
```
{% endcode %}

Dockerfile 최적화 예시(패시브 모드를 비활성화하고 Active 모드 중심으로 구성):

* pasv\_enable=NO
* listen=YES
* anonymous\_enable=NO
* local\_enable=YES
* write\_enable=YES
* dirmessage\_enable=YES
* use\_localtime=YES
* xferlog\_enable=YES
* connect\_from\_port\_20=YES
* chroot\_local\_user=YES
* allow\_writeable\_chroot=YES

컨테이너 실행(Active 모드 포트만 노출) 예시:

docker run -d --name Ubuntu-FTP -p 21:21 -p 20:20 ubuntu-ftp

방화벽 예시:

sudo firewall-cmd --permanent --add-port=21/tcp\
sudo firewall-cmd --permanent --add-port=20/tcp\
sudo firewall-cmd --reload

이미지 푸시 예시(로그인 후):

docker run -d --name Ubuntu-FTP -p 21:21 -p 20:20 krjaeh0/ubuntu-ftp:latest

***

## FTP 테스트 및 검증

* FTP 접속 확인
* 파일 전송 확인 (예: 파일명 변경 또는 업로드 후 확인)
* 컨테이너 내부에서 파일 확인 및 변조 예시:
  * docker exec -it Ubuntu-FTP bash
  * 파일 변조: docker-ftp-test.txt → ftp-server.txt
  * 파일 변조 확인

***

## Docker 이미지 빌드 및 실행 요약 (단계별)

{% stepper %}
{% step %}
### 이미지 빌드

docker build -t ubuntu-ftp .
{% endstep %}

{% step %}
### 컨테이너 실행 (호스트 IP 반영 방식 예시)

docker run -d\
\--name Ubuntu-FTP\
-p 21:21 -p 30000-30010:30000-30010\
\--add-host=ftp.local:$(hostname -I | awk '{print $1}')\
ubuntu-ftp
{% endstep %}

{% step %}
### 컨테이너 실행 (Active 모드 예시)

docker run -d --name Ubuntu-FTP -p 21:21 -p 20:20 ubuntu-ftp
{% endstep %}
{% endstepper %}

***

## 보안 설정 요구 사항 (예: Vmware ESXi 상에서)

* 웹서버 접근 제어: 192.168.0.0/16 네트워크에서만 접근 가능하도록 보안 설정 수행 필요

(구체적 방화벽 규칙 설정은 구축 환경에 따라 적용)

***

## 모니터링

* 서비스되고 있는 클라우드 시스템에 대해 모니터링을 진행하여 확인 (세부 툴/설정은 환경에 따라 상이)

***

## 관련 노드 이름 (원문에 표기된 노드)

* k8s-control-node
* k8s-worker01-node

***

## (원본 이미지 파일은 본 문서에 임베드되어 있는 파일 참조를 유지합니다.)

위 내용은 원문 Excalidraw 문서의 텍스트 요소를 가능한 한 원문 의미와 구조를 유지한 채 정리한 것입니다. 원문에 포함된 모든 명령어나 설정값, 이미지 참조는 변경 없이 유지했습니다. 필요한 경우 각 섹션을 세부 가이드(예: 실제 명령어와 단계별 절차)로 확장할 수 있습니다.
