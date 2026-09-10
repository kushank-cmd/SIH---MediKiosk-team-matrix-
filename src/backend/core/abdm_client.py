# backend/core/abdm_client.py
import httpx
from core.config import settings

class ABDMHttpClient:
    @staticmethod
    async def get_client() -> httpx.AsyncClient:
        return httpx.AsyncClient(base_url=settings.ABDM_BASE_URL, timeout=30.0)