import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../ariza/bloc/ariza_cubit.dart';

class KurumSikayetDetayScreen extends StatefulWidget {
  final String arizaId;

  const KurumSikayetDetayScreen({super.key, required this.arizaId});

  @override
  State<KurumSikayetDetayScreen> createState() => _KurumSikayetDetayScreenState();
}

class _KurumSikayetDetayScreenState extends State<KurumSikayetDetayScreen> {
  String? _secilenDurum;
  final _notController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ArizaCubit>().loadArizaDetail(widget.arizaId);
  }

  @override
  void dispose() {
    _notController.dispose();
    super.dispose();
  }

  Future<void> _durumGuncelle() async {
    if (_secilenDurum == null) return;

    try {
      await context.read<ArizaCubit>().updateArizaStatus(
            id: widget.arizaId,
            durum: _secilenDurum!,
            aciklama: _notController.text.trim().isNotEmpty
                ? _notController.text.trim()
                : null,
          );
      _notController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Durum başarıyla güncellendi.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${error.toString()}')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şikayet Detayı #${widget.arizaId.split('_').last}'),
        centerTitle: true,
      ),
      body: BlocBuilder<ArizaCubit, ArizaState>(
        builder: (context, state) {
          if (state.isLoading && state.selectedAriza == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Hata: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ariza = state.selectedAriza;
          if (ariza == null) {
            return const Center(child: Text('Arıza bulunamadı.'));
          }

          _secilenDurum ??= ariza.durum;
          final stateColor = _statusColor(ariza.durum);

          return RefreshIndicator(
            onRefresh: () =>
                context.read<ArizaCubit>().loadArizaDetail(widget.arizaId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vatandaş Bilgisi
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(
                        ariza.vatandasAdSoyad ?? 'Kullanıcı',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        ariza.vatandasTelefon?.isNotEmpty == true
                            ? ariza.vatandasTelefon!
                            : 'Telefon numarası belirtilmemiş',
                      ),
                      trailing: ariza.vatandasTelefon?.isNotEmpty == true
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const IconButton(
                                icon: Icon(Icons.phone, color: Colors.green),
                                onPressed: null, // Arama işlevi eklenebilir
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Arıza Detayları
                  const Text(
                    'Arıza Bilgileri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  ariza.kategori.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.grey.shade100,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stateColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: stateColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  _statusLabel(ariza.durum),
                                  style: TextStyle(
                                    color: stateColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ariza.baslik,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ariza.adres,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Açıklama:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(ariza.aciklama),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Durum Güncelleme
                  const Text(
                    'İşlem Yap / Durum Güncelle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Yeni Durum',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _secilenDurum,
                            items: const [
                              DropdownMenuItem(value: 'bekliyor', child: Text('Bekliyor')),
                              DropdownMenuItem(value: 'inceleniyor', child: Text('İnceleniyor')),
                              DropdownMenuItem(value: 'devam_ediyor', child: Text('Devam Ediyor')),
                              DropdownMenuItem(value: 'cozuldu', child: Text('Çözüldü')),
                              DropdownMenuItem(value: 'reddedildi', child: Text('Reddedildi')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _secilenDurum = v);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notController,
                            decoration: const InputDecoration(
                              labelText: 'Vatandaşa Not (Opsiyonel)',
                              border: OutlineInputBorder(),
                              hintText: 'Bildirim güncellemesine açıklama ekleyin...',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _durumGuncelle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Güncelle ve Kaydet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Zaman Çizelgesi / Durum Geçmişi
                  const Text(
                    'Durum Geçmişi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (ariza.guncellemeler.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Henüz bir güncelleme kaydı yok.',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ariza.guncellemeler.length,
                      itemBuilder: (context, index) {
                        final update = ariza.guncellemeler[index];
                        final dateStr = update.tarih.toLocal().toString().split('.').first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: _statusColor(update.durum),
                                    size: 20,
                                  ),
                                  if (index < ariza.guncellemeler.length - 1)
                                    Container(
                                      width: 2,
                                      height: 40,
                                      color: Colors.grey.shade300,
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _statusLabel(update.durum),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _statusColor(update.durum),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      update.aciklama,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}
