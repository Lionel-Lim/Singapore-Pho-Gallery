import random
import requests
import firebase_admin
from firebase_admin import credentials, firestore
import time
from datetime import datetime
import openai
import os
from dotenv import load_dotenv

# Load OpenAI API Key
load_dotenv()
openai_api_key = os.getenv("OPENAI_API_KEY")
if not openai_api_key:
    raise ValueError("OpenAI API key not found! Ensure your .env file is correctly set up.")

# Initialize OpenAI Client
client = openai.OpenAI(api_key=openai_api_key)

# Initialize Firebase Admin
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

# Constants
MOCK_POST_TYPES = ["follow", "explore", "community"]
SINGAPORE_LAT_RANGE = (1.24, 1.45)
SINGAPORE_LON_RANGE = (103.7, 104.0)

# 🔹 Utility Functions
def get_random_singapore_location():
    """Returns a random latitude and longitude in Singapore."""
    return (random.uniform(*SINGAPORE_LAT_RANGE), random.uniform(*SINGAPORE_LON_RANGE))

def fetch_random_meal():
    """Fetches a random meal from TheMealDB API."""
    try:
        response = requests.get("https://www.themealdb.com/api/json/v1/1/random.php")
        response.raise_for_status()
        meals = response.json().get("meals")
        return meals[0] if meals else None
    except requests.exceptions.RequestException as e:
        print(f"Error fetching meal: {e}")
        return None

def store_meal_in_firestore(meal):
    """Stores meal data in Firestore using its ID as the document key."""
    db.collection("meals").document(meal["idMeal"]).set(meal)
    print(f"✅ Stored meal '{meal['idMeal']}' in Firestore.")

# 🔹 AI-Generated Content
def generate_random_username():
    """Generates a creative username using GPT-4o."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Generate a unique and fun username under 15 characters. Do not type reaction."}],
        temperature=0.8,
        max_tokens=15
    )
    return response.choices[0].message.content.strip().replace(" ", "_")


def generate_post_content(meal_name: str):
    """Generates a catchy post title and description using GPT-4o."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Write a catchy social media post title and a short description about '{meal_name}', separating them with '|'. Keep it fun and engaging."}],
        temperature=0.7,
        max_tokens=100
    )
    text = response.choices[0].message.content.strip()
    return text.split("|") if '|' in text else ("Delicious Meal", text)

# 🔹 Post Generation
def generate_random_usernames(n=500):
    """Generates a batch of random usernames with fewer OpenAI API calls."""
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "Generate a list of unique, fun usernames (comma-separated). Each username should be under 15 characters."}
        ],
        temperature=0.8,
        max_tokens=200
    )

    # Extract usernames and split into a list
    usernames = response.choices[0].message.content.strip().split(", ")
    return usernames[:n]  # Ensure we get exactly 'n' usernames

def generate_random_likes():
    """
    Generates a random number of likes (0 to 500) from a pool of pre-generated usernames.
    """
    num_likes = random.randint(0, 500)
    all_usernames = generate_random_usernames(n=500)  # Generate once per batch
    liked_users = random.sample(all_usernames, min(num_likes, len(all_usernames)))  # Pick unique likes
    return liked_users

def create_random_post_for_meal(meal):
    """Creates a Firestore post referencing a given meal."""
    meal_id = meal["idMeal"]
    user_id = generate_random_username()
    post_type = random.choice(MOCK_POST_TYPES)
    lat, lng = get_random_singapore_location()
    title, description = generate_post_content(meal.get('strMeal', 'Unknown Meal'))
    likes = generate_random_likes()

    post_data = {
        "meal_id": meal_id,
        "user_id": user_id,
        "post_type": post_type,
        "location": {"latitude": lat, "longitude": lng},
        "created_at": datetime.utcnow(),
        "likes": likes,
        "like_count": len(likes),
        "image_url": meal.get("strMealThumb", ""),
        "title": title,
        "description": description,
    }
    db.collection("posts").document().set(post_data)
    print(f"✅ Created post for meal '{meal_id}' with {len(likes)} likes.")

# 🔹 Main Execution
def generate_random_meals_and_posts(n=5, delay=1):
    """Fetches random meals and creates associated posts."""
    for i in range(n):
        meal = fetch_random_meal()
        if meal:
            store_meal_in_firestore(meal)
            create_random_post_for_meal(meal)
            print(f"🎉 Done {i+1}/{n} meal + post.")
        else:
            print("⚠️ Skipping - No meal returned.")
        
        if delay > 0:
            time.sleep(delay)

if __name__ == "__main__":
    generate_random_meals_and_posts(n=5, delay=1)