import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';

abstract class AlertsRepository {
  Stream<List<ParkingAlert>> watchAlerts(String userId);
  Future<void> markAlertAsRead(String alertId);
}

class FirestoreAlertsRepository implements AlertsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ParkingAlert>> watchAlerts(String userId) {
    return _firestore
        .collection('alerts')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            _seedDefaultAlerts();
            return MockData.alerts;
          }
          final alerts = snapshot.docs.map((doc) => ParkingAlert.fromFirestore(doc.data(), doc.id)).toList();
          // Sort by timestamp descending (newest first)
          alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return alerts;
        });
  }

  Future<void> _seedDefaultAlerts() async {
    try {
      final batch = _firestore.batch();
      for (final alert in MockData.alerts) {
        final docRef = _firestore.collection('alerts').doc(alert.id);
        batch.set(docRef, alert.toFirestore());
      }
      await batch.commit();
      debugPrint('Seeded default alerts to Firestore.');
    } catch (e) {
      debugPrint('Failed to seed default alerts: $e');
    }
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    await _firestore.collection('alerts').doc(alertId).update({
      'isRead': true,
    });
  }
}
