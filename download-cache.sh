#!/bin/bash

CACHE_DIR="/vagrant/cache"
mkdir -p "$CACHE_DIR"

# Function to download file if not in cache
download_cached() {
    local url=$1
    local output=$2
    local filename=$(basename "$output")
    
    if [ -f "$CACHE_DIR/$filename" ]; then
        echo "Using cached $filename"
        cp "$CACHE_DIR/$filename" "$output"
    else
        echo "Downloading $filename"
        curl -L "$url" -o "$output"
        cp "$output" "$CACHE_DIR/$filename"
    fi
}

# Download containerd with caching
download_cached \
    "https://github.com/containerd/containerd/releases/download/v2.0.4/containerd-2.0.4-linux-amd64.tar.gz" \
    "/tmp/containerd-2.0.4-linux-amd64.tar.gz"

# Download runc with caching
download_cached \
    "https://github.com/opencontainers/runc/releases/download/v1.2.6/runc.amd64" \
    "/tmp/runc.amd64"

# Download CNI plugins with caching
download_cached \
    "https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz" \
    "/tmp/cni-plugins-linux-amd64-v1.6.2.tgz"

##k9s
# download_cached \
#     "https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb" \
#     "/tmp/k9s_linux_amd64.deb"

    