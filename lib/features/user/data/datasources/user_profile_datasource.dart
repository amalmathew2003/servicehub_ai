import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserProfileDatasource {
  final FirebaseFirestore firestore;

  UserProfileDatasource({
    required this.firestore,
  });

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<UserProfileModel?> getUserProfile({
    required String userUid,
  }) async {
    final doc = await firestore
        .collection('users')
        .doc(userUid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserProfileModel.fromMap(
      doc.data()!,
    );
  }

  // ============================================================
  // UPDATE USER PROFILE
  // ============================================================

  Future<void> updateUserProfile({
    required String userUid,
    required UserProfileModel profile,
  }) async {
    await firestore
        .collection('users')
        .doc(userUid)
        .update(
          profile.toMap(),
        );
  }
}