import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/abonelik_model.dart';

class AbonelikService {
  final SharedPreferences _prefs;
  static const String _abonelikPrefix = 'abonelik_';

  AbonelikService(this._prefs);

  AbonelikModel getAbonelik(String type) {
    final raw = _prefs.getString('$_abonelikPrefix$type');
    if (raw == null) {
      // Varsayılan zengin demo durumlarını oluşturuyoruz
      return _generateDefaultAbonelik(type);
    }
    return AbonelikModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveAbonelik(AbonelikModel abonelik) async {
    await _prefs.setString(
      '$_abonelikPrefix${abonelik.type}',
      jsonEncode(abonelik.toJson()),
    );
  }

  AbonelikModel _generateDefaultAbonelik(String type) {
    switch (type) {
      case 'su':
        return AbonelikModel(
          type: 'su',
          isSubscribed: false,
          subscriptionNo: '',
          daysRemaining: 0,
          usageRemaining: 0.0,
          planName: '',
          debt: 0.0,
          invoiceHistory: [],
        );
      case 'elektrik':
        return AbonelikModel(
          type: 'elektrik',
          isSubscribed: true,
          subscriptionNo: 'ELK-982741',
          daysRemaining: 12,
          usageRemaining: 84.5,
          planName: 'Standart Ev',
          debt: 185.75,
          invoiceHistory: [
            InvoiceModel(
              id: 'FAT-ELK-001',
              amount: 185.75,
              date: DateTime.now().subtract(const Duration(days: 5)),
              status: 'odenmemis',
            ),
            InvoiceModel(
              id: 'FAT-ELK-002',
              amount: 142.30,
              date: DateTime.now().subtract(const Duration(days: 35)),
              status: 'odenmis',
            ),
          ],
        );
      case 'dogalgaz':
        return AbonelikModel(
          type: 'dogalgaz',
          isSubscribed: true,
          subscriptionNo: 'GAZ-403912',
          daysRemaining: 45,
          usageRemaining: 120.0,
          planName: 'Isınma & Mutfak',
          debt: 0.0,
          invoiceHistory: [
            InvoiceModel(
              id: 'FAT-GAZ-001',
              amount: 320.00,
              date: DateTime.now().subtract(const Duration(days: 10)),
              status: 'odenmis',
            ),
          ],
        );
      default:
        return AbonelikModel(
          type: type,
          isSubscribed: false,
          subscriptionNo: '',
          daysRemaining: 0,
          usageRemaining: 0.0,
          planName: '',
          debt: 0.0,
          invoiceHistory: [],
        );
    }
  }
}
