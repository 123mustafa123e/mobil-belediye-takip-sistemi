import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class KurumDashboardScreen extends StatelessWidget {
  const KurumDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurum Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kurum Kartı
            Card(
              color: Colors.blue.shade50,
              child: const ListTile(
                leading: CircleAvatar(child: Icon(Icons.business)),
                title: Text('ASKİ - Su Arıza Birimi', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Kurum Kodu: KRM-101'),
              ),
            ),
            const SizedBox(height: 24),
            // İstatistik Grid
            const Text('Genel Durum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Bekleyen', '15', Colors.red)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('İncelenen', '8', Colors.orange)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Devam Eden', '5', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Çözülen', '42', Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            // Acil Şikayetler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Acil Şikayetler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.kurumSikayetListesi);
                  },
                  child: const Text('Tümünü Gör'),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: const Text('Ana Boru Patlaması'),
                    subtitle: const Text('Atatürk Mah. Lale Sok.'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.kurumSikayetDetay,
                        arguments: {'sikayetId': '${3000 + index}'},
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
