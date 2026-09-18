import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_hub_ai/features/staff/data/models/staff_profile_model.dart';

class StaffProfileDatasource {
  final FirebaseFirestore firestore;
  StaffProfileDatasource({required this.firestore});

  Future<StaffProfileModel?> getStaffProfile({required String staffUid}) async {
    final doc = await firestore.collection("users").doc(staffUid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return StaffProfileModel.fromMap(doc.data()!);
  }

  Future<void> updateStaffProfile({
    required String staffUid,
    required StaffProfileModel profile,
  }) async {
    await firestore.collection("users").doc(staffUid).update(profile.toMap());
  }
}
