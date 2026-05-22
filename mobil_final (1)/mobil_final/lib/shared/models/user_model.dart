class UserModel {
  final String id;
  final String ad;
  final String soyad;
  final String tcKimlik;
  final String email;
  final String telefon;
  final String adres;
  final String tip; // vatandas
  final bool bildirimAktif;

  UserModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.tcKimlik,
    required this.email,
    required this.telefon,
    required this.adres,
    this.tip = 'vatandas',
    this.bildirimAktif = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      ad: json['ad'] ?? '',
      soyad: json['soyad'] ?? '',
      tcKimlik: json['tcKimlik'] ?? '',
      email: json['email'] ?? '',
      telefon: json['telefon'] ?? '',
      adres: json['adres'] ?? '',
      tip: json['tip'] ?? 'vatandas',
      bildirimAktif: json['bildirimAktif'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'soyad': soyad,
      'tcKimlik': tcKimlik,
      'email': email,
      'telefon': telefon,
      'adres': adres,
      'tip': tip,
      'bildirimAktif': bildirimAktif,
    };
  }
}

class KurumModel {
  final String id;
  final String kurumAdi;
  final String kurumKodu;
  final String kurumTipi; // elektrik, su vb.
  final String yetkiliAd;
  final String logo;

  KurumModel({
    required this.id,
    required this.kurumAdi,
    required this.kurumKodu,
    required this.kurumTipi,
    required this.yetkiliAd,
    required this.logo,
  });

  factory KurumModel.fromJson(Map<String, dynamic> json) {
    return KurumModel(
      id: json['id'] ?? '',
      kurumAdi: json['kurumAdi'] ?? '',
      kurumKodu: json['kurumKodu'] ?? '',
      kurumTipi: json['kurumTipi'] ?? '',
      yetkiliAd: json['yetkiliAd'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kurumAdi': kurumAdi,
      'kurumKodu': kurumKodu,
      'kurumTipi': kurumTipi,
      'yetkiliAd': yetkiliAd,
      'logo': logo,
    };
  }
}
