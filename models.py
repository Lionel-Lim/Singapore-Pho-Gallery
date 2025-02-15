from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

class UserCreateRequest(BaseModel):
    name: str
    email: EmailStr
    diet: Optional[str] = None
    excluded_ingredients: List[str] = []
    cuisine: List[str] = []

class MealPlanRequest(BaseModel):
    user_id: str
    mealPlan: dict  # Will contain full meal plan JSON

class Location(BaseModel):
    latitude: float
    longitude: float

class Post(BaseModel):
    user_id: str
    title: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    location: Optional[Location] = None
    created_at: datetime = datetime.utcnow()
    recipe_id: Optional[str] = None
    post_type: str

class Comment(BaseModel):
    post_id: str
    user_id: str
    comment_txt: str
    comment_time: datetime = datetime.utcnow()

class Like(BaseModel):
    post_id: str
    user_id: str