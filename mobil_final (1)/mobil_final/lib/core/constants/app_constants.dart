class AppConstants {
  // Uygulama Adı
  static const String appName = 'Belediye Arıza Takip Sistemi';

  // API (Gelecekte entegre edilecek)
  static const String baseUrl = 'https://api.belediye-ariza.com';

  // Arıza Durumları
  static const String durumBekliyor = 'bekliyor';
  static const String durumInceleniyor = 'inceleniyor';
  static const String durumDevamEdiyor = 'devam_ediyor';
  static const String durumCozuldu = 'cozuldu';
  static const String durumReddedildi = 'reddedildi';

  // Arıza Kategorileri
  static const String kategoriSu = 'su';
  static const String kategoriElektrik = 'elektrik';
  static const String kategoriKarayolu = 'karayolu';
  static const String kategoriDogalgaz = 'dogalgaz';
  static const String kategoriParkBahce = 'park_bahce';
  static const String kategoriDiger = 'diger';

  // Öncelik Seviyeleri
  static const String oncelikDusuk = 'dusuk';
  static const String oncelikNormal = 'normal';
  static const String oncelikYuksek = 'yuksek';
  static const String oncelikAcil = 'acil';

  // Kullanıcı Tipleri
  static const String tipVatandas = 'vatandas';
  static const String tipKurum = 'kurum';
}
