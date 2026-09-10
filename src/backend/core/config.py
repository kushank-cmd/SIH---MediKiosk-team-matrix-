# backend/core/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "MEDIKOSK ABHA Service"
    ABDM_BASE_URL: str = "https://dev.abdm.gov.in"
    ABDM_CLIENT_ID: str
    ABDM_CLIENT_SECRET: str
    SUPABASE_URL: str
    SECRET_KEY: str = "your_super_secret_jwt_key_here"
    ALGORITHM: str = "HS256"

    class Config:
        env_file = ".env"

settings = Settings()