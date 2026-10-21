#!/usr/bin/env bash
set -euo pipefail

# Install Docker on Ubuntu if it is not already installed.
if ! command -v docker >/dev/null 2>&1; then
    sudo apt-get update
    
# Wait for Ubuntu's background package installation to finish.
wait_count=0

while pgrep -x apt-get >/dev/null || \
      pgrep -x apt >/dev/null || \
      pgrep -x dpkg >/dev/null || \
      pgrep -x unattended-upgr >/dev/null; do

    wait_count=$((wait_count + 1))

    if [ "$wait_count" -ge 60 ]; then
        echo "Timed out waiting for Ubuntu package manager." >&2
        ps -eo pid,etime,cmd | grep -E '[a]pt|[d]pkg|[u]nattended-upgr' || true
        exit 1
    fi

    echo "Waiting for Ubuntu package manager... ($wait_count/60)"
    sleep 10
done

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

# Build the Docker image on the EC2 instance.
cd /opt/docker-nginx
sudo docker build -t custom-nginx:1.0 .

# Remove an existing container if present.
sudo docker rm -f nginx-web 2>/dev/null || true

# Publish host port 8080 to container port 80.
sudo docker run -d \
    --name nginx-web \
    --restart unless-stopped \
    -p 8080:80 \
    custom-nginx:1.0

sudo docker ps
sudo docker image ls custom-nginx

# Verify that Nginx responds locally.
curl -fsS http://localhost:8080/ >/dev/null
echo "Nginx is responding successfully on port 8080."
