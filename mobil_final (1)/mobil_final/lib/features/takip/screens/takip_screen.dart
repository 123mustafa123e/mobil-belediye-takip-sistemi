import 'package:flutter/material.dart';

class TakipScreen extends StatelessWidget {
  const TakipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şikayet Takip')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Takip Numarası ile Sorgula', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Takip Numarası (Örn: 10245)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Sorgula ve detay sayfasına git
                },
                child: const Text('Sorgula'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
