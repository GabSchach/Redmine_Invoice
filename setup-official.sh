#!/bin/bash

# Setup script for Redmine using the official Docker image

echo "Setting up Redmine using official Docker image..."

# Create necessary directories
mkdir -p config

# Copy configuration files
echo "Creating configuration files..."
cat > config/configuration.yml << 'EOL'
default:
  # Outgoing email settings
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: "smtp.example.com"
      port: 25
      domain: "example.com"
      authentication: :login
      user_name: "redmine@example.com"
      password: "redmine"
      
  # Attachment storage settings 
  attachments_storage_path: /usr/src/redmine/files
  
  # Authentication modes
  # Available modes: :ldap, :cas, none
  authentication_mode: none
  
production:
  # Use the default settings

development:
  # Use the default settings

test:
  # Use the default settings
EOL

echo "Using official docker-compose.yml..."
cat > docker-compose.yml << 'EOL'
# Docker Compose configuration for Redmine using official image

services:
  redmine:
    image: redmine:5
    ports:
      - "3000:3000"
    volumes:
      - redmine_files:/usr/src/redmine/files
      - redmine_plugins:/usr/src/redmine/plugins
      - ./config/configuration.yml:/usr/src/redmine/config/configuration.yml
    environment:
      - REDMINE_DB_POSTGRES=postgres
      - REDMINE_DB_DATABASE=redmine
      - REDMINE_DB_USERNAME=redmine
      - REDMINE_DB_PASSWORD=redmine_password
      - REDMINE_DB_PORT=5432
    depends_on:
      - postgres
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=redmine
      - POSTGRES_PASSWORD=redmine_password
      - POSTGRES_DB=redmine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  redmine_files:
  redmine_plugins:
  postgres_data:
EOL

# Start containers
echo "Starting Docker Compose services..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 20

# Check if redmine container is running
if ! docker-compose ps | grep redmine | grep "Up"; then
  echo "Error: Redmine container is not running. Check the logs with: docker-compose logs redmine"
  exit 1
fi

echo "Setup complete!"
echo "You can now access Redmine at: http://localhost:3000"
echo "Default login: admin / admin"
echo "Remember to change the default password after first login."