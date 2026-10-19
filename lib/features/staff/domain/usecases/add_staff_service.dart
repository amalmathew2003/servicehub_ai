import '../entities/staff_service.dart';
import '../repositories/staff_service_repository.dart';

class AddStaffService {
  final StaffServiceRepository repository;

  AddStaffService(this.repository);

  Future<void> call({
    required String staffUid,
    required StaffService service,
  }) async {
    return await repository.addService(
      staffUid: staffUid,
      service: service,
    );
  }
}