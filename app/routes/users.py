from fastapi import APIRouter, HTTPException, status
from typing import List, Dict, Any
import uuid

router = APIRouter()

# In-memory storage for demo purposes
users_db = {}

@router.get("/", response_model=List[Dict[str, Any]])
async def list_users(skip: int = 0, limit: int = 10):
    """List all users with pagination"""
    users = list(users_db.values())
    return users[skip:skip + limit]

@router.post("/", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_user(user: Dict[str, Any]):
    """Create a new user"""
    user_id = str(uuid.uuid4())
    user_with_id = {"id": user_id, **user}
    users_db[user_id] = user_with_id
    return user_with_id

@router.get("/{user_id}", response_model=Dict[str, Any])
async def get_user(user_id: str):
    """Get user by ID"""
    if user_id not in users_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return users_db[user_id]

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: str):
    """Delete user by ID"""
    if user_id not in users_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    del users_db[user_id]
    return None
