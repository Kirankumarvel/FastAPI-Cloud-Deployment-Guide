#!/bin/bash
set -e

# Configuration
AWS_REGION="us-east-1"
ECR_REPOSITORY="fastapi-app"
APP_NAME="fastapi-service"

echo "🚀 Starting AWS deployment process..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo "❌ Failed to get AWS account ID. Please check your AWS credentials."
    exit 1
fi

echo "✅ AWS Account ID: $AWS_ACCOUNT_ID"

# Login to ECR
echo "🔐 Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Create ECR repository if it doesn't exist
echo "📦 Checking ECR repository..."
if ! aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $AWS_REGION &> /dev/null; then
    echo "📦 Creating ECR repository..."
    aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION
    echo "✅ ECR repository created."
else
    echo "✅ ECR repository already exists."
fi

# Build the image
echo "🐳 Building Docker image..."
docker build -t $ECR_REPOSITORY .

# Tag the image
echo "🏷️ Tagging Docker image..."
docker tag $ECR_REPOSITORY:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

# Push the image
echo "📤 Pushing Docker image to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest

echo "✅ Image pushed to ECR successfully!"
echo "📝 Now create App Runner service manually in AWS Console:"
echo "   - Go to AWS Console → App Runner → Create service"
echo "   - Choose 'Container registry' → 'Amazon ECR'"
echo "   - Select your image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY:latest"
echo "   - Configure service:"
echo "     - Service name: $APP_NAME"
echo "     - Port: 80"
echo "     - Environment variables: CLOUD_PROVIDER=aws, DEBUG=False"
echo "   - Click 'Create & Deploy'"
