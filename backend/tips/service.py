from typing import Optional
import os
import json
from datetime import datetime
import random
from backend.config import GEMINI_API_KEY
import google.generativeai as genai

CACHE_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "daily_tip_cache.json")

# Fallback tips for different categories
FALLBACK_TIPS = [
    "Save ₹50 daily to have ₹18,250 in a year! Small habits matter.",
    "Track every expense for a week to understand your spending patterns.",
    "Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings.",
    "Start a SIP with just ₹500 monthly to begin your investment journey.",
    "Review and cut one unnecessary subscription to save money monthly.",
    "Cook meals at home to save ₹100+ daily compared to ordering food.",
    "Compare prices before buying anything above ₹1000.",
    "Keep a piggy bank for loose change - it adds up surprisingly fast!",
    "Set a spending limit before going shopping to avoid overspending.",
    "Learn one new financial concept every week to improve money skills.",
]

def _ensure_cache_dir():
    cache_dir = os.path.dirname(CACHE_FILE)
    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir, exist_ok=True)

def get_cached_tip() -> Optional[dict]:
    try:
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                # Ensure it's for today
                if data.get("date") == datetime.utcnow().strftime("%Y-%m-%d"):
                    return data
    except Exception:
        pass
    return None

def cache_tip(tip_text: str) -> dict:
    _ensure_cache_dir()
    data = {
        "date": datetime.utcnow().strftime("%Y-%m-%d"),
        "tip": tip_text,
        "cached_at": datetime.utcnow().isoformat()
    }
    with open(CACHE_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    return data

def generate_daily_tip(user_context: Optional[str] = None, category: str = "general") -> dict:
    """Generate a short daily tip. If Gemini API key is not configured, return a random fallback tip."""
    # For varied notifications, don't use cache to ensure variety
    if category != "general":
        return _generate_varied_tip(user_context, category)
    
    cached = get_cached_tip()
    if cached:
        return cached

    if not GEMINI_API_KEY:
        # Random fallback tip
        tip = random.choice(FALLBACK_TIPS)
        return cache_tip(tip)

    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemini-1.5-flash")
        
        # Create varied prompts for different days
        day_of_week = datetime.utcnow().weekday()
        prompts = [
            "Provide one short actionable personal finance tip for students about saving money in 1-2 sentences.",
            "Give a quick budgeting tip for college students in 1-2 sentences.",
            "Share a simple investment tip for beginners in India in 1-2 sentences.",
            "Suggest a practical way for students to track expenses in 1-2 sentences.",
            "Give advice on avoiding unnecessary spending for young people in 1-2 sentences.",
            "Share a tip about building an emergency fund for students in 1-2 sentences.",
            "Provide advice on smart money habits for teenagers in 1-2 sentences."
        ]
        
        prompt = prompts[day_of_week % len(prompts)]
        if user_context:
            prompt += f" Context: {user_context}"

        response = model.generate_content(
            prompt, 
            generation_config=genai.types.GenerationConfig(max_output_tokens=80)
        )
        tip_text = response.text.strip()
        return cache_tip(tip_text)
    except Exception as e:
        # On errors, return random fallback
        print(f"Error generating tip: {e}")
        tip = random.choice(FALLBACK_TIPS)
        return cache_tip(tip)

def _generate_varied_tip(user_context: Optional[str] = None, category: str = "general") -> dict:
    """Generate category-specific tips without caching for variety."""
    if not GEMINI_API_KEY:
        # Random fallback tip
        tip = random.choice(FALLBACK_TIPS)
        return {
            "date": datetime.utcnow().strftime("%Y-%m-%d"),
            "tip": tip,
            "category": category,
            "generated_at": datetime.utcnow().isoformat()
        }

    try:
        genai.configure(api_key=GEMINI_API_KEY)
        model = genai.GenerativeModel("gemini-1.5-flash")
        
        # Category-specific prompts
        category_prompts = {
            'saving': "Give a practical money-saving tip for students in India in 1-2 sentences. Focus on daily savings habits.",
            'budgeting': "Provide a budgeting tip for college students in 1-2 sentences. Make it actionable and simple.",
            'investing': "Share an investment tip for beginners in India in 1-2 sentences. Keep it simple and safe.",
            'goals': "Give advice on setting and achieving financial goals for young people in 1-2 sentences.",
            'quick_tip': "Provide a quick money management hack for students in 1-2 sentences.",
            'spending': "Share advice on smart spending habits for young adults in 1-2 sentences.",
            'banking': "Give a banking or digital payments tip for students in India in 1-2 sentences."
        }
        
        prompt = category_prompts.get(category, category_prompts['saving'])
        if user_context:
            prompt += f" Context: {user_context}"

        response = model.generate_content(
            prompt, 
            generation_config=genai.types.GenerationConfig(max_output_tokens=80)
        )
        tip_text = response.text.strip()
        
        return {
            "date": datetime.utcnow().strftime("%Y-%m-%d"),
            "tip": tip_text,
            "category": category,
            "generated_at": datetime.utcnow().isoformat()
        }
    except Exception as e:
        # On errors, return random fallback
        print(f"Error generating varied tip: {e}")
        tip = random.choice(FALLBACK_TIPS)
        return {
            "date": datetime.utcnow().strftime("%Y-%m-%d"),
            "tip": tip,
            "category": category,
            "generated_at": datetime.utcnow().isoformat()
        }
