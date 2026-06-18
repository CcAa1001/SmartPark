import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

abstract class BookingRepository {
  Future<void> createBooking(Booking booking, String userId);
  Stream<List<Booking>> watchUserBookings(String userId);
  Future<void> cancelBooking(String bookingId);
}

class FirestoreBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createBooking(Booking booking, String userId) async {
    final data = booking.toFirestore();
    data['userId'] = userId;
    await _firestore.collection('bookings').doc(booking.id).set(data);
  }

  @override
  Stream<List<Booking>> watchUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs.map((doc) => Booking.fromFirestore(doc.data(), doc.id)).toList();
          // Sort by arrival time descending
          bookings.sort((a, b) => b.arrivalTime.compareTo(a.arrivalTime));
          return bookings;
        });
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
    });
  }
}
