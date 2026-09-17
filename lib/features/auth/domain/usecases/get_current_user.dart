import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<AppUser?> call() {
    return repository.getCurrentUser();
  }
}