import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import 'package:intl/intl.dart';

class BookingConfirmScreen extends StatelessWidget {
  final Booking booking;
  const BookingConfirmScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Booking Confirmed',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 24, 16, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.slotAvailable.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.slotAvailable, size: 56),
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.elasticOut,
                  duration: 700.ms,
                )
                .fade(begin: 0, end: 1, duration: 400.ms),

            const SizedBox(height: 16),
            Text('Booking Confirmed!', style: AppTextStyles.headlineLg)
                .animate(delay: 200.ms)
                .fade(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Your parking spot has been reserved.\nShow the QR code at the gate.',
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ).animate(delay: 300.ms).fade(duration: 400.ms),

            const SizedBox(height: 28),

            // Booking details card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.3)),
                    ),
                    child: QrImageView(
                      data: booking.qrData,
                      version: QrVersions.auto,
                      size: 180,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.onSurface,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ).animate(delay: 400.ms).fade(duration: 500.ms),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0x1AC3C6D7)),
                  const SizedBox(height: 16),

                  // Booking info grid
                  _InfoRow('Location', booking.locationName),
                  const SizedBox(height: 12),
                  _InfoRow('Slot Number', booking.slotNumber,
                      valueColor: AppColors.primaryContainer),
                  const SizedBox(height: 12),
                  _InfoRow('Vehicle',
                      '${booking.vehicleModel} (${booking.vehiclePlate})'),
                  const SizedBox(height: 12),
                  _InfoRow('Duration', '${booking.durationHours} Hours'),
                  const SizedBox(height: 12),
                  _InfoRow(
                    'Arrival',
                    DateFormat('dd MMM yyyy, HH:mm').format(booking.arrivalTime),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    'Expires',
                    DateFormat('dd MMM yyyy, HH:mm').format(booking.expiryTime),
                    valueColor: AppColors.slotOccupied,
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fade(duration: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Gate Access button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('/gate-access', extra: booking),
                icon: const Icon(Icons.qr_code_2, color: Colors.white),
                label: Text('Open Gate Access',
                    style:
                        AppTextStyles.labelLg.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ).animate(delay: 500.ms).fade(duration: 400.ms),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.outlineVariant),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Back to Home',
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ),
            ).animate(delay: 600.ms).fade(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant)),
        Text(value,
            style: AppTextStyles.labelLg.copyWith(
              color: valueColor ?? AppColors.onSurface,
            )),
      ],
    );
  }
}
