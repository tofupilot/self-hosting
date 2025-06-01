#!/bin/bash
# GitHub PAT and Docker Authentication Test Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
warn() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}"; }
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

echo "=============================================="
echo "GitHub PAT & Docker Authentication Test"
echo "=============================================="
echo

# Get credentials
echo -n "GitHub Username: "
read github_username

echo -n "GitHub Personal Access Token: "
read -s github_token
echo

if [ -z "$github_username" ] || [ -z "$github_token" ]; then
    error "Username and token are required"
    exit 1
fi

echo
log "Starting authentication tests..."

# Test 1: GitHub API access
echo
info "Test 1: Testing GitHub API access with PAT..."
if curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep -q "login"; then
    log "✓ GitHub API access successful"
    github_user=$(curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep '"login"' | cut -d'"' -f4)
    info "Authenticated as: $github_user"
else
    error "✗ GitHub API access failed - check your PAT"
    echo "Make sure your PAT has the following permissions:"
    echo "  - read:packages (required)"
    echo "  - repo (if accessing private repos)"
    exit 1
fi

# Test 2: Package registry access
echo
info "Test 2: Testing GitHub Packages API access..."
if curl -s -H "Authorization: token $github_token" "https://api.github.com/user/packages?package_type=container" >/dev/null; then
    log "✓ GitHub Packages API access successful"
else
    warn "⚠ GitHub Packages API access limited (this may be normal)"
fi

# Test 3: Docker logout and clean slate
echo
info "Test 3: Cleaning Docker authentication state..."
docker logout >/dev/null 2>&1 || true
log "✓ Docker logout completed"

# Test 4: Docker login to ghcr.io
echo
info "Test 4: Testing Docker login to GitHub Container Registry..."
if echo "$github_token" | docker login ghcr.io -u "$github_username" --password-stdin >/dev/null 2>&1; then
    log "✓ Docker login to ghcr.io successful"
else
    error "✗ Docker login to ghcr.io failed"
    echo "Possible issues:"
    echo "  1. PAT doesn't have 'read:packages' permission"
    echo "  2. PAT is expired or invalid"
    echo "  3. Username is incorrect"
    exit 1
fi

# Test 5: Test pull specific TofuPilot image
echo
info "Test 5: Testing access to TofuPilot image..."
if docker pull --platform linux/amd64 ghcr.io/tofupilot/tofupilot:latest >/dev/null 2>&1; then
    log "✓ TofuPilot image pull successful"
    
    # Get image info
    image_id=$(docker images ghcr.io/tofupilot/tofupilot:latest --format "{{.ID}}")
    image_size=$(docker images ghcr.io/tofupilot/tofupilot:latest --format "{{.Size}}")
    info "Image ID: $image_id"
    info "Image Size: $image_size"
else
    error "✗ TofuPilot image pull failed"
    echo "This could mean:"
    echo "  1. You don't have access to the tofupilot/tofupilot repository"
    echo "  2. The repository doesn't exist or is private"
    echo "  3. PAT permissions are insufficient"
    exit 1
fi

# Test 6: Test docker compose authentication
echo
info "Test 6: Creating test docker-compose.yml and testing pull..."

cat > test-compose.yml <<EOF
version: '3.8'
services:
  test-app:
    image: ghcr.io/tofupilot/tofupilot:latest
    platform: linux/amd64
EOF

if docker compose -f test-compose.yml pull >/dev/null 2>&1; then
    log "✓ Docker Compose pull successful"
else
    error "✗ Docker Compose pull failed"
    echo "This suggests an issue with compose-specific authentication"
    
    # Debug info
    echo
    warn "Debug information:"
    echo "Docker version: $(docker --version)"
    echo "Docker Compose version: $(docker compose version)"
    echo "Current Docker auth:"
    cat ~/.docker/config.json 2>/dev/null | grep -A 5 -B 5 "ghcr.io" || echo "No ghcr.io auth found"
fi

# Cleanup
rm -f test-compose.yml

echo
log "=== AUTHENTICATION TEST SUMMARY ==="
info "If all tests passed, your authentication should work with the deploy script"
info "If any tests failed, fix those issues before running the deployment"

echo
info "To use these credentials with the deploy script:"
echo "1. Run: bash <(curl -s URL) --allow-root"
echo "2. When prompted for GitHub auth, choose option 1 (PAT)"
echo "3. Enter username: $github_username"
echo "4. Enter the same PAT you just tested"

echo
warn "Keep your PAT secure and never share it publicly!"