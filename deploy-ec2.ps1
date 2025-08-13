# EC2 Docker Deployment PowerShell Script
# Make sure you have PuTTY installed and configured

param(
    [Parameter(Mandatory=$false)]
    [string]$EC2_IP = "your-ec2-public-ip-here",
    
    [Parameter(Mandatory=$false)]
    [string]$KeyFile = "your-key.ppk",
    
    [Parameter(Mandatory=$false)]
    [string]$RemoteUser = "ec2-user",
    
    [Parameter(Mandatory=$false)]
    [string]$AppDir = "cemverse-flask-app"
)

Write-Host "🚀 Starting EC2 Docker deployment from PowerShell..." -ForegroundColor Green

# Function to check if command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check if PuTTY is available
if (-not (Test-Command "plink")) {
    Write-Host "❌ PuTTY not found. Please install PuTTY and add it to PATH" -ForegroundColor Red
    Write-Host "Download from: https://www.putty.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if key file exists
if (-not (Test-Path $KeyFile)) {
    Write-Host "❌ Key file not found: $KeyFile" -ForegroundColor Red
    Write-Host "Please update the KeyFile parameter or provide the correct path" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "  EC2 IP: $EC2_IP" -ForegroundColor White
Write-Host "  Key File: $KeyFile" -ForegroundColor White
Write-Host "  Remote User: $RemoteUser" -ForegroundColor White
Write-Host "  App Directory: $AppDir" -ForegroundColor White
Write-Host ""

# Function to execute remote command
function Invoke-RemoteCommand($Command) {
    $plinkArgs = @("-i", $KeyFile, "$RemoteUser@$EC2_IP", $Command)
    $result = & plink @plinkArgs 2>&1
    return $LASTEXITCODE, $result
}

# Test SSH connection
Write-Host "🔌 Testing SSH connection..." -ForegroundColor Yellow
$exitCode, $output = Invoke-RemoteCommand "echo 'SSH connection successful'"
if ($exitCode -ne 0) {
    Write-Host "❌ SSH connection failed. Please check:" -ForegroundColor Red
    Write-Host "  - EC2 IP address is correct" -ForegroundColor White
    Write-Host "  - Key file path is correct" -ForegroundColor White
    Write-Host "  - Security group allows SSH from your IP" -ForegroundColor White
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ SSH connection successful!" -ForegroundColor Green

# Check if Docker is running on EC2
Write-Host "🔍 Checking Docker status on EC2..." -ForegroundColor Yellow
$exitCode, $output = Invoke-RemoteCommand "sudo systemctl is-active docker"
if ($exitCode -ne 0) {
    Write-Host "⚠️ Docker not running on EC2. Starting Docker service..." -ForegroundColor Yellow
    $exitCode, $output = Invoke-RemoteCommand "sudo systemctl start docker"
    Start-Sleep -Seconds 5
}

# Check if user is in docker group
Write-Host "🔍 Checking Docker permissions..." -ForegroundColor Yellow
$exitCode, $output = Invoke-RemoteCommand "groups | grep docker"
if ($exitCode -ne 0) {
    Write-Host "⚠️ User not in docker group. Adding user to docker group..." -ForegroundColor Yellow
    $exitCode, $output = Invoke-RemoteCommand "sudo usermod -a -G docker $RemoteUser"
    Write-Host "ℹ️ Please log out and log back in to EC2 for group changes to take effect" -ForegroundColor Cyan
    Write-Host "ℹ️ Or run 'newgrp docker' on EC2" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit 1
}

# Navigate to app directory and deploy
Write-Host "🚀 Starting deployment..." -ForegroundColor Green
$deployCommand = "cd ~/$AppDir && ./deploy-ec2.sh"
$exitCode, $output = Invoke-RemoteCommand $deployCommand

# Display output
if ($output) {
    Write-Host "📤 Command output:" -ForegroundColor Gray
    $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
}

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "🌐 Your API is now available at: http://$EC2_IP`:5000" -ForegroundColor Cyan
    Write-Host "📊 Health check: http://$EC2_IP`:5000/health" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Useful commands to run on EC2:" -ForegroundColor Yellow
    Write-Host "  View logs: docker-compose logs -f" -ForegroundColor White
    Write-Host "  Stop service: docker-compose down" -ForegroundColor White
    Write-Host "  Restart service: docker-compose restart" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ Deployment failed. Please check the logs above." -ForegroundColor Red
    Write-Host "💡 Common issues:" -ForegroundColor Yellow
    Write-Host "  - Docker not accessible (run 'newgrp docker' on EC2)" -ForegroundColor White
    Write-Host "  - Port 5000 not open in security group" -ForegroundColor White
    Write-Host "  - Insufficient disk space or memory" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 Deployment script completed!" -ForegroundColor Green
Read-Host "Press Enter to exit"
