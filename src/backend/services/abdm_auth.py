# backend/services/abdm_auth.py
import time
import httpx
from core.config import settings

_token_cache = {"access_token": None, "expires_at": 0}

async def get_abdm_access_token() -> str:
    current_time = time.time()
    if _token_cache["access_token"] and current_time < _token_cache["expires_at"]:
        return _token_cache["access_token"]

    url = f"{settings.ABDM_BASE_URL}/gateway/v3/sessions"
    payload = {
        "clientId": settings.ABDM_CLIENT_ID,
        "clientSecret": settings.ABDM_CLIENT_SECRET,
        "grantType": "client_credentials"
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload)
        response.raise_for_status()
        data = response.json()

        _token_cache["access_token"] = data["accessToken"]
        _token_cache["expires_at"] = current_time + data.get("expiresIn", 1200) - 60
        
        return _token_cache["access_token"]