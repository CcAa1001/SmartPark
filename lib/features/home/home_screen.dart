import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/parking_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthRepository>(context, listen: false);
    final parkingRepo = Provider.of<ParkingRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserModel?>(
        stream: authRepo.onAuthStateChanged,
        builder: (context, userSnapshot) {
          final user = userSnapshot.data ?? authRepo.currentUser ?? MockData.currentUser;
          
          return StreamBuilder<List<ParkingLocation>>(
            stream: parkingRepo.watchLocations(),
            builder: (context, locationsSnapshot) {
              if (locationsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final locations = locationsSnapshot.data ?? [];
              
              final hour = DateTime.now().hour;
              final greeting = hour < 12
                  ? 'Good morning'
                  : hour < 17
                      ? 'Good afternoon'
                      : 'Good evening';

              return SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        Text(
                          'CampusPark',
                          style: AppTextStyles.headlineMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
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

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${user.name.split(' ').first}',
                      style: AppTextStyles.headlineLg,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is the current parking status on campus.',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0),
            ),

            // Live Status Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LiveStatusCard(locations: locations),
              ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Weather Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _WeatherCard(),
              ).animate(delay: 150.ms).fade(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Nearby Parking Areas header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nearby Parking Areas',
                        style: AppTextStyles.headlineSm),
                    GestureDetector(
                      onTap: () => context.go('/map'),
                      child: Row(
                        children: [
                          Text(
                            'View Map',
                            style: AppTextStyles.labelLg
                                .copyWith(color: AppColors.primary),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fade(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Lot tiles
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final loc = locations[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: _LotTile(location: loc),
                  ).animate(delay: Duration(milliseconds: 250 + index * 80))
                      .fade(duration: 400.ms)
                      .slideX(begin: 0.1, end: 0);
                },
                childCount: locations.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
    },
  );
    },
  ),
);
  }
}

class _LiveStatusCard extends StatelessWidget {
  final List<ParkingLocation> locations;
  const _LiveStatusCard({required this.locations});

  @override
  Widget build(BuildContext context) {
    int totalAvailable = 0;
    int totalCapacity = 0;
    for (final loc in locations) {
      totalAvailable += loc.availableSlots;
      totalCapacity += loc.totalSlots;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live Status',
                style: AppTextStyles.labelMd.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              const Icon(Icons.info_outline, color: Colors.white70, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$totalAvailable',
            style: AppTextStyles.dataDisplay.copyWith(
              color: Colors.white,
              fontSize: 48,
              height: 1,
            ),
          ),
          Text(
            'Spots Available Campus-wide',
            style: AppTextStyles.bodyLg.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusStat(
                label: 'Total Capacity',
                value: '$totalCapacity',
              ),
              Container(
                  width: 1, height: 40, color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 20)),
              const _StatusStat(
                label: 'Peak Hours',
                value: '08:00 – 11:00',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusStat extends StatelessWidget {
  final String label;
  final String value;
  const _StatusStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.labelMd.copyWith(color: Colors.white60)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Campus Weather',
                      style: AppTextStyles.labelLg
                          .copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '24°',
                        style: AppTextStyles.headlineLg.copyWith(
                            color: AppColors.onSurface, fontSize: 28),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mostly Sunny',
                                style: AppTextStyles.bodyMd),
                            Text('Good driving conditions',
                                style: AppTextStyles.labelMd),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny_outlined,
                  color: AppColors.onSurfaceVariant, size: 36),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.directions_car_outlined,
                  size: 16, color: AppColors.primary),
              label: Text(
                'Navigate to Campus',
                style: AppTextStyles.labelLg
                    .copyWith(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryFixed),
                backgroundColor: AppColors.primaryFixed.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LotTile extends StatelessWidget {
  final ParkingLocation location;
  const _LotTile({required this.location});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/parking/${location.id}'),
      child: Container(
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
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_parking_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.name, style: AppTextStyles.labelLg),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.outline),
                          const SizedBox(width: 2),
                          Text(location.distance,
                              style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${location.availableSlots}',
                      style: AppTextStyles.headlineSm.copyWith(
                          color: location.availabilityColor),
                    ),
                    Text('available',
                        style: AppTextStyles.labelMd
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value:
                    (location.totalSlots - location.availableSlots) /
                        location.totalSlots,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(location.availabilityColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  location.availabilityLabel,
                  style: AppTextStyles.labelMd
                      .copyWith(color: location.availabilityColor),
                ),
                Text(
                  '${location.totalSlots} total',
                  style: AppTextStyles.labelMd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
