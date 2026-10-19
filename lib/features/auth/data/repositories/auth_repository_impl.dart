import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({
    required this.datasource,
  });

  // ==========================================
  // REGISTER WITH EMAIL
  // ==========================================

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final UserCredential credential =
        await datasource.registerWithEmail(
      email: email,
      password: password,
    );

    final User user = credential.user!;

    await datasource.createUserDocument(
      user: user,
      name: name,
      role: role,
    );

    return AppUserModel(
      uid: user.uid,
      name: name,
      email: user.email ?? email,
      phone: user.phoneNumber,
      role: role,
      profileImage: user.photoURL,
    );
  }

  // ==========================================
  // LOGIN WITH EMAIL
  // ==========================================

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await datasource.loginWithEmail(
      email: email,
      password: password,
    );

    final User user = credential.user!;

    final document =
        await datasource.getUserDocument(user.uid);

    // If Firestore doc exists, use it
    if (document.exists && document.data() != null) {
      return AppUserModel.fromMap(document.data()!);
    }

    // Fallback: Firestore doc missing (e.g. rules blocked write during registration).
    // Try to re-create the document using data from Firebase Auth.
    // Default role to 'user' since we can't recover it.
    const fallbackRole = 'user';
    try {
      await datasource.createUserDocument(
        user: user,
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
        role: fallbackRole,
      );
    } catch (_) {
      // Still blocked by rules — return minimal user so app doesn't crash.
    }

    return AppUserModel(
      uid: user.uid,
      name: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? email,
      phone: user.phoneNumber,
      role: fallbackRole,
      profileImage: user.photoURL,
    );
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  @override
  Future<AppUser> googleLogin({
    required String role,
  }) async {
    final UserCredential credential =
        await datasource.signInWithGoogle();

    final User user = credential.user!;

    final document =
        await datasource.getUserDocument(user.uid);

    // First Google login
    if (!document.exists) {
      final name = user.displayName ?? 'User';

      await datasource.createUserDocument(
        user: user,
        name: name,
        role: role,
      );

      return AppUserModel(
        uid: user.uid,
        name: name,
        email: user.email ?? '',
        phone: user.phoneNumber,
        role: role,
        profileImage: user.photoURL,
      );
    }

    // Existing Google user
    return AppUserModel.fromMap(
      document.data()!,
    );
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  @override
  Future<void> logout() async {
    await datasource.logout();
  }

  // ==========================================
  // CURRENT USER
  // ==========================================

  @override
  Future<AppUser?> getCurrentUser() async {
    final User? user =
        datasource.auth.currentUser;

    if (user == null) {
      return null;
    }

    final document =
        await datasource.getUserDocument(user.uid);

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return AppUserModel.fromMap(
      document.data()!,
    );
  }
}