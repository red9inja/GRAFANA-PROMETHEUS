#!/bin/bash

# Update system and install necessary packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install unzip -y

# Fetch the latest Promtail version
echo "Fetching latest Promtail version..."
PROMTAIL_VERSION=$(curl -s "https://api.github.com/repos/grafana/loki/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

# Download Promtail binary
echo "Downloading Promtail v${PROMTAIL_VERSION}..."
wget https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip

# Unzip and install Promtail
echo "Installing Promtail..."
unzip promtail-linux-amd64.zip
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod a+x /usr/local/bin/promtail

# Create Promtail configuration file
echo "Creating Promtail configuration file..."
sudo bash -c 'cat > /etc/promtail-local-config.yaml << EOF
server:
  http_listen_port: 9080

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*.log
EOF'

# Create Promtail systemd service file
echo "Creating Promtail systemd service..."
sudo bash -c 'cat > /etc/systemd/system/promtail.service << EOF
[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd, start and enable Promtail service
echo "Starting and enabling Promtail service..."
sudo systemctl daemon-reload
sudo systemctl start promtail.service
sudo systemctl enable promtail.service

# Check Promtail service status
echo "Promtail installation completed. Checking service status..."
sudo systemctl status promtail.service

echo "Promtail is now installed and running!"
