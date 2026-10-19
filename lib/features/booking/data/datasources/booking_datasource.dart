
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../models/booking_model.dart';

class BookingDatasource {
  final FirebaseFirestore firestore;
  final Dio dio = ApiConfig.dio;

  BookingDatasource({
    required this.firestore,
  });

  // ============================================================
  // CREATE BOOKING THROUGH FASTAPI
  // ============================================================

  Future<void> createBooking({
    required BookingModel booking,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('Please sign in before creating a booking.');
    }

    final idToken = await currentUser.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Could not obtain Firebase authentication token.');
    }

    await dio.post(
      '/bookings',
      data: {
        'id': booking.id,
        'staffId': booking.staffId,
        'serviceId': booking.serviceId,
        'scheduledDate': booking.scheduledDate?.toIso8601String(),
        'staffLatitude': booking.staffLatitude,
        'staffLongitude': booking.staffLongitude,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      ),
    );
  }

  // ============================================================
  // GET STAFF BOOKINGS
  // ============================================================

  Future<List<BookingModel>> getStaffBookings({
    required String staffId,
  }) async {
    final snapshot = await firestore
        .collection('bookings')
        .where('staffId', isEqualTo: staffId)
        .get();

    return snapshot.docs.map((doc) {
      return BookingModel.fromMap(doc.data());
    }).toList();
  }

  // ============================================================
  // UPDATE BOOKING STATUS
  // ============================================================

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await firestore
        .collection('bookings')
        .doc(bookingId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}