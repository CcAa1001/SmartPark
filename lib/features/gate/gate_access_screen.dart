import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

class GateAccessScreen extends StatefulWidget {
  final Booking booking;
  const GateAccessScreen({super.key, required this.booking});

  @override
  State<GateAccessScreen> createState() => _GateAccessScreenState();
}

class _GateAccessScreenState extends State<GateAccessScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.booking.expiryTime.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remaining = widget.booking.expiryTime.difference(DateTime.now());
          if (_remaining.isNegative) {
            _remaining = Duration.zero;
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeFormatted {
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isExpired = _remaining == Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gate Access',
          style: AppTextStyles.headlineSm,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Instruction
            Text(
              'Scan this at the entrance gate of\nUniversitas Internasional Batam',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ).animate().fade(duration: 400.ms),

            const SizedBox(height: 24),

            // QR Code Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isExpired
                  ? Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.slotOccupied, size: 80),
                        const SizedBox(height: 12),
                        Text('QR Code Expired',
                            style: AppTextStyles.headlineSm.copyWith(
                                color: AppColors.slotOccupied)),
                      ],
                    )
                  : QrImageView(
                      data: booking.qrData,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.onSurface,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.onSurface,
                      ),
                    ),
            )
                .animate()
                .fade(duration: 500.ms, delay: 200.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOut,
                  duration: 400.ms,
                  delay: 200.ms,
                ),

            const SizedBox(height: 24),

            // Booking info chip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.apartment_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BUILDING',
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                            Text(booking.locationName,
                                style: AppTextStyles.headlineSm),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('SPOT',
                              style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant)),
                          Text(booking.slotNumber,
                              style: AppTextStyles.headlineSm.copyWith(
                                  color: AppColors.primaryContainer)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0x1AC3C6D7)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Time Remaining',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurfaceVariant)),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _timeFormatted,
                          key: ValueKey(_timeFormatted),
                          style: AppTextStyles.headlineSm.copyWith(
                            color: isExpired
                                ? AppColors.slotOccupied
                                : AppColors.slotOccupied,
                            fontFeatures: const [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fade(duration: 400.ms),

            const Spacer(),

            // Broadcast icon
            Column(
              children: [
                Icon(
                  Icons.sensors,
                  color: AppColors.primaryContainer,
                  size: 32,
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.4, end: 1.0, duration: 1200.ms),
                const SizedBox(height: 8),
                Text(
                  'Keep this screen open while approaching the gate.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate(delay: 400.ms).fade(duration: 400.ms),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
