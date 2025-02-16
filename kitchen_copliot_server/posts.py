from fastapi import HTTPException, APIRouter
from database import db
from models import Post, Comment, Like
from datetime import datetime

router = APIRouter()


@router.get("/posts")
def read_all_posts():
    return get_all_posts()


def create_post(post_data: Post):
    """Creates a new post in Firestore."""
    data_dict = post_data.dict()
    data_dict["created_at"] = datetime.utcnow()
    doc_ref = db.collection("posts").document()
    doc_ref.set(data_dict)
    return {"post_id": doc_ref.id, **data_dict}


def get_post_with_recipe(post_id: str):
    """Fetches a single post with optional recipe data."""
    doc = db.collection("posts").document(post_id).get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail="Post not found")

    post_data = doc.to_dict()
    post_data["post_id"] = doc.id

    if post_data.get("recipe_id"):
        recipe_doc = db.collection("recipes").document(post_data["recipe_id"]).get()
        if recipe_doc.exists:
            post_data["recipe"] = recipe_doc.to_dict()

    return post_data


def get_all_posts():
    """Fetches all posts from Firestore."""
    docs = db.collection("posts").get()
    posts = []
    for doc in docs:
        data = doc.to_dict()
        data["post_id"] = doc.id
        if data.get("recipe_id"):
            recipe_doc = db.collection("recipes").document(data["recipe_id"]).get()
            if recipe_doc.exists():
                data["recipe"] = recipe_doc.to_dict()
        posts.append(data)
    return posts
