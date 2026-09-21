import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl
    implements UserProfileRepository {
  final UserProfileDatasource datasource;

  UserProfileRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<UserProfile?> getUserProfile({
    required String userUid,
  }) async {
    return datasource.getUserProfile(
      userUid: userUid,
    );
  }

  @override
  Future<void> updateUserProfile({
    required String userUid,
    required UserProfile profile,
  }) async {
    final model = UserProfileModel(
      uid: profile.uid,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
      profileImage: profile.profileImage,
      latitude: profile.latitude,
      longitude: profile.longitude,
      locationName: profile.locationName,
    );

    await datasource.updateUserProfile(
      userUid: userUid,
      profile: model,
    );
  }
}