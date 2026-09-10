# backend/models/verification.py
from sqlalchemy import String, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from core.database import Base

class ABHAVerificationSession(Base):
    __tablename__ = "abha_verification_sessions"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    txn_id: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    status: Mapped[str] = mapped_column(String(20), default="OTP_PENDING")
    created_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now())