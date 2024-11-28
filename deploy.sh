#!/bin/bash

# Script to deploy TofuPilot on a self-hosted server
# This script installs necessary dependencies, configures SSL certificates,
# sets up Nginx as a reverse proxy, and runs the TofuPilot application using Docker Compose.

#----------------------------#
#       Configuration        #
#----------------------------#

# Main domain name for TofuPilot (e.g., tofupilot.example.com)
DOMAIN_NAME="" # e.g tofupilot.your-domain.com, please DO NOT include the protocol scheme (`https://`)

# Email associated with your domain name (used for SSL certificates)
EMAIL="" # THE_EMAIL_ASSOCIATED_WITH_YOUR_DOMAIN_NAME

# Storage domain name (used for object storage service)
STORAGE_DOMAIN_NAME="storage.$DOMAIN_NAME" # Default value; replace if desired, please DO NOT include the protocol scheme (`https://`)

#----------------------------#
#   Authentication Config    #
#----------------------------#

# At least one of these authentication methods must be configured

# Google OAuth Credentials
GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""

# Azure AD Credentials
AZURE_AD_CLIENT_ID=""
AZURE_AD_CLIENT_SECRET=""
AZURE_AD_TENANT_ID=""

# SMTP Credentials (for email authentication)
SMTP_HOST=""
SMTP_PASSWORD=""
SMTP_PORT="587"
SMTP_USER=""
EMAIL_FROM="" # Example: tofupilot-auth@your-domain

#----------------------------#
#    Preliminary Checks      #
#----------------------------#

# Verify that DOMAIN_NAME and EMAIL are set
if [ -z "$DOMAIN_NAME" ]; then
  echo "Error: DOMAIN_NAME is not set. Please set your domain name in the script."
  exit 1
fi

if [ -z "$EMAIL" ]; then
  echo "Error: EMAIL is not set. Please set your email address in the script."
  exit 1
fi

# Verify that at least one authentication provider is configured
if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
  if [ -z "$AZURE_AD_CLIENT_ID" ] || [ -z "$AZURE_AD_CLIENT_SECRET" ] || [ -z "$AZURE_AD_TENANT_ID" ]; then
    if [ -z "$SMTP_HOST" ] || [ -z "$SMTP_PASSWORD" ] || [ -z "$SMTP_PORT" ] || [ -z "$SMTP_USER" ] || [ -z "$EMAIL_FROM" ]; then
      echo "Error: Neither Google OAuth, Azure AD, nor SMTP credentials are fully configured. Authentication will not be possible."
      exit 1
    fi
  fi
fi

echo "Configuration is valid."

#----------------------------#
#        Environment         #
#----------------------------#

# EdgeDB Configuration
EDGEDB_USER=edgedb
EDGEDB_PASSWORD=$(openssl rand -base64 12)  # Generate a random 12-character password
EDGEDB_DATABASE=edgedb
EDGEDB_HOST=edgedb
EDGEDB_PORT=5656
EDGEDB_CLIENT_TLS_SECURITY=insecure

# AWS S3 Compatible Storage Configuration
AWS_ACCESS_KEY_ID=TOFUPILOT
AWS_SECRET_ACCESS_KEY=$(openssl rand -base64 12)  # Generate a random 12-character password
STORAGE_EXTERNAL_ENDPOINT_URL=https://$STORAGE_DOMAIN_NAME
STORAGE_INTERNAL_ENDPOINT_URL=http://minio:9000
BUCKET_NAME=tofupilot
REGION="us-east-1"

# NextAuth Configuration
NEXTAUTH_SECRET=$(openssl rand -base64 12)  # Generate a random 12-character password
NEXTAUTH_URL=https://$DOMAIN_NAME

# Script Variables
REPO_URL="https://github.com/tofupilot/self-hosting.git"
# Installation directory for TofuPilot
TOFUPILOT_DIR=~/tofupilot # Folder where TofuPilot will be installed; If you wish to update it, please update it in the ./update.sh script too.

#----------------------------#
#      System Updates        #
#----------------------------#

echo "Updating package list and upgrading existing packages..."
sudo apt update && sudo apt upgrade -y

#----------------------------#
#     Clone TofuPilot Repo   #
#----------------------------#

# Clone the Git repository or pull the latest changes if it already exists
if [ -d "$TOFUPILOT_DIR" ]; then
  echo "Directory $TOFUPILOT_DIR already exists. Pulling latest changes..."
  cd $TOFUPILOT_DIR && git pull
else
  echo "Cloning repository from $REPO_URL..."
  git clone $REPO_URL $TOFUPILOT_DIR
  cd $TOFUPILOT_DIR
fi

#----------------------------#
#       Configure .env       #
#----------------------------#

# Back up the existing .env file before overriding it
if [ -f "$TOFUPILOT_DIR/.env" ]; then
  echo ".env file already exists. Backing up to .env.bak"
  mv "$TOFUPILOT_DIR/.env" "$TOFUPILOT_DIR/.env.bak"
fi

# Create the .env file inside the app directory
echo "Creating .env configuration file..."

cat <<EOL > "$TOFUPILOT_DIR/.env"
# Domain name configuration
DOMAIN_NAME=$DOMAIN_NAME

# EdgeDB Configuration
EDGEDB_USER=$EDGEDB_USER
EDGEDB_PASSWORD=$EDGEDB_PASSWORD
EDGEDB_DATABASE=$EDGEDB_DATABASE
EDGEDB_HOST=$EDGEDB_HOST
EDGEDB_PORT=$EDGEDB_PORT
EDGEDB_CLIENT_TLS_SECURITY=$EDGEDB_CLIENT_TLS_SECURITY

# Open-source AWS S3 Compatible Storage Configuration
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
STORAGE_EXTERNAL_ENDPOINT_URL=$STORAGE_EXTERNAL_ENDPOINT_URL
STORAGE_INTERNAL_ENDPOINT_URL=$STORAGE_INTERNAL_ENDPOINT_URL
BUCKET_NAME=$BUCKET_NAME
REGION=$REGION

# NextAuth Configuration
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
NEXTAUTH_URL=$NEXTAUTH_URL

# Authentication Configuration
# Google OAuth
GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET

# Azure AD
AZURE_AD_CLIENT_ID=$AZURE_AD_CLIENT_ID
AZURE_AD_CLIENT_SECRET=$AZURE_AD_CLIENT_SECRET
AZURE_AD_TENANT_ID=$AZURE_AD_TENANT_ID

# SMTP Configuration
SMTP_HOST=$SMTP_HOST
SMTP_PASSWORD=$SMTP_PASSWORD
SMTP_PORT=$SMTP_PORT
SMTP_USER=$SMTP_USER
EMAIL_FROM=$EMAIL_FROM
EOL

echo ".env file created successfully."

#----------------------------#
#       Install Nginx        #
#----------------------------#

echo "Installing Nginx..."
sudo apt install nginx -y

# Remove old Nginx config if it exists
echo "Removing old Nginx configuration (if any)..."
sudo rm -f /etc/nginx/sites-available/tofupilot
sudo rm -f /etc/nginx/sites-enabled/tofupilot

#----------------------------#
#    Obtain SSL Certificates #
#----------------------------#

# Stop Nginx temporarily to allow Certbot to run in standalone mode
echo "Stopping Nginx temporarily for SSL certificate generation..."
sudo systemctl stop nginx

# Install Certbot
echo "Installing Certbot..."
sudo apt install certbot -y

# Obtain SSL certificates using Certbot standalone mode
echo "Obtaining SSL certificates..."
sudo certbot certonly --standalone -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL
sudo certbot certonly --standalone -d $STORAGE_DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL

# Ensure SSL files exist or generate them
if [ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]; then
  echo "Downloading options-ssl-nginx.conf..."
  sudo wget https://raw.githubusercontent.com/certbot/certbot/main/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /etc/letsencrypt/
fi

if [ ! -f /etc/letsencrypt/ssl-dhparams.pem ]; then
  echo "Generating Diffie-Hellman parameters..."
  sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
fi

#----------------------------#
#     Configure Nginx        #
#----------------------------#

echo "Configuring Nginx..."

# Create Nginx config with reverse proxy, SSL support, rate limiting, and streaming support
sudo bash -c "cat > /etc/nginx/sites-available/tofupilot" <<EOL
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    listen 80;
    server_name $DOMAIN_NAME;

    # Redirect all HTTP requests to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Enable rate limiting
    limit_req zone=mylimit burst=20 nodelay;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;

        # Disable buffering for streaming support
        proxy_buffering off;
        proxy_set_header X-Accel-Buffering no;
    }
}

server {
    listen 80;
    server_name $STORAGE_DOMAIN_NAME;

    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $STORAGE_DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$STORAGE_DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$STORAGE_DOMAIN_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Proxy to storage service
    location / {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;

        # Disable buffering for streaming support
        proxy_buffering off;
        proxy_set_header X-Accel-Buffering no;
    }
}
EOL

# Create symbolic link to enable the site
echo "Enabling Nginx site configuration..."
sudo ln -s /etc/nginx/sites-available/tofupilot /etc/nginx/sites-enabled/tofupilot

# Restart Nginx to apply the new configuration
echo "Restarting Nginx..."
sudo systemctl restart nginx

#----------------------------#
#     Run Docker Compose     #
#----------------------------#

echo "Building and starting Docker containers..."

# Build and run the Docker containers from the app directory
cd $TOFUPILOT_DIR
docker-compose up -d

# Check if Docker Compose started correctly
if ! sudo docker-compose ps | grep "Up"; then
  echo "Docker containers failed to start. Check logs with 'docker-compose logs'."
  exit 1
fi

#----------------------------#
#      Deployment Done       #
#----------------------------#

echo "Deployment complete. Your TofuPilot app and database are now running."
echo "TofuPilot is available at https://$DOMAIN_NAME"