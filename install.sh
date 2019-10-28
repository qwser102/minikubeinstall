#!/bin/bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config
setenforce 0
systemctl disable firewalld && systemctl stop firewalld

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

yum makecache 
yum install kubelet-1.16.2-0.x86_64 -y
yum install kubeadm-1.16.2-0.x86_64 -y
yum install  bind-utils-9.11.4-9.P2.el7.x86_64 -y
#yum intall bind-utils -y
yum install docker -y

systemctl start docker 
systemctl enable docker 
systemctl start kubelet && systemctl enable kubelet

sed -ie 's/--exec-opt native.cgroupdriver=systemd/--exec-opt native.cgroupdriver=cgroupfs/g' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker 
docker info 
sleep 5
systemctl restart docker 
docker info 

tar -xvf pkg.tar
cd pkg
for i in `ls |grep tar`;do docker load -i $i;done

cp ./kubectl /usr/local/bin/kubectl
sudo install minikube /usr/local/bin/

minikube start --vm-driver=none
