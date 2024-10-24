#!/bin/bash

# Update the system and install unzip
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install unzip -y

# Fetch the latest Loki version
echo "Fetching latest Loki version..."
LOKI_VERSION=$(curl -s "https://api.github.com/repos/grafana/loki/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

# Download Loki binary
echo "Downloading Loki v${LOKI_VERSION}..."
wget https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip

# Unzip the Loki binary and move it to /usr/local/bin
echo "Installing Loki..."
unzip loki-linux-amd64.zip
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chmod a+x /usr/local/bin/loki

# Download the Loki configuration file
echo "Downloading Loki configuration file..."
sudo wget -O /etc/loki-local-config.yaml https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml

# Create the Loki systemd service file
echo "Creating Loki systemd service..."
sudo bash -c 'cat > /etc/systemd/system/loki.service << EOF
[Unit]
Description=Loki log aggregation system
After=network.target

[Service]
ExecStart=/usr/local/bin/loki -config.file=/etc/loki-local-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, start and enable the Loki service
echo "Starting and enabling Loki service..."
sudo systemctl daemon-reload
sudo systemctl start loki.service
sudo systemctl enable loki.service

# Check Loki service status
echo "Loki installation completed. Checking service status..."
sudo systemctl status loki.service

echo "Loki is now installed and running!"
