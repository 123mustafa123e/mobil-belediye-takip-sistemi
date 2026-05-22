import os
import base64
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

# ─── Yanıt modeli ────────────────────────────────────────────────
class AnalizSonucu(BaseModel):
    ariza_turu: str        # örn. "Yangın", "Su Kaçağı", "Elektrik Arızası"
    aciliyet: str          # "Düşük" | "Orta" | "Yüksek" | "Kritik"
    aciklama: str          # AI'nın detaylı açıklaması
    onerim: str            # Yapılması gereken ilk adımlar

# ─── Sistem Promptu ──────────────────────────────────────────────
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

# ─── Ana endpoint ─────────────────────────────────────────────────
@app.post("/analiz", response_model=AnalizSonucu)
async def gorsel_analiz_et(
    gorsel: UploadFile = File(None, description="Arıza görseli (jpg/png)"),
    aciklama: str = Form("", description="Kullanıcının metin açıklaması"),
    ai_secim: str = Form("gemini", description="'gemini'")
):
    """
    Arıza görselini ve/veya açıklamasını analiz eder.
    GEMINI_API_KEY ortam değişkeni gereklidir.
    """
    api_key = os.getenv("GEMINI_API_KEY") or "AIzaSyAMfz_AbtbH8xBhNe0w2eEob4B1d7MUkq0"
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY ortam değişkeni ayarlanmamış.")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel("gemini-2.0-flash")

    # Kullanıcı mesajını oluştur
    parts = []

    # Görsel varsa ekle
    if gorsel and gorsel.filename:
        gorsel_bytes = await gorsel.read()
        gorsel_base64 = base64.standard_b64encode(gorsel_bytes).decode()
        parts.append({
            "inline_data": {
                "mime_type": gorsel.content_type or "image/jpeg",
                "data": gorsel_base64,
            }
        })

    # Metin açıklama
    kullanici_mesaj = aciklama if aciklama else "Görseldeki arızayı analiz et."
    parts.append({"text": kullanici_mesaj})

    try:
        response = model.generate_content(
            [SISTEM_PROMPTU, *parts],
            generation_config={"temperature": 0.2},
        )

        import json
        text = response.text.strip()
        # JSON bloğu varsa temizle
        if "```" in text:
            text = text.split("```")[1]
            if text.startswith("json"):
                text = text[4:]

        data = json.loads(text)
        return AnalizSonucu(**data)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI analiz hatası: {str(e)}")


@app.get("/")
def root():
    return {"mesaj": "Arıza Analiz API çalışıyor", "durum": "OK"}
