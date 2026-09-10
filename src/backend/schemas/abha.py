# backend/schemas/abha.py
from pydantic import BaseModel, StringConstraints
from typing import Annotated, Optional

class GenerateOTPRequest(BaseModel):
    aadhaar_number: Annotated[str, StringConstraints(pattern=r"^\d{12}$")]

class GenerateOTPResponse(BaseModel):
    txn_id: str
    message: str

class VerifyOTPRequest(BaseModel):
    txn_id: str
    otp: Annotated[str, StringConstraints(pattern=r"^\d{6}$")]

class ABHAProfileResponse(BaseModel):
    abha_number: str
    abha_address: Optional[str] = None
    name: str
    gender: str
    date_of_birth: str
    mobile: Optional[str] = None
    jwt_token: str