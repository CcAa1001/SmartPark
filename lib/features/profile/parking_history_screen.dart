import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import 'package:intl/intl.dart';

class ParkingHistoryScreen extends StatelessWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final bookingRepo = Provider.of<BookingRepository>(context, listen: false);
    final userId = authRepo.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text('Parking History',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingRepo.watchUserBookings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 64, color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No parking history yet',
                      style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  Text('Your past bookings will appear here.',
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.outline)),
                ],
              ),
            );
          }

          return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final b = history[index];
                return Container(
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _statusColor(b.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_parking_rounded,
                            color: _statusColor(b.status), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.locationName, style: AppTextStyles.labelLg),
                            Text('Spot ${b.slotNumber} · ${b.durationHours}h',
                                style: AppTextStyles.bodyMd.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                            Text(
                              DateFormat('EEE, dd MMM yyyy, HH:mm')
                                  .format(b.arrivalTime),
                              style: AppTextStyles.labelMd,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(b.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(b.status),
                          style: AppTextStyles.labelMd.copyWith(
                              color: _statusColor(b.status),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
        },
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.active:
        return AppColors.slotAvailable;
      case BookingStatus.completed:
        return AppColors.primary;
      case BookingStatus.cancelled:
        return AppColors.slotOccupied;
    }
  }

  String _statusLabel(BookingStatus s) {
    switch (s) {
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Done';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
