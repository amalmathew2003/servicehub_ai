import 'package:dio/dio.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.220.39:8000',
  );

  static final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
      receiveDataWhenStatusError: true,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  );
}
