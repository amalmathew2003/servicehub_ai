import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.customerId,
    required super.staffId,
    required super.serviceId,
    required super.serviceName,
    required super.customerName,
    required super.staffName,
    required super.status,
    super.scheduledDate,
    super.customerLatitude,
    super.customerLongitude,
    super.staffLatitude,
    super.staffLongitude,
    super.createdAt,
    super.updatedAt,
  });

  factory BookingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return BookingModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      staffId: map['staffId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      customerName: map['customerName'] ?? '',
      staffName: map['staffName'] ?? '',
      status: map['status'] ?? 'pending',

      scheduledDate:
          (map['scheduledDate'] as Timestamp?)?.toDate(),

      customerLatitude:
          (map['customerLatitude'] as num?)?.toDouble(),

      customerLongitude:
          (map['customerLongitude'] as num?)?.toDouble(),

      staffLatitude:
          (map['staffLatitude'] as num?)?.toDouble(),

      staffLongitude:
          (map['staffLongitude'] as num?)?.toDouble(),

      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate(),

      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'staffId': staffId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'customerName': customerName,
      'staffName': staffName,
      'status': status,

      'scheduledDate': scheduledDate != null
          ? Timestamp.fromDate(scheduledDate!)
          : null,

      'customerLatitude': customerLatitude,
      'customerLongitude': customerLongitude,

      'staffLatitude': staffLatitude,
      'staffLongitude': staffLongitude,

      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}