#!/bin/bash

# EC2 Docker Deployment Script
echo "🚀 Starting EC2 Docker deployment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Stop and remove existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove old images
echo "🧹 Cleaning up old images..."
docker image prune -f

# Build the new image
echo "🔨 Building Docker image..."
docker-compose build --no-cache

# Start the services
echo "🚀 Starting services..."
docker-compose up -d

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
echo "  View logs: docker-compose logs -f"
echo "  Stop service: docker-compose down"
echo "  Restart service: docker-compose restart"
