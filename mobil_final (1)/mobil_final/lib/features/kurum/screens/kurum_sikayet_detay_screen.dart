import 'package:flutter/material.dart';

class KurumSikayetDetayScreen extends StatelessWidget {
  final String arizaId;

  const KurumSikayetDetayScreen({super.key, required this.arizaId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Şikayet Detayı #$arizaId')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vatandaş Bilgisi
            const Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Ahmet Yılmaz'),
                subtitle: Text('0500 000 00 00'),
                trailing: Icon(Icons.phone, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Arıza Bilgileri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Başlık: Su Borusu Patlaması'),
            const Text('Adres: Atatürk Mah. Lale Sok. No:5'),
            const SizedBox(height: 16),
            const Text('Açıklama:'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade100,
              child: const Text('Sokak girişinde su borusu patladı, sular boşa akıyor. Acil müdahale gerekiyor.'),
            ),
            const SizedBox(height: 24),
            // İşlem Yap
            const Text('Durum Güncelle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              initialValue: 'inceleniyor',
              items: const [
                DropdownMenuItem(value: 'bekliyor', child: Text('Bekliyor')),
                DropdownMenuItem(value: 'inceleniyor', child: Text('İnceleniyor')),
                DropdownMenuItem(value: 'devam_ediyor', child: Text('Devam Ediyor')),
                DropdownMenuItem(value: 'cozuldu', child: Text('Çözüldü')),
                DropdownMenuItem(value: 'reddedildi', child: Text('Reddedildi')),
              ],
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Vatandaşa Not (Opsiyonel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Güncelle ve Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
