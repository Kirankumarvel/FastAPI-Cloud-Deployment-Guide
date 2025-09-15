#!/bin/bash
set -e

# Configuration
RESOURCE_GROUP="fastapi-rg"
LOCATION="eastus"
ACR_NAME="fastapiacr"
APP_NAME="fastapi-app"
ENVIRONMENT="fastapi-env"

echo "🚀 Starting Azure deployment process..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure. Please run: az login"
    exit 1
fi

echo "✅ Logged in to Azure."

# Create resource group
echo "📦 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
echo "🐳 Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Build and push image to ACR
echo "📤 Building and pushing image to ACR..."
az acr build --registry $ACR_NAME --image $APP_NAME:latest .

# Create Container App environment
echo "🌿 Creating Container App environment..."
az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Create Container App
echo "🚀 Creating Container App..."
az containerapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/$APP_NAME:latest \
  --target-port 80 \
  --ingress 'external' \
  --env-vars CLOUD_PROVIDER=azure DEBUG=False \
  --query properties.configuration.ingress.fqdn

echo "✅ Deployment completed successfully!"
echo "📝 Note: The Container App URL will be displayed above once creation is complete."
