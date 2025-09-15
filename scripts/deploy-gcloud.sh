#!/bin/bash
set -e

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
SERVICE_NAME="fastapi-service"

echo "🚀 Starting Google Cloud deployment process..."

# Check if gcloud is installed
