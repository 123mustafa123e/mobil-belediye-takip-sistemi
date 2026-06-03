import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_routes.dart';
import '../../ariza/bloc/ariza_cubit.dart';
import '../../auth/bloc/auth_cubit.dart';

class KurumDashboardScreen extends StatefulWidget {
  const KurumDashboardScreen({super.key});

  @override
  State<KurumDashboardScreen> createState() => _KurumDashboardScreenState();
}

class _KurumDashboardScreenState extends State<KurumDashboardScreen> {
  String _secilenKategori = 'tumu';

  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizalar();
  }

  String _statusLabel(String durum) {
    switch (durum) {
      case 'bekliyor':
        return 'Bekliyor';
      case 'inceleniyor':
        return 'İnceleniyor';
      case 'devam_ediyor':
        return 'Devam Ediyor';
      case 'cozuldu':
        return 'Çözüldü';
      case 'reddedildi':
        return 'Reddedildi';
      default:
        return durum;
    }
  }

  IconData _categoryIcon(String kategori) {
    switch (kategori) {
      case 'su':
        return Icons.water_drop;
      case 'elektrik':
        return Icons.electric_bolt;
      case 'karayolu':
        return Icons.add_road;
      case 'dogalgaz':
        return Icons.local_fire_department;
      default:
        return Icons.warning;
    }
  }

  Color _categoryColor(String kategori) {
    switch (kategori) {
      case 'su':
        return Colors.blue;
      case 'elektrik':
        return Colors.yellow.shade700;
      case 'karayolu':
        return Colors.orange;
      case 'dogalgaz':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFilterChip(String value, String label, IconData icon, Color color) {
    final isSelected = _secilenKategori == value;
    return ChoiceChip(
      avatar: Icon(icon, color: isSelected ? Colors.white : color, size: 16),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _secilenKategori = value);
        }
      },
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurum Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: BlocBuilder<ArizaCubit, ArizaState>(
        builder: (context, state) {
          final arizalar = state.arizalar;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bekleyenCount = arizalar.where((a) => a.durum == 'bekliyor').length;
          final incelenenCount = arizalar.where((a) => a.durum == 'inceleniyor').length;
          final devamCount = arizalar.where((a) => a.durum == 'devam_ediyor').length;
          final cozulendenCount = arizalar.where((a) => a.durum == 'cozuldu').length;

          // Kategoriye göre filtrele
          final filteredArizalar = _secilenKategori == 'tumu'
              ? arizalar
              : arizalar.where((a) => a.kategori == _secilenKategori).toList();

          // Acil veya yüksek öncelikli şikayetler
          final acilArizalar = filteredArizalar
              .where((a) => a.oncelik == 'acil' || a.oncelik == 'yuksek')
              .toList();

          // Eğer acil şikayet yoksa, en yeni şikayetleri gösterelim
          final gosterilecekList = acilArizalar.isNotEmpty ? acilArizalar : filteredArizalar;

          return RefreshIndicator(
            onRefresh: () => context.read<ArizaCubit>().loadArizalar(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kurum Kartı
                  Card(
                    color: Colors.blue.shade50,
                    child: const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.business)),
                      title: Text('Belediye Arıza Takip Birimi', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Kurum Kodu: KRM-101'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // İstatistik Grid
                  const Text('Genel Durum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Bekleyen', '$bekleyenCount', Colors.red)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('İncelenen', '$incelenenCount', Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Devam Eden', '$devamCount', Colors.blue)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Çözülen', '$cozulendenCount', Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Birim Filtreleri
                  const Text('Birimlere Göre Filtrele', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('tumu', 'Tümü', Icons.all_inclusive, Colors.grey),
                        const SizedBox(width: 8),
                        _buildFilterChip('su', 'Su İşleri', Icons.water_drop, Colors.blue),
                        const SizedBox(width: 8),
                        _buildFilterChip('elektrik', 'Elektrik', Icons.electric_bolt, Colors.yellow.shade700),
                        const SizedBox(width: 8),
                        _buildFilterChip('karayolu', 'Fen/Yol İşleri', Icons.add_road, Colors.orange),
                        const SizedBox(width: 8),
                        _buildFilterChip('dogalgaz', 'Doğalgaz', Icons.local_fire_department, Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Acil/Son Şikayetler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        acilArizalar.isNotEmpty ? 'Acil Şikayetler' : 'Son Şikayetler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: acilArizalar.isNotEmpty ? Colors.red : Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.kurumSikayetListesi);
                        },
                        child: const Text('Tümünü Gör'),
                      ),
                    ],
                  ),
                  if (gosterilecekList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('Henüz bildirilen bir arıza yok.')),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gosterilecekList.take(5).length,
                      itemBuilder: (context, index) {
                        final ariza = gosterilecekList[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _categoryColor(ariza.kategori).withOpacity(0.15),
                              child: Icon(
                                _categoryIcon(ariza.kategori),
                                color: _categoryColor(ariza.kategori),
                              ),
                            ),
                            title: Text(ariza.baslik),
                            subtitle: Text('${ariza.adres} (${_statusLabel(ariza.durum)})'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.kurumSikayetDetay,
                                arguments: {'sikayetId': ariza.id},
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
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
