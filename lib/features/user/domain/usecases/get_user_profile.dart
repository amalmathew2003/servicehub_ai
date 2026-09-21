import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfile {
  final UserProfileRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile?> call({
    required String userUid,
  }) {
    return repository.getUserProfile(
      userUid: userUid,
    );
  }
}