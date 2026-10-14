
import 'package:service_hub_ai/features/ai/data/datasources/ai_remote_datasource.dart';

class SubmitServiceRequest {
  final AiRemoteDatasource remoteDatasource;

  SubmitServiceRequest(this.remoteDatasource);

  Future<Map<String, dynamic>> call({
    required String requestedService,
    String description = '',
  }) {
    return remoteDatasource.submitServiceRequest(
      requestedService: requestedService,
      description: description,
    );
  }
}
