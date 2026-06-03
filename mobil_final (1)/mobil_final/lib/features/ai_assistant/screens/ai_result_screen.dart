import 'dart:typed_data';
import 'package:flutter/material.dart';

class AnalizSonucEkrani extends StatelessWidget {
  final String arizaTuru;
  final String aciliyet;
  final String aciklama;
  final String onerim;
  final Uint8List? gorselBytes;

  const AnalizSonucEkrani({
    super.key,
    required this.arizaTuru,
    required this.aciliyet,
    required this.aciklama,
    required this.onerim,
    this.gorselBytes,
  });

  Color _aciliyetRengi() {
    switch (aciliyet) {
      case 'Kritik':
        return const Color(0xFFE53935);
      case 'Yüksek':
        return const Color(0xFFFF7043);
      case 'Orta':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  Color _aciliyetArkaPlan() {
    switch (aciliyet) {
      case 'Kritik':
        return const Color(0xFFFFEBEE);
      case 'Yüksek':
        return const Color(0xFFFBE9E7);
      case 'Orta':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  IconData _arizaIkonu() {
    switch (arizaTuru) {
      case 'Yangın':
        return Icons.local_fire_department;
      case 'Su Kaçağı':
        return Icons.water_damage;
      case 'Elektrik Arızası':
        return Icons.electrical_services;
      case 'Yapısal Hasar':
        return Icons.domain_disabled;
      case 'Yol/Kaldırım':
        return Icons.construction;
      case 'Park/Bahçe':
        return Icons.park;
      default:
        return Icons.report_problem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> adimlar = onerim
        .split('.')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analiz Sonucu',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Görsel
                                  if (gorselBytes != null && gorselBytes!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          gorselBytes!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Text('Görsel yüklenemedi: $error'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Analiz Kartı
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tür + Aciliyet
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _aciliyetArkaPlan(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _arizaIkonu(),
                                      color: _aciliyetRengi(),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Arıza Türü',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        arizaTuru,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _aciliyetArkaPlan(),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _aciliyetRengi(),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      aciliyet,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: _aciliyetRengi(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 28),

                          // Açıklama
                          const Text(
                            'AÇIKLAMA',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            aciklama,
                            style: const TextStyle(fontSize: 14, height: 1.6),
                          ),

                          const Divider(height: 28),

                          // Yapılması Gerekenler
                          const Text(
                            'YAPILMASI GEREKENLER',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...adimlar.asMap().entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE3F2FD),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1565C0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Yeni Analiz Butonu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Yeni Analiz Yap',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}