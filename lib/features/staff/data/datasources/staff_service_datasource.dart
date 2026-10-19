
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
    final cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      throw ArgumentError('Service name cannot be empty.');
    }

    // Prevent duplicate service names for this staff member.
    final existingServices = await firestore
        .collection('users')
        .doc(staffUid)
        .collection('services')
        .get();

    final duplicateExists = existingServices.docs.any((doc) {
      final existingName = doc.data()['name'];

      return existingName is String &&
          existingName.trim().toLowerCase() ==
              cleanedName.toLowerCase();
    });

    if (duplicateExists) {
      throw Exception('You have already added this service.');
    }

    await firestore
        .collection('users')
        .doc(staffUid)
        .collection('services')
        .doc(serviceId)
        .set({
      'id': serviceId,
      'name': cleanedName,
      'description': description.trim(),
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
