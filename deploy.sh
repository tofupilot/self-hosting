#!/usr/bin/env bash

# Script to deploy TofuPilot on a self-hosted server
# This script installs necessary dependencies, configures SSL certificates,
# sets up Nginx as a reverse proxy, and runs the TofuPilot application using Docker Compose.

#----------------------------#
#         Functions          #
#----------------------------#

CONFIG_FILE="./config.env"

prompt_for_value() {
  local var_name="$1"
  local prompt_message="$2"
  local default_value="$3"

  # Checking if config file exists and if value already recorded
  if [ -f "$CONFIG_FILE" ]; then
    local existing_value
    existing_value=$(grep "^${var_name}=" "$CONFIG_FILE" | cut -d= -f2-)
    if [ -n "$existing_value" ]; then
      echo "$existing_value" # Returning existing value
      return
    fi
  fi

  # Prompting user if value not found
  if [ -n "$default_value" ]; then
    read -r -p "$prompt_message [$default_value]: " user_input
  else
    read -r -p "$prompt_message: " user_input
  fi

  if [ -z "$user_input" ]; then
    user_input="$default_value"
  fi

  # Saving value to config file
  echo "${var_name}=${user_input}" >> "$CONFIG_FILE"
  echo "$user_input"
}

create_env_file() {
  # Backing up existing .env if exists
  if [ -f "./.env" ]; then
    echo ".env file already exists. Backing up to .env.bak"
    mv "./.env" "./.env.bak"
  fi

  echo "Creating .env configuration file..."

  cat <<EOL > "./.env"
# Domain name configuration
NEXT_PUBLIC_DOMAIN_NAME=$DOMAIN_NAME

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
}

install_nginx() {
  echo "Installing Nginx..."
  sudo apt install nginx -y

  echo "Removing old Nginx configuration (if any)..."
  sudo rm -f /etc/nginx/sites-available/tofupilot
  sudo rm -f /etc/nginx/sites-enabled/tofupilot
}

obtain_ssl_certificates() {
  echo "Stopping Nginx temporarily for SSL certificate generation..."
  sudo systemctl stop nginx

  echo "Installing Certbot..."
  sudo apt install certbot -y

  echo "Obtaining SSL certificates..."
  sudo certbot certonly --standalone -d "$DOMAIN_NAME" --non-interactive --agree-tos -m "$EMAIL"
  sudo certbot certonly --standalone -d "$STORAGE_DOMAIN_NAME" --non-interactive --agree-tos -m "$EMAIL"

  if [ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]; then
    echo "Downloading options-ssl-nginx.conf..."
    sudo wget https://raw.githubusercontent.com/certbot/certbot/main/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /etc/letsencrypt/
  fi

  if [ ! -f /etc/letsencrypt/ssl-dhparams.pem ]; then
    echo "Generating Diffie-Hellman parameters..."
    sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
  fi
}

configure_nginx() {
  echo "Configuring Nginx..."

  sudo bash -c "cat > /etc/nginx/sites-available/tofupilot" <<EOL
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    listen 80;
    server_name $DOMAIN_NAME;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    limit_req zone=mylimit burst=20 nodelay;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_buffering off;
        proxy_set_header X-Accel-Buffering no;
    }
}

server {
    listen 80;
    server_name $STORAGE_DOMAIN_NAME;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $STORAGE_DOMAIN_NAME;

    ssl_certificate /etc/letsencrypt/live/$STORAGE_DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$STORAGE_DOMAIN_NAME/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_buffering off;
        proxy_set_header X-Accel-Buffering no;
    }
}
EOL

  echo "Enabling Nginx site configuration..."
  sudo ln -s /etc/nginx/sites-available/tofupilot /etc/nginx/sites-enabled/tofupilot

  echo "Restarting Nginx..."
  sudo systemctl restart nginx
}

run_docker_compose() {
  echo "Building and starting Docker containers..."
  docker-compose up -d

  if ! sudo docker-compose ps | grep "Up"; then
    echo "Docker containers failed to start. Check logs with 'docker-compose logs'."
    exit 1
  fi
}

#----------------------------#
#         Main Script        #
#----------------------------#

# Create config file if does not exist
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
fi

# Prompting user for necessary environment variables
DOMAIN_NAME=$(prompt_for_value "DOMAIN_NAME" "Hostname for your TofuPilot?" "tofupilot.example.com")
STORAGE_DOMAIN_NAME=$(prompt_for_value "STORAGE_DOMAIN_NAME" "Hostname for your TofuPilot storage?" "storage.$DOMAIN_NAME")
EMAIL=$(prompt_for_value "EMAIL" "Email address associated with your domain (for SSL)?" "me@example.com")

GOOGLE_CLIENT_ID=$(prompt_for_value "GOOGLE_CLIENT_ID" "Google Client ID? (leave blank if not using Google auth)" "")
GOOGLE_CLIENT_SECRET=$(prompt_for_value "GOOGLE_CLIENT_SECRET" "Google Client Secret? (leave blank if not using Google auth)" "")

AZURE_AD_CLIENT_ID=$(prompt_for_value "AZURE_AD_CLIENT_ID" "Azure AD Client ID? (leave blank if not using Azure AD auth)" "")
AZURE_AD_CLIENT_SECRET=$(prompt_for_value "AZURE_AD_CLIENT_SECRET" "Azure AD Client Secret? (leave blank if not using Azure AD auth)" "")
AZURE_AD_TENANT_ID=$(prompt_for_value "AZURE_AD_TENANT_ID" "Azure AD Tenant ID? (leave blank if not using Azure AD auth)" "")

SMTP_HOST=$(prompt_for_value "SMTP_HOST" "SMTP server address? (leave blank if not using Email auth)" "")
SMTP_PORT=$(prompt_for_value "SMTP_PORT" "SMTP port? (leave blank if not using Email auth)" "")
SMTP_USER=$(prompt_for_value "SMTP_USER" "SMTP user name? (leave blank if not using Email auth)" "")
SMTP_PASSWORD=$(prompt_for_value "SMTP_PASSWORD" "SMTP password? (leave blank if not using Email auth)" "")

EMAIL_FROM=$(prompt_for_value "EMAIL_FROM" "Email address used as 'from' in emails? (leave blank if not using Email auth)" "")

# Setting STORAGE_DOMAIN_NAME default
STORAGE_DOMAIN_NAME="storage.$DOMAIN_NAME"

# Verify configuration validity
if [ -z "$DOMAIN_NAME" ] || [ -z "$EMAIL" ]; then
  echo "Error: DOMAIN_NAME and EMAIL must be set."
  exit 1
fi

# Check if at least one auth is configured
if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
  if [ -z "$AZURE_AD_CLIENT_ID" ] || [ -z "$AZURE_AD_CLIENT_SECRET" ] || [ -z "$AZURE_AD_TENANT_ID" ]; then
    if [ -z "$SMTP_HOST" ] || [ -z "$SMTP_PASSWORD" ] || [ -z "$SMTP_PORT" ] || [ -z "$SMTP_USER" ] || [ -z "$EMAIL_FROM" ]; then
      echo "Error: Neither Google OAuth, Azure AD, nor SMTP credentials are fully configured. Authentication will not be possible."
      exit 1
    fi
  fi
fi

echo "Configuration is valid."

# Environment variables setup
EDGEDB_USER="edgedb"
EDGEDB_PASSWORD=$(openssl rand -base64 12)
EDGEDB_DATABASE="edgedb"
EDGEDB_HOST="edgedb"
EDGEDB_PORT="5656"
EDGEDB_CLIENT_TLS_SECURITY="insecure"

AWS_ACCESS_KEY_ID="TOFUPILOT"
AWS_SECRET_ACCESS_KEY=$(openssl rand -base64 12)
STORAGE_EXTERNAL_ENDPOINT_URL="https://$STORAGE_DOMAIN_NAME"
STORAGE_INTERNAL_ENDPOINT_URL="http://minio:9000"
BUCKET_NAME="tofupilot"
REGION="us-east-1"

NEXTAUTH_SECRET=$(openssl rand -base64 12)
NEXTAUTH_URL="https://$DOMAIN_NAME"

create_env_file
install_nginx
obtain_ssl_certificates
configure_nginx
run_docker_compose

echo "Deployment complete. Your TofuPilot app and database are now running."
echo "TofuPilot is available at https://$DOMAIN_NAME"