import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/models.dart';
import '../../data/repositories/parking_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedPinId;

  @override
  Widget build(BuildContext context) {
    final parkingRepo = Provider.of<ParkingRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ParkingLocation>>(
        stream: parkingRepo.watchLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final locations = snapshot.data ?? [];

          return Stack(
        children: [
          // Map background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE5E5F7),
            ),
            child: CustomPaint(
              painter: _MapGridPainter(),
              child: Container(),
            ),
          ),

          // Stylized campus map image overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/sporthall_map.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search,
                        color: AppColors.onSurfaceVariant),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search lots, buildings, or zones...',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant
                                .withOpacity(0.7)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainer,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: -0.2, end: 0),
          ),

          // Parking Pins
          ...locations.map((loc) {
            return Positioned(
              left: MediaQuery.of(context).size.width * loc.mapLeft - 24,
              top: MediaQuery.of(context).size.height * loc.mapTop - 24,
              child: _ParkingPin(
                location: loc,
                isSelected: _selectedPinId == loc.id,
                onTap: () {
                  setState(() => _selectedPinId = loc.id);
                  context.push('/parking/${loc.id}');
                },
              ).animate(
                delay: Duration(
                    milliseconds: 300 + locations.indexOf(loc) * 150),
              ).scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
                duration: 600.ms,
              ),
            );
          }),

          // Legend card
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Availability Status',
                      style: AppTextStyles.headlineSm),
                  const SizedBox(height: 10),
                  _LegendRow(
                      color: AppColors.pinHigh, label: 'High (>50 spots)'),
                  const SizedBox(height: 6),
                  _LegendRow(
                      color: AppColors.pinMedium,
                      label: 'Medium (10-50 spots)'),
                  const SizedBox(height: 6),
                  _LegendRow(
                      color: AppColors.pinLow, label: 'Low (<10 spots)'),
                ],
              ),
            ).animate(delay: 600.ms).fade(duration: 400.ms).slideY(begin: 0.2),
          ),

          // My car FAB
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => context.push('/my-bookings'),
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.white, size: 28),
            ).animate(delay: 700.ms).scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
          ),
        ],
      );
        },
      ),
    );
  }
}

class _ParkingPin extends StatelessWidget {
  final ParkingLocation location;
  final bool isSelected;
  final VoidCallback onTap;

  const _ParkingPin({
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  Color get _color {
    switch (location.availabilityLevel) {
      case AvailabilityLevel.high:
        return AppColors.pinHigh;
      case AvailabilityLevel.medium:
        return AppColors.pinMedium;
      case AvailabilityLevel.low:
        return AppColors.pinLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_parking_rounded,
                    color: Colors.white, size: 22),
              ),
              // Tooltip
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(location.name,
                          style: AppTextStyles.labelLg
                              .copyWith(fontSize: 11)),
                      Text('${location.availableSlots} spots',
                          style: AppTextStyles.bodyMd
                              .copyWith(fontSize: 10,
                                  color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE0E3E5).withOpacity(0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
