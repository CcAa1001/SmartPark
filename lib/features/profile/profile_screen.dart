import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserModel?>(
        stream: authRepo.onAuthStateChanged,
        builder: (context, snapshot) {
          final user = snapshot.data ?? authRepo.currentUser ?? MockData.currentUser;

          return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // App Bar
              Padding(
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

              // Profile Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
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
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Text(
                        user.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: AppTextStyles.headlineLg.copyWith(
                          color: AppColors.primaryContainer,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: AppTextStyles.headlineMd),
                    const SizedBox(height: 4),
                    Text('Student ID: ${user.studentId}',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    if (user.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded,
                                color: AppColors.primaryContainer, size: 14),
                            const SizedBox(width: 4),
                            Text('Premium Member',
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.primaryContainer,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 20),

              // Registered Vehicle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registered Vehicle',
                        style: AppTextStyles.headlineSm),
                    const SizedBox(height: 10),
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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.directions_car_outlined,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.vehiclePlate,
                                    style: AppTextStyles.labelLg),
                                Text(
                                    '${user.vehicleModel} · ${user.vehicleColor}',
                                    style: AppTextStyles.bodyMd.copyWith(
                                        color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.primary, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fade(duration: 400.ms),

              const SizedBox(height: 20),

              // Account Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Options', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 10),
                    Container(
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
                        children: [
                          _OptionTile(
                            icon: Icons.history_rounded,
                            label: 'Parking History',
                            onTap: () => context.push('/parking-history'),
                          ),
                          const Divider(
                              height: 1, color: Color(0x1AC3C6D7),
                              indent: 16, endIndent: 16),
                          _OptionTile(
                            icon: Icons.credit_card_outlined,
                            label: 'Payment Methods',
                            onTap: () => context.push('/payment-methods'),
                          ),
                          const Divider(
                              height: 1, color: Color(0x1AC3C6D7),
                              indent: 16, endIndent: 16),
                          _OptionTile(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () => context.push('/settings'),
                          ),
                          const Divider(
                              height: 1, color: Color(0x1AC3C6D7),
                              indent: 16, endIndent: 16),
                          _OptionTile(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            labelColor: AppColors.error,
                            iconColor: AppColors.error,
                            showChevron: false,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fade(duration: 400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    },
  ),
);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authRepo = Provider.of<AuthRepository>(context, listen: false);
              await authRepo.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon,
                  color: iconColor ?? AppColors.onSurfaceVariant, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyLg
                        .copyWith(color: labelColor ?? AppColors.onSurface)),
              ),
              if (showChevron)
                const Icon(Icons.chevron_right,
                    color: AppColors.outline, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
