import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/models/abonelik_model.dart';
import '../../../shared/services/abonelik_service.dart';

class AbonelikState {
  final Map<String, AbonelikModel> abonelikler;
  final bool isLoading;
  final String? error;
  final bool isProcessing;
  final bool paymentSuccess;

  const AbonelikState({
    this.abonelikler = const {},
    this.isLoading = false,
    this.error,
    this.isProcessing = false,
    this.paymentSuccess = false,
  });

  AbonelikState copyWith({
    Map<String, AbonelikModel>? abonelikler,
    bool? isLoading,
    String? error,
    bool? isProcessing,
    bool? paymentSuccess,
  }) {
    return AbonelikState(
      abonelikler: abonelikler ?? this.abonelikler,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isProcessing: isProcessing ?? this.isProcessing,
      paymentSuccess: paymentSuccess ?? this.paymentSuccess,
    );
  }
}

class AbonelikCubit extends Cubit<AbonelikState> {
  final AbonelikService _abonelikService;

  AbonelikCubit(this._abonelikService) : super(const AbonelikState());

  void loadAbonelikler() {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final su = _abonelikService.getAbonelik('su');
      final elektrik = _abonelikService.getAbonelik('elektrik');
      final dogalgaz = _abonelikService.getAbonelik('dogalgaz');

      emit(state.copyWith(
        abonelikler: {
          'su': su,
          'elektrik': elektrik,
          'dogalgaz': dogalgaz,
        },
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> subscribe({
    required String type,
    required String planName,
    required int months,
    required double price,
  }) async {
    emit(state.copyWith(isProcessing: true, error: null));
    await Future.delayed(const Duration(seconds: 2)); // Ödeme simülasyonu gecikmesi

    try {
      final randomNo = (100000 + Random().nextInt(900000)).toString();
      final prefix = type == 'su' ? 'SU' : (type == 'elektrik' ? 'ELK' : 'GAZ');
      final subscriptionNo = '$prefix-$randomNo';
      final invoiceId = 'FAT-$prefix-${100 + Random().nextInt(900)}';

      final newAbonelik = AbonelikModel(
        type: type,
        isSubscribed: true,
        subscriptionNo: subscriptionNo,
        daysRemaining: months * 30,
        usageRemaining: months * 30.0,
        planName: planName,
        debt: 0.0,
        invoiceHistory: [
          InvoiceModel(
            id: invoiceId,
            amount: price,
            date: DateTime.now(),
            status: 'odenmis',
          ),
        ],
      );

      await _abonelikService.saveAbonelik(newAbonelik);
      
      final updatedMap = Map<String, AbonelikModel>.from(state.abonelikler);
      updatedMap[type] = newAbonelik;

      emit(state.copyWith(
        abonelikler: updatedMap,
        isProcessing: false,
        paymentSuccess: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> renew({
    required String type,
    required int months,
    required double price,
  }) async {
    emit(state.copyWith(isProcessing: true, error: null));
    await Future.delayed(const Duration(seconds: 2)); // Ödeme simülasyonu gecikmesi

    try {
      final current = state.abonelikler[type];
      if (current == null || !current.isSubscribed) {
        throw Exception('Aktif abonelik bulunamadı.');
      }

      final prefix = type == 'su' ? 'SU' : (type == 'elektrik' ? 'ELK' : 'GAZ');
      final invoiceId = 'FAT-$prefix-${100 + Random().nextInt(900)}';

      final updatedHistory = List<InvoiceModel>.from(current.invoiceHistory);
      updatedHistory.insert(
        0,
        InvoiceModel(
          id: invoiceId,
          amount: price,
          date: DateTime.now(),
          status: 'odenmis',
        ),
      );

      final updatedAbonelik = current.copyWith(
        daysRemaining: current.daysRemaining + (months * 30),
        usageRemaining: current.usageRemaining + (months * 30.0),
        invoiceHistory: updatedHistory,
      );

      await _abonelikService.saveAbonelik(updatedAbonelik);

      final updatedMap = Map<String, AbonelikModel>.from(state.abonelikler);
      updatedMap[type] = updatedAbonelik;

      emit(state.copyWith(
        abonelikler: updatedMap,
        isProcessing: false,
        paymentSuccess: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> payInvoice({
    required String type,
    required String invoiceId,
  }) async {
    emit(state.copyWith(isProcessing: true, error: null));
    await Future.delayed(const Duration(seconds: 1500)); // Hızlı ödeme simülasyonu

    try {
      final current = state.abonelikler[type];
      if (current == null) {
        throw Exception('Abonelik bulunamadı.');
      }

      final updatedHistory = current.invoiceHistory.map((invoice) {
        if (invoice.id == invoiceId) {
          return InvoiceModel(
            id: invoice.id,
            amount: invoice.amount,
            date: invoice.date,
            status: 'odenmis',
          );
        }
        return invoice;
      }).toList();

      final paidAmount = current.invoiceHistory
          .firstWhere((inv) => inv.id == invoiceId)
          .amount;

      final updatedAbonelik = current.copyWith(
        debt: max(0.0, current.debt - paidAmount),
        invoiceHistory: updatedHistory,
      );

      await _abonelikService.saveAbonelik(updatedAbonelik);

      final updatedMap = Map<String, AbonelikModel>.from(state.abonelikler);
      updatedMap[type] = updatedAbonelik;

      emit(state.copyWith(
        abonelikler: updatedMap,
        isProcessing: false,
        paymentSuccess: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isProcessing: false, error: e.toString()));
      return false;
    }
  }

  void clearPaymentSuccess() {
    emit(state.copyWith(paymentSuccess: false));
  }
}
