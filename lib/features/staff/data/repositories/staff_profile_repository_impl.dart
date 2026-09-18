import '../../domain/entities/staff_profile.dart';
import '../../domain/repositories/staff_profile_repository.dart';
import '../datasources/staff_profile_datasource.dart';
import '../models/staff_profile_model.dart';

class StaffProfileRepositoryImpl implements StaffProfileRepository {
  final StaffProfileDatasource datasource;

  StaffProfileRepositoryImpl({required this.datasource});

  @override
  Future<StaffProfile?> getStaffProfile({required String staffUid}) async {
    return await datasource.getStaffProfile(staffUid: staffUid);
  }

  @override
  Future<void> updateStaffProfile({
    required String staffUid,
    required StaffProfile profile,
  }) async {
    final model = StaffProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      profileImage: profile.profileImage,
      latitude: profile.latitude,
      longitude: profile.longitude,
      isOnline: profile.isOnline,
    );

    await datasource.updateStaffProfile(staffUid: staffUid, profile: model);
  }
}
