class ArizaGuncellemesi {
  final String id;
  final String durum;
  final String aciklama;
  final DateTime tarih;

  ArizaGuncellemesi({
    required this.id,
    required this.durum,
    required this.aciklama,
    required this.tarih,
  });

  factory ArizaGuncellemesi.fromJson(Map<String, dynamic> json) {
    return ArizaGuncellemesi(
      id: json['id'] ?? '',
      durum: json['durum'] ?? '',
      aciklama: json['aciklama'] ?? '',
      tarih: DateTime.parse(json['tarih'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'durum': durum,
      'aciklama': aciklama,
      'tarih': tarih.toIso8601String(),
    };
  }
}

class ArizaModel {
  final String id;
  final String baslik;
  final String aciklama;
  final String kategori; // su | elektrik | karayolu | dogalgaz | vb.
  final String oncelik; // dusuk | normal | yuksek | acil
  final String durum; // bekliyor | inceleniyor | devam_ediyor | cozuldu | reddedildi
  final String adres;
  final double? enlem;
  final double? boylam;
  final List<String> fotograflar;
  final String vatandasId;
  final String? kurumId;
  final List<ArizaGuncellemesi> guncellemeler;
  final int puanlama; // 1-5

  ArizaModel({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.kategori,
    required this.oncelik,
    required this.durum,
    required this.adres,
    this.enlem,
    this.boylam,
    required this.fotograflar,
    required this.vatandasId,
    this.kurumId,
    required this.guncellemeler,
    required this.puanlama,
  });

  factory ArizaModel.fromJson(Map<String, dynamic> json) {
    return ArizaModel(
      id: json['id'] ?? '',
      baslik: json['baslik'] ?? '',
      aciklama: json['aciklama'] ?? '',
      kategori: json['kategori'] ?? '',
      oncelik: json['oncelik'] ?? 'normal',
      durum: json['durum'] ?? 'bekliyor',
      adres: json['adres'] ?? '',
      enlem: (json['enlem'] as num?)?.toDouble(),
      boylam: (json['boylam'] as num?)?.toDouble(),
      fotograflar: List<String>.from(json['fotograflar'] ?? []),
      vatandasId: json['vatandasId'] ?? '',
      kurumId: json['kurumId'],
      guncellemeler: (json['guncellemeler'] as List<dynamic>?)
              ?.map((e) => ArizaGuncellemesi.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      puanlama: json['puanlama'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'aciklama': aciklama,
      'kategori': kategori,
      'oncelik': oncelik,
      'durum': durum,
      'adres': adres,
      'enlem': enlem,
      'boylam': boylam,
      'fotograflar': fotograflar,
      'vatandasId': vatandasId,
      'kurumId': kurumId,
      'guncellemeler': guncellemeler.map((e) => e.toJson()).toList(),
      'puanlama': puanlama,
    };
  }
}
