@echo off
setlocal enabledelayedexpansion

REM EC2 Docker Deployment Batch Script for Windows
REM Make sure you have PuTTY installed and configured

echo 🚀 Starting EC2 Docker deployment from Windows...

REM Configuration - Update these values
set EC2_IP=your-ec2-public-ip-here
set KEY_FILE=your-key.ppk
set REMOTE_USER=ec2-user
set APP_DIR=cemverse-flask-app

REM Check if PuTTY is available
where plink >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ PuTTY not found. Please install PuTTY and add it to PATH
    echo Download from: https://www.putty.org/
    pause
    exit /b 1
)

REM Check if required files exist
if not exist "%KEY_FILE%" (
    echo ❌ Key file not found: %KEY_FILE%
    echo Please update the KEY_FILE variable in this script
    pause
    exit /b 1
)

echo 📋 Configuration:
echo   EC2 IP: %EC2_IP%
echo   Key File: %KEY_FILE%
echo   Remote User: %REMOTE_USER%
echo   App Directory: %APP_DIR%
echo.

REM Test SSH connection
echo 🔌 Testing SSH connection...
plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "echo 'SSH connection successful'"
if %errorlevel% neq 0 (
    echo ❌ SSH connection failed. Please check:
    echo   - EC2 IP address is correct
    echo   - Key file path is correct
    echo   - Security group allows SSH from your IP
    pause
    exit /b 1
)

echo ✅ SSH connection successful!

REM Check if Docker is running on EC2
echo 🔍 Checking Docker status on EC2...
plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "sudo systemctl is-active docker"
if %errorlevel% neq 0 (
    echo ⚠️ Docker not running on EC2. Starting Docker service...
    plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "sudo systemctl start docker"
    timeout /t 5 /nobreak >nul
)

REM Check if user is in docker group
echo 🔍 Checking Docker permissions...
plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "groups | grep docker"
if %errorlevel% neq 0 (
    echo ⚠️ User not in docker group. Adding user to docker group...
    plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "sudo usermod -a -G docker %REMOTE_USER%"
    echo ℹ️ Please log out and log back in to EC2 for group changes to take effect
    echo ℹ️ Or run 'newgrp docker' on EC2
    pause
    exit /b 1
)

REM Navigate to app directory and deploy
echo 🚀 Starting deployment...
plink -i "%KEY_FILE%" %REMOTE_USER%@%EC2_IP% "cd ~/%APP_DIR% && ./deploy-ec2.sh"

if %errorlevel% equ 0 (
    echo.
    echo ✅ Deployment completed successfully!
    echo 🌐 Your API is now available at: http://%EC2_IP%:5000
    echo 📊 Health check: http://%EC2_IP%:5000/health
    echo.
    echo 📋 Useful commands to run on EC2:
    echo   View logs: docker-compose logs -f
    echo   Stop service: docker-compose down
    echo   Restart service: docker-compose restart
) else (
    echo.
    echo ❌ Deployment failed. Please check the logs above.
    echo 💡 Common issues:
    echo   - Docker not accessible (run 'newgrp docker' on EC2)
    echo   - Port 5000 not open in security group
    echo   - Insufficient disk space or memory
)

echo.
echo 🎯 Deployment script completed!
pause
