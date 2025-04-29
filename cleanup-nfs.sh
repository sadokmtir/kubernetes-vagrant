#!/bin/bash

# Cleanup shared folder
if [ -d "$(pwd)/shared/" ]; then
    rm -rf "$(pwd)/shared/"*
    echo "Cleaned up shared folder"
fi

# Cleanup NFS export
LOCK_FILE="/tmp/vagrant-nfs-cleanup.lock"
if [ ! -f "$LOCK_FILE" ]; then
	echo "Running NFS cleanup..."
	sudo sed -i '/# VAGRANT-BEGIN/,/# VAGRANT-END/d' /etc/exports
	sudo exportfs -ra
	touch "$LOCK_FILE"
else
	echo "NFS cleanup already done."
fi

# Restart NFS server
systemctl restart nfs-kernel-server

exit 0