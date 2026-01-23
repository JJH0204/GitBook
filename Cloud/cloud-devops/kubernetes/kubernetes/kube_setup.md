# Kube\_setup

{% stepper %}
{% step %}
### Set Hostname & Update Hosts File

Configure the master and worker nodes' hostnames and update the hosts file for network communication.

```bash
sudo hostnamectl set-hostname "k8s-control-node"      // Master Node
sudo hostnamectl set-hostname "k8s-worker01-node"    // Worker Node 1
sudo hostnamectl set-hostname "k8s-worker02-node"    // Worker Node 2
```

Add the following lines to `/etc/hosts` file on each node:

```
192.168.1.118  k8s-control-node
192.168.1.117  k8s-worker01-node
192.168.1.116  k8s-worker02-node
```
{% endstep %}

{% step %}
### Disable Swap & Load Kernel Modules

* 만약 클러스터가 잘 동작하지 않으면 `selinux/firewalld disabled`

{% hint style="warning" %}
If needed, disable firewalld and set SELinux to permissive:
{% endhint %}

```bash
sudo systemctl stop firewalld
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

Disable swap memory and configure kernel modules like overlay and br\_netfilter for Kubernetes.

```bash
sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo modprobe overlay && sudo modprobe br_netfilter
```

Create a file with the following content:

```bash
sudo vi /etc/modules-load.d/k8s.conf
# add:
overlay
br_netfilter
```

Or:

```bash
sudo tee /etc/modules-load.d/k8s.conf << EOF
overlay
br_netfilter
EOF
```

Next, add the kernel parameters like IP forwarding. Create a file and load the parameters using sysctl command:

```bash
sudo vi /etc/sysctl.d/kubernetes.conf
# add:
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
```

Or:

```bash
sudo tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

To load the above kernel parameters, run:

```bash
sudo sysctl --system
```
{% endstep %}

{% step %}
### Install Containerd

Install and configure containerd with SystemdCgroup to manage container runtime.

```bash
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/containerd.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install containerd.io -y
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

```bash
sudo systemctl restart containerd
```
{% endstep %}

{% step %}
### Add Kubernetes Package Repository

Download and configure the Kubernetes package repository for Ubuntu 24.04.

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo 'deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/k8s.list
```
{% endstep %}

{% step %}
### Install Kubernetes Components

Install Kubeadm, Kubelet, and Kubectl on all nodes to manage your Kubernetes cluster.

```bash
sudo apt update
sudo apt install kubelet kubeadm kubectl -y
```
{% endstep %}

{% step %}
### Initialize the Kubernetes Cluster

Initialize the control plane node using kubeadm.

```bash
sudo kubeadm init --control-plane-endpoint=k8s-control-node
```

On the master node, run the following commands to configure kubectl:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf
```
{% endstep %}

{% step %}
### Join Worker Nodes

Add worker nodes to your Kubernetes cluster using the token generated during initialization.

```bash
kubeadm join k8s-control-node:6443 --token ja17vs.yryk24e3iqp2rc60 \
        --discovery-token-ca-cert-hash sha256:4fee1cbd324a37b82b57c55f2feb3371dd8bbae781c6826ab72e7b44f3530c5a
```

Now head back to the master node and verify the status of worker nodes:

```bash
kubectl get nodes
```

* (Example) 3 node(Status - NotReady)
{% endstep %}

{% step %}
### Install Calico Network Plugin

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
```

After the successful installation of Calico, nodes' status will change to Ready in a minute or two.

```bash
kubectl get pods -n kube-system
kubectl get nodes
```
{% endstep %}

{% step %}
### Test Kubernetes Installation

Create and expose an NGINX deployment to verify the setup.

```bash
kubectl create ns demo-app
kubectl create deployment nginx-app --image nginx --replicas 2 --namespace demo-app
kubectl get deployment -n demo-app
kubectl get pods -n demo-app
kubectl expose deployment nginx-app -n demo-app --type NodePort --port 80
kubectl get svc -n demo-app
```

Now try to access your application using NodePort:

```bash
curl http://Any-worker-IP:32488
```

By the end of this tutorial, you’ll have a fully functioning Kubernetes cluster with networking and a test deployment.

Commands and configurations mentioned in the video are included step-by-step. Make sure to follow along!

Don’t forget to like, subscribe, and hit the bell icon to stay updated with more Linux and Kubernetes tutorials!
{% endstep %}
{% endstepper %}
