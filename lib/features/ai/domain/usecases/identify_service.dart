import 'package:service_hub_ai/features/ai/domain/repositories/ai_repository.dart';

class IdentifyService {
  final AiRepository repository;
  IdentifyService(this.repository);
  Future<Map<String, dynamic>> call(String message) async {
    return await repository.identifyService(message);
  }
}
