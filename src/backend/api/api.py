# backend/api/api.py
from fastapi import APIRouter
from backend.api.routers import abha

api_router = APIRouter()
api_router.include_router(abha.router)