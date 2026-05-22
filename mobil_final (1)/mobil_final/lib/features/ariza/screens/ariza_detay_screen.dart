import 'package:flutter/material.dart';

class ArizaDetayScreen extends StatelessWidget {
  final String arizaId;

  const ArizaDetayScreen({super.key, required this.arizaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Arıza Detayı #$arizaId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum Banner
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Durum: İnceleniyor', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Başlık', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Su Borusu Patlaması'),
            const SizedBox(height: 8),
            const Text('Kategori: Su', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Text('Açıklama', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Sokak girişinde su borusu patladı, sular boşa akıyor.'),
            const SizedBox(height: 24),
            const Text('Zaman Çizelgesi (Süreç)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimelineItem('Bildirim Alındı', '12:00 - 10 Ekim 2023', true),
            _buildTimelineItem('Kuruma İletildi', '12:15 - 10 Ekim 2023', true),
            _buildTimelineItem('İnceleniyor', '13:00 - 10 Ekim 2023', false, isCurrent: true),
            _buildTimelineItem('Çözüldü', 'Bekleniyor', false),
            
            const SizedBox(height: 32),
            // Değerlendirme
            const Text('Hizmeti Değerlendirin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: List.generate(5, (index) => IconButton(
                icon: const Icon(Icons.star_border),
                onPressed: () {},
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, {bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
              color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey),
            ),
            Container(width: 2, height: 30, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }
}
