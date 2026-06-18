import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/parking_repository.dart';

class AdminSimulatorScreen extends StatefulWidget {
  const AdminSimulatorScreen({super.key});

  @override
  State<AdminSimulatorScreen> createState() => _AdminSimulatorScreenState();
}

class _AdminSimulatorScreenState extends State<AdminSimulatorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isSimulating = false;
  double _intervalSeconds = 8.0;
  double _targetOccupancyRate = 0.65; // default 65% occupied
  Timer? _timer;
  
  final List<String> _logs = [];
  final ScrollController _logScrollController = ScrollController();

  @override
  void dispose() {
    _timer?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final timestamp = TimeOfDay.now().format(context);
    if (mounted) {
      setState(() {
        _logs.insert(0, '[$timestamp] $message');
      });
    }
  }

  void _toggleSimulation(bool value) {
    setState(() {
      _isSimulating = value;
    });
    if (_isSimulating) {
      _addLog('Occupancy Simulator Started.');
      _startTimer();
    } else {
      _addLog('Occupancy Simulator Stopped.');
      _timer?.cancel();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _intervalSeconds.toInt()), (timer) {
      _runSimulationStep();
    });
  }

  Future<void> _runSimulationStep() async {
    _addLog('Running simulation step...');
    try {
      // 1. Get all active bookings to avoid messing with user reservations
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .where('status', isEqualTo: 'active')
          .get();
      final activeSlotIds = bookingsSnapshot.docs.map((doc) => doc.data()['slotId'] as String).toSet();

      // 2. Fetch all locations and slots
      final locationsSnapshot = await _firestore.collection('locations').get();
      final slotsSnapshot = await _firestore.collection('parking_slots').get();

      if (locationsSnapshot.docs.isEmpty || slotsSnapshot.docs.isEmpty) {
        _addLog('No slots/locations found in database. Seed them first.');
        return;
      }

      final locations = locationsSnapshot.docs;
      final slots = slotsSnapshot.docs.map((doc) => ParkingSlot.fromFirestore(doc.data())).toList();

      final random = Random();
      int changesCount = 0;
      final Set<String> affectedLocationIds = {};

      final batch = _firestore.batch();

      // Group slots by location
      for (final locDoc in locations) {
        final locId = locDoc.id;
        final locSlots = slots.where((s) => s.locationId == locId).toList();
        if (locSlots.isEmpty) continue;

        final occupiedCount = locSlots.where((s) => s.status == SlotStatus.occupied).length;
        final currentOccupancy = occupiedCount / locSlots.length;

        // If occupancy is below target, we change some available spots to occupied
        if (currentOccupancy < _targetOccupancyRate) {
          final spotsToFill = ((_targetOccupancyRate - currentOccupancy) * locSlots.length).round();
          final availableSlots = locSlots.where((s) => s.status == SlotStatus.available && !activeSlotIds.contains(s.id)).toList();
          
          if (availableSlots.isNotEmpty) {
            availableSlots.shuffle(random);
            final count = min(spotsToFill, availableSlots.length);
            for (int i = 0; i < count; i++) {
              final slot = availableSlots[i];
              batch.update(_firestore.collection('parking_slots').doc(slot.id), {'status': SlotStatus.occupied.name});
              changesCount++;
              affectedLocationIds.add(locId);
            }
          }
        } 
        // If occupancy is above target, we change some occupied spots back to available
        else if (currentOccupancy > _targetOccupancyRate) {
          final spotsToFree = ((currentOccupancy - _targetOccupancyRate) * locSlots.length).round();
          final occupiedSlots = locSlots.where((s) => s.status == SlotStatus.occupied && !activeSlotIds.contains(s.id)).toList();
          
          if (occupiedSlots.isNotEmpty) {
            occupiedSlots.shuffle(random);
            final count = min(spotsToFree, occupiedSlots.length);
            for (int i = 0; i < count; i++) {
              final slot = occupiedSlots[i];
              batch.update(_firestore.collection('parking_slots').doc(slot.id), {'status': SlotStatus.available.name});
              changesCount++;
              affectedLocationIds.add(locId);
            }
          }
        }
      }

      if (changesCount > 0) {
        await batch.commit();
        _addLog('Simulated changes on $changesCount spots.');

        // Recalculate totals for affected locations
        for (final locId in affectedLocationIds) {
          final freshSlotsSnap = await _firestore
              .collection('parking_slots')
              .where('locationId', isEqualTo: locId)
              .get();
          final freshSlots = freshSlotsSnap.docs.map((doc) => ParkingSlot.fromFirestore(doc.data())).toList();

          int available = 0;
          int booked = 0;
          int occupied = 0;
          for (final slot in freshSlots) {
            if (slot.status == SlotStatus.available) available++;
            if (slot.status == SlotStatus.booked) booked++;
            if (slot.status == SlotStatus.occupied) occupied++;
          }

          await _firestore.collection('locations').doc(locId).update({
            'availableSlots': available,
            'bookedSlots': booked,
            'occupiedSlots': occupied,
          });
        }
        _addLog('Updated database occupancy totals.');
      } else {
        _addLog('Occupancy matches targets. No changes.');
      }
    } catch (e) {
      _addLog('Error in simulator: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingRepo = Provider.of<ParkingRepository>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Occupancy Simulator',
            style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
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
                          Text('Auto-Simulation Mode', style: AppTextStyles.labelLg),
                          Text(
                            _isSimulating ? 'Active (Running...)' : 'Idle',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: _isSimulating ? AppColors.slotAvailable : AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isSimulating,
                        onChanged: _toggleSimulation,
                        activeColor: AppColors.slotAvailable,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Speed slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Interval Speed', style: AppTextStyles.labelMd),
                          Text('${_intervalSeconds.toInt()} seconds', style: AppTextStyles.labelLg),
                        ],
                      ),
                      Slider(
                        value: _intervalSeconds,
                        min: 3.0,
                        max: 30.0,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceContainer,
                        onChanged: _isSimulating
                            ? null
                            : (val) {
                                setState(() => _intervalSeconds = val);
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Target Occupancy Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Target Occupancy Rate', style: AppTextStyles.labelMd),
                          Text('${(_targetOccupancyRate * 100).toInt()}%', style: AppTextStyles.labelLg),
                        ],
                      ),
                      Slider(
                        value: _targetOccupancyRate,
                        min: 0.1,
                        max: 0.9,
                        divisions: 8,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.surfaceContainer,
                        onChanged: (val) {
                          setState(() => _targetOccupancyRate = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSimulating ? null : _runSimulationStep,
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text('Trigger Single Step', style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms),

            const SizedBox(height: 20),

            // Live Location Status
            Text('Live Database Status', style: AppTextStyles.headlineSm),
            const SizedBox(height: 10),
            StreamBuilder<List<ParkingLocation>>(
              stream: parkingRepo.watchLocations(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final locations = snapshot.data!;
                return Column(
                  children: locations.map((loc) {
                    final occupancyPercent = ((loc.totalSlots - loc.availableSlots) / loc.totalSlots * 100).toInt();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.local_parking, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.name, style: AppTextStyles.labelLg),
                                  Text('${loc.availableSlots} / ${loc.totalSlots} available', style: AppTextStyles.labelMd),
                                ],
                              ),
                            ),
                            Text('$occupancyPercent% Full', style: AppTextStyles.labelLg.copyWith(color: loc.availabilityColor)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            // Simulation Logs
            Text('Simulation Logs', style: AppTextStyles.headlineSm),
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              ),
              child: _logs.isEmpty
                  ? Center(child: Text('No log entries yet.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline)))
                  : ListView.builder(
                      controller: _logScrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[index],
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
