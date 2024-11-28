#!/bin/bash

# Script Vars
REPO_URL="https://github.com/tofupilot/self-hosting.git"
TOFUPILOT_DIR=~/tofupilot

# Pull the latest changes from the Git repository
if [ -d "$TOFUPILOT_DIR" ]; then
  echo "Pulling latest changes from the repository..."
  cd $TOFUPILOT_DIR
  git pull origin main
else
  echo "Cloning repository from $REPO_URL..."
  git clone $REPO_URL $TOFUPILOT_DIR
  cd $TOFUPILOT_DIR
fi

# Build and restart the Docker containers from the app directory (~/tofupilot)
echo "Rebuilding and restarting Docker containers..."
docker-compose down
docker-compose up -d --pull always

# Check if Docker Compose started correctly
if ! docker-compose ps | grep "Up"; then
  echo "Docker containers failed to start. Check logs with 'docker-compose logs'."
  exit 1
fi

# Output final message
echo "Update complete. Your TofuPilot app has been deployed with the latest changes."