import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Özet Kartları
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Açık', '3', Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Çözülen', '12', Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Kategori Grid
            const Text('Hızlı Bildirim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: [
                _buildCategoryItem(Icons.water_drop, 'Su', Colors.blue),
                _buildCategoryItem(Icons.electric_bolt, 'Elektrik', Colors.yellow.shade700),
                _buildCategoryItem(Icons.add_road, 'Karayolu', Colors.grey),
                _buildCategoryItem(Icons.local_fire_department, 'Doğalgaz', Colors.red),
                _buildCategoryItem(Icons.park, 'Park/Bahçe', Colors.green),
                _buildCategoryItem(Icons.more_horiz, 'Diğer', Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            
            // Yeni Eklenen Araçlar (Map & AI)
            const Text('Akıllı Araçlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/map'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.map, size: 32, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Arıza Haritası', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/ai_assistant'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.smart_toy, size: 32, color: Colors.deepPurple),
                          SizedBox(height: 8),
                          Text('Yapay Zeka', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Son Şikayetler
            const Text('Son Bildirimlerim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.report_problem),
                    title: Text('Arıza Bildirimi #${1000 + index}'),
                    subtitle: const Text('Durum: İnceleniyor'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.arizaDetay,
                        arguments: {'arizaId': '${1000 + index}'},
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.arizaBildir);
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        tooltip: 'Yeni Arıza Bildir',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
