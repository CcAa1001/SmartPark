import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(settings);
    
    // Initialize timezone database for scheduling
    tz.initializeTimeZones();
  }

  static Future<void> scheduleBookingExpiryNotification({
    required String bookingId,
    required String locationName,
    required String slotNumber,
    required DateTime expiryTime,
  }) async {
    // Notify 15 minutes before expiry
    final notifyTime = expiryTime.subtract(const Duration(minutes: 15));
    final now = DateTime.now();

    if (notifyTime.isBefore(now)) {
      // Expiry is in less than 15 minutes, notify immediately
      await _showImmediateWarning(bookingId, locationName, slotNumber);
      return;
    }

    final int notificationId = bookingId.hashCode;

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Parking session ending soon',
      'Your session at $locationName ($slotNumber) ends in 15 minutes.',
      tz.TZDateTime.from(notifyTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_expiry_channel',
          'Parking Expiry Warnings',
          channelDescription: 'Alerts when your reserved slot session is close to expiring',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> _showImmediateWarning(
      String bookingId, String locationName, String slotNumber) async {
    await _notificationsPlugin.show(
      bookingId.hashCode,
      'Parking session ending soon',
      'Your session at $locationName ($slotNumber) ends in less than 15 minutes.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'parking_expiry_channel',
          'Parking Expiry Warnings',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> cancelBookingNotification(String bookingId) async {
    await _notificationsPlugin.cancel(bookingId.hashCode);
  }
}
