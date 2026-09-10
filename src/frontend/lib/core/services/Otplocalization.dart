import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'local_storage_service.dart';

class OtpService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String keyStoredOtp = 'stored_verification_otp';

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // Corrected: Pass initializationSettings positionally
    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Request notification permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    // Create required Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'secure_login_channel_v2',
      'Secure Login OTP',
      description: 'Notifications for login verification codes',
      importance: Importance.max,
    );

    await androidImplementation?.createNotificationChannel(channel);
  }

  static Future<String> generateAndSendOtp() async {
    final rng = Random();
    final otp = (100000 + rng.nextInt(900000)).toString();

    await LocalStorageService.saveString(keyStoredOtp, otp);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'secure_login_channel_v2',
      'Secure Login OTP',
      channelDescription: 'Notifications for login verification codes',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    // Corrected: Pass arguments positionally (id, title, body, notificationDetails)
    await _notificationsPlugin.show(
      id: DateTime.now().millisecond ~/ 1000,
      title: 'Medikisko Verification OTP',
      body: 'Your secure verification code is: $otp',
      notificationDetails: notificationDetails,
    );

    return otp;
  }

  static bool verifyOtp(String enteredOtp) {
    final storedOtp = LocalStorageService.getString(keyStoredOtp) ?? '';
    return storedOtp.isNotEmpty && storedOtp == enteredOtp;
  }
}