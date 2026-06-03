import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/network/app_api_client.dart';
import '../models/user_model.dart';
import '../services/session_service.dart';

class AuthRepository {
  AuthRepository({required this.apiClient, required this.sessionService});

  final AppApiClient apiClient;
  final SessionService sessionService;

  Future<(UserModel user, String token)> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final supabaseUser = response.user;
    if (supabaseUser == null) {
      throw Exception('Supabase kullanıcı girişi yapılamadı.');
    }

    final token = response.session?.accessToken ?? '';
    final user = UserModel(
      id: supabaseUser.id,
      ad: '',
      soyad: '',
      tcKimlik: '',
      email: supabaseUser.email ?? email,
      telefon: '',
      adres: '',
      tip: role,
      bildirimAktif: true,
    );

    await sessionService.saveSession(user: user, token: token, role: role);

    return (user, token);
  }

  Future<UserModel> register({
    required String ad,
    required String soyad,
    required String tcKimlik,
    required String email,
    required String telefon,
    required String adres,
    required String password,
    required String role,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': ad,
        'last_name': soyad,
        'role': role,
        'tcKimlik': tcKimlik,
        'telefon': telefon,
        'adres': adres,
      },
    );

    final supabaseUser = response.user;
    if (supabaseUser == null) {
      throw Exception('Supabase kullanıcı oluşturulamadı.');
    }

    final token = response.session?.accessToken ?? '';

    final user = UserModel(
      id: supabaseUser.id,
      ad: ad,
      soyad: soyad,
      tcKimlik: tcKimlik,
      email: email,
      telefon: telefon,
      adres: adres,
      tip: role,
      bildirimAktif: true,
    );

    await sessionService.saveSession(user: user, token: token, role: role);

    return user;
  }

  Future<UserModel?> loadSession() async {
    return sessionService.user;
  }

  Future<String?> loadRole() async {
    return sessionService.role;
  }

  Future<void> logout() async {
    await sessionService.clearSession();
  }
}
