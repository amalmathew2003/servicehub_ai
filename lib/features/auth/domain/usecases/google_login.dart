import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GoogleLogin {
  final AuthRepository repository;

  GoogleLogin(this.repository);

  Future<AppUser> call({
    required String role,
  }) {
    return repository.googleLogin(
      role: role,
    );
  }
}