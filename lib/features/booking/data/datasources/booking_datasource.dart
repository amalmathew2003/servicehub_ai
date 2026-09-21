import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';

class BookingDatasource {
  final FirebaseFirestore firestore;

  BookingDatasource({
    required this.firestore,
  });

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<void> createBooking({
    required BookingModel booking,
  }) async {
    await firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toMap());
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