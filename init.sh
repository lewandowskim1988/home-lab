#!/usr/bin/env bash
set -euo pipefail

# Update and upgrade system
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.2.1/install/prerequisites.html
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install python3-setuptools python3-wheel

# https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.2.1/install/native-install/ubuntu.html
sudo mkdir --parents --mode=0755 /etc/apt/keyrings
wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.2.1/ubuntu noble main" \
  | sudo tee /etc/apt/sources.list.d/amdgpu.list
sudo apt update
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.2.1 noble main" \
  | sudo tee --append /etc/apt/sources.list.d/rocm.list
echo -e 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' \
  | sudo tee /etc/apt/preferences.d/rocm-pin-600
sudo apt update

sudo apt install -y amdgpu-dkms
sudo reboot

sudo apt install -y rocm

# https://rocm.docs.amd.com/projects/install-on-linux/en/docs-6.2.1/install/post-install.html
sudo tee --append /etc/ld.so.conf.d/rocm.conf <<EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF
sudo ldconfig

# Install wireguard for remote access
sudo apt install -y wireguard cron iptables

systemctl start wg-quick@wg0.service
systemctl enable wg-quick@wg0.service

sudo sysctl -w net.ipv4.ip_forward=1

sudo iptables -t nat -A POSTROUTING -s 10.66.66.0/24 -o enp112s0 -j MASQUERADE

# Prepare disk for OpenEBS
sudo pvcreate /dev/nvme0n1p3
sudo vgcreate openebs /dev/nvme0n1p3

sudo sysctl -w fs.inotify.max_user_watches=2099999999
sudo sysctl -w fs.inotify.max_user_instances=2099999999
sudo sysctl -w fs.inotify.max_queued_events=2099999999

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server" sh -s - --disable traefik --disable local-storage

helm template argocd \
  -f argocd/values-skynet.yaml argo/argo-cd | kubectl apply -f-
