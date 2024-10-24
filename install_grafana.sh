#!/bin/bash

# Update package lists and install prerequisites
echo "Installing prerequisites..."
sudo apt update && sudo apt install -y apt-transport-https software-properties-common wget

# Create directory for keyrings
echo "Creating keyrings directory..."
sudo mkdir -p /etc/apt/keyrings/

# Download and add Grafana GPG key
echo "Adding Grafana GPG key..."
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add Grafana repository
echo "Adding Grafana repository..."
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package lists again
echo "Updating package lists..."
sudo apt update

# Install Grafana
echo "Installing Grafana..."
sudo apt install -y grafana

# Start and enable Grafana service
echo "Starting and enabling Grafana service..."
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Confirm installation
echo "Grafana installation completed successfully!"
