# WIP

## How it works:
The Vagrantfile creates three VMs (node1, node2 and node3) using libvirt provider.
Both VMs share a two folders using NFS:
* `./shared` : used to share configuration files between nodes
* `./shared-cache`: used to share cached files for configuration (for performance reasons only)
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


### SSH into node1

`vagran ssh node1`

### Check cluster status
`kubectl get nodes`
You should see three nodes listed, with node1 as master and node2, node3 as workers.

## Set-up (WIP):

Important: NFS requires the `nfs-kernel-server` package on the host. Install it with:

```
sudo apt update
sudo apt install nfs-kernel-server
```