import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import uuid


# 🔹 Initialize Firebase (if not already initialized)
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()


def create_user(
    name: str,
    email: str,
    diet: str = None,
    excluded_ingredients: list = None,
    cuisine: list = None,
):
    """Creates a new user and stores preferences in Firestore."""
    user_id = str(uuid.uuid4())  # Generate a unique ID

    user_data = {
        "user_id": user_id,
        "name": name,
        "email": email,
        "preferences": {
            "diet": diet or "none",
            "excluded_ingredients": excluded_ingredients or [],
            "cuisine": cuisine or [],
        },
        "created_at": datetime.utcnow(),
    }

    db.collection("users").document(user_id).set(user_data)

    # ✅ Return the generated user_id in the response
    return {"message": "User created successfully!", "user_id": user_id}


def get_monday_of_current_week():
    """Returns the date (YYYY-MM-DD) of the most recent Monday."""
    today = datetime.utcnow()
    monday = today - timedelta(days=today.weekday())  # Moves back to Monday
    return monday.strftime("%Y-%m-%d")


def store_weekly_meal_plan(user_id: str, meal_plan: dict):
    """Stores a full weekly meal plan under a user's subcollection in Firestore."""
    from database import db  # ✅ Fix circular import issue

    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if not user_doc.exists:
        return {"error": "User not found!"}

    # ✅ Ensure we get the correct Monday date
    week_start = get_monday_of_current_week()

    # ✅ Store the full week's meal plan
    meal_plan_doc_ref = user_ref.collection("meal_plans").document(f"week_{week_start}")
    meal_plan_data = {
        "week_start": week_start,
        "mealPlan": meal_plan,  # ✅ Store full week meal plan instead of one day
    }

    meal_plan_doc_ref.set(meal_plan_data)
    return {
        "message": "Full weekly meal plan stored successfully!",
        "week_start": week_start,
    }


def get_user_meal_plans(user_id: str):
    """Fetches all meal plans for a user from Firestore."""
    user_ref = db.collection("users").document(user_id)
    meal_plans_ref = user_ref.collection("meal_plans").stream()

    meal_plans = {}
    for doc in meal_plans_ref:
        meal_plans[doc.id] = doc.to_dict()

    return (
        meal_plans if meal_plans else {"message": "No meal plans found for this user"}
    )
