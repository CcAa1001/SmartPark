import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _expiryReminders = true;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Notifications'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive real-time parking alerts',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              const Divider(height: 1, color: Color(0x1AC3C6D7)),
              _SwitchTile(
                icon: Icons.email_outlined,
                title: 'Email Alerts',
                subtitle: 'Get booking summaries via email',
                value: _emailAlerts,
                onChanged: (v) => setState(() => _emailAlerts = v),
              ),
              const Divider(height: 1, color: Color(0x1AC3C6D7)),
              _SwitchTile(
                icon: Icons.timer_outlined,
                title: 'Expiry Reminders',
                subtitle: 'Alert 15 min before slot expires',
                value: _expiryReminders,
                onChanged: (v) => setState(() => _expiryReminders = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Privacy & Location'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Location Services',
                subtitle: 'Used to find nearby parking',
                value: _locationServices,
                onChanged: (v) => setState(() => _locationServices = v),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Account'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _ActionTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0x1AC3C6D7)),
              _ActionTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                titleColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('Developer Options'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _ActionTile(
                icon: Icons.developer_mode,
                title: 'Occupancy Simulator Panel',
                onTap: () => context.push('/admin-simulator'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionHeader('About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _InfoTile(label: 'App Version', value: '1.0.0'),
              const Divider(height: 1, color: Color(0x1AC3C6D7)),
              _InfoTile(
                  label: 'Universitas Internasional Batam',
                  value: 'Batam, Indonesia'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This action cannot be undone. Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: AppTextStyles.labelMd.copyWith(
          color: AppColors.onSurfaceVariant, letterSpacing: 0.8));
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLg),
                  Text(subtitle,
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryContainer,
            ),
          ],
        ),
      );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.titleColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon,
                    color: iconColor ?? AppColors.onSurfaceVariant,
                    size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: AppTextStyles.bodyLg.copyWith(
                          color: titleColor ?? AppColors.onSurface)),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.outline, size: 20),
              ],
            ),
          ),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyLg),
            Text(value,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
}
