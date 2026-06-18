import 'dart:math';
import '../models/models.dart';

class MockData {
  // ─── Current User ─────────────────────────────────────────────────────────
  static final UserModel currentUser = UserModel(
    id: 'u001',
    name: 'Muhammad Taufik',
    email: 'taufik@uib.ac.id',
    studentId: '19827364',
    vehiclePlate: 'B 1234 XYZ',
    vehicleModel: 'Honda Civic',
    vehicleColor: 'Black',
    isPremium: true,
  );

  // ─── Parking Locations ────────────────────────────────────────────────────
  static final List<ParkingLocation> locations = [
    ParkingLocation(
      id: 'gedung_a',
      name: 'Gedung A',
      address: '250m away • Campus North',
      totalSlots: 92,
      availableSlots: 26,
      bookedSlots: 11,
      occupiedSlots: 55,
      peakHours: '08:00 – 11:00',
      operationalHours: 'Mon - Fri: 6:00 AM - 10:00 PM',
      operationalHoursWeekend: 'Sat - Sun: 8:00 AM - 8:00 PM',
      timeLimit: '4 Hours Max per Session',
      vehicleTypes: ['Compact', 'Sedan', 'SUV'],
      status: 'Open',
      mapAsset: 'assets/images/gedung_a_map.jpg',
      viewAsset: 'assets/images/gedung_a_view.jpg',
      distance: '250m away',
      mapLeft: 0.28,
      mapTop: 0.32,
      availabilityLevel: AvailabilityLevel.medium,
    ),
    ParkingLocation(
      id: 'gedung_b',
      name: 'Gedung B',
      address: '400m away • Campus South',
      totalSlots: 92,
      availableSlots: 11,
      bookedSlots: 7,
      occupiedSlots: 74,
      peakHours: '09:00 – 12:00',
      operationalHours: 'Mon - Fri: 6:00 AM - 10:00 PM',
      operationalHoursWeekend: 'Sat - Sun: 8:00 AM - 8:00 PM',
      timeLimit: '4 Hours Max per Session',
      vehicleTypes: ['Compact', 'Sedan'],
      status: 'Open',
      mapAsset: 'assets/images/gedung_b_map.jpg',
      viewAsset: 'assets/images/gedung_a_view.jpg',
      distance: '400m away',
      mapLeft: 0.60,
      mapTop: 0.50,
      availabilityLevel: AvailabilityLevel.low,
    ),
    ParkingLocation(
      id: 'sporthall',
      name: 'Sporthall',
      address: '650m away • Campus East',
      totalSlots: 96,
      availableSlots: 29,
      bookedSlots: 10,
      occupiedSlots: 57,
      peakHours: '17:00 – 20:00',
      operationalHours: 'Mon - Sun: 6:00 AM - 11:00 PM',
      operationalHoursWeekend: 'Sat - Sun: 6:00 AM - 11:00 PM',
      timeLimit: '6 Hours Max per Session',
      vehicleTypes: ['Compact', 'Sedan', 'SUV', 'Motorcycle'],
      status: 'Open',
      mapAsset: 'assets/images/sporthall_map.jpg',
      viewAsset: 'assets/images/sporthall_view.jpg',
      distance: '650m away',
      mapLeft: 0.38,
      mapTop: 0.72,
      availabilityLevel: AvailabilityLevel.high,
    ),
  ];

  // ─── Generate Slots for a Location ────────────────────────────────────────
  static List<ParkingSlot> generateSlots(String locationId) {
    final loc = locations.firstWhere((l) => l.id == locationId);
    final slots = <ParkingSlot>[];
    int slotNum = 1;

    final occupied = loc.occupiedSlots;
    final booked = loc.bookedSlots;

    void addSlot(double x, double y, double width, double height, double angle, int row, int col) {
      if (slotNum > loc.totalSlots) return;
      SlotStatus status;
      if (slotNum <= occupied) {
        status = SlotStatus.occupied;
      } else if (slotNum <= occupied + booked) {
        status = SlotStatus.booked;
      } else {
        status = SlotStatus.available;
      }

      SlotType type = (slotNum == 1 || slotNum == 2) ? SlotType.accessible : SlotType.regular;

      slots.add(ParkingSlot(
        id: '${locationId}_$slotNum',
        locationId: locationId,
        number: '${locationId == 'gedung_a' ? 'A' : locationId == 'gedung_b' ? 'B' : 'S'}-${slotNum.toString().padLeft(3, '0')}',
        status: status,
        type: type,
        row: row,
        col: col,
        x: x,
        y: y,
        width: width,
        height: height,
        angle: angle,
      ));
      slotNum++;
    }

    if (locationId == 'sporthall') {
      // Sporthall Layout (continuous columns, no gaps, straight rectangular alignment)
      // Left Column (24 slots)
      for (int i = 0; i < 24; i++) {
        addSlot(0.185, 0.125 + (i * 0.0305), 0.065, 0.024, 0, 0, i);
      }
      // Center-Left Column (24 slots)
      for (int i = 0; i < 24; i++) {
        addSlot(0.325, 0.125 + (i * 0.0305), 0.065, 0.024, 0, 1, i);
      }
      // Center-Right Column (24 slots)
      for (int i = 0; i < 24; i++) {
        addSlot(0.395, 0.125 + (i * 0.0305), 0.065, 0.024, 0, 2, i);
      }
      // Right Column (24 slots)
      for (int i = 0; i < 24; i++) {
        addSlot(0.535, 0.125 + (i * 0.0305), 0.065, 0.024, 0, 3, i);
      }
    } else {
      // Gedung A & B Layout
      // Left big column (24 slots)
      for (int i=0; i<24; i++) addSlot(0.185, 0.125 + (i * 0.0305), 0.065, 0.024, 0, i, 0);
      
      // Middle vertical blocks
      for (int c=0; c<12; c++) addSlot(0.325, 0.165 + (c * 0.0305), 0.065, 0.024, 0, 0, c);
      for (int c=0; c<12; c++) addSlot(0.395, 0.165 + (c * 0.0305), 0.065, 0.024, 0, 1, c);
      for (int c=0; c<11; c++) addSlot(0.325, 0.550 + (c * 0.0305), 0.065, 0.024, 0, 2, c);
      for (int c=0; c<11; c++) addSlot(0.395, 0.550 + (c * 0.0305), 0.065, 0.024, 0, 3, c);

      // Right column
      // Top: 5 slots
      for (int c=0; c<5; c++) addSlot(0.535, 0.135 + (c * 0.0305), 0.065, 0.024, 0, 4, c);
      // Middle: 9 slots
      for (int c=0; c<9; c++) addSlot(0.535, 0.335 + (c * 0.0305), 0.065, 0.024, 0, 4, c+5);
      // Bottom: 8 slots
      for (int c=0; c<8; c++) addSlot(0.535, 0.635 + (c * 0.0305), 0.065, 0.024, 0, 4, c+14);
    }

    // Fill remaining if needed up to total slots
    while (slotNum <= loc.totalSlots) {
      addSlot(0.9, 0.9, 0.01, 0.01, 0, 0, 0); // Hide offscreen or small if unaccounted
    }
    
    // Shuffle statuses stably for realism using a fixed seed
    slots.shuffle(Random(42));
    return slots;
  }

  // ─── Active Bookings ──────────────────────────────────────────────────────
  static final List<Booking> bookings = [
    Booking(
      id: 'bk001',
      locationId: 'gedung_b',
      locationName: 'Block B',
      slotId: 'gedung_b_102',
      slotNumber: 'B-102',
      vehiclePlate: 'B 1234 XYZ',
      vehicleModel: 'Honda Civic',
      durationHours: 2,
      arrivalTime: DateTime.now(),
      expiryTime: DateTime.now().add(const Duration(hours: 2)),
      status: BookingStatus.active,
      qrData: 'CAMPUSPARK:BK001:B-102:GEDUNG_B:${DateTime.now().millisecondsSinceEpoch}',
    ),
    Booking(
      id: 'bk002',
      locationId: 'gedung_a',
      locationName: 'Gedung A',
      slotId: 'gedung_a_042',
      slotNumber: 'A-042',
      vehiclePlate: 'B 1234 XYZ',
      vehicleModel: 'Honda Civic',
      durationHours: 3,
      arrivalTime: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      expiryTime: DateTime.now().subtract(const Duration(days: 1)),
      status: BookingStatus.completed,
      qrData: 'CAMPUSPARK:BK002:A-042:GEDUNG_A',
    ),
    Booking(
      id: 'bk003',
      locationId: 'sporthall',
      locationName: 'Sporthall',
      slotId: 'sporthall_015',
      slotNumber: 'S-015',
      vehiclePlate: 'B 1234 XYZ',
      vehicleModel: 'Honda Civic',
      durationHours: 4,
      arrivalTime: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
      expiryTime: DateTime.now().subtract(const Duration(days: 3)),
      status: BookingStatus.completed,
      qrData: 'CAMPUSPARK:BK003:S-015:SPORTHALL',
    ),
  ];

  // ─── Alerts ───────────────────────────────────────────────────────────────
  static final List<ParkingAlert> alerts = [
    ParkingAlert(
      id: 'a001',
      title: 'Peringatan: Parkir Ti...',
      message:
          'Spot B-102 yang Anda pesan telah ditempati oleh kendaraan lain. Harap segera konfirmasi ke petugas.',
      type: AlertType.warning,
      timestamp: DateTime.now(),
      isRead: false,
      actionLabel: 'Laporkan',
    ),
    ParkingAlert(
      id: 'a002',
      title: 'Gedung A is nearly full',
      message:
          'Only 5 spots remaining in Gedung A. Consider routing to Gedung C for better availability.',
      type: AlertType.warning,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      actionLabel: 'Read more',
    ),
    ParkingAlert(
      id: 'a003',
      title: 'Booking Confirmed',
      message:
          'Your reservation for Spot B-42 tomorrow at 08:00 AM has been confirmed. Show QR at the gate.',
      type: AlertType.success,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      actionLabel: 'View details',
    ),
    ParkingAlert(
      id: 'a005',
      title: 'Sporthall Now Open',
      message:
          'Sporthall parking has reopened after maintenance. 29 spots available.',
      type: AlertType.success,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      actionLabel: null,
    ),
  ];

  // ─── Vehicles ─────────────────────────────────────────────────────────────
  static const List<String> vehicles = [
    'Honda Civic (B 1234 XYZ)',
    'Toyota Avanza (B 5678 ABC)',
  ];

  // ─── Campus Stats ─────────────────────────────────────────────────────────
  static int get totalCampusAvailable =>
      locations.fold(0, (sum, l) => sum + l.availableSlots);
  static int get totalCampusCapacity =>
      locations.fold(0, (sum, l) => sum + l.totalSlots);
}
