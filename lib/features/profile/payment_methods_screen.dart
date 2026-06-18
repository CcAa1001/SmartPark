import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text('Payment Methods',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your Methods', style: AppTextStyles.headlineSm),
          const SizedBox(height: 12),
          _PaymentCard(
            icon: Icons.school_outlined,
            title: 'Student Account (Default)',
            subtitle: 'Free parking up to 4 hours daily',
            isDefault: true,
          ),
          const SizedBox(height: 12),
          _PaymentCard(
            icon: Icons.credit_card_outlined,
            title: 'Credit Card',
            subtitle: '**** **** **** 4242 · Visa',
            isDefault: false,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: AppColors.primaryContainer),
            label: Text('Add Payment Method',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.primaryContainer)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryContainer),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryFixed.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'As a student, parking is free up to 4 hours per day. Premium membership extends this to 8 hours.',
                    style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onPrimaryFixed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;

  const _PaymentCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault
              ? AppColors.primaryContainer.withOpacity(0.5)
              : AppColors.outlineVariant.withOpacity(0.3),
          width: isDefault ? 1.5 : 1,
        ),
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
              color: isDefault
                  ? AppColors.primaryFixed
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isDefault
                    ? AppColors.primaryContainer
                    : AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLg),
                Text(subtitle,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('Default',
                  style: AppTextStyles.labelMd
                      .copyWith(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
