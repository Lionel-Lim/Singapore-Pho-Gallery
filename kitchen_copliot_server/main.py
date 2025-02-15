from fastapi import FastAPI
from models import UserCreateRequest, MealPlanRequest, Post
from database import create_user, store_weekly_meal_plan, get_user_meal_plans
from meal_plan import generate_weekly_meal_plan
from posts import create_post, get_post_with_recipe

app = FastAPI()

# 🔹 User APIs

# 🔹 Create a New User
@app.post("/create-user")
def api_create_user(user: UserCreateRequest):
    return create_user(user.name, user.email, user.diet, user.excluded_ingredients, user.cuisine)

@app.post("/store-meal-plan/{user_id}")
def api_store_meal_plan(user_id: str):
    """Generates and stores a full weekly meal plan for a user."""
    meal_plan = generate_weekly_meal_plan()
    return store_weekly_meal_plan(user_id, meal_plan)

@app.get("/user/{user_id}/meal-plans")
def api_get_user_meal_plans(user_id: str):
    """Retrieves all meal plans for a user."""
    from database import get_user_meal_plans
    return get_user_meal_plans(user_id)

# 🔹 Generate a Meal Plan
@app.get("/meal-plan")
def get_meal_plan():
    return generate_weekly_meal_plan()

# 🔹 Post APIs
@app.post("/posts")
def api_create_post(post_data: Post):
    return create_post(post_data)

@app.get("/posts/{post_id}")
def api_get_post(post_id: str):
    return get_post_with_recipe(post_id)

@app.get("/user/{user_id}/meal-plans")
def api_get_user_meal_plans(user_id: str):
    return get_user_meal_plans(user_id)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)