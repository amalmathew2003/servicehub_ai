import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<AppUser> googleLogin({
    required String role,
  });

  Future<void> logout();

  Future<AppUser?> getCurrentUser();
}