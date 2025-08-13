# 🚀 EC2 Docker Deployment Guide for PDF-to-PPT API

## 📋 Prerequisites

- AWS Account with EC2 access
- Basic knowledge of AWS EC2
- SSH client (PuTTY for Windows, Terminal for Mac/Linux)

## 🏗️ Step 1: Launch EC2 Instance

### Instance Configuration:
- **AMI**: Amazon Linux 2 (recommended) or Ubuntu 20.04 LTS
- **Instance Type**: t3.small (2 vCPU, 2 GB RAM) - minimum
- **Storage**: 20 GB GP2 (minimum)
- **Security Group**: 
  - SSH (Port 22) - Your IP only
  - HTTP (Port 80) - 0.0.0.0/0 (if using load balancer)
  - Custom TCP (Port 5000) - 0.0.0.0/0 (for direct API access)

### Key Pair:
- Create or select an existing key pair
- Download the .pem file and keep it secure

## 🔧 Step 2: Connect to EC2 Instance

```bash
# For Linux/Mac
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@your-ec2-public-ip

# For Windows (using PuTTY)
# Convert .pem to .ppk using PuTTYgen
# Connect using PuTTY with your .ppk file
```

## 🐳 Step 3: Install Docker and Dependencies

Run the setup script on your EC2 instance:

```bash
# Make script executable
chmod +x setup-ec2.sh

# Run setup
./setup-ec2.sh
```

**Important**: Log out and log back in after running the setup script for Docker group changes to take effect.

## 📁 Step 4: Upload Application Files

### Option A: Using SCP (Linux/Mac)
```bash
scp -i your-key.pem -r pdf-to-ppt-flask/* ec2-user@your-ec2-public-ip:~/pdf-to-ppt-api/
```

### Option B: Using WinSCP (Windows)
- Download WinSCP
- Connect using your .ppk file
- Upload all files from `pdf-to-ppt-flask/` to `~/pdf-to-ppt-api/`

### Option C: Using Git (if your code is in a repository)
```bash
cd ~/pdf-to-ppt-api
git clone https://github.com/yourusername/your-repo.git .
```

## 🚀 Step 5: Deploy the Application

```bash
# Navigate to application directory
cd ~/pdf-to-ppt-api

# Make deployment script executable
chmod +x deploy-ec2.sh

# Deploy the application
./deploy-ec2.sh
```

## ✅ Step 6: Verify Deployment

### Check if service is running:
```bash
# Check container status
docker ps

# Check logs
docker-compose logs -f

# Test health endpoint
curl http://localhost:5000/health
```

### Test the API:
```bash
# Test file upload endpoint
curl -X POST -F "pdf_file=@test.pdf" http://localhost:5000/convert

# Test URL conversion endpoint
curl -X POST -H "Content-Type: application/json" \
  -d '{"pdf_url":"https://example.com/sample.pdf"}' \
  http://localhost:5000/convert-url
```

## 🌐 Step 7: Access from Internet

### Option A: Direct Access (Port 5000)
- Your API will be available at: `http://your-ec2-public-ip:5000`
- Make sure port 5000 is open in your security group

### Option B: Using Load Balancer (Recommended for production)
1. Create Application Load Balancer
2. Configure target group pointing to port 5000
3. Update security group to allow traffic from load balancer
4. Access via load balancer DNS name

### Option C: Using Domain Name
1. Purchase domain from Route 53 or external provider
2. Create A record pointing to your EC2 public IP
3. Use domain name instead of IP address

## 🔒 Step 8: Security Considerations

### Update Security Groups:
- Restrict SSH access to your IP only
- Consider using AWS Systems Manager Session Manager instead of SSH
- Use VPC with private subnets for production

### SSL/TLS (HTTPS):
```bash
# Install Certbot for Let's Encrypt certificates
sudo yum install -y certbot

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Configure Nginx as reverse proxy with SSL
```

## 📊 Step 9: Monitoring and Logging

### View Application Logs:
```bash
# Real-time logs
docker-compose logs -f

# Specific service logs
docker-compose logs pdf-to-ppt-api
```

### Monitor Resources:
```bash
# Check container resource usage
docker stats

# Check system resources
htop
free -h
df -h
```

## 🔄 Step 10: Updates and Maintenance

### Update Application:
```bash
# Pull latest code
git pull origin main

# Redeploy
./deploy-ec2.sh
```

### Update Docker Images:
```bash
# Pull latest base images
docker-compose pull

# Rebuild and restart
docker-compose up -d --build
```

### Backup Data:
```bash
# Backup uploads directory
tar -czf uploads-backup-$(date +%Y%m%d).tar.gz uploads/

# Backup to S3
aws s3 cp uploads-backup-$(date +%Y%m%d).tar.gz s3://your-backup-bucket/
```

## 🚨 Troubleshooting

### Common Issues:

1. **Port 5000 not accessible**:
   - Check security group rules
   - Verify firewall configuration
   - Check if container is running

2. **Docker permission denied**:
   - Log out and log back in after setup
   - Verify ec2-user is in docker group

3. **Application not starting**:
   - Check logs: `docker-compose logs`
   - Verify all files are uploaded correctly
   - Check Python dependencies

4. **Memory issues**:
   - Increase instance size to t3.medium or larger
   - Monitor memory usage with `docker stats`

### Useful Commands:
```bash
# Restart service
docker-compose restart

# Stop service
docker-compose down

# Start service
docker-compose up -d

# View container logs
docker-compose logs -f pdf-to-ppt-api

# Access container shell
docker-compose exec pdf-to-ppt-api bash

# Check service status
systemctl status pdf-to-ppt-api
```

## 💰 Cost Optimization

- **Instance Type**: Start with t3.small, scale up as needed
- **Storage**: Use GP2 for better performance/cost ratio
- **Reserved Instances**: For predictable workloads
- **Spot Instances**: For non-critical workloads (not recommended for production)

## 🎯 Next Steps

1. Set up monitoring with CloudWatch
2. Configure auto-scaling based on CPU/memory usage
3. Set up CI/CD pipeline for automated deployments
4. Implement backup strategy for uploaded files
5. Add SSL certificate for HTTPS
6. Set up domain name and DNS

---

**Need Help?** Check the logs first, then refer to Docker and AWS documentation.
