---
description: 전체 문서의 공통 키워드 기반 IA(Information Architecture)와 페이지 매핑.
---

# Pillar · Cluster 맵

### 공통 키워드(요약)

아래 키워드가 대부분의 페이지에서 반복적으로 등장합니다.

* **운영체제/리눅스**: shell, filesystem, process, permission, user/group, package, service, boot, storage, log
* **네트워크/보안**: ssh, vpn, firewall(iptables/firewalld), selinux, access control(ACL)
* **운영/자동화**: systemctl, cron, patch, monitoring, troubleshooting
* **컨테이너/오케스트레이션**: docker(image/container/registry/hub), kubernetes(pod/service/deployment), kubeadm, kind
* **클라우드/플랫폼**: aws(ec2/services), ci/cd(jenkins), devsecops, vmware(esxi/vcenter)

### Pillar 정의

* **Pillar 1 — Linux**
  * 목표: 설치/기본/명령어/보안/운영을 한 흐름으로 학습·참고
* **Pillar 2 — Cloud · DevOps**
  * 목표: Docker → Kubernetes → AWS/CI·CD/DevSecOps로 확장
* **Pillar 3 — Reference**
  * 목표: 링크/참고 자료, 아카이빙

### Cluster 정의 + 페이지 매핑

#### Pillar: Linux

> 현재 TOC 구조가 이미 Cluster 형태를 잘 갖추고 있어서, **현 구조를 정답 구조로 확정**했습니다.

* [Linux Basic](undefined-1/linux-basic.md)
* **개요 · 설치**
  * [개요 · 설치](../Linux/undefined-1/undefined/)
  * [about\_Linux](../Linux/undefined-1/undefined/about_linux.md)
  * [install\_Linux](../Linux/undefined-1/undefined/install_linux.md)
  * [slitaz linux set](../Linux/undefined-1/undefined/slitaz-linux-set.md)
  * [LinuxGeneral](../Linux/undefined-1/undefined/linuxgeneral.md)
* **기본 사용**
  * [기본 사용](../Linux/undefined-1/undefined-1/)
  * [LinuxBasicDirectoryDescription](../Linux/undefined-1/undefined-1/linuxbasicdirectorydescription.md)
  * [vi](../Linux/undefined-1/undefined-1/vi.md)
  * [Wildcards](../Linux/undefined-1/undefined-1/wildcards.md)
  * [LinuxUtilization](../Linux/undefined-1/undefined-1/linuxutilization.md)
* **명령어(레퍼런스)**
  * [명령어](../Linux/undefined-1/undefined-2/)
  * [HelpCommands](../Linux/undefined-1/undefined-2/helpcommands.md)
  * [LinuxCommand](../Linux/undefined-1/undefined-2/linuxcommand.md)
  * [Linux\_Command](../Linux/undefined-1/undefined-2/linux_command.md)
  * [linux\_basic\_commands](../Linux/undefined-1/undefined-2/linux_basic_commands.md)
  * [MiscCommands](../Linux/undefined-1/undefined-2/misccommands.md)
  * [TextFileCommands](../Linux/undefined-1/undefined-2/textfilecommands.md)
  * [SystemShutdownCommands](../Linux/undefined-1/undefined-2/systemshutdowncommands.md)
  * [bzip2](../Linux/undefined-1/undefined-2/bzip2.md)
  * [find\_time](../Linux/undefined-1/undefined-2/find_time.md)
* **계정 · 권한**
  * [계정 · 권한](../Linux/undefined-1/undefined-3/)
  * [Account Management](../Linux/undefined-1/undefined-3/account-management.md)
  * [UserCreationCommands](../Linux/undefined-1/undefined-3/usercreationcommands.md)
  * [UserQueryCommands](../Linux/undefined-1/undefined-3/userquerycommands.md)
  * [UserManagementCommands](../Linux/undefined-1/undefined-3/usermanagementcommands.md)
  * [linuxpasswd](../Linux/undefined-1/undefined-3/linuxpasswd.md)
  * [GroupManagement](../Linux/undefined-1/undefined-3/groupmanagement.md)
  * [GroupInfo](../Linux/undefined-1/undefined-3/groupinfo.md)
  * [GroupManagementCommands](../Linux/undefined-1/undefined-3/groupmanagementcommands.md)
  * [Permission](../Linux/undefined-1/undefined-3/permission.md)
* **네트워크 · 원격**
  * [네트워크 · 원격](../Linux/undefined-1/undefined-4/)
  * [NetworkCommands](../Linux/undefined-1/undefined-4/networkcommands.md)
  * [Remote Access Management](../Linux/undefined-1/undefined-4/remote-access-management.md)
  * [Remote SSH](../Linux/undefined-1/undefined-4/remote-ssh.md)
  * [RemoteTerminalAccess](../Linux/undefined-1/undefined-4/remoteterminalaccess.md)
  * [Open VPN](../Linux/undefined-1/undefined-4/open-vpn.md)
  * [Switch Based](../Linux/undefined-1/undefined-4/switch-based.md)
* **보안**
  * [보안](../Linux/undefined-1/undefined-5/)
  * [Linux\_Sec](../Linux/undefined-1/undefined-5/linux_sec.md)
  * [firewalld](../Linux/undefined-1/undefined-5/firewalld.md)
  * [iptables](../Linux/undefined-1/undefined-5/iptables.md)
  * [SELinux](../Linux/undefined-1/undefined-5/selinux.md)
  * [tcpwrapper](../Linux/undefined-1/undefined-5/tcpwrapper.md)
* **서비스**
  * [서비스](../Linux/undefined-1/undefined-6/)
  * [NFS](../Linux/undefined-1/undefined-6/nfs.md)
  * [Samba](../Linux/undefined-1/undefined-6/samba.md)
  * [NIS](../Linux/undefined-1/undefined-6/nis.md)
  * [Service Management](../Linux/undefined-1/undefined-6/service-management.md)
* **스토리지 · 부팅**
  * [스토리지 · 부팅](../Linux/undefined-1/undefined-7/)
  * [Storage Management](../Linux/undefined-1/undefined-7/storage-management.md)
  * [Disk\_Druid](../Linux/undefined-1/undefined-7/disk_druid.md)
  * [SMARTTool](../Linux/undefined-1/undefined-7/smarttool.md)
  * [LILO](../Linux/undefined-1/undefined-7/lilo.md)
  * [LILO\_lilo.conf](../Linux/undefined-1/undefined-7/lilo_lilo.conf.md)
  * [RunLevel](../Linux/undefined-1/undefined-7/runlevel.md)
  * [df](../Linux/undefined-1/undefined-7/df.md)
  * [mount](../Linux/undefined-1/undefined-7/mount.md)
* **운영 · 관리**
  * [운영 · 관리](../Linux/undefined-1/undefined-8/)
  * [linux\_admin](../Linux/undefined-1/undefined-8/linux_admin/)
  * [LinuxOpsAndManagement](../Linux/undefined-1/undefined-8/linuxopsandmanagement.md)
  * [LinuxPackageManagementTool](../Linux/undefined-1/undefined-8/linuxpackagemanagementtool.md)
  * [Patch Management](../Linux/undefined-1/undefined-8/patch-management.md)
  * [Redistribution](../Linux/undefined-1/undefined-8/redistribution.md)
  * [VirtualEnvAndKernel](../Linux/undefined-1/undefined-8/virtualenvandkernel.md)
  * [LinuxServer](../Linux/undefined-1/undefined-8/linuxserver.md)
* **로깅 · 모니터링**
  * [로깅 · 모니터링](../Linux/undefined-1/undefined-9/)
  * [Log Management](../Linux/undefined-1/undefined-9/log-management.md)
  * [Log\_File](../Linux/undefined-1/undefined-9/log_file.md)
  * [Logrotate](../Linux/undefined-1/undefined-9/logrotate.md)
  * [logwatch](../Linux/undefined-1/undefined-9/logwatch.md)
  * [sysstat](../Linux/undefined-1/undefined-9/sysstat.md)
* **스크립트 · 자동화**
  * [스크립트 · 자동화](../Linux/undefined-1/undefined-10/)
  * [Shell Script](../Linux/undefined-1/undefined-10/shell-script.md)
  * [scripts](../Linux/undefined-1/undefined-10/scripts.md)
  * [cron](../Linux/undefined-1/undefined-10/cron.md)
* **시험 · 학습**
  * [시험 · 학습](../Linux/undefined-1/undefined-11/)
  * [LinuxMasterExamPrep](../Linux/undefined-1/undefined-11/linuxmasterexamprep.md)
  * [LinuxMasterLevel2](../Linux/undefined-1/undefined-11/linuxmasterlevel2.md)
* **링크 · 참고 / 아카이브**
  * [링크 · 참고](../Linux/undefined-1/undefined-12/)
    * [Link](../Linux/undefined-1/undefined-12/link.md)
    * [LinuxLink](../Linux/undefined-1/undefined-12/linuxlink.md)
    * [LinuxLinks](../Linux/undefined-1/undefined-12/linuxlinks.md)
  * [아카이브](../Linux/undefined-1/undefined-13/)
    * [Archive](../Linux/undefined-1/undefined-13/archive.md)

#### Pillar: Cloud · DevOps

* [Cloud · DevOps 개요](cloud-devops/cloud-devops.md)
* **AWS**
  * [AWS](cloud-devops/aws/)
  * [aws](/broken/spaces/YPIWbzxCJ7vgiXOF76ir/pages/47c90ab814410d648ec1e442e9f7c06f4d36dc82)
    * [AWS](cloud-devops/aws/aws.md)
    * [AWS\_Services](cloud-devops/aws/aws_services.md)
    * [AWS\_EC2](cloud-devops/aws/aws_ec2.md)
* **Docker**
  * [Docker](cloud-devops/docker/)
  * [Docker](cloud-devops/docker/docker.md)
  * [DockerTheory](cloud-devops/docker/dockertheory.md)
  * [Docker\_Container](cloud-devops/docker/docker_container.md)
  * [Docker\_Build](cloud-devops/docker/docker_build.md)
  * [Docker\_Hub](cloud-devops/docker/docker_hub.md)
  * [Docker\_Registry](cloud-devops/docker/docker_registry.md)
  * [Docker\_Image](cloud-devops/docker/docker_image.md)
  * [Docker\_commend](cloud-devops/docker/docker_commend.md)
  * [Docker\_install](cloud-devops/docker/docker_install.md)
  * [docker hub image share](cloud-devops/docker/docker-hub-image-share.md)
  * [Dockerfile](cloud-devops/docker/dockerfile.md)
  * [ubuntu wordpress docker](cloud-devops/docker/ubuntu-wordpress-docker.md)
  * [docker](cloud-devops/docker/docker-1/)
    * [DockerPractice](cloud-devops/docker/docker-1/dockerpractice.md)
* **Kubernetes**
  * [Kubernetes](cloud-devops/kubernetes/)
  * [kubernetes\_in\_windows](cloud-devops/kubernetes/kubernetes_in_windows.md)
  * [kubernetes](cloud-devops/kubernetes/kubernetes/)
    * [EKS](cloud-devops/kubernetes/kubernetes/eks.md)
    * [Kube\_setup](cloud-devops/kubernetes/kubernetes/kube_setup.md)
    * [KubeSetup](cloud-devops/kubernetes/kubernetes/kubesetup.md)
    * [Kube\_webDashboard](cloud-devops/kubernetes/kubernetes/kube_webdashboard.md)
    * [Kubernetes on dockerImage](cloud-devops/kubernetes/kubernetes/kubernetes-on-dockerimage.md)
    * [KubernetesTheory](cloud-devops/kubernetes/kubernetes/kubernetestheory.md)
* **CI/CD · DevSecOps**
  * [CI/CD · DevSecOps](cloud-devops/ci-cd-devsecops/)
  * [Jenkins](cloud-devops/ci-cd-devsecops/jenkins.md)
* **Private Cloud**
  * [Private Cloud](cloud-devops/private-cloud/)
  * [VMwarePrivateCloud](cloud-devops/private-cloud/vmwareprivatecloud.md)
* **Theory · Assignments**
  * [Theory · Assignments](cloud-devops/theory-assignments/)
  * [CloudTheory](cloud-devops/theory-assignments/cloudtheory.md)
  * [CloudSecuritySystemManagementAssignment](cloud-devops/theory-assignments/cloudsecuritysystemmanagementassignment.md)
* **Legacy**
  * [cloud\_devops](cloud-devops/cloud_devops-legacy.md)

### 운영 규칙(추천)

* 새 문서는 먼저 **Pillar → Cluster**를 결정하고 추가합니다.
* 파일명/제목에 `_`가 섞여 있으면, 장기적으로는 `Title Case`로 정리하는 걸 추천합니다.
* 실습/예시와 이론은 섞지 말고, 가능하면 `Practice` / `Theory`로 분리합니다.
