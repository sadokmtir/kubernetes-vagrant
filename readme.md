
# WIP


## How it works:
The Vagrantfile creates three VMs (node1, node2 and node 2) using libvirt provider.
Both VMs share a common folder using NFS.
Node1:
Sets up Kubernetes dependencies
Initializes the cluster
Generates the join command and saves it to the shared folder
Node2, Node3:
Sets up Kubernetes dependencies
Waits for the join command to be available in the shared folder
Executes the join command to join the cluster
Verification:
After both nodes are up, you can verify the setup:

bash
# SSH into node1
vagrant ssh node1

# Check cluster status
kubectl get nodes
You should see both nodes listed, with node1 as master and node2 as worker.

## Set-up:

Important: NFS requires the nfs-kernel-server package on the host. Install it with:

bash
sudo apt update
sudo apt install nfs-kernel-server


Ensure the ./shared folder exists on the host. If it doesn’t, create it:

bash
mkdir -p ./shared
