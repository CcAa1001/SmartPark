import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/parking_repository.dart';
import '../../core/services/notification_service.dart';

class BookingScreen extends StatefulWidget {
  final String locationId;
  final String? slotId;
  const BookingScreen({super.key, required this.locationId, this.slotId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _durationHours = 2;
  late String _selectedVehicle;
  bool _arrivalNow = true;
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _resolvedSlotId;
  late String _resolvedSlotNumber;

  bool _initializedVehicle = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = MockData.vehicles.first;
    
    // Resolve slot details
    _resolvedSlotId = widget.slotId ?? '${widget.locationId}_001';
    
    if (widget.slotId != null) {
      final parts = widget.slotId!.split('_');
      final numStr = parts.last;
      final prefix = parts[0] == 'gedung_a' ? 'A' : parts[0] == 'gedung_b' ? 'B' : 'S';
      final val = int.tryParse(numStr) ?? 1;
      _resolvedSlotNumber = '$prefix-${val.toString().padLeft(3, '0')}';
    } else {
      final prefix = widget.locationId == 'gedung_a' ? 'A' : widget.locationId == 'gedung_b' ? 'B' : 'S';
      _resolvedSlotNumber = '$prefix-001';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedVehicle) {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);
      final user = authRepo.currentUser;
      if (user != null && user.vehiclePlate != 'N/A' && user.vehiclePlate.isNotEmpty) {
        _selectedVehicle = '${user.vehicleModel} (${user.vehiclePlate})';
      } else {
        _selectedVehicle = MockData.vehicles.first;
      }
      _initializedVehicle = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final bookingRepo = Provider.of<BookingRepository>(context, listen: false);
    final parkingRepo = Provider.of<ParkingRepository>(context, listen: false);
    final userId = authRepo.currentUser?.id ?? '';

    return StreamBuilder<List<Booking>>(
      stream: bookingRepo.watchUserBookings(userId),
      builder: (context, bookingsSnapshot) {
        final bookings = bookingsSnapshot.data ?? [];
        final hasActiveBooking = bookings.any((b) => b.status == BookingStatus.active);
        final activeBooking = bookings.where((b) => b.status == BookingStatus.active).firstOrNull;

        return StreamBuilder<List<ParkingLocation>>(
          stream: parkingRepo.watchLocations(),
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final locations = snapshot.data ?? [];
        final location = locations.firstWhere(
          (l) => l.id == widget.locationId,
          orElse: () => MockData.locations.firstWhere((l) => l.id == widget.locationId),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Book a Spot – ${location.name}',
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.08),
          ),
          body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasActiveBooking && activeBooking != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slotOccupied.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.slotOccupied, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Active Booking Detected',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.slotOccupied),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You already have an active reservation at ${activeBooking.locationName} (Spot ${activeBooking.slotNumber}).\n\nPlease complete or cancel it before reserving a new spot.',
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.slotOccupied.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/gate-access', extra: activeBooking),
                            icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                            label: Text('Show Active QR', style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.slotOccupied,
                              minimumSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),

                // Location preview card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.outlineVariant.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          location.viewAsset,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${location.name} Premium Lot',
                                style: AppTextStyles.labelLg),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 12, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text('Campus North, Level 1',
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.slotAvailable,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${location.availableSlots} spots available',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.slotAvailable,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 20),

                // Select Vehicle
                Text('Select Vehicle', style: AppTextStyles.labelLg),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVehicle,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: AppTextStyles.bodyMd,
                      items: (() {
                        final list = <String>[];
                        final authRepo = Provider.of<AuthRepository>(context, listen: false);
                        final user = authRepo.currentUser;
                        if (user != null && user.vehiclePlate != 'N/A' && user.vehiclePlate.isNotEmpty) {
                          list.add('${user.vehicleModel} (${user.vehiclePlate})');
                        }
                        for (final v in MockData.vehicles) {
                          if (!list.contains(v)) {
                            list.add(v);
                          }
                        }
                        return list;
                      })()
                          .map((v) => DropdownMenuItem(
                                value: v,
                                child: Text(v),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedVehicle = v!),
                    ),
                  ),
                ).animate(delay: 100.ms).fade(duration: 400.ms),

                const SizedBox(height: 20),

                // Parking Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parking Duration', style: AppTextStyles.labelLg),
                    Text(
                      '$_durationHours Hours',
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.primaryContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryContainer,
                    inactiveTrackColor: AppColors.surfaceContainer,
                    thumbColor: AppColors.primaryContainer,
                    overlayColor:
                        AppColors.primaryContainer.withOpacity(0.1),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _durationHours.toDouble(),
                    min: 1,
                    max: 12,
                    divisions: 11,
                    onChanged: (v) =>
                        setState(() => _durationHours = v.round()),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1h',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.outline)),
                    Text('6h',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.outline)),
                    Text('12h',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.outline)),
                  ],
                ),

                const SizedBox(height: 20),

                // Arrival Time
                Text('Arrival Time', style: AppTextStyles.labelLg),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _arrivalNow = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _arrivalNow
                                ? AppColors.surfaceContainerLowest
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _arrivalNow
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant,
                              width: _arrivalNow ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time,
                                  size: 16,
                                  color: _arrivalNow
                                      ? AppColors.primary
                                      : AppColors.outline),
                              const SizedBox(width: 6),
                              Text('Now',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: _arrivalNow
                                        ? AppColors.primary
                                        : AppColors.outline,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() {
                              _selectedTime = time;
                              _arrivalNow = false;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_arrivalNow
                                ? AppColors.surfaceContainerLowest
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: !_arrivalNow
                                  ? AppColors.primaryContainer
                                  : AppColors.outlineVariant,
                              width: !_arrivalNow ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 16,
                                  color: !_arrivalNow
                                      ? AppColors.primary
                                      : AppColors.outline),
                              const SizedBox(width: 6),
                              Text(
                                _arrivalNow
                                    ? 'Select Time'
                                    : _selectedTime.format(context),
                                style: AppTextStyles.labelLg.copyWith(
                                  color: !_arrivalNow
                                      ? AppColors.primary
                                      : AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Balance/Pricing card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time Limit',
                                  style: AppTextStyles.labelMd
                                      .copyWith(color: Colors.white70)),
                              const SizedBox(height: 4),
                              Text('Remaining Balance',
                                  style: AppTextStyles.headlineMd.copyWith(
                                      color: Colors.white, fontSize: 22)),
                            ],
                          ),
                          Text('(Student Time Quota)',
                              style: AppTextStyles.labelMd
                                  .copyWith(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rate',
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: Colors.white70)),
                          Text('Free for Students (Limit 4h)',
                              style: AppTextStyles.labelLg
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fade(duration: 400.ms),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Show your Entry QR Code at the gate to enter',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Confirm Booking button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16,
                  MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
              ),
              child: ElevatedButton(
                // onPressed: () => _confirmBooking(context, location),
                onPressed: hasActiveBooking ? null : () => _confirmBooking(context, location),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActiveBooking ? AppColors.surfaceContainerHigh : AppColors.primaryContainer,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm Booking',
                    style:
                        AppTextStyles.labelLg.copyWith(color: Colors.white)),
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: 1, end: 0),
          ),
        ],
      ),
    );
      },
    );
      },
    );
  }

  void _confirmBooking(BuildContext context, ParkingLocation location) async {
    final now = DateTime.now();
    final arrival = _arrivalNow
        ? now
        : DateTime(now.year, now.month, now.day, _selectedTime.hour,
            _selectedTime.minute);
    
    final booking = Booking(
      id: 'bk_new_${now.millisecondsSinceEpoch}',
      locationId: location.id,
      locationName: location.name,
      slotId: _resolvedSlotId,
      slotNumber: _resolvedSlotNumber,
      vehiclePlate: _selectedVehicle.split('(').last.replaceAll(')', '').trim(),
      vehicleModel: _selectedVehicle.split('(').first.trim(),
      durationHours: _durationHours,
      arrivalTime: arrival,
      expiryTime: arrival.add(Duration(hours: _durationHours)),
      status: BookingStatus.active,
      qrData:
          'CAMPUSPARK:${location.id.toUpperCase()}:${_resolvedSlotNumber.replaceAll('-', '')}:${now.millisecondsSinceEpoch}',
    );

    try {
      final authRepo = Provider.of<AuthRepository>(context, listen: false);
      final bookingRepo = Provider.of<BookingRepository>(context, listen: false);
      final parkingRepo = Provider.of<ParkingRepository>(context, listen: false);
      final userId = authRepo.currentUser?.id ?? '';

      // 1. Create booking in DB
      await bookingRepo.createBooking(booking, userId);

      // 2. Update slot status in repository
      await parkingRepo.updateSlotStatus(_resolvedSlotId, location.id, SlotStatus.booked);

      // 3. Schedule warning notification
      await NotificationService.scheduleBookingExpiryNotification(
        bookingId: booking.id,
        locationName: booking.locationName,
        slotNumber: booking.slotNumber,
        expiryTime: booking.expiryTime,
      );
    } catch (e) {
      debugPrint('Failed to save booking or update slot status: $e');
    }

    if (context.mounted) {
      context.push('/booking-confirm', extra: booking);
    }
  }
}
