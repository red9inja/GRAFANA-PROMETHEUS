#!/bin/bash

# Exit the script on any error
set -e

echo "Updating system packages..."
sudo apt update -y
sudo apt install unzip wget -y

echo "Downloading Promtail binary..."
wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip

echo "Extracting Promtail..."
unzip promtail-linux-amd64.zip

echo "Moving Promtail to /usr/local/bin/..."
sudo mv promtail-linux-amd64 /usr/local/bin/promtail
sudo chmod +x /usr/local/bin/promtail

echo "Creating Promtail configuration file..."
sudo tee /etc/promtail-config.yaml > /dev/null << EOF
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*log
EOF

echo "Creating systemd service file for Promtail..."
sudo tee /etc/systemd/system/promtail.service > /dev/null << EOF
[Unit]
Description=Promtail Log Collector
After=network.target

[Service]
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Starting Promtail service..."
sudo systemctl start promtail

echo "Enabling Promtail service to start on boot..."
sudo systemctl enable promtail

echo "Promtail installation and setup completed successfully!"
