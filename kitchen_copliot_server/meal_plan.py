import random
from database import db


def get_meal_by_id(meal_id: str):
    """Fetches a meal by its idMeal value from Firestore."""
    meal_query = db.collection("meals").where("idMeal", "==", meal_id).limit(1).stream()
    meal = next(meal_query, None)
    return meal.to_dict() if meal else None


def fetch_all_meals():
    """Fetch all stored meals from Firestore."""
    meal_docs = db.collection("meals").stream()
    meals = [doc.to_dict() for doc in meal_docs]
    return meals if meals else []  # Return empty list if no meals found


def generate_weekly_meal_plan():
    """Generates a full week's meal plan (Monday - Sunday) using stored meals."""
    meals = fetch_all_meals()

    if not meals:
        return {"error": "No meals found in database."}

    days = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
    ]
    meal_types = ["Breakfast", "Lunch", "Dinner"]

    meal_plan = {}

    for day in days:
        daily_meals = {}
        for meal_type in meal_types:
            meal = random.choice(meals)  # Select a random meal
            daily_meals[meal_type] = {
                "id": meal.get("idMeal"),
                "name": meal.get("strMeal"),
                # "description": meal.get("strInstructions", "No description available."),
                "imageUrl": meal.get("strMealThumb", ""),
            }
        meal_plan[day] = daily_meals  # ✅ Store all meals for each day

    return {
        "summary": "They are the curated easy meals for your busy week!",
        "mealPlan": meal_plan,  # ✅ Stores full week meal plan
    }
