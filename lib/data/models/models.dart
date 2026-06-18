import 'package:flutter/material.dart';

// ─── Parking Location ────────────────────────────────────────────────────────
class ParkingLocation {
  final String id;
  final String name;
  final String address;
  final int totalSlots;
  final int availableSlots;
  final int bookedSlots;
  final int occupiedSlots;
  final String peakHours;
  final String operationalHours;
  final String operationalHoursWeekend;
  final String timeLimit;
  final List<String> vehicleTypes;
  final String status;
  final String mapAsset;
  final String viewAsset;
  final String distance;
  final double mapLeft;
  final double mapTop;
  final AvailabilityLevel availabilityLevel;

  ParkingLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.bookedSlots,
    required this.occupiedSlots,
    required this.peakHours,
    required this.operationalHours,
    required this.operationalHoursWeekend,
    required this.timeLimit,
    required this.vehicleTypes,
    required this.status,
    required this.mapAsset,
    required this.viewAsset,
    required this.distance,
    required this.mapLeft,
    required this.mapTop,
    required this.availabilityLevel,
  });

  factory ParkingLocation.fromFirestore(Map<String, dynamic> json) {
    return ParkingLocation(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      totalSlots: json['totalSlots'] as int? ?? 0,
      availableSlots: json['availableSlots'] as int? ?? 0,
      bookedSlots: json['bookedSlots'] as int? ?? 0,
      occupiedSlots: json['occupiedSlots'] as int? ?? 0,
      peakHours: json['peakHours'] as String? ?? '',
      operationalHours: json['operationalHours'] as String? ?? '',
      operationalHoursWeekend: json['operationalHoursWeekend'] as String? ?? '',
      timeLimit: json['timeLimit'] as String? ?? '',
      vehicleTypes: List<String>.from(json['vehicleTypes'] as List? ?? []),
      status: json['status'] as String? ?? '',
      mapAsset: json['mapAsset'] as String? ?? '',
      viewAsset: json['viewAsset'] as String? ?? '',
      distance: json['distance'] as String? ?? '',
      mapLeft: (json['mapLeft'] as num? ?? 0.0).toDouble(),
      mapTop: (json['mapTop'] as num? ?? 0.0).toDouble(),
      availabilityLevel: AvailabilityLevel.values.firstWhere(
        (e) => e.name == json['availabilityLevel'],
        orElse: () => AvailabilityLevel.medium,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'bookedSlots': bookedSlots,
      'occupiedSlots': occupiedSlots,
      'peakHours': peakHours,
      'operationalHours': operationalHours,
      'operationalHoursWeekend': operationalHoursWeekend,
      'timeLimit': timeLimit,
      'vehicleTypes': vehicleTypes,
      'status': status,
      'mapAsset': mapAsset,
      'viewAsset': viewAsset,
      'distance': distance,
      'mapLeft': mapLeft,
      'mapTop': mapTop,
      'availabilityLevel': availabilityLevel.name,
    };
  }

  int get fullnessPercent =>
      ((totalSlots - availableSlots) / totalSlots * 100).round();

  String get availabilityLabel {
    if (availableSlots > 50) return 'Plenty';
    if (availableSlots > 10) return 'Moderate';
    if (availableSlots > 0) return 'Almost Full';
    return 'Full';
  }

  Color get availabilityColor {
    if (availableSlots > 50) return const Color(0xFF10B981);
    if (availableSlots > 10) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

enum AvailabilityLevel { high, medium, low }

// ─── Parking Slot ─────────────────────────────────────────────────────────────
class ParkingSlot {
  final String id;
  final String locationId;
  final String number;
  final SlotStatus status;
  final SlotType type;
  final bool isVIP;
  final int row;
  final int col;

  // Positional coordinates relative to 1000x1000 map (0.0 to 1.0)
  final double x;
  final double y;
  final double width;
  final double height;
  final double angle;

  const ParkingSlot({
    required this.id,
    required this.locationId,
    required this.number,
    this.status = SlotStatus.available,
    required this.type,
    this.isVIP = false,
    required this.row,
    required this.col,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 0.04,
    this.height = 0.08,
    this.angle = 0.0,
  });

  ParkingSlot copyWith({
    SlotStatus? status,
    bool? isVIP,
  }) =>
      ParkingSlot(
        id: id,
        locationId: locationId,
        number: number,
        status: status ?? this.status,
        type: type,
        isVIP: isVIP ?? this.isVIP,
        row: row,
        col: col,
        x: x,
        y: y,
        width: width,
        height: height,
        angle: angle,
      );

  factory ParkingSlot.fromFirestore(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      number: json['number'] as String,
      status: SlotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SlotStatus.available,
      ),
      type: SlotType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SlotType.regular,
      ),
      isVIP: json['isVIP'] as bool? ?? false,
      row: json['row'] as int,
      col: json['col'] as int,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'locationId': locationId,
      'number': number,
      'status': status.name,
      'type': type.name,
      'isVIP': isVIP,
      'row': row,
      'col': col,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'angle': angle,
    };
  }
}

enum SlotStatus { available, booked, occupied }

enum SlotType { regular, accessible }

// ─── Booking ──────────────────────────────────────────────────────────────────
class Booking {
  final String id;
  final String locationId;
  final String locationName;
  final String slotId;
  final String slotNumber;
  final String vehiclePlate;
  final String vehicleModel;
  final int durationHours;
  final DateTime arrivalTime;
  final DateTime expiryTime;
  final BookingStatus status;
  final String qrData;

  Booking({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.slotId,
    required this.slotNumber,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.durationHours,
    required this.arrivalTime,
    required this.expiryTime,
    required this.status,
    required this.qrData,
  });

  factory Booking.fromFirestore(Map<String, dynamic> json, String id) {
    return Booking(
      id: id,
      locationId: json['locationId'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      slotId: json['slotId'] as String? ?? '',
      slotNumber: json['slotNumber'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      durationHours: json['durationHours'] as int? ?? 1,
      arrivalTime: DateTime.fromMillisecondsSinceEpoch(json['arrivalTime'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      expiryTime: DateTime.fromMillisecondsSinceEpoch(json['expiryTime'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.active,
      ),
      qrData: json['qrData'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'slotId': slotId,
      'slotNumber': slotNumber,
      'vehiclePlate': vehiclePlate,
      'vehicleModel': vehicleModel,
      'durationHours': durationHours,
      'arrivalTime': arrivalTime.millisecondsSinceEpoch,
      'expiryTime': expiryTime.millisecondsSinceEpoch,
      'status': status.name,
      'qrData': qrData,
    };
  }
}

enum BookingStatus { active, completed, cancelled }

// ─── User ─────────────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String vehiclePlate;
  final String vehicleModel;
  final String vehicleColor;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.isPremium,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleColor: json['vehicleColor'] as String? ?? '',
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'studentId': studentId,
      'vehiclePlate': vehiclePlate,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'isPremium': isPremium,
    };
  }
}

// ─── Alert ────────────────────────────────────────────────────────────────────
class ParkingAlert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionLabel;

  ParkingAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.actionLabel,
  });

  factory ParkingAlert.fromFirestore(Map<String, dynamic> json, String id) {
    return ParkingAlert(
      id: id,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.info,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      isRead: json['isRead'] as bool? ?? false,
      actionLabel: json['actionLabel'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'actionLabel': actionLabel,
    };
  }
}

enum AlertType { warning, info, success, error }
