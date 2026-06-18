import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/alerts_repository.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final alertsRepo = Provider.of<AlertsRepository>(context, listen: false);
    final userId = authRepo.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<ParkingAlert>>(
          stream: alertsRepo.watchAlerts(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            final alerts = snapshot.data ?? [];
            final today = alerts
                .where((a) => DateTime.now().difference(a.timestamp).inHours < 24)
                .toList();
            final yesterday = alerts
                .where((a) =>
                    DateTime.now().difference(a.timestamp).inHours >= 24 &&
                    DateTime.now().difference(a.timestamp).inHours < 48)
                .toList();
            final older = alerts
                .where((a) => DateTime.now().difference(a.timestamp).inHours >= 48)
                .toList();

            if (alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppColors.outlineVariant),
                    const SizedBox(height: 16),
                    Text('No alerts yet',
                        style: AppTextStyles.headlineSm.copyWith(
                            color: AppColors.onSurfaceVariant)),
                    Text('You will receive updates here.',
                        style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.outline)),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_parking_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('CampusPark',
                            style: AppTextStyles.headlineMd
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.primary),
                      onPressed: () => context.go('/settings'),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Alerts',
                        style: AppTextStyles.headlineLg),
                    const SizedBox(height: 4),
                    Text(
                      'Stay updated on your parking and campus status.',
                      style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ).animate().fade(duration: 400.ms),
            ),

            if (today.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('TODAY',
                      style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.2)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _AlertTile(alert: today[index]),
                  ).animate(delay: Duration(milliseconds: 50 + index * 80))
                      .fade(duration: 400.ms)
                      .slideX(begin: 0.05, end: 0),
                  childCount: today.length,
                ),
              ),
            ],

            if (yesterday.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text('YESTERDAY',
                      style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.2)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _AlertTile(alert: yesterday[index]),
                  ),
                  childCount: yesterday.length,
                ),
              ),
            ],

            if (older.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text('EARLIER',
                      style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1.2)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _AlertTile(alert: older[index]),
                  ),
                  childCount: older.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    ),
  ),
);
  }
}

class _AlertTile extends StatelessWidget {
  final ParkingAlert alert;
  const _AlertTile({required this.alert});

  Color get _bgColor {
    switch (alert.type) {
      case AlertType.warning:
      case AlertType.error:
        return const Color(0xFFFFF3F3);
      case AlertType.success:
        return const Color(0xFFF0FAF5);
      case AlertType.info:
        return AppColors.surfaceContainerLow;
    }
  }

  Color get _iconColor {
    switch (alert.type) {
      case AlertType.warning:
      case AlertType.error:
        return AppColors.slotOccupied;
      case AlertType.success:
        return AppColors.slotAvailable;
      case AlertType.info:
        return AppColors.primary;
    }
  }

  IconData get _icon {
    switch (alert.type) {
      case AlertType.warning:
      case AlertType.error:
        return Icons.warning_rounded;
      case AlertType.success:
        return Icons.check_circle_rounded;
      case AlertType.info:
        return Icons.info_rounded;
    }
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return 'Yesterday';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(alert.title,
                          style: AppTextStyles.labelLg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(_timeLabel(alert.timestamp),
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (alert.actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alert.actionLabel!,
                          style: AppTextStyles.labelLg
                              .copyWith(color: AppColors.primary),
                        ),
                        const Icon(Icons.arrow_forward,
                            size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
