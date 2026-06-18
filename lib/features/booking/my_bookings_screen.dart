import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

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
        title: Text('My Bookings',
            style: AppTextStyles.headlineSm
                .copyWith(color: AppColors.primary)),
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
          final bookings = snapshot.data ?? [];
          final active = bookings
              .where((b) => b.status == BookingStatus.active)
              .toList();
          final past = bookings
              .where((b) => b.status != BookingStatus.active)
              .toList();

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 64, color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No bookings yet',
                      style: AppTextStyles.headlineSm.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  Text('Your active and past bookings will appear here.',
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.outline)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                Text('Active',
                    style: AppTextStyles.headlineSm
                        .copyWith(color: AppColors.slotAvailable)),
                const SizedBox(height: 12),
                ...active.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(booking: b, isActive: true),
                    )),
                const SizedBox(height: 8),
              ],
              if (past.isNotEmpty) ...[
                Text('History', style: AppTextStyles.headlineSm),
                const SizedBox(height: 12),
                ...past.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BookingCard(booking: b, isActive: false),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isActive;
  const _BookingCard({required this.booking, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.slotAvailable.withOpacity(0.3)
              : AppColors.outlineVariant.withOpacity(0.3),
          width: isActive ? 1.5 : 1,
        ),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.slotAvailable.withOpacity(0.1)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? Icons.local_parking_rounded : Icons.history_rounded,
                  color: isActive
                      ? AppColors.slotAvailable
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.locationName, style: AppTextStyles.labelLg),
                    Text('Spot ${booking.slotNumber}',
                        style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.slotAvailable.withOpacity(0.1)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'Active' : 'Completed',
                  style: AppTextStyles.labelMd.copyWith(
                    color: isActive
                        ? AppColors.slotAvailable
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x1AC3C6D7)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BookingMeta(
                icon: Icons.directions_car_outlined,
                text: '${booking.vehicleModel}',
              ),
              _BookingMeta(
                icon: Icons.timer_outlined,
                text: '${booking.durationHours}h',
              ),
              _BookingMeta(
                icon: Icons.calendar_today_outlined,
                text: DateFormat('dd MMM, HH:mm')
                    .format(booking.arrivalTime),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/gate-access', extra: booking),
                icon: const Icon(Icons.qr_code_2,
                    color: Colors.white, size: 18),
                label: Text('Show QR',
                    style: AppTextStyles.labelLg
                        .copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BookingMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: AppTextStyles.labelMd
                .copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
