import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

abstract class AuthRepository {
  UserModel? get currentUser;
  Stream<UserModel?> get onAuthStateChanged;
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> register(String name, String email, String password, String plateNumber);
  Future<void> logout();
}

class FirestoreAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _cachedUser;

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        _cachedUser = null;
        return null;
      }
      try {
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();
        if (doc.exists && doc.data() != null) {
          _cachedUser = UserModel.fromFirestore(doc.data()!, fbUser.uid);
        } else {
          _cachedUser = UserModel(
            id: fbUser.uid,
            name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
            email: fbUser.email ?? '',
            studentId: 'N/A',
            vehiclePlate: 'N/A',
            vehicleModel: 'N/A',
            vehicleColor: 'N/A',
            isPremium: false,
          );
        }
      } catch (e) {
        debugPrint('Error fetching user profile: $e');
        _cachedUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
          email: fbUser.email ?? '',
          studentId: 'N/A',
          vehiclePlate: 'N/A',
          vehicleModel: 'N/A',
          vehicleColor: 'N/A',
          isPremium: false,
        );
      }
      return _cachedUser;
    });
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    final credentials = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    
    final fbUser = credentials.user;
    if (fbUser != null) {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        _cachedUser = UserModel.fromFirestore(doc.data()!, fbUser.uid);
      } else {
        _cachedUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
          email: fbUser.email ?? '',
          studentId: 'N/A',
          vehiclePlate: 'N/A',
          vehicleModel: 'N/A',
          vehicleColor: 'N/A',
          isPremium: false,
        );
      }
      return _cachedUser;
    }
    return null;
  }

  @override
  Future<UserModel?> register(String name, String email, String password, String plateNumber) async {
    final credentials = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    
    final fbUser = credentials.user;
    if (fbUser != null) {
      await fbUser.updateDisplayName(name);
      
      final newUser = UserModel(
        id: fbUser.uid,
        name: name,
        email: email.trim(),
        studentId: (10000000 + name.hashCode % 10000000).toString(),
        vehiclePlate: plateNumber.toUpperCase().trim(),
        vehicleModel: 'Sedan',
        vehicleColor: 'Black',
        isPremium: true,
      );
      
      await _firestore.collection('users').doc(fbUser.uid).set(newUser.toFirestore());
      _cachedUser = newUser;
      return _cachedUser;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    _cachedUser = null;
  }
}
