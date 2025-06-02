#!/usr/bin/env sh
# This file defines steps to execute before startup of the tofupilot Docker container

# Make sure that script exists when any error occurs
set -e

# Define dump directory (use /tmp for permissions)
DUMP_DIR="${DUMP_DIR:-/tmp/backups}"
mkdir -p "$DUMP_DIR"

# Extract version from package.json (BusyBox compatible)
PACKAGE_VERSION=$(jq -r '.version' package.json 2>/dev/null || grep -o '"version":[[:space:]]*"[0-9]\+\.[0-9]\+\.[0-9]\+"' package.json | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

# Ensure the version is extracted
if [ -z "$PACKAGE_VERSION" ]; then
  echo "Error: Unable to extract version from package.json"
  exit 1
fi

# Dump database
DUMP_FILE="${DUMP_DIR}/$(date +%Y%m%d)_v${PACKAGE_VERSION}.dump"
echo "Dumping database to $DUMP_FILE"
gel dump --to "$DUMP_FILE"

# Compress dump file to save space (optional)
gzip "$DUMP_FILE"
echo "Database dumped and compressed: ${DUMP_FILE}.gz"

# Run migrations
echo "Running database migrations..."
gel migrate --branch main

# Delete dumps older than 7 days
echo "Deleting dumps older than 7 days in $DUMP_DIR"
find "$DUMP_DIR" -type f -name "*.dump.gz" -mtime +7 -exec rm -f {} \;

# Start server
echo "Starting Next.js server"
exec "$@"