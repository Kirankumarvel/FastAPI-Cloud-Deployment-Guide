#!/bin/bash
set -e

# Configuration
APP_NAME="fastapi-app-$(date +%s | cut -c 6-10)"  # Generate unique app name

echo "🚀 Starting Heroku deployment process..."

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI is not installed. Please install it first."
    exit 1
fi

# Check if user is logged in
if ! heroku whoami &> /dev/null; then
    echo "❌ Not logged in to Heroku. Please run: heroku login"
    exit 1
fi

echo "✅ Logged in to Heroku."

# Create app
echo "📦 Creating Heroku app..."
heroku create $APP_NAME

# Set stack to container
echo "🐳 Setting stack to container..."
heroku stack:set container -a $APP_NAME

# Login to Heroku Container Registry
echo "🔐 Logging in to Heroku Container Registry..."
heroku container:login

# Build and push container
echo "📤 Building and pushing container..."
heroku container:push web -a $APP_NAME

# Release the container
echo "🚀 Releasing container..."
heroku container:release web -a $APP_NAME

# Set environment variables
echo "⚙️ Setting environment variables..."
heroku config:set CLOUD_PROVIDER=heroku DEBUG=False -a $APP_NAME

# Open the app
echo "🌐 Opening the application..."
heroku open -a $APP_NAME

echo "✅ Deployment completed successfully!"
echo "📝 Your app name: $APP_NAME"
echo "🌐 Your application is available at: https://$APP_NAME.herokuapp.com"
