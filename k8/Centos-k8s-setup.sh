#! /bin/bash

# https://kubernetes.io/docs/setup/cri/
# Install Docker CE
## Set up the repository
### Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2

### Add Docker repository.
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
yum update -y && yum install -y docker-ce-18.09.5

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "bip": "172.26.0.1/16",
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl enable docker
systemctl daemon-reload
systemctl restart docker


#################

# https://kubernetes.io/docs/setup/independent/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl
# Install k8s

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet #&& systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# ke
# echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

# Make sure that the br_netfilter module is loaded before this step. This can be done by running lsmod | grep br_netfilter. To load it explicitly call 
# lsmod | grep br_netfilter
modprobe br_netfilter

systemctl daemon-reload
systemctl restart kubelet

# Enabling shell autocompletion 脚本补全
yum install bash-completion -y
grep 'kubectl completion bash' ~/.bashrc > /dev/null || echo "source <(kubectl completion bash)" >> ~/.bashrc

# kubeadm init --pod-network-cidr=10.244.0.0/16
