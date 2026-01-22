# Kali IP Setup

### Network Interface Setting File

```sh
sudo vi /etc/network/interfaces 
# 또는 root 계정으로 접속해 vi /etc/network/interfaces
```

### File Desc

```sh
auto eth0               # 장치 활성화 명령어
iface eth0 inet static  # 장치 수동/자동 설정 여부
address = IP            # 장치 IP
netmask = SUBNET        # IP Subnet mask
geteway = IP            # Gateway IP
```
