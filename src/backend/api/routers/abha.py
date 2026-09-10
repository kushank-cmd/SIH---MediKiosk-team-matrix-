# backend/api/routers/abha.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from core.database import get_db
from models.user import User
from models.verification import ABHAVerificationSession
from schemas.abha import (
    GenerateOTPRequest, 
    GenerateOTPResponse, 
    VerifyOTPRequest, 
    ABHAProfileResponse
)
from services.abdm_verify import request_aadhaar_otp, verify_aadhaar_otp
from core.security import create_access_token

router = APIRouter(prefix="/abha", tags=["ABHA"])

@router.post("/generate-otp", response_model=GenerateOTPResponse)
async def generate_otp(
    payload: GenerateOTPRequest, 
    db: AsyncSession = Depends(get_db)
):
    try:
        res = await request_aadhaar_otp(payload.aadhaar_number)
        txn_id = res.get("txnId")
        
        if not txn_id:
            raise HTTPException(status_code=400, detail="Failed to retrieve transaction ID from ABDM.")
        
        session_record = ABHAVerificationSession(
            txn_id=txn_id, 
            status="OTP_PENDING"
        )
        db.add(session_record)
        await db.commit()
        
        return GenerateOTPResponse(
            txn_id=txn_id,
            message="OTP sent successfully to the mobile number linked with Aadhaar."
        )
    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=f"Error generating OTP: {str(e)}"
        )

@router.post("/verify-otp", response_model=ABHAProfileResponse)
async def verify_otp(
    payload: VerifyOTPRequest, 
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(ABHAVerificationSession).where(ABHAVerificationSession.txn_id == payload.txn_id)
    )
    verification_session = result.scalars().first()
    
    if not verification_session or verification_session.status != "OTP_PENDING":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Invalid or expired transaction session."
        )

    try:
        abdm_response = await verify_aadhaar_otp(payload.txn_id, payload.otp)
        profile_data = abdm_response.get("ABHAProfile", {})

        abha_num = profile_data.get("ABHANumber") or profile_data.get("abhaNumber")
        full_name = f"{profile_data.get('firstName', '')} {profile_data.get('middleName', '')} {profile_data.get('lastName', '')}".strip()
        dob_str = profile_data.get("dob") or f"{profile_data.get('dayOfBirth', '01')}-{profile_data.get('monthOfBirth', '01')}-{profile_data.get('yearOfBirth', '2000')}"

        phr_addresses = profile_data.get("phrAddress")
        abha_address_val = phr_addresses[0] if isinstance(phr_addresses, list) and phr_addresses else (phr_addresses or profile_data.get("abhaAddress"))

        user_result = await db.execute(select(User).where(User.abha_number == abha_num))
        user = user_result.scalars().first()

        if not user:
            user = User(
                abha_number=abha_num,
                abha_address=abha_address_val,
                full_name=full_name,
                gender=profile_data.get("gender"),
                dob=dob_str,
                mobile=profile_data.get("mobile"),
                is_kyc_verified=True
            )
            db.add(user)
        else:
            user.full_name = full_name
            user.mobile = profile_data.get("mobile")
            user.is_kyc_verified = True

        verification_session.status = "VERIFIED"
        await db.commit()
        await db.refresh(user)

        jwt_token = create_access_token({"sub": str(user.id), "abha_number": user.abha_number})

        return ABHAProfileResponse(
            abha_number=user.abha_number or "",
            abha_address=user.abha_address or "",
            name=user.full_name,
            gender=user.gender or "",
            date_of_birth=user.dob or "",
            mobile=user.mobile or "",
            jwt_token=jwt_token
        )

    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail=f"OTP verification failed: {str(e)}"
        )