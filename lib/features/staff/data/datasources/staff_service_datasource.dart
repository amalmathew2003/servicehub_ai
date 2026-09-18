import 'package:cloud_firestore/cloud_firestore.dart';

class StaffServiceDatasource {
  final FirebaseFirestore firestore;

  StaffServiceDatasource({
    required this.firestore,
  });

  Future<void> addService({
    required String staffUid,
    required String serviceId,
    required String name,
    required String description,
  }) async {
    await firestore
        .collection('users')
        .doc(staffUid)
        .collection('services')
        .doc(serviceId)
        .set({
      'id': serviceId,
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getServices({
    required String staffUid,
  }) async {
    final snapshot = await firestore
        .collection('users')
        .doc(staffUid)
        .collection('services')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}