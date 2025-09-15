from fastapi import APIRouter, HTTPException, status
from typing import List, Dict, Any
import uuid

router = APIRouter()

# In-memory storage for demo purposes
items_db = {}

@router.get("/", response_model=List[Dict[str, Any]])
async def list_items(skip: int = 0, limit: int = 10):
    """List all items with pagination"""
    items = list(items_db.values())
    return items[skip:skip + limit]

@router.post("/", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_item(item: Dict[str, Any]):
    """Create a new item"""
    item_id = str(uuid.uuid4())
    item_with_id = {"id": item_id, **item}
    items_db[item_id] = item_with_id
    return item_with_id

@router.get("/{item_id}", response_model=Dict[str, Any])
async def get_item(item_id: str):
    """Get item by ID"""
    if item_id not in items_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )
    return items_db[item_id]

@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(item_id: str):
    """Delete item by ID"""
    if item_id not in items_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )
    del items_db[item_id]
    return None
