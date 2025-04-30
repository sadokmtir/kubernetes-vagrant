#!/bin/bash


# Set-up kubectl
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "Done Setting up kubeconfig"

# Bash Helpers
echo 'alias k=kubectl' >> $HOME/.bashrc
echo 'complete -o default -F __start_kubectl k' >> $HOME/.bashrc


##Add k9s helper
# if [ ! -f "/tmp/k9s_linux_amd64.deb" ]; then
#     echo "Running download cache script"
#     /bin/bash /tmp/download-cache.sh
# fi
# apt install /tmp/k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

