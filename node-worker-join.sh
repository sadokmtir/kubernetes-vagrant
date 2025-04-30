#!/bin/bash

echo "Setting up Kubernetes Worker Node on Node 2..."

# Wait for the kubeadm join command to be ready
while [ ! -f /vagrant/shared/kubeadm_join.sh ]; do
echo "Waiting for kubeadm join command from Node 1..."
sleep 5
done

# Execute the kubeadm join command
bash /vagrant/shared/kubeadm_join.sh
echo "Worker Node successfully joined the cluster!"

mkdir -p ~/.kube

# Wait for the kubeadm join command to be ready
while [ ! -f /vagrant/shared/admin.conf ]; do
echo "Waiting for kube config from Node 1..."
sleep 5
done

sudo cp /vagrant/shared/admin.conf /etc/kubernetes/admin.conf
