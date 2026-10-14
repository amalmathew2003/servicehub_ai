import 'package:service_hub_ai/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:service_hub_ai/features/ai/domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDatasource remoteDatasource;

  AiRepositoryImpl(this.remoteDatasource);

  @override
  Future<Map<String, dynamic>> identifyService(String message) async {
    return await remoteDatasource.identifyService(message);
  }

  @override
  Future<Map<String, dynamic>> searchNearbyStaff({
    required double latitude,
    required double longitude,
    required String serviceName,
    double radiusKm = 10,
  }) async {
    return await remoteDatasource.searchNearbyStaff(
      latitude: latitude,
      longitude: longitude,
      serviceName: serviceName,
      radiusKm: radiusKm,
    );
  }
}
