#!/bin/bash

# Extract the IP address of eth0
export CONTROL_PLANE_IP_ADDRESS=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

pushd /tmp
envsubst < kubeadm-config.tpl > kubeadm-config.yaml
sudo kubeadm init phase preflight --config kubeadm-config.yaml
sudo kubeadm init --config kubeadm-config.yaml



#Set-up calico
echo "Setting-up Calico"
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config

curl https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/calico-typha.yaml -o calico.yaml
kubectl apply -f calico.yaml
echo "Done Setting-up Calico"


# Run this on a control plane node
CLUSTER_TOKEN=$(sudo kubeadm token create)

CLUSTER_CA_CERT_HASH=$(sudo cat /etc/kubernetes/pki/ca.crt | openssl x509 -pubkey  | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //')


# Generate the kubeadm join command
KUBEADM_JOIN_CMD="sudo kubeadm join --token $CLUSTER_TOKEN $CONTROL_PLANE_IP_ADDRESS:6443 --discovery-token-ca-cert-hash sha256:$CLUSTER_CA_CERT_HASH"
# Save the command to the shared folder
echo $KUBEADM_JOIN_CMD > /vagrant/shared/kubeadm_join.sh
chmod +x /vagrant/shared/kubeadm_join.sh

echo "Kubeadm join command generated and saved to /vagrant/shared/kubeadm_join.sh"

# Use kubeconfig for other nodes
sudo cp /etc/kubernetes/admin.conf /vagrant/shared/admin.conf
