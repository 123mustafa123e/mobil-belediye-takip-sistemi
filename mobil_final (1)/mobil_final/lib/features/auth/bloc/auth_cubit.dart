import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/auth_repository.dart';

class AuthState {
  const AuthState({this.user, this.role, this.isLoading = false, this.error});

  final UserModel? user;
  final String? role;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    String? role,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<void> loadSession() async {
    emit(state.copyWith(isLoading: true, error: null));

    final user = await _authRepository.loadSession();
    final role = await _authRepository.loadRole();

    emit(state.copyWith(user: user, role: role, isLoading: false, error: null));
  }

  Future<void> login({
    required String email,
    required String password,
    required String role,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final (user, _) = await _authRepository.login(
        email: email,
        password: password,
        role: role,
      );

      emit(
        state.copyWith(user: user, role: role, isLoading: false, error: null),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> register({
    required String ad,
    required String soyad,
    required String tcKimlik,
    required String email,
    required String telefon,
    required String adres,
    required String password,
    required String role,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final user = await _authRepository.register(
        ad: ad,
        soyad: soyad,
        tcKimlik: tcKimlik,
        email: email,
        telefon: telefon,
        adres: adres,
        password: password,
        role: role,
      );

      emit(
        state.copyWith(user: user, role: role, isLoading: false, error: null),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState());
  }
}
