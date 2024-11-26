#!/bin/bash

DOMAIN_NAME="" # Add your own
EMAIL="" # Add your own

# Verify that DOMAIN_NAME and EMAIL are set
if [ -z "$DOMAIN_NAME" ]; then
  echo "Error: DOMAIN_NAME is not set. Please set your domain name in the script."
  exit 1
fi

if [ -z "$EMAIL" ]; then
  echo "Error: EMAIL is not set. Please set your email address in the script."
  exit 1
fi

# At least one of these two groups must be set
AZURE_AD_CLIENT_ID=""
AZURE_AD_CLIENT_SECRET=""
AZURE_AD_TENANT_ID=""

GOOGLE_CLIENT_ID=""
GOOGLE_CLIENT_SECRET=""

# Verify that at least one authentication provider (Google or Azure) is configured
if [ -z "$AZURE_AD_CLIENT_ID" ] || [ -z "$AZURE_AD_CLIENT_SECRET" ] || [ -z "$AZURE_AD_TENANT_ID" ]; then
  if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
    echo "Error: Neither Azure AD nor Google authentication credentials are configured. Authentication will not be possible."
    exit 1
  fi
fi

echo "Configuration is valid."


# Env Vars
EDGEDB_USER=edgedb
EDGEDB_PASSWORD=$(openssl rand -base64 12)  # Generate a random 12-character password
EDGEDB_DATABASE=edgedb
EDGEDB_HOST=edgedb
EDGEDB_PORT=5656
EDGEDB_CLIENT_TLS_SECURITY=insecure

AWS_ACCESS_KEY_ID=TOFUPILOT
AWS_SECRET_ACCESS_KEY=$(openssl rand -base64 12)  # Generate a random 12-character password
S3_ENDPOINT_URL=$DOMAIN_NAME:9000
BUCKET_NAME=tofupilot
REGION="us-east-1"

NEXTAUTH_SECRET=$(openssl rand -base64 12)  # Generate a random 12-character password
NEXTAUTH_URL=$DOMAIN_NAME

NEXT_SHARP_PATH=/tmp/node_modules/sharp

# Script Vars
REPO_URL="https://github.com/tofupilot/on-premise.git"
APP_DIR=~/tofupilot

# Update package list and upgrade existing packages
sudo apt update && sudo apt upgrade -y

# Clone the Git repository
if [ -d "$APP_DIR" ]; then
  echo "Directory $APP_DIR already exists. Pulling latest changes..."
  cd $APP_DIR && git pull
else
  echo "Cloning repository from $REPO_URL..."
  git clone $REPO_URL $APP_DIR
  cd $APP_DIR
fi

# Back-up the .env file before overriding it
if [ -f "$APP_DIR/.env" ]; then
  echo ".env file already exists. Backing up to .env.bak"
  mv "$APP_DIR/.env" "$APP_DIR/.env.bak"
fi

# Create the .env file inside the app directory (~/tofupilot/.env)
echo "EDGEDB_USER=$EDGEDB_USER" > "$APP_DIR/.env"
echo "EDGEDB_PASSWORD=$EDGEDB_PASSWORD" >> "$APP_DIR/.env"
echo "EDGEDB_DATABASE=$EDGEDB_DATABASE" >> "$APP_DIR/.env"
echo "EDGEDB_HOST=$EDGEDB_HOST" >> "$APP_DIR/.env"
echo "EDGEDB_PORT=$EDGEDB_PORT" >> "$APP_DIR/.env"
echo "EDGEDB_CLIENT_TLS_SECURITY=$EDGEDB_CLIENT_TLS_SECURITY" >> "$APP_DIR/.env"
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY" >> "$APP_DIR/.env"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> "$APP_DIR/.env"
echo "S3_ENDPOINT_URL=$S3_ENDPOINT_URL" >> "$APP_DIR/.env"
echo "BUCKET_NAME=$BUCKET_NAME" >> "$APP_DIR/.env"
echo "REGION=$REGION" >> "$APP_DIR/.env"
echo "NEXTAUTH_SECRET=$NEXTAUTH_SECRET" >> "$APP_DIR/.env"
echo "NEXTAUTH_URL=$NEXTAUTH_URL" >> "$APP_DIR/.env"
echo "NEXT_SHARP_PATH=$NEXT_SHARP_PATH" >> "$APP_DIR/.env"

# Install Nginx
sudo apt install nginx -y

# Remove old Nginx config (if it exists)
sudo rm -f /etc/nginx/sites-available/tofupilot
sudo rm -f /etc/nginx/sites-enabled/tofupilot

# Stop Nginx temporarily to allow Certbot to run in standalone mode
sudo systemctl stop nginx

# Obtain SSL certificate using Certbot standalone mode
sudo apt install certbot -y
sudo certbot certonly --standalone -d $DOMAIN_NAME --non-interactive --agree-tos -m $EMAIL

# Ensure SSL files exist or generate them
if [ ! -f /etc/letsencrypt/options-ssl-nginx.conf ]; then
  sudo wget https://raw.githubusercontent.com/certbot/certbot/main/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf -P /etc/letsencrypt/
fi

if [ ! -f /etc/letsencrypt/ssl-dhparams.pem ]; then
  sudo openssl dhparam -out /etc/letsencrypt/ssl-dhparams.pem 2048
fi

# Create Nginx config with reverse proxy, SSL support, rate limiting, and streaming support
sudo cat > /etc/nginx/sites-available/tofupilot <<EOL
limit_req_zone \$binary_remote_addr zone=mylimit:10m rate=10r/s;

server {
    listen 80;
    server_name $DOMAIN_NAME;

    # Redirect all HTTP requests to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
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
EOL

# Create symbolic link if it doesn't already exist
sudo ln -s /etc/nginx/sites-available/tofupilot /etc/nginx/sites-enabled/tofupilot

# Restart Nginx to apply the new configuration
sudo systemctl restart nginx

# Build and run the Docker containers from the app directory (~/tofupilot)
cd $APP_DIR
sudo docker-compose up -d

# Check if Docker Compose started correctly
if ! sudo docker-compose ps | grep "Up"; then
  echo "Docker containers failed to start. Check logs with 'docker-compose logs'."
  exit 1
fi

# Output final message
echo "Deployment complete. Your TofuPilot app and database are now running. 
TofuPilot is available at https://$DOMAIN_NAME, and the database is accessible from the web service."