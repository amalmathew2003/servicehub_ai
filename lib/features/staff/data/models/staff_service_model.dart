import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/staff_service.dart';

class StaffServiceModel extends StaffService {
  const StaffServiceModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory StaffServiceModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return StaffServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}