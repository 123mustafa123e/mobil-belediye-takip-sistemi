import os
import base64
import json
import mimetypes
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai

app = FastAPI(title="Arıza Analiz Servisi")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class AnalizSonucu(BaseModel):
    ariza_turu: str
    aciliyet: str
    aciklama: str
    onerim: str

SISTEM_PROMPTU = """Sen bir bina arıza tespit uzmanısın.
Sana bir görsel ve kullanıcının açıklaması verilecek.

Görevin:
1. Görseli analiz et
2. Arıza türünü belirle (Yangın, Su Kaçağı, Elektrik Arızası, Yapısal Hasar, Yol/Kaldırım, Park/Bahçe, Diğer)
3. Aciliyet seviyesini belirle (Düşük, Orta, Yüksek, Kritik)
4. Kısa ve net bir açıklama yap
5. İlk yapılması gerekenleri söyle

SADECE şu JSON formatında yanıt ver, başka hiçbir şey yazma:
{
  "ariza_turu": "...",
  "aciliyet": "...",
  "aciklama": "...",
  "onerim": "..."
}"""


@app.post("/analiz", response_model=AnalizSonucu)
async def gorsel_analiz_et(
    gorsel: UploadFile = File(None),
    aciklama: str = Form(""),
    ai_secim: str = Form("gemini"),
):
    api_key = os.getenv("GEMINI_API_KEY", "AIzaSyBNnuf-n_O7jcW79HGLHgBxRVN5LLCzs-A")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY ortam değişkeni ayarlanmamış.")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(
        "gemini-2.5-flash",
        system_instruction=SISTEM_PROMPTU,
    )

    parts = []

    if gorsel and gorsel.filename:
        gorsel_bytes = await gorsel.read()
        gorsel_base64 = base64.standard_b64encode(gorsel_bytes).decode()

        # Mime type belirle
        filename = gorsel.filename or ""
        content_type = gorsel.content_type or ""

        if content_type and content_type != "application/octet-stream":
            mime = content_type
        elif filename.lower().endswith(".png"):
            mime = "image/png"
        elif filename.lower().endswith((".jpg", ".jpeg")):
            mime = "image/jpeg"
        elif filename.lower().endswith(".webp"):
            mime = "image/webp"
        else:
            guessed, _ = mimetypes.guess_type(filename)
            mime = guessed or "image/jpeg"

        parts.append({
            "inline_data": {
                "mime_type": mime,
                "data": gorsel_base64,
            }
        })

    kullanici_mesaj = aciklama.strip() if aciklama.strip() else "Görseldeki arızayı analiz et."
    parts.append({"text": kullanici_mesaj})

    try:
        response = model.generate_content(
            parts,
            generation_config={"temperature": 0.2},
        )

        text = response.text.strip()

        start = text.find("{")
        end = text.rfind("}") + 1
        text = text[start:end]

        data = json.loads(text)
        return AnalizSonucu(**data)

    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"JSON parse hatası: {str(e)} | Ham yanıt: {response.text[:300]}"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI analiz hatası: {str(e)}")


@app.get("/")
def root():
    return {"mesaj": "Arıza Analiz API çalışıyor", "durum": "OK"}