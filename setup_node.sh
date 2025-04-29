#!/bin/bash

echo "Waiting for the system and network to be ready..."
# Ensure networking is up (example: ping a well-known server)
while ! ping -c 1 google.com &> /dev/null; do
  echo "Waiting for network..."
  sleep 2
done
echo "Network is ready. Running the script on VM1..."


Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
# Apply sysctl params without reboot
sudo sysctl --system

# Verify that net.ipv4.ip_forward is set to 1 with:
sysctl net.ipv4.ip_forward

# Set-up containerd
curl -L https://github.com/containerd/containerd/releases/download/v2.0.4/containerd-2.0.4-linux-amd64.tar.gz -o /tmp/containerd-2.0.4-linux-amd64.tar.gz 
sudo tar Cxzvf /usr/local /tmp/containerd-2.0.4-linux-amd64.tar.gz

sudo mkdir -p /usr/local/lib/systemd/system
sudo touch /usr/local/lib/systemd/system/containerd.service
sudo curl -L -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

# Set-up RunC
curl -L https://github.com/opencontainers/runc/releases/download/v1.2.6/runc.amd64 -o /tmp/runc.amd64
pushd /tmp/
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
curl -L https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz -o cni-plugins-linux-amd64-v1.6.2.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz

# Generate containerd config 
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml 
# Use sed to insert `SystemdCgroup = true` inside the desired block
sudo sed -i "/\[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options\]/a\ \ \ \ \ \ \ \ SystemdCgroup = true" /etc/containerd/config.toml
# Re-align the inserted line to match the indentation of other attributes
sudo sed -i "/SystemdCgroup = true/s/^/          /" /etc/containerd/config.toml

containerd config dump | grep SystemdCgroup # check config

sudo systemctl restart containerd

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


# Bash Helpers
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

