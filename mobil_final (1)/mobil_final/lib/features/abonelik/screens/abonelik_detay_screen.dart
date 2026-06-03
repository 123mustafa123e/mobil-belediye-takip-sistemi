import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/abonelik_cubit.dart';
import '../../../shared/models/abonelik_model.dart';

class AbonelikDetayScreen extends StatefulWidget {
  final String type;

  const AbonelikDetayScreen({super.key, required this.type});

  @override
  State<AbonelikDetayScreen> createState() => _AbonelikDetayScreenState();
}

class _AbonelikDetayScreenState extends State<AbonelikDetayScreen> {
  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında güncel abonelik bilgilerini yükle/yenile
    context.read<AbonelikCubit>().loadAbonelikler();
  }

  // Yardımcı metodlar: Tip bazlı renk ve isim eşleme
  Color _getPrimaryColor() {
    switch (widget.type) {
      case 'su':
        return Colors.blue.shade700;
      case 'elektrik':
        return Colors.amber.shade800;
      case 'dogalgaz':
        return Colors.red.shade700;
      default:
        return Colors.blue;
    }
  }

  String _getUtilityTitle() {
    switch (widget.type) {
      case 'su':
        return 'Su Aboneliği';
      case 'elektrik':
        return 'Elektrik Aboneliği';
      case 'dogalgaz':
        return 'Doğalgaz Aboneliği';
      default:
        return 'Kurum Aboneliği';
    }
  }

  String _getUtilityProvider() {
    switch (widget.type) {
      case 'su':
        return 'Bartın Belediyesi Su İşleri';
      case 'elektrik':
        return 'BEDAŞ Enerji Dağıtım A.Ş.';
      case 'dogalgaz':
        return 'AKSA Doğalgaz Dağıtım';
      default:
        return 'Belediye Hizmetleri';
    }
  }

  IconData _getUtilityIcon() {
    switch (widget.type) {
      case 'su':
        return Icons.water_drop;
      case 'elektrik':
        return Icons.electric_bolt;
      case 'dogalgaz':
        return Icons.local_fire_department;
      default:
        return Icons.business;
    }
  }

  String _getUtilityUnit() {
    switch (widget.type) {
      case 'su':
        return 'm³';
      case 'elektrik':
        return 'kWh';
      case 'dogalgaz':
        return 'm³';
      default:
        return 'Birim';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getPrimaryColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getUtilityTitle()),
        backgroundColor: themeColor,
      ),
      body: BlocConsumer<AbonelikCubit, AbonelikState>(
        listener: (context, state) {
          if (state.paymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Ödeme işleminiz başarıyla tamamlandı!'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 3),
              ),
            );
            context.read<AbonelikCubit>().clearPaymentSuccess();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final abonelik = state.abonelikler[widget.type];
          if (abonelik == null) {
            return const Center(child: Text('Abonelik bilgisi yüklenemedi.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kurum Tanıtım Kartı
                _buildProviderCard(themeColor),
                const SizedBox(height: 16),

                // Abonelik Durum Kartı
                _buildStatusCard(abonelik, themeColor),
                const SizedBox(height: 16),

                // Borç ve Fatura Durumu
                _buildInvoiceSection(abonelik, themeColor),
                const SizedBox(height: 16),

                // İşlem Geçmişi
                if (abonelik.isSubscribed && abonelik.invoiceHistory.isNotEmpty) ...[
                  const Text(
                    'Geçmiş Faturalar & Ödemeler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentHistoryList(abonelik),
                  const SizedBox(height: 16),
                ],

                // Hızlı Arıza Bildirim Kartı
                _buildQuickFaultReportCard(themeColor),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: themeColor.withOpacity(0.1),
            child: Icon(_getUtilityIcon(), color: themeColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getUtilityTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getUtilityProvider(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AbonelikModel abonelik, Color themeColor) {
    if (!abonelik.isSubscribed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor.withOpacity(0.8), themeColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Aktif Aboneliğiniz Bulunmuyor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu hizmet için hemen yeni bir abonelik başlatın.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showSubscribeDialog(themeColor),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: themeColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Abonelik Başlat',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // Abonelik aktifse gösterilecek şık kart
    final daysRemaining = abonelik.daysRemaining;
    final isLow = daysRemaining <= 15;
    final progress = (daysRemaining / 90.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abonelik Numarası',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    abonelik.subscriptionNo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              // Kalan gün dairesel gösterge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade100,
                      color: isLow ? Colors.orange : themeColor,
                      strokeWidth: 8,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$daysRemaining',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.orange.shade800 : Colors.black87,
                        ),
                      ),
                      const Text(
                        'Gün',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLow ? 'Abonelik Süreniz Azaldı' : 'Abonelik Süresi Yeterli',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isLow ? Colors.orange.shade800 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLow
                          ? 'Aboneliğinizin kesilmemesi için lütfen süre yenileyin.'
                          : 'Aboneliğiniz sorunsuz bir şekilde devam etmektedir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalan Kullanım',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '${abonelik.usageRemaining.toStringAsFixed(1)} ${_getUtilityUnit()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Abonelik Tipi',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    abonelik.planName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSubscribeDialog(themeColor, isRenewal: true),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: themeColor),
                foregroundColor: themeColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.history),
              label: const Text(
                'Abonelik Süresi Yenile / Yükleme Yap',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(AbonelikModel abonelik, Color themeColor) {
    if (!abonelik.isSubscribed) return const SizedBox.shrink();

    final hasDebt = abonelik.debt > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fatura Bilgisi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDebt ? 'Ödenmemiş Toplam Borç' : 'Borç Bulunmamaktadır',
                    style: TextStyle(
                      fontSize: 14,
                      color: hasDebt ? Colors.red.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasDebt
                        ? '${abonelik.debt.toStringAsFixed(2)} TL'
                        : '0.00 TL',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: hasDebt ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              if (hasDebt)
                ElevatedButton.icon(
                  onPressed: () {
                    // Bulunan ilk ödenmemiş faturayı seçip ödeme formunu aç
                    final unpaid = abonelik.invoiceHistory
                        .firstWhere((inv) => inv.status == 'odenmemis');
                    _showPaymentBottomSheet(unpaid.amount, themeColor, invoiceId: unpaid.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.payment),
                  label: const Text('Fatura Öde'),
                )
              else
                Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryList(AbonelikModel abonelik) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: abonelik.invoiceHistory.length,
      itemBuilder: (context, index) {
        final invoice = abonelik.invoiceHistory[index];
        final isPaid = invoice.status == 'odenmis';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: ListTile(
            leading: Icon(
              isPaid ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isPaid ? Colors.green.shade600 : Colors.orange.shade800,
            ),
            title: Text(
              invoice.id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${invoice.date.day.toString().padLeft(2, '0')}.${invoice.date.month.toString().padLeft(2, '0')}.${invoice.date.year}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${invoice.amount.toStringAsFixed(2)} TL',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  isPaid ? 'Ödendi' : 'Ödenmedi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFaultReportCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem, color: themeColor),
              const SizedBox(width: 8),
              Text(
                'Arıza Bildirimi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hizmet bölgesinde bir kesinti, sızıntı veya arıza mı fark ettiniz? Fotoğraflı arıza kaydı oluşturarak belediyeye iletebilirsiniz.',
            style: TextStyle(fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.arizaBildir);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Hemen Arıza Bildir',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Paket satın alma/yenileme diyaloğu
  void _showSubscribeDialog(Color themeColor, {bool isRenewal = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isRenewal ? 'Abonelik Süresini Yenile' : 'Yeni Abonelik Başlat',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isRenewal
                        ? 'Süre uzatımı veya ek kota paketi seçin.'
                        : 'Kullanım alışkanlığınıza uygun bir abonelik paketi seçin.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _buildPackageOption(
                    title: '1 Aylık Standart Paket',
                    description: '30 Gün Abonelik & 30 Kredi Kota',
                    price: 75.00,
                    months: 1,
                    planName: 'Standart Paket',
                    themeColor: themeColor,
                    isRenewal: isRenewal,
                  ),
                  const SizedBox(height: 12),
                  _buildPackageOption(
                    title: '6 Aylık Standart Paket',
                    description: '180 Gün Abonelik & 180 Kredi Kota',
                    price: 390.00,
                    months: 6,
                    planName: 'Standart Paket',
                    themeColor: themeColor,
                    isRenewal: isRenewal,
                  ),
                  const SizedBox(height: 12),
                  _buildPackageOption(
                    title: '12 Aylık Standart Paket (%20 İndirimli)',
                    description: '360 Gün Abonelik & 360 Kredi Kota',
                    price: 720.00,
                    months: 12,
                    planName: 'Yıllık Paket',
                    themeColor: themeColor,
                    isRenewal: isRenewal,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPackageOption({
    required String title,
    required String description,
    required double price,
    required int months,
    required String planName,
    required Color themeColor,
    required bool isRenewal,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Diyaloğu kapat
        _showPaymentBottomSheet(
          price,
          themeColor,
          months: months,
          planName: planName,
          isRenewal: isRenewal,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '${price.toStringAsFixed(2)} TL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: themeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ödeme ve Kredi Kartı Görsel Formu Bottom Sheet
  void _showPaymentBottomSheet(
    double price,
    Color themeColor, {
    int? months,
    String? planName,
    bool isRenewal = false,
    String? invoiceId,
  }) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final cardNoController = TextEditingController();
    final holderController = TextEditingController();
    final dateController = TextEditingController();
    final cvvController = TextEditingController();

    // Kart görselinin durumlarını güncellemek için StateSetter
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BlocBuilder<AbonelikCubit, AbonelikState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20,
                    right: 20,
                    top: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Güvenli Ödeme',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toplam Ödenecek Tutar: ${price.toStringAsFixed(2)} TL',
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Kart Görseli (Glassmorphism & Harika Gradient Tasarım)
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [themeColor, themeColor.withRed(100)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Vatandaş Kart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    Icon(
                                      Icons.nfc,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ],
                                ),
                                Text(
                                  cardNoController.text.isEmpty
                                      ? '•••• •••• •••• ••••'
                                      : cardNoController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'KART SAHİBİ',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.6),
                                              fontSize: 9,
                                            ),
                                          ),
                                          Text(
                                            holderController.text.isEmpty
                                                ? 'AD SOYAD'
                                                : holderController.text.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'SKT',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 9,
                                          ),
                                        ),
                                        Text(
                                          dateController.text.isEmpty
                                              ? 'AA/YY'
                                              : dateController.text,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Kart Numarası Alanı
                          TextFormField(
                            controller: cardNoController,
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            decoration: const InputDecoration(
                              labelText: 'Kart Numarası',
                              prefixIcon: Icon(Icons.credit_card),
                              counterText: '',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _CardNumberInputFormatter(),
                            ],
                            validator: (val) {
                              if (val == null || val.replaceAll(' ', '').length < 16) {
                                return 'Geçersiz kart numarası';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 12),

                          // Kart Sahibi
                          TextFormField(
                            controller: holderController,
                            keyboardType: TextInputType.name,
                            decoration: const InputDecoration(
                              labelText: 'Kart Sahibi Adı Soyadı',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Kart sahibi adı gereklidir';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setModalState(() {});
                            },
                          ),
                          const SizedBox(height: 12),

                          // SKT ve CVV Satırı
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: dateController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Son Kul. Tarihi (AA/YY)',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    counterText: '',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    _CardExpiryInputFormatter(),
                                  ],
                                  validator: (val) {
                                    if (val == null || val.length < 5) {
                                      return 'AA/YY şeklinde olmalıdır';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    setModalState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: cvvController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    prefixIcon: Icon(Icons.lock_outline),
                                    counterText: '',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.length < 3) {
                                      return '3 haneli olmalıdır';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Ödeme Butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isProcessing
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        bool success = false;
                                        if (invoiceId != null) {
                                          // Borç Ödeme
                                          success = await context
                                              .read<AbonelikCubit>()
                                              .payInvoice(
                                                type: widget.type,
                                                invoiceId: invoiceId,
                                              );
                                        } else if (isRenewal) {
                                          // Abonelik Yenileme
                                          success = await context
                                              .read<AbonelikCubit>()
                                              .renew(
                                                type: widget.type,
                                                months: months ?? 1,
                                                price: price,
                                              );
                                        } else {
                                          // Yeni Abonelik Başlatma
                                          success = await context
                                              .read<AbonelikCubit>()
                                              .subscribe(
                                                type: widget.type,
                                                planName: planName ?? 'Standart',
                                                months: months ?? 1,
                                                price: price,
                                              );
                                        }

                                        if (success && context.mounted) {
                                          Navigator.pop(context); // Bottom sheet kapat
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      '${price.toStringAsFixed(2)} TL Öde',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Kart numarası formatter'ı (Aralara boşluk ekler)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Her 4 hanede bir boşluk koy
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Kart SKT formatter'ı (Araya / koyar)
class _CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && newText.length > 2) {
        buffer.write('/'); // İkinci haneden sonra eğik çizgi koy
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
