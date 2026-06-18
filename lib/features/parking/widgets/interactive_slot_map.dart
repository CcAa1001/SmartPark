import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';

class InteractiveSlotMap extends StatefulWidget {
  final ParkingLocation location;
  final List<ParkingSlot> slots;
  final Function(ParkingSlot) onSlotTap;
  final ParkingSlot? selectedSlot;

  const InteractiveSlotMap({
    super.key,
    required this.location,
    required this.slots,
    required this.onSlotTap,
    this.selectedSlot,
  });

  @override
  State<InteractiveSlotMap> createState() => _InteractiveSlotMapState();
}

class _InteractiveSlotMapState extends State<InteractiveSlotMap> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Color _getSlotColor(SlotStatus status, bool isSelected) {
    if (isSelected) return AppColors.primary;
    switch (status) {
      case SlotStatus.available:
        return const Color(0xFF10B981).withValues(alpha: 0.8);
      case SlotStatus.booked:
        return const Color(0xFFF59E0B).withValues(alpha: 0.8);
      case SlotStatus.occupied:
        return const Color(0xFFEF4444).withValues(alpha: 0.8);
    }
  }

  void _handleDoubleTap() {
    if (_transformController.value.getMaxScaleOnAxis() > 1.5) {
      // Zoom out
      _transformController.value = Matrix4.identity();
    } else {
      // Zoom in
      _transformController.value = Matrix4.identity()..scale(2.5, 2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 1.0,
          maxScale: 4.0,
          panEnabled: true,
          scaleEnabled: true,
          constrained: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Assume map is roughly square or base layout on width
              final height = width; 

              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    // Background Map Image
                    Positioned.fill(
                      child: Image.asset(
                      widget.location.mapAsset,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(
                          child: Icon(Icons.map_outlined, color: AppColors.outline, size: 48),
                        ),
                      ),
                    ),
                  ),
                  
                  // Slots Overlay
                  ...widget.slots.map((slot) {
                    final isSelected = widget.selectedSlot?.id == slot.id;
                    return Positioned(
                      left: slot.x * width,
                      top: slot.y * height,
                      width: slot.width * width,
                      height: slot.height * height,
                      child: GestureDetector(
                        onTap: () => widget.onSlotTap(slot),
                        child: Transform.rotate(
                          angle: slot.angle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: _getSlotColor(slot.status, isSelected),
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ] : null,
                            ),
                            child: isSelected 
                                ? const Center(
                                    child: Icon(Icons.check, color: Colors.white, size: 12),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}
