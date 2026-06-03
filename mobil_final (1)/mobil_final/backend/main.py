import os
import base64
import json
import mimetypes
import uuid
from datetime import datetime, timezone
from typing import List

from fastapi import Depends, FastAPI, File, Form, HTTPException, Header, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import asyncio
import httpx
from dotenv import load_dotenv

# .env dosyasındaki çevre değişkenlerini yükle
load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

async def save_to_supabase(table: str, data: dict):
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "return=minimal"
    }
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=data, headers=headers)
            print(f"Supabase save to {table}: status code {response.status_code}")
            if response.status_code >= 400:
                print(f"Supabase error response for {table}: {response.text}")
    except Exception as e:
        print(f"Exception saving to Supabase {table}: {e}")

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


class LoginRequest(BaseModel):
    email: str
    password: str
    role: str


class ArizaGuncelleme(BaseModel):
    id: str
    durum: str
    aciklama: str
    tarih: str


class ArizaKayit(BaseModel):
    id: str
    baslik: str
    aciklama: str
    kategori: str
    oncelik: str
    durum: str
    adres: str
    enlem: float | None = None
    boylam: float | None = None
    fotograflar: List[str] = []
    vatandasId: str
    kurumId: str | None = None
    guncellemeler: List[ArizaGuncelleme] = []
    puanlama: int = 0


class ArizaOlusturRequest(BaseModel):
    baslik: str
    aciklama: str
    kategori: str
    oncelik: str
    adres: str
    enlem: float | None = None
    boylam: float | None = None
    fotograflar: List[str] = []
    vatandasId: str


class UserResponse(BaseModel):
    id: str
    ad: str
    soyad: str
    tcKimlik: str
    email: str
    telefon: str
    adres: str
    tip: str
    bildirimAktif: bool = True


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


USERS = {}
TOKENS = {}
ARIZALAR = []

DB_FILE = os.path.join(os.path.dirname(__file__), "db.json")

def load_data():
    global USERS, ARIZALAR
    if os.path.exists(DB_FILE):
        try:
            with open(DB_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                USERS = data.get("USERS", {})
                ARIZALAR = data.get("ARIZALAR", [])
                print(f"Veritabanı yüklendi. USERS: {len(USERS)}, ARIZALAR: {len(ARIZALAR)}")
        except Exception as e:
            print(f"Veritabanı yükleme hatası: {e}")

def save_data():
    try:
        with open(DB_FILE, "w", encoding="utf-8") as f:
            json.dump({"USERS": USERS, "ARIZALAR": ARIZALAR}, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Veritabanı kaydetme hatası: {e}")

load_data()


def populate_ariza_user_info(ariza_dict: dict) -> dict:
    copy_item = dict(ariza_dict)
    vatandas_id = copy_item.get("vatandasId")
    if vatandas_id and vatandas_id in USERS:
        user = USERS[vatandas_id]
        copy_item["vatandasAdSoyad"] = f"{user.get('ad', '')} {user.get('soyad', '')}".strip()
        copy_item["vatandasTelefon"] = user.get("telefon", "")
    else:
        copy_item["vatandasAdSoyad"] = "Kullanıcı"
        copy_item["vatandasTelefon"] = ""
    return copy_item



def now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def generate_token() -> str:
    return uuid.uuid4().hex


def get_user_from_token(authorization: str | None) -> str:
    if not authorization:
        raise HTTPException(status_code=401, detail="Yetkisiz istek")

    prefix = "Bearer "
    if not authorization.startswith(prefix):
        raise HTTPException(status_code=401, detail="Geçersiz yetkilendirme başlığı")

    token = authorization[len(prefix) :].strip()

    # Supabase JWT tokenini çözmeye çalış
    try:
        parts = token.split('.')
        if len(parts) == 3:
            payload_b64 = parts[1]
            payload_b64 += '=' * (4 - len(payload_b64) % 4)
            payload_bytes = base64.urlsafe_b64decode(payload_b64)
            payload = json.loads(payload_bytes.decode('utf-8'))
            
            user_id = payload.get('sub')
            if user_id:
                # Kullanıcı bilgilerini yerel USERS hafızasına ekle
                if user_id not in USERS:
                    user_metadata = payload.get('user_metadata', {})
                    USERS[user_id] = {
                        "id": user_id,
                        "ad": user_metadata.get("first_name", "Kullanıcı"),
                        "soyad": user_metadata.get("last_name", ""),
                        "tcKimlik": user_metadata.get("tcKimlik", ""),
                        "email": payload.get("email", ""),
                        "telefon": user_metadata.get("telefon", ""),
                        "adres": user_metadata.get("adres", ""),
                        "tip": user_metadata.get("role", "vatandas"),
                        "bildirimAktif": True,
                    }
                    save_data()
                return user_id
    except Exception:
        pass

    user_id = TOKENS.get(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Geçersiz veya süresi dolmuş token")

    return user_id


@app.post("/auth/login")
async def login(payload: LoginRequest):
    if not payload.email or not payload.password:
        raise HTTPException(status_code=400, detail="E-posta ve şifre gerekli")

    user_id = f"user_{uuid.uuid4().hex[:8]}"
    user = UserResponse(
        id=user_id,
        ad=payload.role.capitalize(),
        soyad=payload.email.split("@")[0][:12] or payload.email,
        tcKimlik="",
        email=payload.email,
        telefon="",
        adres="",
        tip=payload.role,
        bildirimAktif=True,
    )

    token = generate_token()
    USERS[user_id] = user.model_dump()
    TOKENS[token] = user_id
    save_data()

    return {"token": token, "user": user.model_dump()}


@app.get("/ariza")
async def list_arizalar(authorization: str | None = Header(default=None)):
    get_user_from_token(authorization)
    return [populate_ariza_user_info(item) for item in ARIZALAR]


@app.post("/ariza")
async def create_ariza(payload: ArizaOlusturRequest, authorization: str | None = Header(default=None)):
    user_id = get_user_from_token(authorization)

    ariza = ArizaKayit(
        id=f"ariza_{uuid.uuid4().hex[:8]}",
        baslik=payload.baslik,
        aciklama=payload.aciklama,
        kategori=payload.kategori,
        oncelik=payload.oncelik,
        durum="bekliyor",
        adres=payload.adres,
        enlem=payload.enlem,
        boylam=payload.boylam,
        fotograflar=payload.fotograflar,
        vatandasId=payload.vatandasId or user_id,
        kurumId=None,
        guncellemeler=[
            ArizaGuncelleme(
                id=f"guncelleme_{uuid.uuid4().hex[:8]}",
                durum="bekliyor",
                aciklama="Bildirim alındı.",
                tarih=now_iso(),
            )
        ],
        puanlama=0,
    )

    ARIZALAR.insert(0, ariza.model_dump())
    save_data()

    # Supabase'e kaydet
    asyncio.create_task(save_to_supabase("arizalar", {
        "id": ariza.id,
        "baslik": ariza.baslik,
        "aciklama": ariza.aciklama,
        "kategori": ariza.kategori,
        "oncelik": ariza.oncelik,
        "durum": ariza.durum,
        "adres": ariza.adres,
        "enlem": ariza.enlem,
        "boylam": ariza.boylam,
        "fotograflar": ariza.fotograflar,
        "vatandas_id": ariza.vatandasId
    }))

    return populate_ariza_user_info(ariza.model_dump())


@app.get("/ariza/{ariza_id}")
async def get_ariza(ariza_id: str, authorization: str | None = Header(default=None)):
    get_user_from_token(authorization)

    for item in ARIZALAR:
        if item["id"] == ariza_id:
            return populate_ariza_user_info(item)

    raise HTTPException(status_code=404, detail="Arıza bulunamadı")


class ArizaDurumGuncelleRequest(BaseModel):
    durum: str
    aciklama: str | None = None


@app.put("/ariza/{ariza_id}")
async def update_ariza_status(
    ariza_id: str,
    payload: ArizaDurumGuncelleRequest,
    authorization: str | None = Header(default=None)
):
    get_user_from_token(authorization)
    
    for item in ARIZALAR:
        if item["id"] == ariza_id:
            item["durum"] = payload.durum
            
            # guncellemeler dizisini kontrol et
            if "guncellemeler" not in item or item["guncellemeler"] is None:
                item["guncellemeler"] = []
                
            # Yeni bir güncelleme ekle
            guncelleme = ArizaGuncelleme(
                id=f"guncelleme_{uuid.uuid4().hex[:8]}",
                durum=payload.durum,
                aciklama=payload.aciklama or f"Durum güncellendi: {payload.durum}",
                tarih=now_iso(),
            )
            item["guncellemeler"].append(guncelleme.model_dump())
            
            save_data()
            return populate_ariza_user_info(item)
            
    raise HTTPException(status_code=404, detail="Arıza bulunamadı")


@app.get("/takip/{ariza_id}")
async def takip_ariza(ariza_id: str, authorization: str | None = Header(default=None)):
    get_user_from_token(authorization)

    for item in ARIZALAR:
        if item["id"] == ariza_id:
            return populate_ariza_user_info(item)

    raise HTTPException(status_code=404, detail="Arıza bulunamadı")


@app.post("/analiz", response_model=AnalizSonucu)
async def gorsel_analiz_et(
    gorsel: UploadFile = File(None),
    aciklama: str = Form(""),
    ai_secim: str = Form("gemini"),
    authorization: str | None = Header(default=None),
):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY ortam değişkeni ayarlanmamış (.env dosyasını kontrol edin).")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel(
        "gemini-2.5-flash",
        system_instruction=SISTEM_PROMPTU,
    )

    parts = []

    if gorsel and gorsel.filename:
        gorsel_bytes = await gorsel.read()
        gorsel_base64 = base64.standard_b64encode(gorsel_bytes).decode()

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

        parts.append({"inline_data": {"mime_type": mime, "data": gorsel_base64}})

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

        # Kullanıcı ID'sini çöz
        user_id = None
        if authorization:
            try:
                user_id = get_user_from_token(authorization)
            except Exception:
                pass

        # Supabase'e sorguyu kaydet
        asyncio.create_task(save_to_supabase("yapay_zeka_sorgular", {
            "id": f"sorgu_{uuid.uuid4().hex[:8]}",
            "aciklama": aciklama.strip(),
            "gorsel_adi": gorsel.filename if (gorsel and gorsel.filename) else None,
            "ariza_turu": data.get("ariza_turu", ""),
            "aciliyet": data.get("aciliyet", ""),
            "detayli_aciklama": data.get("aciklama", ""),
            "oneriler": data.get("onerim", ""),
            "vatandas_id": user_id
        }))

        return AnalizSonucu(**data)

    except json.JSONDecodeError as e:
        raise HTTPException(
            status_code=500,
            detail=f"JSON parse hatası: {str(e)} | Ham yanıt: {response.text[:300]}",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI analiz hatası: {str(e)}")


@app.get("/")
def root():
    return {"mesaj": "Arıza Analiz API çalışıyor", "durum": "OK"}
