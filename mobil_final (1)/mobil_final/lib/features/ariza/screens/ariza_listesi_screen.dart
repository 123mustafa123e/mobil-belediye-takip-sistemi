import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';

class ArizaListesiScreen extends StatelessWidget {
  const ArizaListesiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Şikayetlerim'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tümü'),
              Tab(text: 'Devam Eden'),
              Tab(text: 'Çözülen'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(),
            _buildList(filter: 'devam'),
            _buildList(filter: 'cozuldu'),
          ],
        ),
      ),
    );
  }

  Widget _buildList({String? filter}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5, // Mock data count
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.build, color: Colors.blue),
            ),
            title: Text('Arıza Kaydı #${2000 + index}'),
            subtitle: Text('Durum: ${filter ?? 'Bekliyor'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.arizaDetay,
                arguments: {'arizaId': '${2000 + index}'},
              );
            },
          ),
        );
      },
    );
  }
}
