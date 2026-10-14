
import 'package:dio/dio.dart';
import 'package:service_hub_ai/core/config/api_config.dart';

class AiRemoteDatasource {
  final Dio dio = ApiConfig.dio;

  // Identify the requested service.
  Future<Map<String, dynamic>> identifyService(
    String message,
  ) async {
    final response = await dio.post(
      '/identify-service',
      data: {
        'message': message,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // Submit a request for an unregistered service.
  Future<Map<String, dynamic>> submitServiceRequest({
    required String requestedService,
    String description = '',
  }) async {
    final response = await dio.post(
      '/service-requests',
      data: {
        'requested_service': requestedService,
        'description': description,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // Search for nearby online staff.
  Future<Map<String, dynamic>> searchNearbyStaff({
    required double latitude,
    required double longitude,
    required String serviceName,
    double radiusKm = 10,
  }) async {
    final response = await dio.get(
      '/staff/search',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'service_name': serviceName,
        'radius_km': radiusKm,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  // Fetch AI service suggestions from FastAPI.
  Future<List<String>> getServiceSuggestions({
    required String serviceText,
  }) async {
    final response = await dio.post(
      '/staff/service-suggestions',
      data: {
        'service_text': serviceText,
      },
    );

    final data = Map<String, dynamic>.from(response.data);
    final suggestions = data['suggestions'];

    if (suggestions is! List) {
      return [];
    }

    final uniqueNames = <String>{};

    for (final item in suggestions) {
      if (item is String && item.trim().isNotEmpty) {
        uniqueNames.add(item.trim());
      }
    }

    return uniqueNames.toList();
  }
}
