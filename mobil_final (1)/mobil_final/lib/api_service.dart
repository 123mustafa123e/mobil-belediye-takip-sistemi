import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalizSonucu {
  final String arizaTuru;
  final String aciliyet;
  final String aciklama;
  final String onerim;

  AnalizSonucu({
    required this.arizaTuru,
    required this.aciliyet,
    required this.aciklama,
    required this.onerim,
  });

  factory AnalizSonucu.fromJson(Map<String, dynamic> json) {
    return AnalizSonucu(
      arizaTuru: json['ariza_turu'] ?? '',
      aciliyet: json['aciliyet'] ?? '',
      aciklama: json['aciklama'] ?? '',
      onerim: json['onerim'] ?? '',
    );
  }
}

class ApiService {
  // Android emülatör için 10.0.2.2, gerçek cihaz için bilgisayarın IP'si
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<AnalizSonucu> analizEt({
    File? gorsel,
    String aciklama = '',
  }) async {
    final uri = Uri.parse('$baseUrl/analiz');
    final request = http.MultipartRequest('POST', uri);

    request.fields['aciklama'] = aciklama;
    request.fields['ai_secim'] = 'gemini';

    if (gorsel != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'gorsel',
        gorsel.path,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AnalizSonucu.fromJson(data);
    } else {
      throw Exception('Analiz hatası: ${response.body}');
    }
  }
}