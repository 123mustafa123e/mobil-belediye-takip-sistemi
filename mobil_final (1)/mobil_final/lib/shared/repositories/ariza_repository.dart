import '../../core/network/app_api_client.dart';
import '../models/ariza_model.dart';
import '../services/session_service.dart';

class ArizaRepository {
  ArizaRepository({required this.apiClient, required this.sessionService});

  final AppApiClient apiClient;
  final SessionService sessionService;

  Future<List<ArizaModel>> getArizalar() async {
    try {
      final data = await apiClient.readJson<List<dynamic>>(
        '/ariza',
        token: sessionService.token,
      );

      final arizalar = data
          .map((item) => ArizaModel.fromJson(item as Map<String, dynamic>))
          .toList();

      await sessionService.cacheArizalar(arizalar);
      return arizalar;
    } catch (_) {
      return sessionService.getCachedArizalar();
    }
  }

  Future<ArizaModel> getArizaById(String id) async {
    try {
      final data = await apiClient.readJson<Map<String, dynamic>>(
        '/ariza/$id',
        token: sessionService.token,
      );

      final ariza = ArizaModel.fromJson(data);
      return ariza;
    } catch (_) {
      final cached = sessionService
          .getCachedArizalar()
          .where((ariza) => ariza.id == id)
          .toList();

      if (cached.isNotEmpty) {
        return cached.first;
      }

      rethrow;
    }
  }

  Future<ArizaModel> submitAriza(Map<String, dynamic> payload) async {
    final response = await apiClient.postJson(
      '/ariza',
      body: payload,
      token: sessionService.token,
    );

    final created = ArizaModel.fromJson(response);

    final updatedCache = [created, ...sessionService.getCachedArizalar()]
      ..removeWhere((ariza) => ariza.id == created.id);

    await sessionService.cacheArizalar(updatedCache);

    return created;
  }

  Future<ArizaModel> trackAriza(String id) async {
    final data = await apiClient.readJson<Map<String, dynamic>>(
      '/takip/$id',
      token: sessionService.token,
    );

    final ariza = ArizaModel.fromJson(data);
    return ariza;
  }

  Future<ArizaModel> updateArizaStatus(
    String id,
    String durum,
    String? aciklama,
  ) async {
    final response = await apiClient.putJson(
      '/ariza/$id',
      body: {
        'durum': durum,
        'aciklama': aciklama,
      },
      token: sessionService.token,
    );

    final updated = ArizaModel.fromJson(response);

    final cached = sessionService.getCachedArizalar();
    final updatedCache = cached.map((ariza) {
      return ariza.id == updated.id ? updated : ariza;
    }).toList();

    await sessionService.cacheArizalar(updatedCache);

    return updated;
  }
}
