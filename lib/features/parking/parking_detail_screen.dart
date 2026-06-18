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
import 'widgets/interactive_slot_map.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String locationId;
  const ParkingDetailScreen({super.key, required this.locationId});

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  ParkingSlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final bookingRepo = Provider.of<BookingRepository>(context, listen: false);
    final repository = Provider.of<ParkingRepository>(context, listen: false);
    final userId = authRepo.currentUser?.id ?? '';

    return StreamBuilder<List<Booking>>(
      stream: bookingRepo.watchUserBookings(userId),
      builder: (context, bookingsSnapshot) {
        final bookings = bookingsSnapshot.data ?? [];
        final activeBooking = bookings.where((b) => b.status == BookingStatus.active).firstOrNull;

        return StreamBuilder<List<ParkingLocation>>(
          stream: repository.watchLocations(),
          builder: (context, locSnapshot) {
            if (locSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            }
            final locations = locSnapshot.data ?? [];
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
        title: Text('CampusPark',
            style:
                AppTextStyles.headlineMd.copyWith(color: AppColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () => context.go('/settings'),
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      body: StreamBuilder<List<ParkingSlot>>(
        stream: repository.watchSlots(widget.locationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading slots: ${snapshot.error}',
                style: AppTextStyles.bodyMd,
              ),
            );
          }
          
          final slots = snapshot.data ?? [];

          return Column(
        children: [
          // Header (Fixed)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(location.name,
                        style: AppTextStyles.dataDisplay.copyWith(fontSize: 32)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(location.address,
                            style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(location.status,
                          style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ).animate().fade(duration: 400.ms),
          ),

          // Map Area (Fixed, takes up most space)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: InteractiveSlotMap(
                        location: location,
                        slots: slots,
                        selectedSlot: _selectedSlot,
                        onSlotTap: (slot) {
                          if (slot.status == SlotStatus.available) {
                            setState(() => _selectedSlot = slot);
                          }
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border(
                          top: BorderSide(
                            color: AppColors.outlineVariant.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _LegendDot(
                              color: AppColors.slotAvailable,
                              label: 'Available'),
                          _LegendDot(
                              color: AppColors.slotBooked,
                              label: 'Booked'),
                          _LegendDot(
                              color: AppColors.slotOccupied,
                              label: 'Occupied'),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1),
            ),
          ),

          // Details Drawer / Scrollable Bottom section
          const SizedBox(height: 12),
          SizedBox(
            height: 180, // Fixed height for stats to keep map large
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Stats card
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Available Slots',
                                style: AppTextStyles.headlineSm.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.directions_car_outlined,
                                  color: AppColors.primaryContainer, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${location.availableSlots}',
                              style: AppTextStyles.dataDisplay.copyWith(
                                color: AppColors.primaryContainer,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '/ ${location.totalSlots}',
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (location.totalSlots - location.availableSlots) /
                                location.totalSlots,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation(
                                AppColors.primaryContainer),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${location.fullnessPercent}% Full',
                            style: AppTextStyles.labelMd,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fade(duration: 400.ms),

                  const SizedBox(height: 12),

                  // Show Entry QR button
                  GestureDetector(
                    onTap: () {
                      if (activeBooking != null) {
                        context.push('/gate-access',
                            extra: activeBooking);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No active booking. Book a spot first.'),
                            backgroundColor: AppColors.primaryContainer,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_2,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Show Entry QR',
                                    style: AppTextStyles.labelLg.copyWith(
                                        color: AppColors.onPrimaryFixed)),
                                Text('Quick access for gate entry',
                                    style: AppTextStyles.labelMd.copyWith(
                                        color: AppColors
                                            .onPrimaryFixedVariant)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ).animate(delay: 300.ms).fade(duration: 400.ms),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Bottom "Book a Spot" button
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16,
                MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              border: Border(
                top: BorderSide(
                    color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                if (_selectedSlot != null) {
                  // Navigate to booking with selected slot
                  context.push('/booking/${widget.locationId}?slot=${_selectedSlot!.id}');
                } else {
                  context.push('/booking/${widget.locationId}');
                }
              },
              icon: const Icon(Icons.event_available, color: Colors.white),
              label: Text(_selectedSlot != null ? 'Book Spot ${_selectedSlot!.number}' : 'Book a Spot',
                  style:
                      AppTextStyles.labelLg.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ).copyWith(
                overlayColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.1)),
              ),
            ),
          ).animate().fade(duration: 300.ms).slideY(begin: 1, end: 0),
        ],
      );
    },
  ),
);
      },
    );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelMd),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? note;
  final List<String>? chips;

  const _DetailRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.note,
    this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.labelLg),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ],
              if (note != null) ...[
                const SizedBox(height: 2),
                Text(note!,
                    style: AppTextStyles.labelMd
                        .copyWith(color: AppColors.tertiary)),
              ],
              if (chips != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: chips!
                      .map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppColors.outlineVariant
                                      .withOpacity(0.5)),
                            ),
                            child: Text(c, style: AppTextStyles.labelMd),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
