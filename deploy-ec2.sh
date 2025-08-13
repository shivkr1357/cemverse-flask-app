#!/bin/bash

# EC2 Docker Deployment Script
echo "🚀 Starting EC2 Docker deployment..."

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

# Remove old images and clean up completely
echo "🧹 Cleaning up old images and containers..."
$DOCKER_CMD system prune -a --volumes -f

# Build the new image
echo "🔨 Building Docker image..."
$COMPOSE_CMD build --no-cache

# Start the services
echo "🚀 Starting services..."
$COMPOSE_CMD up -d

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
