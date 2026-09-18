import '../entities/staff_service.dart';
import '../repositories/staff_service_repository.dart';

class GetStaffServices {
  final StaffServiceRepository repository;

  GetStaffServices(this.repository);

  Future<List<StaffService>> call({required String staffUid}) {
    return repository.getServices(staffUid: staffUid);
  }
}
