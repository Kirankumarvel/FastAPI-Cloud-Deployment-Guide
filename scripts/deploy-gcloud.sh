#!/bin/bash
set -e

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
SERVICE_NAME="fastapi-service"

echo "🚀 Starting Google Cloud deployment process..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK is not installed. Please install it first."
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ Not authenticated with Google Cloud. Please run: gcloud auth login"
    exit 1
fi

# Set project
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project configured. Please set a project: gcloud config set project PROJECT_ID"
    exit 1
fi

echo "✅ Google Cloud Project: $PROJECT_ID"

# Enable required services
echo "🔧 Enabling required Google Cloud services..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Build and deploy
echo "🐳 Building and deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --source . \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars="CLOUD_PROVIDER=google-cloud,DEBUG=False" \
  --memory 512Mi \
  --cpu 1 \
  --quiet

# Get service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')
echo "✅ Service deployed successfully!"
echo "🌐 Your application is available at: $SERVICE_URL"
