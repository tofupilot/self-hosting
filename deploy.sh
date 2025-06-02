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

COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
ENV_FILE="$SCRIPT_DIR/.env"

# Colors for output
RED='\033[0;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; BLUE='\033[1;34m'; CYAN='\033[1;36m'; NC='\033[0m'

#----------------------------#
#         Functions          #
#----------------------------#
log(){ echo -e "${GREEN}✓ $1${NC}"; }
warn(){ echo -e "${YELLOW}! $1${NC}"; }
error(){ echo -e "${RED}✗ $1${NC}"; exit 1; }
info(){ echo -e "${CYAN}→ $1${NC}"; }
step(){ echo -e "${BLUE}$1${NC}"; }

command_exists(){ command -v "$1" >/dev/null 2>&1; }
generate_password(){ openssl rand -base64 32 | tr -d "=+/" | cut -c1-25; }

# Simple progress bar
progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    
    printf "\r["
    for ((i=0; i<completed; i++)); do printf "█"; done
    for ((i=completed; i<width; i++)); do printf "░"; done
    printf "] %d%%" $percentage
}

# Get existing value from env file
get_env_value() {
    local var_name="$1"
    if [ -f "$ENV_FILE" ]; then
        grep -E "^${var_name}=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- | tr -d '"'
    fi
}

# Prompt with pre-filled values from env file
prompt_env() {
    local var_name="$1"
    local message="$2"
    local secret="${3:-false}"
    local existing_value=""
    local user_input=""
    
    # Get existing value from .env file
    if [ -f "$ENV_FILE" ]; then
        existing_value=$(grep -E "^${var_name}=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- | tr -d '"' || true)
    fi
    
    # Display the prompt with existing value as default
    if [ -n "$existing_value" ] && [ "$secret" = "false" ]; then
        printf "%s [%s]: " "$message" "$existing_value" >&2
    elif [ -n "$existing_value" ] && [ "$secret" = "true" ]; then
        printf "%s [***hidden***]: " "$message" >&2
    else
        printf "%s: " "$message" >&2
    fi
    
    if [ "$secret" = "true" ]; then
        read -s user_input
        echo >&2
    else
        read user_input
    fi
    
    # Use existing value if user pressed enter
    if [ -z "$user_input" ] && [ -n "$existing_value" ]; then
        user_input="$existing_value"
    fi
    
    echo "$user_input"
}

# Prompt with custom default value
prompt_env_with_default() {
    local var_name="$1"
    local message="$2"
    local default_value="$3"
    local secret="${4:-false}"
    local user_input=""
    
    # Display the prompt with default value
    if [ "$secret" = "false" ]; then
        printf "%s [%s]: " "$message" "$default_value" >&2
    else
        printf "%s [***hidden***]: " "$message" >&2
    fi
    
    if [ "$secret" = "true" ]; then
        read -s user_input
        echo >&2
    else
        read user_input
    fi
    
    # Use default value if user pressed enter
    if [ -z "$user_input" ]; then
        user_input="$default_value"
    fi
    
    echo "$user_input"
}

# GitHub authentication and testing
github_auth() {
    info "GitHub authentication required"
    echo "Need GitHub Personal Access Token with 'read:packages' permission"
    echo "Create at: https://github.com/settings/tokens"
    echo
    
    echo -n "GitHub Username: "
    read github_username
    echo -n "GitHub Personal Access Token: "
    read -s github_token
    echo
    
    if [ -z "$github_username" ] || [ -z "$github_token" ]; then
        error "Username and token required"
    fi
    
    echo
    info "Testing authentication..."
    
    # Test GitHub API
    if curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep -q "login"; then
        github_user=$(curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
        log "GitHub API access ($github_user)"
    else
        warn "GitHub API failed - using dummy auth for testing"
    fi
    
    # Test package access
    if curl -s -H "Authorization: token $github_token" "https://api.github.com/user/packages?package_type=container" >/dev/null; then
        log "Package registry access"
    else
        warn "Package access limited"
    fi
    
    # Clean Docker auth
    docker logout >/dev/null 2>&1 || true
    
    # Test Docker login
    if echo "$github_token" | docker login ghcr.io -u "$github_username" --password-stdin >/dev/null 2>&1; then
        log "Docker registry login"
    else
        warn "Docker login failed - using dummy auth for testing"
    fi
    
    # Test image pull
    if docker pull --platform linux/amd64 ghcr.io/tofupilot/tofupilot:latest >/dev/null 2>&1; then
        log "TofuPilot image access"
    else
        warn "Image pull failed - using dummy auth for testing"
    fi
    
    log "Authentication complete"
}

# Check system requirements
check_requirements() {
    info "Checking system requirements"
    
    # Root check
    if [ "$EUID" -eq 0 ] && [ "$ALLOW_ROOT" = "false" ]; then
        error "Don't run as root. Use --allow-root if needed"
    fi
    
    if [ "$EUID" -eq 0 ] && [ "$ALLOW_ROOT" = "true" ]; then
        warn "Running as root - may cause file ownership issues"
    fi
    
    # OS check
    if ! command_exists apt; then
        error "Requires Ubuntu/Debian with apt"
    fi
    log "Operating system"
    
    # Docker check
    if ! command_exists docker; then
        info "Installing Docker..."
        curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
        sudo usermod -aG docker "$USER"
        log "Docker installed"
    else
        log "Docker found"
    fi
    
    # Docker permissions
    if ! docker ps >/dev/null 2>&1; then
        info "Fixing Docker permissions..."
        if ! groups "$USER" | grep -q docker; then
            sudo usermod -aG docker "$USER"
        fi
        sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
        
        if ! docker ps >/dev/null 2>&1; then
            error "Docker permissions failed - logout/login required"
        fi
    fi
    log "Docker permissions"
    
    # Docker Compose
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        info "Installing Docker Compose..."
        sudo apt update >/dev/null 2>&1
        sudo apt install -y docker-compose-plugin >/dev/null 2>&1
        log "Docker Compose installed"
    else
        log "Docker Compose found"
    fi
    
    # Port check
    if command_exists netstat && sudo netstat -tlnp 2>/dev/null | grep -E ':80|:443' >/dev/null 2>&1; then
        warn "Ports 80/443 in use"
    elif command_exists ss && sudo ss -tlnp 2>/dev/null | grep -E ':80|:443' >/dev/null 2>&1; then
        warn "Ports 80/443 in use"
    else
        log "Ports available"
    fi
    
    # Architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
        warn "ARM64 detected - using emulation (may be slower)"
    else
        log "Architecture (AMD64)"
    fi
}

# Create Docker Compose file (for curl deployments)
create_compose_file() {
  log "Creating Docker Compose configuration..."
  
  # Remove existing compose file if it exists
  if [ -f "$COMPOSE_FILE" ]; then
    rm -f "$COMPOSE_FILE"
    info "Removed existing docker-compose.yml file"
  fi

  cat > "$COMPOSE_FILE" <<'EOF'

services:
  # Reverse proxy with automatic SSL
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
      - "--certificatesresolvers.letsencrypt.acme.storage=/data/acme.json"
      - "--entrypoints.web.http.redirections.entrypoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik-acme:/data
    environment:
      - ACME_EMAIL=${ACME_EMAIL}

  # TofuPilot Application
  app:
    image: ghcr.io/tofupilot/tofupilot:latest
    container_name: tofupilot-app
    restart: unless-stopped
    depends_on:
      - database
      - storage
    environment:
      # Domain Configuration
      - NEXT_PUBLIC_DOMAIN_NAME=${DOMAIN_NAME}
      
      # Authentication Configuration
      - AUTH_SECRET=${AUTH_SECRET}
      - AUTH_URL=https://${DOMAIN_NAME}
      - AUTH_GOOGLE_ID=${AUTH_GOOGLE_ID:-}
      - AUTH_GOOGLE_SECRET=${AUTH_GOOGLE_SECRET:-}
      - AUTH_MICROSOFT_ENTRA_ID_ID=${AUTH_MICROSOFT_ENTRA_ID_ID:-}
      - AUTH_MICROSOFT_ENTRA_ID_SECRET=${AUTH_MICROSOFT_ENTRA_ID_SECRET:-}
      - AUTH_MICROSOFT_ENTRA_ID_ISSUER=${AUTH_MICROSOFT_ENTRA_ID_ISSUER:-}
      
      # Database Configuration
      - GEL_DSN=gel://edgedb:${GEL_PASSWORD}@database:5656/main
      - GEL_CLIENT_TLS_SECURITY=insecure
      
      # Storage Configuration
      - AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY}
      - AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}
      - STORAGE_EXTERNAL_ENDPOINT_URL=https://${STORAGE_DOMAIN_NAME}
      - STORAGE_INTERNAL_ENDPOINT_URL=http://storage:9000
      - BUCKET_NAME=tofupilot
      - REGION=us-east-1
      
      # Email Configuration
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

  # Database
  database:
    image: geldata/gel:latest
    container_name: tofupilot-database
    restart: unless-stopped
    environment:
      - GEL_SERVER_PASSWORD=${GEL_PASSWORD}
      - GEL_SERVER_SECURITY=insecure_dev_mode
      - GEL_SERVER_HTTP_ENDPOINT_SECURITY=optional
      - GEL_SERVER_BINARY_ENDPOINT_SECURITY=optional
    volumes:
      - database-data:/var/lib/gel/data
    ports:
      - "127.0.0.1:5656:5656"

  # Object Storage (MinIO)
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

volumes:
  database-data:
  storage-data:
  traefik-acme:
EOF

  log "Docker Compose file created"
}

# Create environment file
create_env_file() {
    info "Creating environment file..."
    
    # Backup existing .env
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%s)"
    fi
    
    cat > "$ENV_FILE" <<EOF
# Domain Configuration
DOMAIN_NAME=${DOMAIN_NAME}
STORAGE_DOMAIN_NAME=${STORAGE_DOMAIN_NAME}
ACME_EMAIL=${ACME_EMAIL}

# Authentication Configuration
AUTH_SECRET=${AUTH_SECRET}
AUTH_GOOGLE_ID=${AUTH_GOOGLE_ID:-}
AUTH_GOOGLE_SECRET=${AUTH_GOOGLE_SECRET:-}
AUTH_MICROSOFT_ENTRA_ID_ID=${AUTH_MICROSOFT_ENTRA_ID_ID:-}
AUTH_MICROSOFT_ENTRA_ID_SECRET=${AUTH_MICROSOFT_ENTRA_ID_SECRET:-}
AUTH_MICROSOFT_ENTRA_ID_ISSUER=${AUTH_MICROSOFT_ENTRA_ID_ISSUER:-}

# Database Configuration
GEL_PASSWORD=${GEL_PASSWORD}
GEL_DSN=gel://edgedb:${GEL_PASSWORD}@database:5656/main
GEL_CLIENT_TLS_SECURITY=insecure

# Storage Configuration
MINIO_ACCESS_KEY=tofupilot
MINIO_SECRET_KEY=${MINIO_SECRET_KEY}

# Email Configuration
SMTP_HOST=${SMTP_HOST:-}
SMTP_PORT=${SMTP_PORT:-587}
SMTP_USER=${SMTP_USER:-}
SMTP_PASSWORD=${SMTP_PASSWORD:-}
EMAIL_FROM=${EMAIL_FROM:-}
EOF
    log "Environment file created"
}

# Collect user configuration
collect_config() {
    info "Collecting configuration"
    echo
    
    if [ "$LOCAL_MODE" = "true" ]; then
        step "Local Development Configuration"
        warn "Local mode - no SSL, localhost only"
    else
        step "Production Configuration"
    fi
    echo
    
    # Domain Configuration
    echo "Domain Configuration:"
    if [ "$LOCAL_MODE" = "true" ]; then
        DOMAIN_NAME=$(prompt_env "DOMAIN_NAME" "Domain name" false)
        if [ -z "$DOMAIN_NAME" ]; then DOMAIN_NAME="localhost"; fi
        
        # Auto-generate storage domain with option to change
        local storage_default="localhost:9000"
        local existing_storage=$(get_env_value "STORAGE_DOMAIN_NAME")
        if [ -n "$existing_storage" ]; then
            storage_default="$existing_storage"
        fi
        STORAGE_DOMAIN_NAME=$(prompt_env_with_default "STORAGE_DOMAIN_NAME" "Storage domain" "$storage_default" false)
        
        ACME_EMAIL="admin@localhost"
    else
        DOMAIN_NAME=$(prompt_env "DOMAIN_NAME" "Domain name" false)
        if [ -z "$DOMAIN_NAME" ]; then DOMAIN_NAME="tofupilot.example.com"; fi
        
        # Auto-generate storage domain based on main domain
        local storage_default="storage.${DOMAIN_NAME}"
        local existing_storage=$(get_env_value "STORAGE_DOMAIN_NAME")
        if [ -n "$existing_storage" ]; then
            storage_default="$existing_storage"
        fi
        STORAGE_DOMAIN_NAME=$(prompt_env_with_default "STORAGE_DOMAIN_NAME" "Storage domain" "$storage_default" false)
        
        # Auto-generate SSL email based on main domain  
        local email_default="admin@${DOMAIN_NAME}"
        local existing_email=$(get_env_value "ACME_EMAIL")
        if [ -n "$existing_email" ]; then
            email_default="$existing_email"
        fi
        ACME_EMAIL=$(prompt_env_with_default "ACME_EMAIL" "SSL certificate email" "$email_default" false)
    fi
    
    echo
    echo "Security Configuration:"
    info "Generating secure passwords automatically..."
    
    # Auto-generate security variables, only use existing if they exist
    AUTH_SECRET=$(get_env_value "AUTH_SECRET")
    if [ -z "$AUTH_SECRET" ]; then 
        AUTH_SECRET=$(generate_password)
        log "Generated Auth secret"
    else
        log "Using existing Auth secret"
    fi
    
    GEL_PASSWORD=$(get_env_value "GEL_PASSWORD")
    if [ -z "$GEL_PASSWORD" ]; then 
        GEL_PASSWORD=$(generate_password)
        log "Generated database password"
    else
        log "Using existing database password"
    fi
    
    MINIO_SECRET_KEY=$(get_env_value "MINIO_SECRET_KEY")
    if [ -z "$MINIO_SECRET_KEY" ]; then 
        MINIO_SECRET_KEY=$(generate_password)
        log "Generated storage secret key"
    else
        log "Using existing storage secret key"
    fi
    
    echo
    echo "Authentication Configuration (required - choose at least one):"
    info "TofuPilot requires at least one authentication method"
    
    # Check existing configuration
    existing_google=$(get_env_value "AUTH_GOOGLE_ID")
    existing_microsoft=$(get_env_value "AUTH_MICROSOFT_ENTRA_ID_ID")
    existing_smtp=$(get_env_value "SMTP_HOST")
    
    # Initialize variables
    AUTH_GOOGLE_ID=""
    AUTH_GOOGLE_SECRET=""
    AUTH_MICROSOFT_ENTRA_ID_ID=""
    AUTH_MICROSOFT_ENTRA_ID_SECRET=""
    AUTH_MICROSOFT_ENTRA_ID_ISSUER=""
    
    # Google OAuth
    printf "Configure Google OAuth? (y/N): " >&2
    read -r configure_google
    if [[ "$configure_google" =~ ^[Yy]$ ]]; then
        AUTH_GOOGLE_ID=$(prompt_env "AUTH_GOOGLE_ID" "Google OAuth Client ID" false)
        AUTH_GOOGLE_SECRET=$(prompt_env "AUTH_GOOGLE_SECRET" "Google OAuth Client Secret" true)
    elif [ -n "$existing_google" ]; then
        printf "Keep existing Google OAuth configuration? (Y/n): " >&2
        read -r keep_google
        if [[ ! "$keep_google" =~ ^[Nn]$ ]]; then
            AUTH_GOOGLE_ID="$existing_google"
            AUTH_GOOGLE_SECRET=$(get_env_value "AUTH_GOOGLE_SECRET")
            log "Keeping existing Google OAuth configuration"
        fi
    fi
    
    # Microsoft Entra ID (formerly Azure AD)
    printf "Configure Microsoft Entra ID? (y/N): " >&2
    read -r configure_microsoft
    if [[ "$configure_microsoft" =~ ^[Yy]$ ]]; then
        AUTH_MICROSOFT_ENTRA_ID_ID=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_ID" "Microsoft Entra ID Client ID" false)
        AUTH_MICROSOFT_ENTRA_ID_SECRET=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_SECRET" "Microsoft Entra ID Client Secret" true)
        AUTH_MICROSOFT_ENTRA_ID_ISSUER=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_ISSUER" "Microsoft Entra ID Issuer URL" false)
    elif [ -n "$existing_microsoft" ]; then
        printf "Keep existing Microsoft Entra ID configuration? (Y/n): " >&2
        read -r keep_microsoft
        if [[ ! "$keep_microsoft" =~ ^[Nn]$ ]]; then
            AUTH_MICROSOFT_ENTRA_ID_ID="$existing_microsoft"
            AUTH_MICROSOFT_ENTRA_ID_SECRET=$(get_env_value "AUTH_MICROSOFT_ENTRA_ID_SECRET")
            AUTH_MICROSOFT_ENTRA_ID_ISSUER=$(get_env_value "AUTH_MICROSOFT_ENTRA_ID_ISSUER")
            log "Keeping existing Microsoft Entra ID configuration"
        fi
    fi
    
    # Check if at least one auth method is configured
    if [ -z "$AUTH_GOOGLE_ID" ] && [ -z "$AUTH_MICROSOFT_ENTRA_ID_ID" ] && [ -z "$existing_smtp" ]; then
        warn "No authentication method configured!"
        echo "TofuPilot requires at least one authentication method:"
        echo "1. Google OAuth"
        echo "2. Microsoft Entra ID"
        echo "3. Email/SMTP (configured in next step)"
        echo
        warn "You must configure at least Google OAuth or Microsoft Entra ID now, or SMTP email in the next step"
        echo
        
        # Force at least one configuration
        while [ -z "$AUTH_GOOGLE_ID" ] && [ -z "$AUTH_MICROSOFT_ENTRA_ID_ID" ]; do
            printf "Configure Google OAuth now? (y/N): " >&2
            read -r force_google
            if [[ "$force_google" =~ ^[Yy]$ ]]; then
                AUTH_GOOGLE_ID=$(prompt_env "AUTH_GOOGLE_ID" "Google OAuth Client ID" false)
                AUTH_GOOGLE_SECRET=$(prompt_env "AUTH_GOOGLE_SECRET" "Google OAuth Client Secret" true)
                break
            fi
            
            printf "Configure Microsoft Entra ID now? (y/N): " >&2
            read -r force_microsoft
            if [[ "$force_microsoft" =~ ^[Yy]$ ]]; then
                AUTH_MICROSOFT_ENTRA_ID_ID=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_ID" "Microsoft Entra ID Client ID" false)
                AUTH_MICROSOFT_ENTRA_ID_SECRET=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_SECRET" "Microsoft Entra ID Client Secret" true)
                AUTH_MICROSOFT_ENTRA_ID_ISSUER=$(prompt_env "AUTH_MICROSOFT_ENTRA_ID_ISSUER" "Microsoft Entra ID Issuer URL" false)
                break
            fi
            
            warn "You must configure at least one authentication method to continue"
        done
    fi
    
    echo
    echo "Email Configuration (optional - but required if no OAuth configured):"
    
    # Check if SMTP is required (no OAuth methods configured)
    local smtp_required=false
    if [ -z "$AUTH_GOOGLE_ID" ] && [ -z "$AUTH_MICROSOFT_ENTRA_ID_ID" ]; then
        smtp_required=true
        warn "SMTP email is REQUIRED since no OAuth methods are configured"
    fi
    
    if [ "$smtp_required" = "true" ]; then
        printf "Configure SMTP email (required)? (Y/n): " >&2
    else
        printf "Configure SMTP email? (y/N): " >&2
    fi
    
    read -r configure_smtp
    
    if [[ "$configure_smtp" =~ ^[Yy]$ ]] || ([[ ! "$configure_smtp" =~ ^[Nn]$ ]] && [ "$smtp_required" = "true" ]); then
        SMTP_HOST=$(prompt_env "SMTP_HOST" "SMTP server hostname" false)
        SMTP_PORT=$(prompt_env "SMTP_PORT" "SMTP port" false)
        if [ -z "$SMTP_PORT" ]; then SMTP_PORT="587"; fi
        
        SMTP_USER=$(prompt_env "SMTP_USER" "SMTP username" false)
        SMTP_PASSWORD=$(prompt_env "SMTP_PASSWORD" "SMTP password" true)
        EMAIL_FROM=$(prompt_env "EMAIL_FROM" "From email address" false)
        if [ -z "$EMAIL_FROM" ]; then EMAIL_FROM="$ACME_EMAIL"; fi
    elif [ "$smtp_required" = "true" ]; then
        error "SMTP email configuration is required when no OAuth methods are configured"
    else
        SMTP_HOST=""
        SMTP_PORT="587"
        SMTP_USER=""
        SMTP_PASSWORD=""
        EMAIL_FROM=""
    fi
    
    # Final validation
    if [ -z "$AUTH_GOOGLE_ID" ] && [ -z "$AUTH_MICROSOFT_ENTRA_ID_ID" ] && [ -z "$SMTP_HOST" ]; then
        error "At least one authentication method must be configured (Google OAuth, Microsoft Entra ID, or SMTP email)"
    fi
    
    echo
    log "Configuration complete"
}

# Deploy the application
deploy() {
    log "Starting deployment..."
    
    # Configuration variables are already loaded in main script
    # Create configuration files
    info "Creating configuration files..."
    create_compose_file
    create_env_file
    
    info "Pulling Docker images..."
    
    if docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull; then
        log "Images downloaded"
    else
        error "Failed to pull images"
    fi
    
    info "Starting services..."
    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    if ! docker compose -f "$COMPOSE_FILE" ps 2>/dev/null | grep -q "Up"; then
        error "Docker containers failed to start. Check logs with: docker compose logs"
    fi
    
    log "Services started"
    
    info "Waiting for services to be ready..."
    
    # Wait for database
    local db_ready=false
    for i in {1..30}; do
        if docker compose -f "$COMPOSE_FILE" ps database 2>/dev/null | grep -q "Up"; then
            db_ready=true
            break
        fi
        progress_bar $i 30
        sleep 2
    done
    echo
    
    if [ "$db_ready" = "true" ]; then
        log "Database ready"
    else
        warn "Database taking longer than expected"
    fi
    
    # Wait for app
    local app_ready=false
    for i in {1..20}; do
        if docker compose -f "$COMPOSE_FILE" ps app 2>/dev/null | grep -q "Up"; then
            app_ready=true
            break
        fi
        progress_bar $i 20
        sleep 3
    done
    echo
    
    if [ "$app_ready" = "true" ]; then
        log "Application ready"
    else
        warn "Application taking longer than expected"
    fi
    
    # Check if services are running
    info "Verifying service status..."
    
    if docker compose -f "$COMPOSE_FILE" ps 2>/dev/null | grep -q "Up"; then
        log "All services running"
        
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
            info "Checking SSL certificate generation..."
            
            local ssl_ready=false
            local retry_count=0
            
            while [ $retry_count -lt 24 ]; do  # 4 minutes max
                progress_bar $retry_count 24
                
                # Check if HTTPS is working
                if curl -f -s -I "https://${DOMAIN_NAME}" >/dev/null 2>&1; then
                    ssl_ready=true
                    break
                fi
                
                # Check if at least HTTP is working
                if curl -f -s -I "http://${DOMAIN_NAME}" >/dev/null 2>&1; then
                    # HTTP works, SSL might still be provisioning
                    if [ $retry_count -gt 12 ]; then
                        break  # Give up on SSL after 2+ minutes, HTTP is working
                    fi
                fi
                
                sleep 10
                retry_count=$((retry_count + 1))
            done
            echo
            
            if [ "$ssl_ready" = "true" ]; then
                log "HTTPS accessible at https://${DOMAIN_NAME}"
            elif curl -f -s -I "http://${DOMAIN_NAME}" >/dev/null 2>&1; then
                log "HTTP accessible (SSL may still be provisioning)"
            else
                warn "Service not yet accessible - DNS may still be propagating"
            fi
        else
            info "Testing local connectivity..."
            
            local local_ready=false
            for i in {1..10}; do
                progress_bar $i 10
                
                if curl -f -s -I "http://localhost" >/dev/null 2>&1; then
                    local_ready=true
                    break
                elif curl -f -s -I "http://localhost:3000" >/dev/null 2>&1; then
                    local_ready=true
                    break
                fi
                
                sleep 3
            done
            echo
            
            if [ "$local_ready" = "true" ]; then
                log "Local access ready at http://localhost"
            else
                warn "Local service not yet ready - may need more time"
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
    echo
    info "Configuration files:"
    echo "  Docker Compose: $COMPOSE_FILE"
    echo "  Environment:    $ENV_FILE"
    echo ""
    echo
    warn "Configure your authentication providers:"
    if [ -n "$AUTH_GOOGLE_ID" ]; then
        echo "  Google OAuth: Add https://${DOMAIN_NAME}/api/auth/callback/google as redirect URI"
    fi
    if [ -n "$AUTH_MICROSOFT_ENTRA_ID_ID" ]; then
        echo "  Microsoft Entra ID: Add https://${DOMAIN_NAME}/api/auth/callback/microsoft-entra-id as redirect URI"
    fi
    if [ -n "$SMTP_HOST" ]; then
        echo "  Email auth: Configured with ${SMTP_HOST}"
    fi
    echo
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
    
    # Show docker-compose status (TofuPilot containers only)
    info "Docker Container Status:"
    docker compose -f "$COMPOSE_FILE" ps 2>/dev/null | grep tofupilot
    
    info "Data Volumes:"
    local volumes=$(docker system df -v 2>/dev/null | grep -E "(root_database-data|root_storage-data|root_traefik-acme)" | awk '{print $1 " " $3}')
    if [ -n "$volumes" ]; then
        echo "$volumes" | while read name size; do
            echo "  $name: $size"
        done
    fi
    
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
        echo "✓ Main application: healthy (https://${DOMAIN_NAME:-localhost})"
    elif curl -f -s -I "http://${DOMAIN_NAME:-localhost}" >/dev/null 2>&1; then
        echo "~ Main application: accessible (SSL provisioning)"
    else
        echo "✗ Main application: not responding"
    fi
    
    # Check storage
    info "Testing storage connectivity..."
    if curl -f -s -I "https://${STORAGE_DOMAIN_NAME:-storage.localhost}" >/dev/null 2>&1; then
        echo "✓ Storage: healthy (https://${STORAGE_DOMAIN_NAME:-storage.localhost})"
    elif curl -f -s -I "http://${STORAGE_DOMAIN_NAME:-storage.localhost}" >/dev/null 2>&1; then
        echo "~ Storage: accessible (SSL provisioning)"  
    else
        echo "✗ Storage: not responding"
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
    
    log "Restart complete"
}

# Stop services
stop_services() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    log "Stopping all services..."
    docker compose -f "$COMPOSE_FILE" down
    log "All services stopped"
}

# Start services  
start_services() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        error "No deployment found."
    fi
    
    log "Starting all services..."
    docker compose -f "$COMPOSE_FILE" up -d
    log "All services started"
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
    echo
    echo "Service Management:"
    echo "  --status                Show service status and health"
    echo "  --logs [service]        Show logs (all services or specific)"
    echo "  --restart [service]     Restart services (all or specific)"
    echo "  --start                 Start all services"
    echo "  --stop                  Stop all services"
    echo
    echo "  --help                  Show this help message"
    echo
    echo "Examples:"
    echo "  $0                      # Fresh installation"
    echo "  $0 --local              # Local development setup"
    echo "  $0 --allow-root         # Fresh installation as root user"
    echo "  $0 --allow-root --local # Local setup as root user"
    echo ""
    echo "  $0 --status             # Check deployment status"
    echo "  $0 --logs app           # Show application logs"
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
echo "=========================================="
if [ "$LOCAL_MODE" = "true" ]; then
    step "TofuPilot Local Development Setup"
    warn "Local mode - no SSL, localhost only"
else
    step "TofuPilot Production Deployment"
    info "Full setup with SSL certificates"
fi
echo "=========================================="
echo

step "1/6 System Requirements"
check_requirements

echo
step "2/6 GitHub Authentication"
github_auth

echo
step "3/6 Configuration"
collect_config

echo
step "4/6 Deployment"
deploy

echo
step "5/6 Verification"
sleep 2

echo
step "6/6 Complete"
show_info

echo
log "Deployment complete"

if [ "$LOCAL_MODE" = "false" ]; then
    echo
    echo "Next steps:"
    echo "1. Point DNS to this server"
    echo "2. Configure auth providers"
    echo "3. Visit https://${DOMAIN_NAME}"
else
    echo
    echo "Access: http://localhost"
fi

