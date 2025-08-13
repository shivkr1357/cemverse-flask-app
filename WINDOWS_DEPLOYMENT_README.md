# 🪟 Windows Deployment Guide for EC2

This guide explains how to deploy your Flask API to EC2 from Windows using the provided batch and PowerShell scripts.

## 📋 Prerequisites

### 1. **PuTTY Installation**

- Download and install PuTTY from [https://www.putty.org/](https://www.putty.org/)
- Make sure `plink.exe` is added to your system PATH
- Verify installation by opening Command Prompt and typing `plink -V`

### 2. **Key File Conversion**

- Convert your AWS `.pem` key to PuTTY `.ppk` format:
  1. Open **PuTTYgen**
  2. Click **Load** and select your `.pem` file
  3. Click **Save private key** and save as `.ppk` file
  4. Keep this `.ppk` file secure

### 3. **EC2 Instance Setup**

- EC2 instance must be running
- Security group must allow SSH (port 22) from your IP
- Security group must allow HTTP (port 5000) for API access

## 🚀 Quick Start

### **Option 1: Using Batch File (deploy-ec2.bat)**

1. **Edit the batch file:**

   ```batch
   set EC2_IP=your-actual-ec2-ip
   set KEY_FILE=path\to\your\key.ppk
   set APP_DIR=cemverse-flask-app
   ```

2. **Run the script:**
   ```batch
   deploy-ec2.bat
   ```

### **Option 2: Using PowerShell (deploy-ec2.ps1)**

1. **Run with parameters:**

   ```powershell
   .\deploy-ec2.ps1 -EC2_IP "your-ec2-ip" -KeyFile "path\to\key.ppk"
   ```

2. **Or edit the script defaults and run:**
   ```powershell
   .\deploy-ec2.ps1
   ```

### **Option 3: Using Configuration File**

1. **Edit `deploy-config.ini`:**

   ```ini
   [EC2_Config]
   EC2_IP=your-ec2-ip
   KEY_FILE=path\to\key.ppk
   APP_DIR=cemverse-flask-app
   ```

2. **Run the script** (it will read the config file)

## 🔧 Configuration

### **Required Settings:**

| Setting       | Description                 | Example              |
| ------------- | --------------------------- | -------------------- |
| `EC2_IP`      | Your EC2 instance public IP | `52.23.45.67`        |
| `KEY_FILE`    | Path to your .ppk key file  | `C:\keys\my-key.ppk` |
| `REMOTE_USER` | EC2 username                | `ec2-user`           |
| `APP_DIR`     | Directory name on EC2       | `cemverse-flask-app` |

### **Example Configuration:**

```ini
[EC2_Config]
EC2_IP=52.23.45.67
KEY_FILE=C:\Users\YourName\Desktop\my-key.ppk
REMOTE_USER=ec2-user
APP_DIR=cemverse-flask-app
```

## 📁 File Structure

```
pdf-to-ppt-flask/
├── deploy-ec2.bat          # Windows batch deployment script
├── deploy-ec2.ps1          # PowerShell deployment script
├── deploy-config.ini       # Configuration file
├── deploy-ec2.sh           # Linux/EC2 deployment script
├── docker-compose.yml      # Docker configuration
├── Dockerfile              # Docker image definition
└── app.py                  # Your Flask application
```

## 🎯 What the Scripts Do

### **Pre-deployment Checks:**

1. ✅ Verify PuTTY is installed
2. ✅ Check key file exists
3. ✅ Test SSH connection to EC2
4. ✅ Verify Docker is running on EC2
5. ✅ Check Docker permissions

### **Deployment Process:**

1. 🚀 Connect to EC2 via SSH
2. 🔍 Navigate to application directory
3. 🐳 Run Docker deployment commands
4. ✅ Verify deployment success
5. 📊 Display API endpoints

## 🚨 Troubleshooting

### **Common Issues:**

#### **1. PuTTY Not Found**

```
❌ PuTTY not found. Please install PuTTY and add it to PATH
```

**Solution:** Install PuTTY and ensure it's in your system PATH

#### **2. Key File Not Found**

```
❌ Key file not found: your-key.ppk
```

**Solution:** Update the `KEY_FILE` path in the script or config file

#### **3. SSH Connection Failed**

```
❌ SSH connection failed
```

**Solutions:**

- Check EC2 IP address is correct
- Verify key file path is correct
- Ensure security group allows SSH from your IP
- Check if EC2 instance is running

#### **4. Docker Permission Issues**

```
⚠️ User not in docker group
```

**Solution:** The script will automatically add the user to the docker group

### **Manual Troubleshooting:**

#### **Test SSH Connection:**

```batch
plink -i "your-key.ppk" ec2-user@your-ec2-ip "echo 'test'"
```

#### **Check PuTTY Version:**

```batch
plink -V
```

#### **Verify Key File:**

- Ensure the `.ppk` file is not corrupted
- Try opening it in PuTTYgen to verify

## 🔒 Security Notes

1. **Keep your `.ppk` file secure** - don't share or commit to version control
2. **Use specific IP ranges** in security groups, not `0.0.0.0/0`
3. **Regularly rotate your AWS keys**
4. **Monitor EC2 access logs**

## 📊 Post-Deployment

After successful deployment, your API will be available at:

- **API Base URL:** `http://your-ec2-ip:5000`
- **Health Check:** `http://your-ec2-ip:5000/health`
- **Upload Form:** `http://your-ec2-ip:5000/upload`

## 🎯 Next Steps

1. **Test your API endpoints**
2. **Set up monitoring and logging**
3. **Configure SSL/HTTPS**
4. **Set up domain name**
5. **Implement backup strategy**

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Check EC2 instance logs
4. Ensure security group configurations are correct

---

**Happy Deploying! 🚀**
