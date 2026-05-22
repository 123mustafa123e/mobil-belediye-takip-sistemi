import google.generativeai as genai
genai.configure(api_key="AIzaSyBNnuf-n_O7jcW79HGLHgBxRVN5LLCzs-A")

for model in genai.list_models():
    if "generateContent" in model.supported_generation_methods:
        print(model.name)