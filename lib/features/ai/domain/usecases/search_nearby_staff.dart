import 'package:service_hub_ai/features/ai/domain/repositories/ai_repository.dart';

class SearchNearbyStaff {
  final AiRepository repository;
  SearchNearbyStaff(this.repository);
  Future<Map<String, dynamic>> call({
    required double latitude,
    required double longitude,
    required String serviceName,
    double radiusKm = 10,
  }) async {
    return await repository.searchNearbyStaff(
      latitude: latitude,
      longitude: longitude,
      serviceName: serviceName,
      radiusKm: radiusKm,
    );
  }
}
