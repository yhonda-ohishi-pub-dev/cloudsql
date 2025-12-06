#!/bin/bash

# CloudSQL Migration Deploy Script
# Usage: ./scripts/deploy.sh [postgres|mysql] [environment]

set -e

DB_TYPE=${1:-postgres}
ENVIRONMENT=${2:-production}

echo "=========================================="
echo "CloudSQL Migration Deploy"
echo "Database: $DB_TYPE"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# Check if gcloud is authenticated
if ! gcloud auth print-identity-token &> /dev/null; then
    echo "Error: Not authenticated with gcloud. Run 'gcloud auth login' first."
    exit 1
fi

# Load environment-specific config
CONFIG_FILE="./configs/config.${DB_TYPE}.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Build the migration tool
echo "Building migration tool..."
make build

# Run migrations
echo "Running migrations..."
./bin/migrate --db="$DB_TYPE" --config="$CONFIG_FILE" --cloudsql up

echo "=========================================="
echo "Migration completed successfully!"
echo "=========================================="
