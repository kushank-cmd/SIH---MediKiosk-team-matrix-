# backend/services/abdm_verify.py
import uuid
from datetime import datetime, timezone
import httpx
from core.config import settings
from services.abdm_auth import get_abdm_access_token

async def request_aadhaar_otp(aadhaar_number: str) -> dict:
    access_token = await get_abdm_access_token()
    url = f"{settings.ABDM_BASE_URL}/v3/enrollment/request/otp"
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "TIMESTAMP": datetime.now(timezone.utc).isoformat(),
        "REQUEST-ID": str(uuid.uuid4()),
        "X-CM-ID": "sbx"
    }
    
    payload = {
        "scope": ["abha-enrol"],
        "loginHint": "aadhaar",
        "loginId": aadhaar_number,
        "otpSystem": "aadhaar"
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers)
        if response.status_code != 200:
            raise Exception(f"ABDM Error: {response.text}")
        return response.json()

async def verify_aadhaar_otp(txn_id: str, otp: str) -> dict:
    access_token = await get_abdm_access_token()
    url = f"{settings.ABDM_BASE_URL}/v3/enrollment/enrol/byAadhaar"
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "TIMESTAMP": datetime.now(timezone.utc).isoformat(),
        "REQUEST-ID": str(uuid.uuid4()),
        "X-CM-ID": "sbx"
    }
    
    payload = {
        "authData": {
            "authMethods": ["otp"],
            "otp": {
                "txnId": txn_id,
                "otpValue": otp
            }
        }
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers)
        if response.status_code != 200:
            raise Exception(f"ABDM Verification Error: {response.text}")
        return response.json()