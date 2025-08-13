# Use Amazon Linux 2 base image
FROM amazonlinux:2

# Set working directory
WORKDIR /app

# Install system dependencies for PDF processing
RUN yum update -y && yum install -y \
    poppler-utils \
    libpng-devel \
    freetype-devel \
    libjpeg-devel \
    curl \
    python3 \
    python3-pip \
    && yum clean all

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create uploads directory
RUN mkdir -p uploads

# Expose port
EXPOSE 5000

# Set environment variables
ENV FLASK_ENV=production
ENV FLASK_APP=app.py

# Run the application
CMD ["python3", "app.py"]
