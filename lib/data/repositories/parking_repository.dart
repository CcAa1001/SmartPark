import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';

abstract class ParkingRepository {
  Stream<List<ParkingLocation>> watchLocations();
  Future<ParkingLocation?> getLocation(String locationId);
  Stream<List<ParkingSlot>> watchSlots(String locationId);
  Future<void> updateSlotStatus(String slotId, String locationId, SlotStatus status);
}

class FirestoreParkingRepository implements ParkingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ParkingLocation>> watchLocations() {
    return _firestore
        .collection('locations')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            _seedDefaultLocations();
            return MockData.locations;
          }
          final locs = snapshot.docs.map((doc) => ParkingLocation.fromFirestore(doc.data())).toList();
          locs.sort((a, b) => a.name.compareTo(b.name));
          return locs;
        });
  }

  Future<void> _seedDefaultLocations() async {
    try {
      final batch = _firestore.batch();
      for (final loc in MockData.locations) {
        final docRef = _firestore.collection('locations').doc(loc.id);
        batch.set(docRef, loc.toFirestore());
      }
      await batch.commit();
      debugPrint('Seeded default locations to Firestore.');
    } catch (e) {
      debugPrint('Failed to seed default locations: $e');
    }
  }

  @override
  Future<ParkingLocation?> getLocation(String locationId) async {
    final doc = await _firestore.collection('locations').doc(locationId).get();
    if (doc.exists && doc.data() != null) {
      return ParkingLocation.fromFirestore(doc.data()!);
    }
    return null;
  }

  @override
  Stream<List<ParkingSlot>> watchSlots(String locationId) {
    return _firestore
        .collection('parking_slots')
        .where('locationId', isEqualTo: locationId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            _seedDefaultSlots(locationId);
            return MockData.generateSlots(locationId);
          }
          final slots = snapshot.docs.map((doc) => ParkingSlot.fromFirestore(doc.data())).toList();
          slots.sort((a, b) => a.id.compareTo(b.id));
          return slots;
        });
  }

  Future<void> _seedDefaultSlots(String locationId) async {
    try {
      final defaultSlots = MockData.generateSlots(locationId);
      final batch = _firestore.batch();
      for (final slot in defaultSlots) {
        final docRef = _firestore.collection('parking_slots').doc(slot.id);
        batch.set(docRef, slot.toFirestore());
      }
      await batch.commit();
      debugPrint('Seeded Firestore collection with default slots for: $locationId');
    } catch (e) {
      debugPrint('Failed to seed default slots: $e');
    }
  }

  @override
  Future<void> updateSlotStatus(String slotId, String locationId, SlotStatus status) async {
    // 1. Update the slot status in DB
    await _firestore.collection('parking_slots').doc(slotId).update({
      'status': status.name,
    });

    // 2. Query and recalculate live counts for the Location
    try {
      final slotsSnapshot = await _firestore
          .collection('parking_slots')
          .where('locationId', isEqualTo: locationId)
          .get();

      final slots = slotsSnapshot.docs.map((doc) => ParkingSlot.fromFirestore(doc.data())).toList();
      
      int available = 0;
      int booked = 0;
      int occupied = 0;
      
      for (final slot in slots) {
        final sStatus = slot.id == slotId ? status : slot.status;
        if (sStatus == SlotStatus.available) available++;
        if (sStatus == SlotStatus.booked) booked++;
        if (sStatus == SlotStatus.occupied) occupied++;
      }
      
      await _firestore.collection('locations').doc(locationId).update({
        'availableSlots': available,
        'bookedSlots': booked,
        'occupiedSlots': occupied,
      });
      debugPrint('Recalculated location $locationId counts: available=$available, booked=$booked, occupied=$occupied');
    } catch (e) {
      debugPrint('Failed to update location slot counts: $e');
    }
  }
}
