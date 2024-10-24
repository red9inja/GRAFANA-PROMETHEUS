#!/bin/bash

# Exit the script on any error
set -e

echo "Updating system packages..."
sudo apt update -y
sudo apt install unzip wget -y

echo "Downloading Loki binary..."
wget https://github.com/grafana/loki/releases/download/v2.9.0/loki-linux-amd64.zip

echo "Extracting Loki..."
unzip loki-linux-amd64.zip

echo "Moving Loki to /usr/local/bin/..."
sudo mv loki-linux-amd64 /usr/local/bin/loki
sudo chmod +x /usr/local/bin/loki

echo "Creating Loki configuration file..."
sudo tee /etc/loki-local-config.yaml > /dev/null << EOF
auth_enabled: false
server:
  http_listen_port: 3100
ingester:
  lifecycler:
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
schema_config:
  configs:
    - from: 2022-01-01
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
storage_config:
  boltdb_shipper:
    active_index_directory: /tmp/loki/boltdb-shipper-active
    cache_location: /tmp/loki/boltdb-shipper-cache
    shared_store: filesystem
  filesystem:
    directory: /tmp/loki/chunks
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
EOF

echo "Creating systemd service file for Loki..."
sudo tee /etc/systemd/system/loki.service > /dev/null << EOF
[Unit]
Description=Loki Log Aggregation System
After=network.target

[Service]
ExecStart=/usr/local/bin/loki -config.file=/etc/loki-local-config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Starting Loki service..."
sudo systemctl start loki

echo "Enabling Loki service to start on boot..."
sudo systemctl enable loki

echo "Loki installation and setup completed successfully!"
