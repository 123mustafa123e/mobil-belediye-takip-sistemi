import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class KurumSikayetListesiScreen extends StatelessWidget {
  const KurumSikayetListesiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gelen Şikayetler'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Bekleyen'),
              Tab(text: 'İncelenen'),
              Tab(text: 'Devam Eden'),
              Tab(text: 'Çözülen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList('Bekliyor', Colors.red),
            _buildList('İnceleniyor', Colors.orange),
            _buildList('Devam Ediyor', Colors.blue),
            _buildList('Çözüldü', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String durum, Color statusColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(Icons.assignment, color: statusColor),
            ),
            title: Text('Şikayet #${3000 + index}'),
            subtitle: Text('Öncelik: ${index % 2 == 0 ? 'Acil' : 'Normal'}'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'durum', child: Text('Durum Güncelle')),
                const PopupMenuItem(value: 'detay', child: Text('Detayları Gör')),
              ],
              onSelected: (value) {
                if (value == 'detay') {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.kurumSikayetDetay,
                    arguments: {'sikayetId': '${3000 + index}'},
                  );
                }
              },
            ),
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
    );
  }
}
