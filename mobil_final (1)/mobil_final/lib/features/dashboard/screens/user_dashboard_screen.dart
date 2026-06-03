import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../ariza/bloc/ariza_cubit.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizalar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profil),
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ArizaCubit, ArizaState>(
        builder: (context, state) {
          final arizalar = state.arizalar;
          final openCount = arizalar
              .where(
                (item) => item.durum != 'cozuldu' && item.durum != 'reddedildi',
              )
              .length;
          final solvedCount = arizalar
              .where((item) => item.durum == 'cozuldu')
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Açık',
                        '$openCount',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Çözülen',
                        '$solvedCount',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hızlı Bildirim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: [
                    _buildCategoryItem(
                      icon: Icons.water_drop,
                      label: 'Su',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.abonelikDetay,
                        arguments: {'type': 'su'},
                      ),
                    ),
                    _buildCategoryItem(
                      icon: Icons.electric_bolt,
                      label: 'Elektrik',
                      color: Colors.yellow.shade700,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.abonelikDetay,
                        arguments: {'type': 'elektrik'},
                      ),
                    ),
                    _buildCategoryItem(
                      icon: Icons.add_road,
                      label: 'Karayolu',
                      color: Colors.grey,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Karayolu için abonelik gerekmemektedir. Doğrudan arıza bildirebilirsiniz.',
                          ),
                        ),
                      ),
                    ),
                    _buildCategoryItem(
                      icon: Icons.local_fire_department,
                      label: 'Doğalgaz',
                      color: Colors.red,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.abonelikDetay,
                        arguments: {'type': 'dogalgaz'},
                      ),
                    ),
                    _buildCategoryItem(
                      icon: Icons.park,
                      label: 'Park/Bahçe',
                      color: Colors.green,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Park ve bahçeler için abonelik gerekmemektedir. Doğrudan arıza bildirebilirsiniz.',
                          ),
                        ),
                      ),
                    ),
                    _buildCategoryItem(
                      icon: Icons.more_horiz,
                      label: 'Diğer',
                      color: Colors.purple,
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Diğer bildirimler için abonelik gerekmemektedir. Doğrudan arıza bildirebilirsiniz.',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Akıllı Araçlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.mapScreen),
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
                              Text(
                                'Arıza Haritası',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.aiAssistant),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.deepPurple.shade200,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 32,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Yapay Zeka',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Son Bildirimlerim',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (arizalar.isEmpty)
                  const Text('Henüz arıza bildirimi yok.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: arizalar.take(3).length,
                    itemBuilder: (context, index) {
                      final ariza = arizalar[index];

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.report_problem),
                          title: Text(ariza.baslik),
                          subtitle: Text('Durum: ${ariza.durum}'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.arizaDetay,
                              arguments: {'arizaId': ariza.id},
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
