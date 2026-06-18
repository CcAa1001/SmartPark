import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/parking/parking_detail_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/booking/booking_confirm_screen.dart';
import '../../features/booking/my_bookings_screen.dart';
import '../../features/gate/gate_access_screen.dart';
import '../../features/alerts/alerts_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/parking_history_screen.dart';
import '../../features/profile/payment_methods_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/main_shell.dart';
import '../../features/admin/admin_simulator_screen.dart';
import '../../data/models/models.dart';

final _rootNavKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/parking/:id',
      builder: (context, state) {
        final locationId = state.pathParameters['id']!;
        return ParkingDetailScreen(locationId: locationId);
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) {
        final locationId = state.pathParameters['id']!;
        final slotId = state.uri.queryParameters['slot'];
        return BookingScreen(locationId: locationId, slotId: slotId);
      },
    ),
    GoRoute(
      path: '/booking-confirm',
      builder: (context, state) {
        final booking = state.extra as Booking;
        return BookingConfirmScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/gate-access',
      builder: (context, state) {
        final booking = state.extra as Booking;
        return GateAccessScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/my-bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/parking-history',
      builder: (context, state) => const ParkingHistoryScreen(),
    ),
    GoRoute(
      path: '/payment-methods',
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/admin-simulator',
      builder: (context, state) => const AdminSimulatorScreen(),
    ),
  ],
);
