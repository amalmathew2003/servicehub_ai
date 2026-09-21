import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfile {
  final UserProfileRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call({
    required String userUid,
    required UserProfile profile,
  }) {
    return repository.updateUserProfile(
      userUid: userUid,
      profile: profile,
    );
  }
}