# backend/models/user.py
from sqlalchemy import String, Boolean, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column
from core.database import Base

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    abha_number: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=True)
    abha_address: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=True)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    gender: Mapped[str] = mapped_column(String(10), nullable=True)
    dob: Mapped[str] = mapped_column(String(15), nullable=True)
    mobile: Mapped[str] = mapped_column(String(15), index=True, nullable=True)
    is_kyc_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now())