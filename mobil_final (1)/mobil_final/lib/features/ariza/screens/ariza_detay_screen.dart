import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ariza_cubit.dart';

class ArizaDetayScreen extends StatefulWidget {
  final String arizaId;

  const ArizaDetayScreen({super.key, required this.arizaId});

  @override
  State<ArizaDetayScreen> createState() => _ArizaDetayScreenState();
}

class _ArizaDetayScreenState extends State<ArizaDetayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizaDetail(widget.arizaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arıza Detayı')),
      body: BlocBuilder<ArizaCubit, ArizaState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          final ariza = state.selectedAriza;
          if (ariza == null) {
            return const Center(child: Text('Arıza bulunamadı.'));
          }

          final color = _statusColor(ariza.durum);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Durum: ${ariza.durum}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Başlık', style: Theme.of(context).textTheme.titleMedium),
                Text(ariza.baslik),
                const SizedBox(height: 12),
                Text(
                  'Kategori: ${ariza.kategori}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  'Açıklama',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(ariza.aciklama),
                const SizedBox(height: 16),
                Text(
                  'Zaman Çizelgesi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...ariza.guncellemeler.map(
                  (update) => _buildTimelineItem(
                    update.aciklama,
                    update.tarih.toString(),
                    true,
                  ),
                ),
                if (ariza.guncellemeler.isEmpty)
                  _buildTimelineItem(
                    'Bildirim alındı',
                    'Henüz güncelleme yok',
                    true,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String durum) {
    switch (durum) {
      case 'cozuldu':
        return Colors.green;
      case 'reddedildi':
        return Colors.red;
      case 'inceleniyor':
        return Colors.orange;
      case 'devam_ediyor':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
