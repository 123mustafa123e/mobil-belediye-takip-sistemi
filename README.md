# Mobil Belediye Takip Sistemi 🏛️📱

Bu proje, vatandaşların belediye ile hızlı ve şeffaf bir şekilde etkileşim kurmasını sağlayan, yapay zeka destekli ve bulut entegrasyonlu modern bir mobil belediyecilik uygulamasıdır. Vatandaşlar arızaları bildirebilir, yapay zeka ile hasar tespiti yapabilir, harita üzerinden bildirimleri izleyebilir ve temel kurum aboneliklerini yönetebilirler.

---

## 🚀 Öne Çıkan Özellikler

### 1. Vatandaş & Kurum Paneli 👥
* **Vatandaş Girişi:** Arıza bildirimi yapma, bildirimlerin durumunu takip etme, yapay zeka asistanını kullanma ve abonelik işlemleri.
* **Kurum Girişi:** Vatandaşlar tarafından gönderilen bildirimleri inceleme, onaylama/reddetme, durum güncelleme (Beklemede, Çözülüyor, Çözüldü vb.) ve istatistik analizi.

### 2. Yapay Zeka Destekli Hasar Analizi (Gemini 2.5) 🧠🤖
* Gemini 2.5 Flash modeli entegrasyonu ile yüklenen arıza fotoğrafının hasar türünü (su kaçağı, elektrik arızası, yol hasarı vb.) ve aciliyet seviyesini (düşük, orta, yüksek, kritik) otomatik analiz etme.
* Vatandaşa ilk aşamada yapılması gereken güvenli aksiyonları içeren profesyonel öneriler sunma.

### 3. İnteraktif Arıza Haritası 🗺️
* Google Maps entegrasyonu sayesinde bildirilen arızaların enlem/boylam koordinatlarıyla harita üzerinde konumlandırılması.
* Harita üzerinden arızaların görsel takibi.

### 4. Kurum Abonelik & Fatura Yönetimi (Su, Elektrik, Doğalgaz) 💧⚡🔥
* **Dinamik Temalandırma:** Su (mavi), Elektrik (amber/sarı) ve Doğalgaz (kırmızı) hizmetlerine özel görsel paneller.
* **Abonelik Kalan Süre Takibi:** Dairesel grafikler yardımıyla aboneliğin bitmesine kalan gün sayısını ve kalan kotayı görselleştirme.
* **Abonelik Yenileme & Satın Alma:** 1, 6 ve 12 aylık paketler arasından süre uzatabilme.
* **Sanal Kredi Kartı Görseli ile Ödeme:** Kart numarası ve SKT formatını otomatik biçimlendiren, kullanıcı yazdıkça kart üzerinde gerçek zamanlı güncellenen şık ve interaktif sanal POS ödeme simülasyonu.
* **Fatura Ödeme:** Ödenmemiş faturaları filtreleme ve anında kapatma.
* **Hızlı Arıza Yönlendirme:** İlgili kurum üzerinden anında arıza bildirim ekranına geçiş yapabilme.

---

## 🛠️ Kullanılan Teknolojiler

### Mobil (Frontend)
* **Framework:** [Flutter](https://flutter.dev) (Dart)
* **State Management:** Flutter BLoC (Cubit)
* **Local Caching:** `shared_preferences`
* **Görsel & Harita:** `google_maps_flutter`, `image_picker`, `cupertino_icons`
* **Bulut / Veri Tabanı:** `supabase_flutter` (Supabase Auth ve Veritabanı istemcisi)

### Sunucu (Backend)
* **Framework:** [FastAPI](https://fastapi.tiangolo.com) (Python)
* **Sunucu:** `uvicorn`
* **AI Modeli:** Google Generative AI (Gemini SDK)
* **Veritabanı Entegrasyonu:** Asenkron HTTP X ile Supabase REST API entegrasyonu.
* **Ortam Yönetimi:** `python-dotenv` (Gizli API Anahtarlarının güvenliği için)

---

## 🔑 Güvenlik & API Anahtarı Yönetimi

Gemini API anahtarlarının sızdırılmasını önlemek amacıyla API Key doğrudan kaynak kod içine gömülmek yerine **`.env`** çevre değişkeni dosyalarında saklanmaktadır. `.env` dosyası `.gitignore` kuralları ile Git sürüm kontrolünün dışında tutulmaktadır.

### Kurulum (Local Setup)

1. `backend/` klasörünün altında `.env` dosyası oluşturun:
   ```env
   GEMINI_API_KEY=kendi_gemini_api_anahtariniz
   ```
2. Bağımlılıkları yükleyin:
   ```bash
   pip install -r requirements.txt
   ```
3. Sunucuyu başlatın:
   ```bash
   python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

---

## 📊 Supabase Veritabanı Kurulumu (SQL)

Uygulamanın arıza kayıtlarını ve yapay zeka analiz geçmişini Supabase üzerinde saklayabilmesi için Supabase SQL Editor üzerinden aşağıdaki tabloları ve RLS politikalarını oluşturmanız gerekir:

```sql
-- 1. Arızalar Tablosu
create table if not exists arizalar (
  id text primary key,
  baslik text not null,
  aciklama text,
  kategori text,
  oncelik text,
  durum text,
  adres text,
  enlem double precision,
  boylam double precision,
  fotograflar jsonb,
  vatandas_id text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- 2. Yapay Zeka Sorguları Tablosu (AI Sorgu Geçmişi)
create table if not exists yapay_zeka_sorgular (
  id text primary key,
  aciklama text,
  gorsel_adi text,
  ariza_turu text,
  aciliyet text,
  detayli_aciklama text,
  oneriler text,
  vatandas_id text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- RLS (Row Level Security) Etkinleştirme
alter table arizalar enable row level security;
alter table yapay_zeka_sorgular enable row level security;

-- Herkesin Okuma/Yazma Yapabilmesi İçin İzinler
create policy "Allow all operations for arizalar" on arizalar for all using (true) with check (true);
create policy "Allow all operations for yapay_zeka_sorgular" on yapay_zeka_sorgular for all using (true) with check (true);
```
