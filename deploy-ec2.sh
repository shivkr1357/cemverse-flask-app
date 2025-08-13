#!/bin/bash

# EC2 Docker Deployment Script
echo "🚀 Starting EC2 Docker deployment..."

# Function to check and fix Docker daemon issues
check_docker_daemon() {
    echo "🔍 Checking Docker daemon health..."
    
    # Check if Docker service is running
    if ! sudo systemctl is-active --quiet docker; then
        echo "⚠️ Docker service not running. Starting Docker service..."
        sudo systemctl start docker
        sleep 5
    fi
    
    # Check Docker daemon logs for errors
    echo "📋 Checking Docker daemon logs..."
    if sudo journalctl -u docker --since "2 minutes ago" | grep -q "error\|failed\|panic"; then
        echo "⚠️ Docker daemon has errors. Restarting Docker service..."
        sudo systemctl restart docker
        sleep 10
    fi
    
    # Verify Docker is responding
    if ! sudo docker info > /dev/null 2>&1; then
        echo "❌ Docker daemon not responding. Attempting recovery..."
        sudo systemctl restart docker
        sleep 10
        
        if ! sudo docker info > /dev/null 2>&1; then
            echo "❌ Docker daemon recovery failed. Please check manually:"
            echo "   sudo systemctl status docker"
            echo "   sudo journalctl -u docker -f"
            return 1
        fi
    fi
    
    echo "✅ Docker daemon is healthy"
    return 0
}

# Check Docker daemon health first
check_docker_daemon

# Check if Docker is accessible (with better error handling)
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not accessible. Trying to fix permissions..."
    
    # Try to start Docker service if not running
    if ! sudo systemctl is-active --quiet docker; then
        echo "🔄 Starting Docker service..."
        sudo systemctl start docker
        sleep 3
    fi
    
    # Check if user is in docker group
    if ! groups | grep -q docker; then
        echo "⚠️ User not in docker group. Adding user to docker group..."
        sudo usermod -a -G docker ec2-user
        echo "🔄 Please run 'newgrp docker' or log out and back in, then run this script again."
        exit 1
    fi
    
    # Try using sudo as fallback
    echo "🔄 Trying with sudo..."
    if ! sudo docker info > /dev/null 2>&1; then
        echo "❌ Docker is still not accessible. Please check Docker installation."
        exit 1
    else
        echo "✅ Docker accessible with sudo. Continuing with sudo..."
        DOCKER_CMD="sudo docker"
        COMPOSE_CMD="sudo docker-compose"
    fi
else
    DOCKER_CMD="docker"
    COMPOSE_CMD="docker-compose"
fi

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
$COMPOSE_CMD down

# Check disk space before cleanup
echo "💾 Checking available disk space..."
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 5 ]; then
    echo "⚠️ Low disk space detected: ${AVAILABLE_SPACE}G available"
    echo "🧹 Performing aggressive cleanup..."
    sudo docker system prune -a --volumes -f
    sudo yum clean all
else
    echo "✅ Sufficient disk space: ${AVAILABLE_SPACE}G available"
    # Remove old images and clean up completely
    echo "🧹 Cleaning up old images and containers..."
    $DOCKER_CMD system prune -a --volumes -f
fi

# Build the new image
echo "🔨 Building Docker image..."
if ! $COMPOSE_CMD build --no-cache; then
    echo "❌ Docker build failed. Attempting to fix Docker daemon issues..."
    
    # Restart Docker service
    echo "🔄 Restarting Docker service..."
    sudo systemctl restart docker
    sleep 10
    
    # Clean up Docker completely
    echo "🧹 Performing complete Docker cleanup..."
    sudo docker system prune -a --volumes -f
    
    # Try building again
    echo "🔨 Retrying Docker build..."
    if ! $COMPOSE_CMD build --no-cache; then
        echo "❌ Docker build still failing. Trying manual build..."
        
        # Try manual Docker build
        if ! $DOCKER_CMD build -t pdf-to-ppt-api .; then
            echo "❌ Manual build also failed. Please check Docker daemon logs:"
            echo "   sudo journalctl -u docker -f"
            echo "   sudo docker info"
            exit 1
        else
            echo "✅ Manual build successful!"
        fi
    fi
fi

# Start the services
echo "🚀 Starting services..."
if ! $COMPOSE_CMD up -d; then
    echo "❌ Failed to start services. Trying manual start..."
    
    # Try manual container start
    if [ "$COMPOSE_CMD" = "sudo docker-compose" ]; then
        sudo docker run -d --name pdf-to-ppt-api -p 5000:5000 -v $(pwd)/uploads:/app/uploads pdf-to-ppt-api
    else
        docker run -d --name pdf-to-ppt-api -p 5000:5000 -v $(pwd)/uploads:/app/uploads pdf-to-ppt-api
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Manual container start successful!"
    else
        echo "❌ Manual start also failed. Please check logs:"
        echo "   sudo docker logs pdf-to-ppt-api"
        exit 1
    fi
fi

# Wait for the service to be ready
echo "⏳ Waiting for service to be ready..."
sleep 10

# Check if the service is running
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✅ Service is running successfully!"
    echo "🌐 API is available at: http://localhost:5000"
    echo "📊 Health check: http://localhost:5000/health"
else
    echo "❌ Service failed to start. Check logs with: docker-compose logs"
    exit 1
fi

echo "📋 Useful commands:"
if [ "$COMPOSE_CMD" = "sudo docker-compose" ]; then
    echo "  View logs: sudo docker-compose logs -f"
    echo "  Stop service: sudo docker-compose down"
    echo "  Restart service: sudo docker-compose restart"
else
    echo "  View logs: docker-compose logs -f"
    echo "  Stop service: docker-compose down"
    echo "  Restart service: docker-compose restart"
fi
