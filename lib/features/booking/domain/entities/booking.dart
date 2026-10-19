import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;

  final String customerId;
  final String staffId;

  final String serviceId;
  final String serviceName;

  final String customerName;
  final String staffName;

  final String status;

  final DateTime? scheduledDate;

  final double? customerLatitude;
  final double? customerLongitude;

  final double? staffLatitude;
  final double? staffLongitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.staffId,
    required this.serviceId,
    required this.serviceName,
    required this.customerName,
    required this.staffName,
    required this.status,
    this.scheduledDate,
    this.customerLatitude,
    this.customerLongitude,
    this.staffLatitude,
    this.staffLongitude,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        staffId,
        serviceId,
        serviceName,
        customerName,
        staffName,
        status,
        scheduledDate,
        customerLatitude,
        customerLongitude,
        staffLatitude,
        staffLongitude,
        createdAt,
        updatedAt,
      ];
}