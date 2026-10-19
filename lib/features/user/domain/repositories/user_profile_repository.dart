import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile({
    required String userUid,
  });

  Future<void> updateUserProfile({
    required String userUid,
    required UserProfile profile,
  });
}