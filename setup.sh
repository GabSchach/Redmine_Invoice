#!/bin/bash

# Setup script for Redmine 6 in GitHub Codespaces

echo "Setting up Redmine 6..."

# Create necessary directories
mkdir -p config

# Copy configuration files
echo "Creating configuration files..."
cat > config/database.yml << 'EOL'
production:
  adapter: postgresql
  database: redmine
  host: postgres
  username: redmine
  password: redmine_password
  port: 5432
  encoding: utf8

development:
  adapter: postgresql
  database: redmine
  host: postgres
  username: redmine
  password: redmine_password
  port: 5432
  encoding: utf8

test:
  adapter: postgresql
  database: redmine_test
  host: postgres
  username: redmine
  password: redmine_password
  port: 5432
  encoding: utf8
EOL

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

# Build and start containers
echo "Starting Docker Compose services..."
docker-compose build --no-cache

# Check if build was successful
if [ $? -ne 0 ]; then
  echo "Error: Docker build failed. Please check the error messages above."
  exit 1
fi

echo "Starting containers..."
docker-compose up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 30

# Check if redmine container is running
if ! docker-compose ps | grep redmine | grep "Up"; then
  echo "Error: Redmine container is not running. Check the logs with: docker-compose logs redmine"
  exit 1
fi

# Set up Redmine database
echo "Setting up Redmine database..."
docker-compose exec -T redmine bundle exec rake db:migrate RAILS_ENV=production

# Load default data
echo "Loading default data (English)..."
docker-compose exec -T redmine bundle exec rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=en

echo "Setup complete!"
echo "You can now access Redmine at: http://localhost:3000"
echo "Default login: admin / admin"
echo "Remember to change the default password after first login."