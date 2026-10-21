#!/usr/bin/env bash
set -euo pipefail

# Install Docker on Ubuntu if it is not already installed.
if ! command -v docker >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    . /etc/os-release
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
fi

sudo systemctl enable --now docker

# Expect the Docker build context to be copied to /opt/docker-nginx.
cd /opt/docker-nginx

sudo docker build -t custom-nginx:1.0 .

# Replace an earlier container, if present.
sudo docker rm -f nginx-web 2>/dev/null || true

sudo docker run -d \
    --name nginx-web \
    --restart unless-stopped \
    -p 8080:80 \
    custom-nginx:1.0

sudo docker ps
sudo docker image ls custom-nginx

curl -fsS http://localhost:8080/ >/dev/null
echo "Nginx is responding successfully on port 8080."
