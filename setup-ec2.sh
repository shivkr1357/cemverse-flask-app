#!/bin/bash

# EC2 Setup Script - Run this on your EC2 instance
echo "🔧 Setting up EC2 instance for PDF-to-PPT API..."

# Update system packages
echo "📦 Updating system packages..."
sudo yum update -y

# Install Docker
echo "🐳 Installing Docker..."
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
echo "📋 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install additional tools
echo "🛠️ Installing additional tools..."
sudo yum install -y git curl wget

# Create application directory
echo "📁 Creating application directory..."
mkdir -p ~/pdf-to-ppt-api
cd ~/pdf-to-ppt-api

# Set up firewall (if using ufw)
echo "🔥 Configuring firewall..."
sudo yum install -y firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Create systemd service for auto-start
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/pdf-to-ppt-api.service > /dev/null <<EOF
[Unit]
Description=PDF to PPT API Docker Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/pdf-to-ppt-api
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl enable pdf-to-ppt-api.service

echo "✅ EC2 setup completed!"
echo "🔄 Please log out and log back in for Docker group changes to take effect"
echo "📋 Next steps:"
echo "  1. Log out and log back in"
echo "  2. Upload your application files to ~/pdf-to-ppt-api/"
echo "  3. Run: ./deploy-ec2.sh"
