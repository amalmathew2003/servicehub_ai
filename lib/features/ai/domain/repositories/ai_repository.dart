abstract class AiRepository {
  Future<Map<String, dynamic>> identifyService(
    String message,
  );

  Future<Map<String, dynamic>> searchNearbyStaff({
    required double latitude,
    required double longitude,
    required String serviceName,
    double radiusKm = 10,
  });
}