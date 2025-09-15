from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import time
import logging
import os
from typing import Dict, Any, List

from .config import settings
from .routes import items, users

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup code
    logger.info("🚀 Starting FastAPI application")
    logger.info(f"📋 Configuration: DEBUG={settings.DEBUG}, CLOUD_PROVIDER={settings.CLOUD_PROVIDER}")
    
    # Initialize resources (database connections, etc.)
    yield
    
    # Shutdown code
    logger.info("🛑 Shutting down FastAPI application")
    # Clean up resources

# Create the FastAPI app instance
app = FastAPI(
    title=settings.APP_NAME,
    description="A FastAPI application ready for cloud deployment",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.DEBUG else ["https://yourdomain.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(items.router, prefix="/items", tags=["items"])
app.include_router(users.router, prefix="/users", tags=["users"])

@app.get("/")
async def root() -> Dict[str, str]:
    return {
        "message": "Welcome to FastAPI Cloud Deployment",
        "cloud_provider": settings.CLOUD_PROVIDER,
        "debug": settings.DEBUG
    }

@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """Health check endpoint for load balancers and monitoring"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "version": "1.0.0",
        "cloud_provider": settings.CLOUD_PROVIDER,
        "debug": settings.DEBUG
    }

@app.get("/health/detailed")
async def detailed_health_check() -> Dict[str, Any]:
    """Detailed health check with system information"""
    try:
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        memory_info = process.memory_info()
        
        return {
            "status": "healthy",
            "timestamp": time.time(),
            "memory_usage_mb": memory_info.rss / 1024 / 1024,
            "cpu_percent": process.cpu_percent(),
            "thread_count": process.num_threads(),
            "cloud_provider": settings.CLOUD_PROVIDER,
            "debug": settings.DEBUG
        }
    except ImportError:
        # psutil not installed, return basic info
        return {
            "status": "healthy",
            "timestamp": time.time(),
            "message": "psutil not installed for detailed metrics",
            "cloud_provider": settings.CLOUD_PROVIDER,
            "debug": settings.DEBUG
        }

@app.get("/env")
async def show_environment():
    """Show environment variables (for debugging)"""
    return {
        "environment_variables": {k: v for k, v in os.environ.items() if not k.startswith(('AWS_', 'GOOGLE_', 'AZURE_'))},
        "cloud_provider": settings.CLOUD_PROVIDER
    }
