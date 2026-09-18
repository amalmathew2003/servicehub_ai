import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';
import 'package:service_hub_ai/features/staff/domain/repositories/staff_profile_repository.dart';

class GetStaffProfile {
  final StaffProfileRepository repository;
  GetStaffProfile(this.repository);

  Future<StaffProfile?> call({required String staffUid}) {
    return repository.getStaffProfile(staffUid: staffUid);
  }
}
