import 'package:service_hub_ai/features/staff/domain/entities/staff_profile.dart';

abstract class StaffProfileRepository {
  Future<StaffProfile?> getStaffProfile({required String staffUid});

  Future<void> updateStaffProfile({
    required String staffUid,
    required StaffProfile profile,
  });
}
