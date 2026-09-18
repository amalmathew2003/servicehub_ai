import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';
import 'package:service_hub_ai/features/staff/domain/repositories/staff_profile_repository.dart';

class UpdateStaffProfile {
  final StaffProfileRepository repository;
  UpdateStaffProfile(this.repository);
  Future<void> call({required String staffUid, required StaffProfile profile}) {
    return repository.updateStaffProfile(staffUid: staffUid, profile: profile);
  }
}
