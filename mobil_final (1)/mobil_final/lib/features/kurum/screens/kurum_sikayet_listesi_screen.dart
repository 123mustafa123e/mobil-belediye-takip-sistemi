import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/models/ariza_model.dart';
import '../../ariza/bloc/ariza_cubit.dart';

class KurumSikayetListesiScreen extends StatefulWidget {
  const KurumSikayetListesiScreen({super.key});

  @override
  State<KurumSikayetListesiScreen> createState() => _KurumSikayetListesiScreenState();
}

class _KurumSikayetListesiScreenState extends State<KurumSikayetListesiScreen> {
  String _secilenKategori = 'tumu';

  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizalar();
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
        body: Column(
          children: [
            // Kategori Seçim Filtresi
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              color: Colors.grey.shade50,
              height: 56,
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
            Expanded(
              child: BlocBuilder<ArizaCubit, ArizaState>(
                builder: (context, state) {
                  final arizalar = state.arizalar;

                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    children: [
                      _buildList(arizalar, 'bekliyor'),
                      _buildList(arizalar, 'inceleniyor'),
                      _buildList(arizalar, 'devam_ediyor'),
                      _buildList(arizalar, 'cozuldu'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ArizaModel> arizalar, String dbDurum) {
    final list = arizalar
        .where((a) =>
            a.durum == dbDurum &&
            (_secilenKategori == 'tumu' || a.kategori == _secilenKategori))
        .toList();

    if (list.isEmpty) {
      return const Center(child: Text('Bu durumda şikayet bulunmamaktadır.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ArizaCubit>().loadArizalar(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final ariza = list[index];
          final color = _categoryColor(ariza.kategori);

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(_categoryIcon(ariza.kategori), color: color),
              ),
              title: Text(ariza.baslik),
              subtitle: Text('Öncelik: ${ariza.oncelik.toUpperCase()}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'detay', child: Text('Detayları Gör')),
                ],
                onSelected: (value) {
                  if (value == 'detay') {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.kurumSikayetDetay,
                      arguments: {'sikayetId': ariza.id},
                    );
                  }
                },
              ),
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
    );
  }
}
