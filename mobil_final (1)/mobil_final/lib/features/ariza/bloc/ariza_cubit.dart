import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/ariza_model.dart';
import '../../../shared/repositories/ariza_repository.dart';

class ArizaState {
  const ArizaState({
    this.arizalar = const [],
    this.selectedAriza,
    this.trackedAriza,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  final List<ArizaModel> arizalar;
  final ArizaModel? selectedAriza;
  final ArizaModel? trackedAriza;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  ArizaState copyWith({
    List<ArizaModel>? arizalar,
    ArizaModel? selectedAriza,
    ArizaModel? trackedAriza,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return ArizaState(
      arizalar: arizalar ?? this.arizalar,
      selectedAriza: selectedAriza ?? this.selectedAriza,
      trackedAriza: trackedAriza ?? this.trackedAriza,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class ArizaCubit extends Cubit<ArizaState> {
  ArizaCubit(this._arizaRepository) : super(const ArizaState());

  final ArizaRepository _arizaRepository;

  Future<void> loadArizalar() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final arizalar = await _arizaRepository.getArizalar();
      emit(state.copyWith(arizalar: arizalar, isLoading: false, error: null));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> loadArizaDetail(String id) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final ariza = await _arizaRepository.getArizaById(id);
      emit(state.copyWith(selectedAriza: ariza, isLoading: false, error: null));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  Future<ArizaModel> submitAriza(Map<String, dynamic> payload) async {
    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      final created = await _arizaRepository.submitAriza(payload);
      final updatedList = [created, ...state.arizalar];

      emit(
        state.copyWith(
          arizalar: updatedList,
          selectedAriza: created,
          isSubmitting: false,
          error: null,
        ),
      );

      return created;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> trackAriza(String id) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final ariza = await _arizaRepository.trackAriza(id);
      emit(state.copyWith(trackedAriza: ariza, isLoading: false, error: null));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> updateArizaStatus({
    required String id,
    required String durum,
    required String? aciklama,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final updated = await _arizaRepository.updateArizaStatus(id, durum, aciklama);
      final updatedList = state.arizalar.map((ariza) {
        return ariza.id == updated.id ? updated : ariza;
      }).toList();

      emit(
        state.copyWith(
          arizalar: updatedList,
          selectedAriza: updated,
          isLoading: false,
          error: null,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
