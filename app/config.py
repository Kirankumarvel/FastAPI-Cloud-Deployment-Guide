import os
from dotenv import load_dotenv

load_dotenv()

class Settings:
    # Application settings
    APP_NAME: str = "FastAPI Cloud Deployment"
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    
    # Database settings
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./test.db")
    
    # Cloud provider settings
    CLOUD_PROVIDER: str = os.getenv("CLOUD_PROVIDER", "local")
    
    @property
    def is_production(self) -> bool:
        return not self.DEBUG

settings = Settings()
