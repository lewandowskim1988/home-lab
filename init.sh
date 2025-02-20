#!/usr/bin/env sh

set -euo pipefail

# Update and upgrade system
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Install rocm 6.2.1 for AMD GPU support (this version was latest working with RX 7600 XT)
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install python3-setuptools python3-wheel
sudo usermod -a -G render,video $LOGNAME # Add the current user to the render and video groups
wget https://repo.radeon.com/amdgpu-install/6.2.1/ubuntu/noble/amdgpu-install_6.2.60201-1_all.deb
sudo apt install ./amdgpu-install_6.2.60201-1_all.deb
sudo apt update
sudo apt install amdgpu-dkms rocm

# Needed after rocm install
sudo reboot

sudo tee --append /etc/ld.so.conf.d/rocm.conf <<EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF
sudo ldconfig
export PATH=$PATH:/opt/rocm-6.2.1/bin

# Install wireguard for remote access
sudo apt install wireguard

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --disable traefik

helm template argocd \
  -f values-skynet.yaml argo/argo-cd | kubectl apply -f-