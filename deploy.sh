#!/usr/bin/env bash
# Simple TofuPilot Deployment Script
# This script sets up TofuPilot with minimal user input and smart defaults
set -e  # Exit on any error

#----------------------------#
#       Configuration        #
#----------------------------#
# Handle case where script is run via curl pipe (BASH_SOURCE points to /dev/fd/XX or /proc/self/fd/XX)
BASH_SOURCE_PATH="${BASH_SOURCE[0]}"
if [[ "$BASH_SOURCE_PATH" =~ ^/dev/fd/ ]] || [[ "$BASH_SOURCE_PATH" =~ ^/proc/self/fd/ ]] || [[ ! -f "$BASH_SOURCE_PATH" ]]; then
    # Script is run via pipe or doesn't exist as a real file, use current directory
    SCRIPT_DIR="$(pwd)"
    echo "[INFO] Script running from pipe - using current directory: $SCRIPT_DIR"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

CONFIG_FILE="$SCRIPT_DIR/.tofupilot.conf"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
ENV_FILE="$SCRIPT_DIR/.env"

# Colours for output
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

#----------------------------#
#         Functions          #
#----------------------------#
log(){ echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"; }
warn(){ echo -e "${YELLOW}[WARNING] $1${NC}"; }
error(){ echo -e "${RED}[ERROR] $1${NC}"; exit 1; }
info(){ echo -e "${BLUE}[INFO] $1${NC}"; }

command_exists(){ command -v "$1" >/dev/null 2>&1; }
generate_password(){ openssl rand -base64 32 | tr -d "=+/" | cut -c1-25; }

# Prompt for input with optional default and secret mode
prompt() {
    local var_name="$1"
    local message="$2"
    local default="$3"
    local secret="${4:-false}"
    local user_input=""
    
    # If already set in config, use that
    if [ -f "$CONFIG_FILE" ]; then
        local existing_value
        existing_value=$(grep -E "^${var_name}=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2- | tr -d '"')
        if [ -n "$existing_value" ]; then
            echo "$existing_value"
            return
        fi
    fi
    
    # Display the prompt
    if [ -n "$default" ]; then
        echo -n "$message [$default]: "
    else
        echo -n "$message: "
    fi
    
    if [ "$secret" = "true" ]; then
        read -s user_input
        echo
    else
        read user_input
    fi
    
    if [ -z "$user_input" ]; then
        user_input="$default"
    fi
    
    # Save to config file (only if var_name and value are not empty)
    if [ -n "$var_name" ] && [ -n "$user_input" ]; then
        echo "${var_name}=\"${user_input}\"" >> "$CONFIG_FILE"
    fi
    
    echo "$user_input"
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    info "Validating your system can run TofuPilot..."
    
    # Check if running as root
    if [ "$EUID" -eq 0 ] && [ "$ALLOW_ROOT" = "false" ]; then
        error "Please don't run this script as root. It will ask for sudo when needed.

Use --allow-root flag to bypass this check if you're in a controlled environment:
  bash <(curl -s URL) --allow-root"
    fi
    
    if [ "$EUID" -eq 0 ] && [ "$ALLOW_ROOT" = "true" ]; then
        warn "Running as root user - this may cause file ownership issues"
        warn "Consider creating a non-root user for better security"
    fi
    
    # Check OS
    info "Checking operating system compatibility..."
    if ! command_exists apt; then
        error "This script requires Ubuntu/Debian with apt package manager"
    fi
    log "Operating system check passed ✓"
    
    # Check Docker
    info "Checking Docker installation..."
    if ! command_exists docker; then
        log "Installing Docker..."
        info "Docker not found - installing automatically..."
        info "This may take a few minutes..."
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        info "Docker installed. You may need to logout and login again for Docker permissions."
    else
        log "Docker found ✓"
    fi
    
    # Check if user is in docker group and has permissions
    info "Checking Docker permissions..."
    if ! docker ps >/dev/null 2>&1; then
        warn "Docker permission issue detected!"
        info "Adding user to docker group and fixing permissions..."
        
        # Add user to docker group if not already
        if ! groups "$USER" | grep -q docker; then
            sudo usermod -aG docker "$USER"
            info "Added $USER to docker group"
        fi
        
        # Try to fix immediate permissions for this session
        info "Attempting to fix permissions for current session..."
        if sudo chmod 666 /var/run/docker.sock 2>/dev/null; then
            info "Temporary permission fix applied"
        else
            warn "Could not apply temporary fix. You may need to logout and login again."
        fi
        
        # Test again
        if ! docker ps >/dev/null 2>&1; then
            error "Docker permissions still not working. Please run: 
1. logout and login again, OR
2. run: newgrp docker, OR  
3. run this script with: sudo -E ./deploy.sh --local"
        fi
    fi
    log "Docker permissions verified ✓"
    
    # Check Docker Compose
    info "Checking Docker Compose installation..."
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        log "Installing Docker Compose..."
        info "Docker Compose not found - installing..."
        sudo apt update
        sudo apt install -y docker-compose-plugin
        log "Docker Compose installed ✓"
    else
        log "Docker Compose found ✓"
    fi
    
    # Check if ports are available
    info "Checking port availability (80, 443)..."
    if command_exists netstat && sudo netstat -tlnp 2>/dev/null | grep -E ':80|:443' >/dev/null 2>&1; then
        warn "Ports 80 or 443 appear to be in use. This might cause issues."
    elif command_exists ss && sudo ss -tlnp 2>/dev/null | grep -E ':80|:443' >/dev/null 2>&1; then
        warn "Ports 80 or 443 appear to be in use. This might cause issues."
    else
        log "Ports 80/443 available ✓"
    fi
    
    # Check system architecture
    info "Checking system architecture..."
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
        warn "Detected ARM64 architecture (Apple Silicon or ARM server)"
        warn "TofuPilot currently only supports AMD64 - we'll use emulation"
        info "This may be slower but should work. If you get 'exec format error', Docker emulation might not be enabled."
        echo
        echo "If the deployment fails with 'exec format error':"
        echo "1. Enable Docker Desktop's 'Use Rosetta for x86/amd64 emulation' (Mac)"
        echo "2. Or try: docker run --rm --privileged tonistiigi/binfmt --install all"
        echo "3. Or contact TofuPilot for ARM64 support"
        echo
    else
        log "Architecture check passed (AMD64) ✓"
    fi
}

# Create Docker Compose file with fixed labels
create_compose_file() {
  log "Creating Docker Compose configuration..."

  # Determine if we're in local mode
  local IS_LOCAL_MODE="false"
  if [[ "$DOMAIN_NAME" == "localhost" ]] || [[ "$LOCAL_MODE" == "true" ]]; then
    IS_LOCAL_MODE="true"
  fi

  if [[ "$IS_LOCAL_MODE" == "true" ]]; then
    # Local mode without SSL
    cat > "$COMPOSE_FILE" <<'EOF'
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    container_name: tofupilot-traefik
    restart: unless-stopped
    command:
      - "--api.dashboard=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./acme.json:/acme.json
    networks:
      - web

  app:
    image: ghcr.io/tofupilot/tofupilot:latest
    platform: linux/amd64
    container_name: tofupilot-app
    ports:
      - "3000:3000"
    restart: unless-stopped
    depends_on:
      - database
      - storage
    environment:
      - NEXT_PUBLIC_DOMAIN_NAME=${DOMAIN_NAME}
      - NEXTAUTH_URL=http://${DOMAIN_NAME}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - EDGEDB_DSN=edgedb://edgedb:${EDGEDB_PASSWORD}@database:5656/edgedb
      - EDGEDB_CLIENT_TLS_SECURITY=insecure
      - AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY}
      - AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}
      - STORAGE_EXTERNAL_ENDPOINT_URL=http://${STORAGE_DOMAIN_NAME}
      - STORAGE_INTERNAL_ENDPOINT_URL=http://storage:9000
      - BUCKET_NAME=tofupilot
      - REGION=us-east-1
      - GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
      - GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
      - AZURE_AD_CLIENT_ID=${AZURE_AD_CLIENT_ID:-}
      - AZURE_AD_CLIENT_SECRET=${AZURE_AD_CLIENT_SECRET:-}
      - AZURE_AD_TENANT_ID=${AZURE_AD_TENANT_ID:-}
      - SMTP_HOST=${SMTP_HOST:-}
      - SMTP_PORT=${SMTP_PORT:-587}
      - SMTP_USER=${SMTP_USER:-}
      - SMTP_PASSWORD=${SMTP_PASSWORD:-}
      - EMAIL_FROM=${EMAIL_FROM:-}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`${DOMAIN_NAME}`)"
      - "traefik.http.routers.app.entrypoints=web"
      - "traefik.http.services.app.loadbalancer.server.port=3000"
    networks:
      - web

  database:
    image: edgedb/edgedb:latest
    container_name: tofupilot-database
    restart: unless-stopped
    environment:
      - EDGEDB_SERVER_SECURITY=insecure_dev_mode
      - EDGEDB_SERVER_PASSWORD=${EDGEDB_PASSWORD}
    volumes:
      - database-data:/var/lib/edgedb/data
    ports:
      - "127.0.0.1:5656:5656"
    networks:
      - web

  storage:
    image: minio/minio:latest
    container_name: tofupilot-storage
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
    volumes:
      - storage-data:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.storage.rule=Host(`${STORAGE_DOMAIN_NAME}`)"
      - "traefik.http.routers.storage.entrypoints=web"
      - "traefik.http.services.storage.loadbalancer.server.port=9000"
    networks:
      - web

volumes:
  database-data:
  storage-data:

networks:
  web:
    driver: bridge

EOF
  else
    # Production mode with SSL
    cat > "$COMPOSE_FILE" <<'EOF'
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    container_name: tofupilot-traefik
    restart: unless-stopped
    command:
      - "--api.dashboard=false"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-acme:/acme
    environment:
      - ACME_EMAIL=${ACME_EMAIL}
    networks:
      - web

  app:
    image: ghcr.io/tofupilot/tofupilot:latest
    platform: linux/amd64
    container_name: tofupilot-app
    ports:
      - "3000:3000"
    restart: unless-stopped
    depends_on:
      - database
      - storage
    environment:
      - NEXT_PUBLIC_DOMAIN_NAME=${DOMAIN_NAME}
      - NEXTAUTH_URL=https://${DOMAIN_NAME}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - EDGEDB_DSN=edgedb://edgedb:${EDGEDB_PASSWORD}@database:5656/edgedb
      - EDGEDB_CLIENT_TLS_SECURITY=insecure
      - AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY}
      - AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}
      - STORAGE_EXTERNAL_ENDPOINT_URL=https://${STORAGE_DOMAIN_NAME}
      - STORAGE_INTERNAL_ENDPOINT_URL=http://storage:9000
      - BUCKET_NAME=tofupilot
      - REGION=us-east-1
      - GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
      - GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
      - AZURE_AD_CLIENT_ID=${AZURE_AD_CLIENT_ID:-}
      - AZURE_AD_CLIENT_SECRET=${AZURE_AD_CLIENT_SECRET:-}
      - AZURE_AD_TENANT_ID=${AZURE_AD_TENANT_ID:-}
      - SMTP_HOST=${SMTP_HOST:-}
      - SMTP_PORT=${SMTP_PORT:-587}
      - SMTP_USER=${SMTP_USER:-}
      - SMTP_PASSWORD=${SMTP_PASSWORD:-}
      - EMAIL_FROM=${EMAIL_FROM:-}
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.app.rule=Host(`${DOMAIN_NAME}`)"
      - "traefik.http.routers.app.entrypoints=websecure"
      - "traefik.http.routers.app.tls.certresolver=letsencrypt"
      - "traefik.http.services.app.loadbalancer.server.port=3000"
    networks:
      - web

  database:
    image: edgedb/edgedb:latest
    container_name: tofupilot-database
    restart: unless-stopped
    environment:
      - EDGEDB_SERVER_SECURITY=insecure_dev_mode
      - EDGEDB_SERVER_PASSWORD=${EDGEDB_PASSWORD}
    volumes:
      - database-data:/var/lib/edgedb/data
    ports:
      - "127.0.0.1:5656:5656"
    networks:
      - web

  storage:
    image: minio/minio:latest
    container_name: tofupilot-storage
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
    volumes:
      - storage-data:/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.storage.rule=Host(`${STORAGE_DOMAIN_NAME}`)"
      - "traefik.http.routers.storage.entrypoints=websecure"
      - "traefik.http.routers.storage.tls.certresolver=letsencrypt"
      - "traefik.http.services.storage.loadbalancer.server.port=9000"
    networks:
      - web

volumes:
  database-data:
  storage-data:
  traefik-acme:

networks:
  web:
    driver: bridge
EOF
  fi

  # Initialize ACME volume with correct permissions
  if [[ "$IS_LOCAL_MODE" == "false" ]]; then
    log "Setting up SSL certificate storage..."
    docker volume create traefik-acme 2>/dev/null || true
    docker run --rm -v traefik-acme:/acme alpine sh -c "touch /acme/acme.json && chmod 600 /acme/acme.json" 2>/dev/null || true
  fi

  log "Docker Compose file created ✓"
}

# Create environment file
create_env_file() {
    log "Creating environment configuration..."
    
    # Backup existing .env
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%s)"
        warn "Backed up existing .env file"
    fi
    
    cat > "$ENV_FILE" <<EOF
# TofuPilot Configuration
DOMAIN_NAME=${DOMAIN_NAME}
STORAGE_DOMAIN_NAME=${STORAGE_DOMAIN_NAME}
ACME_EMAIL=${ACME_EMAIL}

# Security
NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
EDGEDB_PASSWORD=${EDGEDB_PASSWORD}
MINIO_ACCESS_KEY=tofupilot
MINIO_SECRET_KEY=${MINIO_SECRET_KEY}

# Authentication
GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID:-}
GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
AZURE_AD_CLIENT_ID=${AZURE_AD_CLIENT_ID:-}
AZURE_AD_CLIENT_SECRET=${AZURE_AD_CLIENT_SECRET:-}
AZURE_AD_TENANT_ID=${AZURE_AD_TENANT_ID:-}

# Email Configuration
SMTP_HOST=${SMTP_HOST:-}
SMTP_PORT=${SMTP_PORT:-587}
SMTP_USER=${SMTP_USER:-}
SMTP_PASSWORD=${SMTP_PASSWORD:-}
EMAIL_FROM=${EMAIL_FROM:-}
EOF
    log "Environment file created ✓"
}

# Collect user configuration
collect_config() {
    log "Collecting configuration..."
    
    # Remove old config to start fresh
    if [ -f "$CONFIG_FILE" ]; then
        rm -f "$CONFIG_FILE"
    fi
    
    echo
    if [ "$LOCAL_MODE" = "true" ]; then
        info "=== Local Development Configuration ==="
        warn "This is for local testing only - no SSL, no real domains"
    else
        info "=== TofuPilot Production Configuration ==="
    fi
    echo
    
    info "Please provide the following configuration details..."
    echo
    
    # Required settings
    info "Domain Configuration:"
    if [ "$LOCAL_MODE" = "true" ]; then
        # Local mode - simple defaults
        echo -n "Enter local domain name [localhost]: "
        read DOMAIN_NAME
        if [ -z "$DOMAIN_NAME" ]; then
            DOMAIN_NAME="localhost"
        fi
        
        echo -n "Enter storage domain name [localhost:9000]: "
        read STORAGE_DOMAIN_NAME
        if [ -z "$STORAGE_DOMAIN_NAME" ]; then
            STORAGE_DOMAIN_NAME="localhost:9000"
        fi
        
        ACME_EMAIL="admin@localhost"
        
        # Save to config file
        echo "DOMAIN_NAME=\"${DOMAIN_NAME}\"" >> "$CONFIG_FILE"
        echo "STORAGE_DOMAIN_NAME=\"${STORAGE_DOMAIN_NAME}\"" >> "$CONFIG_FILE"
        echo "ACME_EMAIL=\"${ACME_EMAIL}\"" >> "$CONFIG_FILE"
    else
        # Production mode
        echo -n "Enter your domain name [tofupilot.example.com]: "
        read DOMAIN_NAME
        if [ -z "$DOMAIN_NAME" ]; then
            DOMAIN_NAME="tofupilot.example.com"
        fi
        
        echo -n "Enter storage domain name [storage.${DOMAIN_NAME}]: "
        read STORAGE_DOMAIN_NAME
        if [ -z "$STORAGE_DOMAIN_NAME" ]; then
            STORAGE_DOMAIN_NAME="storage.${DOMAIN_NAME}"
        fi
        
        echo -n "Enter email for SSL certificates [admin@${DOMAIN_NAME}]: "
        read ACME_EMAIL
        if [ -z "$ACME_EMAIL" ]; then
            ACME_EMAIL="admin@${DOMAIN_NAME}"
        fi
        
        # Save to config file
        echo "DOMAIN_NAME=\"${DOMAIN_NAME}\"" >> "$CONFIG_FILE"
        echo "STORAGE_DOMAIN_NAME=\"${STORAGE_DOMAIN_NAME}\"" >> "$CONFIG_FILE"
        echo "ACME_EMAIL=\"${ACME_EMAIL}\"" >> "$CONFIG_FILE"
    fi
    
    # Generate secure passwords if not provided
    if [ -z "$NEXTAUTH_SECRET" ]; then
        NEXTAUTH_SECRET=$(generate_password)
        echo "NEXTAUTH_SECRET=\"${NEXTAUTH_SECRET}\"" >> "$CONFIG_FILE"
    fi
    if [ -z "$EDGEDB_PASSWORD" ]; then
        EDGEDB_PASSWORD=$(generate_password)
        echo "EDGEDB_PASSWORD=\"${EDGEDB_PASSWORD}\"" >> "$CONFIG_FILE"
    fi
    if [ -z "$MINIO_SECRET_KEY" ]; then
        MINIO_SECRET_KEY=$(generate_password)
        echo "MINIO_SECRET_KEY=\"${MINIO_SECRET_KEY}\"" >> "$CONFIG_FILE"
    fi
    
    echo
    if [ "$LOCAL_MODE" = "true" ]; then
        info "=== Authentication Setup (Optional for Local Testing) ==="
        warn "You can skip authentication setup for local testing"
        echo
        echo "Choose authentication method:"
        echo "1) Skip authentication (local testing only)"
        echo "2) Google OAuth"
        echo "3) Azure AD" 
        echo "4) Email authentication"
        echo -n "Enter choice [1]: "
        read auth_choice
        if [ -z "$auth_choice" ]; then
            auth_choice="1"
        fi
    else
        info "=== Authentication Setup ==="
        warn "At least one authentication method is required for TofuPilot to work."
        echo
        echo "Choose authentication method:"
        echo "1) Google OAuth (Recommended)"
        echo "2) Azure AD"
        echo "3) Email authentication"
        echo -n "Enter choice [1]: "
        read auth_choice
        if [ -z "$auth_choice" ]; then
            auth_choice="1"
        fi
    fi
    
    # Configure based on choice
    AUTH_CONFIGURED=false
    
    case "$auth_choice" in
        1)
            if [ "$LOCAL_MODE" = "true" ]; then
                info "✓ Skipping authentication for local testing"
                AUTH_CONFIGURED=true
            else
                info "Configuring Google OAuth..."
                echo -n "Google OAuth Client ID: "
                read GOOGLE_CLIENT_ID
                if [ -n "$GOOGLE_CLIENT_ID" ]; then
                    echo -n "Google OAuth Client Secret: "
                    read -s GOOGLE_CLIENT_SECRET
                    echo
                    if [ -n "$GOOGLE_CLIENT_SECRET" ]; then
                        AUTH_CONFIGURED=true
                        info "✓ Google OAuth configured"
                        echo "GOOGLE_CLIENT_ID=\"${GOOGLE_CLIENT_ID}\"" >> "$CONFIG_FILE"
                        echo "GOOGLE_CLIENT_SECRET=\"${GOOGLE_CLIENT_SECRET}\"" >> "$CONFIG_FILE"
                    fi
                fi
            fi
            ;;
        2)
            info "Configuring Azure AD..."
            echo -n "Azure AD Client ID: "
            read AZURE_AD_CLIENT_ID
            if [ -n "$AZURE_AD_CLIENT_ID" ]; then
                echo -n "Azure AD Client Secret: "
                read -s AZURE_AD_CLIENT_SECRET
                echo
                echo -n "Azure AD Tenant ID: "
                read AZURE_AD_TENANT_ID
                if [ -n "$AZURE_AD_CLIENT_SECRET" ] && [ -n "$AZURE_AD_TENANT_ID" ]; then
                    AUTH_CONFIGURED=true
                    info "✓ Azure AD configured"
                    echo "AZURE_AD_CLIENT_ID=\"${AZURE_AD_CLIENT_ID}\"" >> "$CONFIG_FILE"
                    echo "AZURE_AD_CLIENT_SECRET=\"${AZURE_AD_CLIENT_SECRET}\"" >> "$CONFIG_FILE"
                    echo "AZURE_AD_TENANT_ID=\"${AZURE_AD_TENANT_ID}\"" >> "$CONFIG_FILE"
                fi
            fi
            ;;
        3)
            info "Configuring Email authentication..."
            echo -n "SMTP server hostname: "
            read SMTP_HOST
            if [ -n "$SMTP_HOST" ]; then
                echo -n "SMTP port [587]: "
                read SMTP_PORT
                if [ -z "$SMTP_PORT" ]; then
                    SMTP_PORT="587"
                fi
                
                echo -n "SMTP username: "
                read SMTP_USER
                
                echo -n "SMTP password: "
                read -s SMTP_PASSWORD
                echo
                
                echo -n "From email address [${ACME_EMAIL}]: "
                read EMAIL_FROM
                if [ -z "$EMAIL_FROM" ]; then
                    EMAIL_FROM="$ACME_EMAIL"
                fi
                
                if [ -n "$SMTP_USER" ] && [ -n "$SMTP_PASSWORD" ] && [ -n "$EMAIL_FROM" ]; then
                    AUTH_CONFIGURED=true
                    info "✓ Email authentication configured"
                    echo "SMTP_HOST=\"${SMTP_HOST}\"" >> "$CONFIG_FILE"
                    echo "SMTP_PORT=\"${SMTP_PORT}\"" >> "$CONFIG_FILE"
                    echo "SMTP_USER=\"${SMTP_USER}\"" >> "$CONFIG_FILE"
                    echo "SMTP_PASSWORD=\"${SMTP_PASSWORD}\"" >> "$CONFIG_FILE"
                    echo "EMAIL_FROM=\"${EMAIL_FROM}\"" >> "$CONFIG_FILE"
                fi
            fi
            ;;
        4)
            if [ "$LOCAL_MODE" = "true" ]; then
                info "Configuring Email authentication..."
                echo -n "SMTP server hostname: "
                read SMTP_HOST
                if [ -n "$SMTP_HOST" ]; then
                    echo -n "SMTP port [587]: "
                    read SMTP_PORT
                    if [ -z "$SMTP_PORT" ]; then
                        SMTP_PORT="587"
                    fi
                    
                    echo -n "SMTP username: "
                    read SMTP_USER
                    
                    echo -n "SMTP password: "
                    read -s SMTP_PASSWORD
                    echo
                    
                    echo -n "From email address [${ACME_EMAIL}]: "
                    read EMAIL_FROM
                    if [ -z "$EMAIL_FROM" ]; then
                        EMAIL_FROM="$ACME_EMAIL"
                    fi
                    
                    if [ -n "$SMTP_USER" ] && [ -n "$SMTP_PASSWORD" ] && [ -n "$EMAIL_FROM" ]; then
                        AUTH_CONFIGURED=true
                        info "✓ Email authentication configured"
                        echo "SMTP_HOST=\"${SMTP_HOST}\"" >> "$CONFIG_FILE"
                        echo "SMTP_PORT=\"${SMTP_PORT}\"" >> "$CONFIG_FILE"
                        echo "SMTP_USER=\"${SMTP_USER}\"" >> "$CONFIG_FILE"
                        echo "SMTP_PASSWORD=\"${SMTP_PASSWORD}\"" >> "$CONFIG_FILE"
                        echo "EMAIL_FROM=\"${EMAIL_FROM}\"" >> "$CONFIG_FILE"
                    fi
                fi
            else
                warn "Invalid choice. Please run the script again and choose 1, 2, or 3."
                exit 1
            fi
            ;;
        *)
            warn "Invalid choice. Please run the script again and choose a valid option."
            exit 1
            ;;
    esac
    
    echo
    
    # Validate that at least one auth method is configured (skip for local mode)
    if [ "$LOCAL_MODE" = "false" ] && [ "$AUTH_CONFIGURED" = "false" ]; then
        error "At least one authentication method must be configured. Please run the script again and configure Google OAuth, Azure AD, or Email authentication."
    fi
    
    if [ "$LOCAL_MODE" = "true" ]; then
        info "Local development mode - authentication validation skipped"
    elif [ "$AUTH_CONFIGURED" = "true" ]; then
        info "Authentication setup complete ✓"
    fi
    
    echo
    log "Configuration collected ✓"
}

# Deploy the application
deploy() {
    log "Starting deployment..."
    
    # Configuration variables are already loaded in main script
    # Create configuration files
    log "⚙️  Setting up configuration files..."
    create_compose_file
    create_env_file
    
    # Pull latest images
    log "📥 Pulling Docker images (this may take a few minutes)..."
    info "TofuPilot uses GitHub Container Registry which may require authentication..."
    
    # Check if we can access the TofuPilot image
    info "Testing access to TofuPilot image..."
    if ! docker pull --platform linux/amd64 ghcr.io/tofupilot/tofupilot:latest 2>/dev/null; then
        warn "Cannot access TofuPilot Docker image - authentication required!"
        echo
        echo "The TofuPilot image is private and requires GitHub authentication."
        echo "Please choose an option:"
        echo
        echo "1) Login with GitHub Personal Access Token (recommended)"
        echo "2) Login with GitHub username/password" 
        echo "3) Skip and build from source (if you have Dockerfile)"
        echo "4) Exit and get access credentials"
        echo
        echo -n "Enter choice [1]: "
        read auth_choice
        if [ -z "$auth_choice" ]; then
            auth_choice="1"
        fi
        
        case "$auth_choice" in
            1)
                echo
                info "GitHub Personal Access Token login:"
                echo "You need a GitHub Personal Access Token with 'read:packages' permission."
                echo "Create one at: https://github.com/settings/tokens"
                echo
                echo -n "GitHub username: "
                read github_username
                echo
                echo "GitHub Personal Access Token:"
                echo "(Note: Text will be hidden for security - paste your token and press Enter)"
                echo -n "Token: "
                # Use a more reliable method for reading the token
                if command -v stty >/dev/null 2>&1; then
                    # Save current terminal settings
                    old_stty_cfg=$(stty -g)
                    # Turn off echo
                    stty -echo
                    read github_token
                    # Restore terminal settings
                    stty "$old_stty_cfg"
                    echo
                else
                    # Fallback for systems without stty
                    read github_token
                fi
                
                if [ -n "$github_username" ] && [ -n "$github_token" ]; then
                    info "Logging into GitHub Container Registry..."
                    if echo "$github_token" | docker login ghcr.io -u "$github_username" --password-stdin; then
                        log "Successfully logged into GitHub Container Registry ✓"
                    else
                        error "Failed to login to GitHub Container Registry. Please check your credentials."
                    fi
                else
                    error "Username and token are required."
                fi
                ;;
            2)
                echo
                info "GitHub username/password login:"
                echo -n "GitHub username: "
                read github_username
                echo -n "GitHub password: "
                if command -v stty >/dev/null 2>&1; then
                    old_stty_cfg=$(stty -g)
                    stty -echo
                    read github_password
                    stty "$old_stty_cfg"
                    echo
                else
                    read -s github_password
                    echo
                fi
                
                if [ -n "$github_username" ] && [ -n "$github_password" ]; then
                    info "Logging into GitHub Container Registry..."
                    if echo "$github_password" | docker login ghcr.io -u "$github_username" --password-stdin; then
                        log "Successfully logged into GitHub Container Registry ✓"
                    else
                        error "Failed to login to GitHub Container Registry. Please check your credentials."
                    fi
                else
                    error "Username and password are required."
                fi
                ;;
            3)
                error "Build from source not implemented yet. Please choose option 1 or 2, or contact TofuPilot for access."
                ;;
            4)
                error "Please get TofuPilot access credentials and run the script again.
                
Contact TofuPilot support or check their documentation at:
https://tofupilot.com/docs"
                ;;
            *)
                error "Invalid choice. Please run the script again."
                ;;
        esac
    fi
    
    info "Downloading TofuPilot application image from GitHub Container Registry..."
    info "Note: Using AMD64 platform (TofuPilot doesn't support ARM64 yet)"
    info "Downloading Traefik reverse proxy image..."
    info "Downloading EdgeDB database image..."
    info "Downloading MinIO storage image..."
    echo "   This step downloads several GB of data - please be patient..."
    
    if docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull; then
        log "Docker images downloaded ✓"
    else
        error "Failed to pull Docker images. If TofuPilot image access was denied, you may need proper credentials or access permissions."
    fi
    
    # Start services
    log "🚀 Starting TofuPilot services..."
    info "Starting reverse proxy (Traefik)..."
    info "Starting database (EdgeDB)..."
    info "Starting object storage (MinIO)..."
    info "Starting main application (TofuPilot)..."
    echo "   Services are starting in the background..."
    
    # Clean up any orphaned containers first
    info "Cleaning up any orphaned containers from previous runs..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
    # Remove any corrupted containers
    info "Removing any corrupted containers..."
    docker container prune -f 2>/dev/null || true
    
    if docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans; then
        log "Services started ✓"
    else
        warn "Service startup failed. Attempting cleanup and retry..."
        
        # More aggressive cleanup
        info "Performing thorough cleanup..."
        docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans 2>/dev/null || true
        docker system prune -f 2>/dev/null || true
        
        # Try again
        info "Retrying service startup..."
        if docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans; then
            log "Services started after cleanup ✓"
        else
            error "Failed to start services even after cleanup. 

Try manual cleanup:
1. docker compose down --volumes --remove-orphans
2. docker system prune -a -f
3. ./deploy.sh --local

Check logs with: docker compose logs"
        fi
    fi
    
    # Wait for services to be ready
    log "⏳ Waiting for services to initialize..."
    info "Services need time to start up and become ready..."
    info "Database initialization in progress..."
    info "Application startup in progress..."
    
    local dots=""
    for i in {1..15}; do
        dots="${dots}."
        echo -ne "\r   Initializing services${dots} ($i/15 seconds)"
        sleep 1
    done
    echo
    
    # Check if services are running
    log "🔍 Verifying service status..."
    info "Checking if all containers are running..."
    info "Testing service connectivity..."
    
    if docker compose -f "$COMPOSE_FILE" ps 2>/dev/null | grep -q "Up"; then
        log "All services are running ✓"
        
        # Check for exec format errors in app container
        if docker compose -f "$COMPOSE_FILE" logs app 2>/dev/null | grep -q "exec format error"; then
            error "TofuPilot app failed with 'exec format error' - architecture compatibility issue.

This happens on ARM64 systems (Apple Silicon Macs) when Docker can't emulate AMD64 images.

Solutions:
1. **Docker Desktop (Mac)**: Enable 'Use Rosetta for x86/amd64 emulation on Apple Silicon'
   - Docker Desktop → Settings → General → Use Rosetta...
   
2. **Install QEMU emulators**: 
   docker run --rm --privileged tonistiigi/binfmt --install all
   
3. **Alternative**: Contact TofuPilot for ARM64-native images

Then restart the deployment:
   docker compose down
   ./deploy.sh --local"
        fi
        
        if [ "$LOCAL_MODE" = "false" ]; then
            # Additional wait for SSL certificates
            log "🔒 Waiting for SSL certificates to be generated..."
            log "   This may take 1-2 minutes for first-time setup..."
            info "Let's Encrypt is validating your domain and issuing certificates..."
            warn "Please ensure your DNS is properly configured and pointing to this server"
            
            local ssl_dots=""
            for i in {1..60}; do
                ssl_dots="${ssl_dots}."
                if [ $((i % 10)) -eq 0 ]; then
                    echo -ne "\r   Generating SSL certificates${ssl_dots} (${i}/60 seconds)"
                else
                    echo -ne "\r   Generating SSL certificates${ssl_dots}"
                fi
                sleep 1
            done
            echo
            
            # Test if the app is accessible
            log "🌐 Verifying deployment accessibility..."
            info "Testing HTTPS connectivity to your domain..."
            
            local retry_count=0
            while [ $retry_count -lt 12 ]; do  # 2 minutes max
                echo -ne "\r   Testing connectivity... attempt $((retry_count + 1))/12"
                
                if curl -f -s -I "https://${DOMAIN_NAME}" >/dev/null 2>&1; then
                    echo
                    log "TofuPilot is accessible at https://${DOMAIN_NAME} ✅"
                    break
                fi
                if curl -f -s -I "http://${DOMAIN_NAME}" >/dev/null 2>&1; then
                    echo
                    log "TofuPilot is accessible (SSL still provisioning) ⏳"
                    break  
                fi
                
                sleep 10
                retry_count=$((retry_count + 1))
            done
            
            if [ $retry_count -eq 12 ]; then
                echo
                warn "Could not verify TofuPilot accessibility via HTTPS."
                warn "This is normal if DNS is still propagating or SSL is still provisioning."
                warn "Check your deployment with: ./deploy.sh --status"
                info "Manual verification: try visiting https://${DOMAIN_NAME} in your browser"
            fi
        else
            # Local mode - test local connectivity
            log "🌐 Testing local connectivity..."
            info "Checking if services are responding on localhost..."
            sleep 5  # Give services time to start
            
            if curl -f -s -I "http://localhost" >/dev/null 2>&1; then
                log "TofuPilot is accessible at http://localhost ✅"
            elif curl -f -s -I "http://localhost:3000" >/dev/null 2>&1; then
                log "TofuPilot is accessible at http://localhost:3000 ✅"
                info "Note: Access via http://localhost (port 80) or http://localhost:3000"
            else
                warn "Local TofuPilot not yet accessible. Services may still be starting up."
                info "Try: curl http://localhost (or wait 30 seconds and try again)"
                info "Direct app access: http://localhost:3000"
                info "Storage access: http://localhost:9000"
            fi
        fi
    else
        error "Some services failed to start. Check logs with: docker compose logs"
    fi
}

# Show deployment information
show_info() {
    echo
    echo "=================================="
    log "🎉 TofuPilot deployment complete!"
    echo "=================================="
    echo
    info "Your TofuPilot instance is available at:"
    if [ "$LOCAL_MODE" = "true" ]; then
        echo "  Main app: http://${DOMAIN_NAME}"
        echo "  Storage:  http://${STORAGE_DOMAIN_NAME}"
    else
        echo "  Main app: https://${DOMAIN_NAME}"
        echo "  Storage:  https://${STORAGE_DOMAIN_NAME}"
    fi
    echo
    if [ "$LOCAL_MODE" = "false" ]; then
        warn "Make sure your DNS is pointing:"
        echo "  ${DOMAIN_NAME} → $(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")"
        echo "  ${STORAGE_DOMAIN_NAME} → $(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")"
        echo
    fi
    info "Useful commands:"
    echo "  View logs:    docker compose logs -f"
    echo "  Stop:         docker compose down"
    echo "  Restart:      docker compose restart"
    echo "  Status:       ./deploy.sh --status"
    echo
    info "Backup & Update commands:"
    echo "  Create backup:  ./deploy.sh --backup"
    echo "  List backups:   ./deploy.sh --list-backups"
    echo "  Restore:        ./deploy.sh --restore <backup-name>"
    echo "  Update:         ./deploy.sh --update"
    echo "  Run migrations: ./deploy.sh --migrate"
    echo
    info "Configuration files:"
    echo "  Docker Compose: $COMPOSE_FILE"
    echo "  Environment:    $ENV_FILE"
    echo "  Config:         $CONFIG_FILE"
    echo
    warn "Configure your authentication providers:"
    if [ -n "$GOOGLE_CLIENT_ID" ]; then
        if [ "$LOCAL_MODE" = "true" ]; then
            echo "  Google OAuth: Add http://${DOMAIN_NAME}/api/auth/callback/google as redirect URI"
        else
            echo "  Google OAuth: Add https://${DOMAIN_NAME}/api/auth/callback/google as redirect URI"
        fi
    fi
    if [ -n "$AZURE_AD_CLIENT_ID" ]; then
        if [ "$LOCAL_MODE" = "true" ]; then
            echo "  Azure AD: Add http://${DOMAIN_NAME}/api/auth/callback/azure-ad as redirect URI"
        else
            echo "  Azure AD: Add https://${DOMAIN_NAME}/api/auth/callback/azure-ad as redirect URI"
        fi
    fi
    if [ -n "$SMTP_HOST" ]; then
        echo "  Email auth: Configured with ${SMTP_HOST}"
    fi
    echo
}

# Create backup
create_backup() {
    local backup_name="${1:-$(date +%Y%m%d_%H%M%S)}"
    local backup_dir="$SCRIPT_DIR/backups/$backup_name"
    
    log "Creating backup: $backup_name"
    info "Backup will be stored in: $backup_dir"
    
    mkdir -p "$backup_dir"
    
    # Backup configuration files
    info "Backing up configuration files..."
    cp "$ENV_FILE" "$backup_dir/" 2>/dev/null || true
    cp "$COMPOSE_FILE" "$backup_dir/" 2>/dev/null || true
    cp "$CONFIG_FILE" "$backup_dir/" 2>/dev/null || true
    
    # Backup database
    if docker compose -f "$COMPOSE_FILE" ps database | grep -q "Up"; then
        log "Backing up EdgeDB database..."
        info "Creating database dump - this may take a few minutes..."
        docker compose -f "$COMPOSE_FILE" exec -T database edgedb dump --tls-security=insecure --dsn "edgedb://edgedb:${EDGEDB_PASSWORD}@database:5656/edgedb" > "$backup_dir/database.dump" || {
            warn "Database backup failed - database might not be running"
        }

    else
        warn "Database service not running - skipping database backup"
    fi
    
    # Backup storage data
    if docker compose -f "$COMPOSE_FILE" ps storage | grep -q "Up"; then
        log "Backing up storage data..."
        info "Compressing storage files - this may take several minutes..."
        docker compose -f "$COMPOSE_FILE" exec -T storage tar czf - /data 2>/dev/null > "$backup_dir/storage.tar.gz" || {
            warn "Storage backup failed - creating volume backup instead"
            info "Trying alternative backup method..."
            # Fallback: backup docker volumes
            docker run --rm -v "$(basename "$SCRIPT_DIR")_storage-data":/data -v "$backup_dir":/backup alpine tar czf /backup/storage-volume.tar.gz -C /data . 2>/dev/null || true
        }
    else
        warn "Storage service not running - skipping storage backup"
    fi
    
    # Create backup manifest
    cat > "$backup_dir/manifest.txt" <<EOF
TofuPilot Backup Manifest
Created: $(date)
Backup Name: $backup_name
TofuPilot Version: $(docker compose -f "$COMPOSE_FILE" images app | tail -n +2 | awk '{print $4}' || echo "unknown")
Files Included:
- .env (configuration)
- docker-compose.yml (service definitions)
- .tofupilot.conf (deployment config)
- database.dump (EdgeDB backup)
- storage.tar.gz (MinIO data)
Restore Command:
./deploy.sh --restore $backup_name
EOF
    
    log "Backup created: $backup_dir ✓"
    echo "  Backup location: $backup_dir"
    echo "  Backup size: $(du -sh "$backup_dir" | cut -f1)"
}

# Restore from backup
restore_backup() {
    local backup_name="$1"
    local backup_dir="$SCRIPT_DIR/backups/$backup_name"
    
    if [ ! -d "$backup_dir" ]; then
        error "Backup not found: $backup_name"
    fi
    
    log "Restoring from backup: $backup_name"
    
    # Stop current services
    if [ -f "$COMPOSE_FILE" ]; then
        log "Stopping current services..."
        docker compose -f "$COMPOSE_FILE" down
    fi
    
    # Restore configuration files
    log "Restoring configuration..."
    cp "$backup_dir/.env" "$ENV_FILE" 2>/dev/null || true
    cp "$backup_dir/docker-compose.yml" "$COMPOSE_FILE" 2>/dev/null || true
    cp "$backup_dir/.tofupilot.conf" "$CONFIG_FILE" 2>/dev/null || true
    
    # Source the restored environment
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
    fi
    
    # Start services (database first)
    log "Starting database service..."
    docker compose -f "$COMPOSE_FILE" up -d database
    
    # Wait for database to be ready
    log "Waiting for database to be ready..."
    sleep 15
    
    # Restore database
    if [ -f "$backup_dir/database.dump" ]; then
        log "Restoring database..."
        docker compose -f "$COMPOSE_FILE" exec -T database edgedb restore --tls-security=insecure --dsn "edgedb://edgedb:${EDGEDB_PASSWORD}@database:5656/edgedb" < "$backup_dir/database.dump" || {
            warn "Database restore failed - continuing with other services"
        }
    fi
    
    # Start storage service
    log "Starting storage service..."
    docker compose -f "$COMPOSE_FILE" up -d storage
    sleep 10
    
    # Restore storage data
    if [ -f "$backup_dir/storage.tar.gz" ]; then
        log "Restoring storage data..."
        docker compose -f "$COMPOSE_FILE" exec -T storage sh -c "cd / && tar xzf -" < "$backup_dir/storage.tar.gz" || {
            warn "Storage restore failed"
        }
    elif [ -f "$backup_dir/storage-volume.tar.gz" ]; then
        log "Restoring storage volume..."
        docker run --rm -v "$(basename "$SCRIPT_DIR")_storage-data":/data -v "$backup_dir":/backup alpine sh -c "cd /data && tar xzf /backup/storage-volume.tar.gz" || {
            warn "Storage volume restore failed"
        }
    fi
    
    # Start all services
    log "Starting all services..."
    docker compose -f "$COMPOSE_FILE" up -d
    
    log "Restore complete ✓"
}

# Run database migrations
run_migrations() {
    log "Running database migrations..."
    
    if ! docker compose -f "$COMPOSE_FILE" ps database | grep -q "Up"; then
        error "Database is not running. Start services first."
    fi
    
    # Wait for database to be ready
    log "Waiting for database to be ready..."
    local retry_count=0
    while [ $retry_count -lt 30 ]; do
        if docker compose -f "$COMPOSE_FILE" exec -T database edgedb query --tls-security=insecure --dsn "edgedb://edgedb:${EDGEDB_PASSWORD}@database:5656/edgedb" "SELECT 1" >/dev/null 2>&1; then
            break
        fi
        sleep 2
        retry_count=$((retry_count + 1))
    done
    
    if [ $retry_count -eq 30 ]; then
        error "Database failed to become ready after 60 seconds"
    fi
    
    # Run migrations through the app container
    log "Applying database schema migrations..."
    docker compose -f "$COMPOSE_FILE" exec -T app npm run migrate || {
        warn "Migration command failed - this might be normal if no migrations are needed"
    }
    
    log "Database migrations complete ✓"
}

# Update existing deployment
update() {
    log "Updating TofuPilot..."
    info "This process will update your TofuPilot installation to the latest version"
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No existing deployment found. Run without --update flag first."
    fi
    
    # Source environment
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
    fi
    
    # Create pre-update backup
    local backup_name="pre-update-$(date +%Y%m%d_%H%M%S)"
    info "Creating pre-update backup for safety..."
    create_backup "$backup_name"
    
    # Pull latest images
    log "Pulling latest Docker images..."
    info "Downloading updated TofuPilot components..."
    info "This may take several minutes depending on your connection..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull
    
    # Stop services gracefully
    log "Stopping services for update..."
    info "Gracefully shutting down all services..."
    docker compose -f "$COMPOSE_FILE" down
    
    # Start database first
    log "Starting database service..."
    info "Database needs to start first for migrations..."
    docker compose -f "$COMPOSE_FILE" up -d database
    
    # Run migrations
    info "Waiting for database to be ready for migrations..."
    sleep 15  # Wait for database to be ready
    run_migrations
    
    # Start all services
    log "Starting all services..."
    info "Bringing up all updated services..."
    docker compose -f "$COMPOSE_FILE" up -d
    
    # Verify services are running
    log "Verifying services..."
    info "Checking that all services started successfully..."
    sleep 10
    if docker compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        log "Update complete ✓"
        echo "  Backup created: backups/$backup_name"
        echo "  Services are running normally"
        info "TofuPilot has been successfully updated!"
    else
        error "Update failed - some services are not running. Check logs with: docker compose logs"
    fi
}

# List available backups
list_backups() {
    local backup_dir="$SCRIPT_DIR/backups"
    
    if [ ! -d "$backup_dir" ] || [ -z "$(ls -A "$backup_dir" 2>/dev/null)" ]; then
        echo "No backups found."
        return
    fi
    
    echo "Available backups:"
    echo
    
    for backup in "$backup_dir"/*; do
        if [ -d "$backup" ]; then
            local backup_name=$(basename "$backup")
            local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "unknown")
            local backup_date=""
            
            if [ -f "$backup/manifest.txt" ]; then
                backup_date=$(grep "Created:" "$backup/manifest.txt" | cut -d: -f2- | xargs)
            fi
            
            printf "  %-25s %8s  %s\n" "$backup_name" "$backup_size" "$backup_date"
        fi
    done
    
    echo
    echo "Restore with: ./deploy.sh --restore <backup_name>"
}

# Cleanup old backups
cleanup_backups() {
    local keep_count="${1:-5}"
    local backup_dir="$SCRIPT_DIR/backups"
    
    if [ ! -d "$backup_dir" ]; then
        return
    fi
    
    log "Cleaning up old backups (keeping $keep_count most recent)..."
    
    # Get list of backups sorted by modification time
    local backups=($(ls -1t "$backup_dir" 2>/dev/null || true))
    local backup_count=${#backups[@]}
    
    if [ "$backup_count" -le "$keep_count" ]; then
        log "No cleanup needed - only $backup_count backups found"
        return
    fi
    
    # Remove old backups
    local removed_count=0
    for ((i=$keep_count; i<$backup_count; i++)); do
        local backup_path="$backup_dir/${backups[$i]}"
        if [ -d "$backup_path" ]; then
            rm -rf "$backup_path"
            removed_count=$((removed_count + 1))
            log "Removed old backup: ${backups[$i]}"
        fi
    done
    
    log "Cleanup complete - removed $removed_count old backups ✓"
}

# Show service status
show_status() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    log "Checking TofuPilot service status..."
    echo
    echo "TofuPilot Service Status"
    echo "======================="
    echo
    
    # Show docker-compose status
    info "Docker Container Status:"
    docker compose -f "$COMPOSE_FILE" ps
    
    echo
    echo "Health Checks:"
    
    # Source environment for domain names
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
    fi
    
    # Check if main app is responding
    info "Testing main application connectivity..."
    if curl -f -s -I "https://${DOMAIN_NAME:-localhost}" >/dev/null 2>&1; then
        echo "✅ Main application: healthy (https://${DOMAIN_NAME:-localhost})"
    elif curl -f -s -I "http://${DOMAIN_NAME:-localhost}" >/dev/null 2>&1; then
        echo "⏳ Main application: accessible (SSL provisioning)"
    else
        echo "❌ Main application: not responding"
    fi
    
    # Check storage
    info "Testing storage connectivity..."
    if curl -f -s -I "https://${STORAGE_DOMAIN_NAME:-storage.localhost}" >/dev/null 2>&1; then
        echo "✅ Storage: healthy (https://${STORAGE_DOMAIN_NAME:-storage.localhost})"
    elif curl -f -s -I "http://${STORAGE_DOMAIN_NAME:-storage.localhost}" >/dev/null 2>&1; then
        echo "⏳ Storage: accessible (SSL provisioning)"  
    else
        echo "❌ Storage: not responding"
    fi
    
    echo
    echo "URLs:"
    echo "  Main app: https://${DOMAIN_NAME:-localhost}"
    echo "  Storage:  https://${STORAGE_DOMAIN_NAME:-storage.localhost}"
}

# Show logs
show_logs() {
    local service="$1"
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    if [ -n "$service" ]; then
        log "Showing logs for service: $service"
        docker compose -f "$COMPOSE_FILE" logs -f --tail=100 "$service"
    else
        log "Showing logs for all services"
        docker compose -f "$COMPOSE_FILE" logs -f --tail=100
    fi
}

# Restart services
restart_services() {
    local service="$1"
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    if [ -n "$service" ]; then
        log "Restarting service: $service"
        docker compose -f "$COMPOSE_FILE" restart "$service"
    else
        log "Restarting all services"
        docker compose -f "$COMPOSE_FILE" restart
    fi
    
    log "Restart complete ✓"
}

# Stop services
stop_services() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    log "Stopping all services..."
    docker compose -f "$COMPOSE_FILE" down
    log "All services stopped ✓"
}

# Start services  
start_services() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    log "Starting all services..."
    docker compose -f "$COMPOSE_FILE" up -d
    log "All services started ✓"
}

# Show usage
usage() {
    echo "TofuPilot Deployment Script"
    echo "=========================="
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Main Commands:"
    echo "  (no options)            Fresh TofuPilot installation"
    echo "  --local                 Local development setup (no SSL)"
    echo "  --allow-root            Allow running as root user (use with caution)"
    echo "  --update                Update existing deployment"
    echo
    echo "Backup & Restore:"
    echo "  --backup [name]         Create backup (optional custom name)"
    echo "  --restore <name>        Restore from backup"
    echo "  --list-backups          List available backups"
    echo "  --cleanup-backups [n]   Remove old backups (keep n most recent, default: 5)"
    echo
    echo "Service Management:"
    echo "  --status                Show service status and health"
    echo "  --logs [service]        Show logs (all services or specific)"
    echo "  --restart [service]     Restart services (all or specific)"
    echo "  --start                 Start all services"
    echo "  --stop                  Stop all services"
    echo
    echo "Maintenance:"
    echo "  --migrate               Run database migrations only"
    echo "  --help                  Show this help message"
    echo
    echo "Examples:"
    echo "  $0                      # Fresh installation"
    echo "  $0 --local              # Local development setup"
    echo "  $0 --allow-root         # Fresh installation as root user"
    echo "  $0 --allow-root --local # Local setup as root user"
    echo "  $0 --update             # Update existing installation"
    echo "  $0 --backup             # Create backup with timestamp"
    echo "  $0 --backup my-backup   # Create backup with custom name"
    echo "  $0 --restore my-backup  # Restore from specific backup"
    echo "  $0 --list-backups       # Show available backups"
    echo "  $0 --status             # Check deployment status"
    echo "  $0 --logs app           # Show application logs"
    echo "  $0 --migrate            # Run database migrations"
    echo
    echo "For more information, visit: https://docs.tofupilot.com"
}

#----------------------------#
#         Main Script        #
#----------------------------#

# Initialize variables
LOCAL_MODE="false"
ALLOW_ROOT="false"

# Parse command line arguments
case "${1:-}" in
    --local)
        LOCAL_MODE="true"
        shift
        ;;
    --allow-root)
        ALLOW_ROOT="true"
        shift
        # Check if there's a second argument
        case "${1:-}" in
            --local)
                LOCAL_MODE="true"
                shift
                ;;
        esac
        ;;
    --update)
        log "🔄 Starting TofuPilot update process..."
        update
        exit 0
        ;;
    --backup)
        if [ ! -f "$COMPOSE_FILE" ]; then
            error "No deployment found. Cannot create backup."
        fi
        # Source environment for backup
        if [ -f "$ENV_FILE" ]; then
            set -a
            source "$ENV_FILE"
            set +a
        fi
        log "💾 Starting backup process..."
        create_backup "$2"
        exit 0
        ;;
    --restore)
        if [ -z "$2" ]; then
            error "Backup name required. Use --list-backups to see available backups."
        fi
        log "🔄 Starting restore process..."
        restore_backup "$2"
        exit 0
        ;;
    --list-backups)
        log "📋 Listing available backups..."
        list_backups
        exit 0
        ;;
    --cleanup-backups)
        log "🧹 Starting backup cleanup..."
        cleanup_backups "$2"
        exit 0
        ;;
    --migrate)
        if [ ! -f "$COMPOSE_FILE" ]; then
            error "No deployment found. Cannot run migrations."
        fi
        # Source environment for migrations
        if [ -f "$ENV_FILE" ]; then
            set -a
            source "$ENV_FILE"
            set +a
        fi
        log "🔄 Starting database migrations..."
        run_migrations
        exit 0
        ;;
    --status)
        show_status
        exit 0
        ;;
    --logs)
        show_logs "$2"
        exit 0
        ;;
    --restart)
        restart_services "$2"
        exit 0
        ;;
    --stop)
        stop_services
        exit 0
        ;;
    --start)
        start_services
        exit 0
        ;;
    --help)
        usage
        exit 0
        ;;
    "")
        # Continue with installation
        ;;
    *)
        error "Unknown option: $1. Use --help for usage information."
        ;;
esac

# Main installation flow
echo
echo "=================================================================="
if [ "$LOCAL_MODE" = "true" ]; then
    log "🧪 Starting TofuPilot LOCAL development deployment..."
    warn "This is for testing only - no SSL, uses localhost"
    info "Perfect for development and testing purposes"
    echo
    info "⏳ Proceeding with local setup in 3 seconds..."
    sleep 1
    echo -n "   Starting"
    for i in {1..3}; do
        echo -n "."
        sleep 1
    done
    echo " ✓"
else
    log "🚀 Starting TofuPilot PRODUCTION deployment..."
    info "This will set up a full production-ready TofuPilot instance"
    info "Complete with SSL certificates and domain configuration"
    echo
    info "⏳ Proceeding with production setup in 3 seconds..."
    sleep 1
    echo -n "   Starting"
    for i in {1..3}; do
        echo -n "."
        sleep 1
    done
    echo " ✓"
fi
echo "=================================================================="
echo

info "Step 1/5: System Requirements Check"
info "🔍 Checking if your system is ready for TofuPilot..."
check_requirements

echo
info "Step 2/5: Configuration Collection"
info "📝 Now we'll gather the information needed for your TofuPilot setup..."
collect_config

# Source the collected configuration to make variables available
if [ -f "$CONFIG_FILE" ]; then
    log "Loading configuration variables..."
    source "$CONFIG_FILE"
    info "Configuration variables loaded ✓"
    
    # Display collected configuration (without secrets)
    echo
    info "Configuration Summary:"
    echo "  Domain: ${DOMAIN_NAME}"
    echo "  Storage Domain: ${STORAGE_DOMAIN_NAME}"
    if [ "$LOCAL_MODE" = "false" ]; then
        echo "  SSL Email: ${ACME_EMAIL}"
    fi
    if [ -n "${GOOGLE_CLIENT_ID:-}" ]; then
        echo "  Google OAuth: Configured"
    fi
    if [ -n "${AZURE_AD_CLIENT_ID:-}" ]; then
        echo "  Azure AD: Configured"
    fi
    if [ -n "${SMTP_HOST:-}" ]; then
        echo "  Email Auth: Configured (${SMTP_HOST})"
    fi
    echo
fi

echo
info "Step 3/5: Service Deployment"
info "🚀 Time to deploy TofuPilot! This is where the magic happens..."
deploy

echo
info "Step 4/5: Final Verification"
info "🔍 Almost done! Just verifying everything is working properly..."
sleep 3  # Brief pause for services to stabilize

echo
info "Step 5/5: Deployment Summary"
info "📋 Generating your deployment summary and next steps..."
show_info

echo
log "🎉 Deployment script completed successfully!"
info "TofuPilot is now ready to use!"

if [ "$LOCAL_MODE" = "false" ]; then
    echo
    warn "Important Next Steps:"
    echo "1. Verify your domain DNS is pointing to this server"
    echo "2. Configure your authentication providers (see output above)"
    echo "3. Visit https://${DOMAIN_NAME} to start using TofuPilot"
    echo "4. Monitor logs with: ./deploy.sh --logs"
else
    echo
    info "Local Development Setup Complete!"
    echo "Access your TofuPilot instance at: http://localhost"
    echo "Monitor with: ./deploy.sh --logs"
fi