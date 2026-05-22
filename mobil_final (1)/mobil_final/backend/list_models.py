import os
import google.generativeai as genai

api_key = os.getenv("GEMINI_API_KEY") or "AIzaSyAMfz_AbtbH8xBhNe0w2eEob4B1d7MUkq0"
genai.configure(api_key=api_key)

print("Listing models:")
try:
    for m in genai.list_models():
        print(f"Name: {m.name}, Supported methods: {m.supported_generation_methods}")
except Exception as e:
    print(f"Error: {e}")
