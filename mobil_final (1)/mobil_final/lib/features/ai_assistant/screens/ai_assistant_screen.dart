import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import 'ai_result_screen.dart';

String get _backendUrl {
  if (kIsWeb) return 'http://localhost:8000';
  return 'http://10.0.2.2:8000';
}

class _AnalizSonucu {
  final String arizaTuru;
  final String aciliyet;
  final String aciklama;
  final String onerim;

  _AnalizSonucu.fromJson(Map<String, dynamic> j)
      : arizaTuru = j['ariza_turu'] ?? '',
        aciliyet = j['aciliyet'] ?? '',
        aciklama = j['aciklama'] ?? '',
        onerim = j['onerim'] ?? '';
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _questionController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showSnackBar('Resim seçilemedi: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamerayla Çek'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.secondary),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeWithAI() async {
    if (_selectedImage == null && _questionController.text.trim().isEmpty) {
      _showSnackBar('Lütfen bir resim seçin veya açıklama yazın.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_backendUrl/analiz'),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['aciklama'] = _questionController.text.trim();
      request.fields['ai_secim'] = 'gemini';

      if (_selectedImage != null) {
        final filename = _selectedImage!.name.toLowerCase();
        String mime = 'image/jpeg';
        if (filename.endsWith('.png')) mime = 'image/png';
        if (filename.endsWith('.webp')) mime = 'image/webp';

        final mimeParts = mime.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'gorsel',
            _selectedImageBytes!,
            filename: _selectedImage!.name,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ),
        );
      }

      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Sunucu yanıt vermiyor (zaman aşımı)'),
      );

      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        final sonuc = _AnalizSonucu.fromJson(jsonData);

        setState(() => _isLoading = false);

        if (mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnalizSonucEkrani(
                arizaTuru: sonuc.arizaTuru,
                aciliyet: sonuc.aciliyet,
                aciklama: sonuc.aciklama,
                onerim: sonuc.onerim,
                gorselBytes: _selectedImageBytes,
              ),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = 'Sunucu hatası: ${response.statusCode}\n$body');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Bağlantı hatası: $e\n\nBackend sunucusunun çalışır durumda olduğundan emin olun.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yapay Zeka Asistanı',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Açıklama Alanı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: 'Arıza hakkında açıklama yazın...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.smart_toy, color: AppColors.primary),
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Resim Seçimi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _selectedImageBytes != null
                      ? Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _selectedImageBytes!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Resmi Değiştir'),
                            ),
                          ],
                        )
                      : const Column(
                          children: [
                            Icon(Icons.add_a_photo, size: 48, color: AppColors.secondary),
                            SizedBox(height: 12),
                            Text(
                              'Fotoğraf Yükle ve Analiz Et',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Arızanın resmini yükleyerek yapay zekanın analiz etmesini sağlayın.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Analiz Butonu
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzeWithAI,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? 'Analiz Ediliyor...' : 'Yapay Zeka ile Analiz Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Hata Alanı
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hata', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),

            if (!_isLoading && _errorMessage == null && _selectedImageBytes == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Resim yükleyin veya açıklama yazın, ardından "Analiz Et" butonuna basın.\n\nYapay zeka arızanın türünü, aciliyetini ve önerilen işlemi belirleyecektir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}