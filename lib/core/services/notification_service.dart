import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:timezone/timezone.dart' as tz;

/// Local notification service for payment reminders and alerts
class NotificationService {
  // Temporarily disabled due to build issues
  // static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> initialize() async {
    // Temporarily disabled - will be re-enabled once flutter_local_notifications is fixed
    print('NotificationService: Temporarily disabled');
    return;
    
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );

    // const initializationSettings = InitializationSettings(
    //   android: androidSettings,
    //   iOS: iosSettings,
    // );

    // await _notificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: _onNotificationTapped,
    // );

    // // Request permissions
    // await _requestPermissions();
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Show payment reminder notification
  Future<void> showPaymentReminder({
    required String customerName,
    required double amount,
  }) async {
    // Temporarily disabled
    print('Payment reminder: $customerName owes ₹${amount.toStringAsFixed(0)}');
    return;
  }

  /// Show payment received notification
  Future<void> showPaymentReceived({
    required String customerName,
    required double amount,
    required String transactionId,
  }) async {
    // Temporarily disabled
    print('Payment received: ₹${amount.toStringAsFixed(0)} from $customerName');
    return;
  }

  /// Schedule payment reminder
  Future<void> schedulePaymentReminder({
    required DateTime scheduledDate,
    required String customerName,
    required double amount,
    required String dueDate,
  }) async {
    // Temporarily disabled
    print('Scheduled reminder: $customerName payment of ₹${amount.toStringAsFixed(0)} due on $dueDate');
    return;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // Temporarily disabled
    print('All notifications cancelled');
    return;
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    // Temporarily disabled
    print('Notification $id cancelled');
    return;
  }

  /// Handle notification tap (temporarily disabled)
  static void _onNotificationTapped(dynamic response) {
    // Temporarily disabled
    print('Notification tapped: $response');
  }
}
