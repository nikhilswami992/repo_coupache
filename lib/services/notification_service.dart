import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _plugin = FlutterLocalNotificationsPlugin();

  /* -------------------- CHANNEL IDS -------------------- */

  static const String _couponChannelId = 'coupon_channel';
  static const String _contextChannelId = 'context_channel';

  /* -------------------- INIT -------------------- */

  static Future<void> init({
    required Function(String? payload) onNotificationTap,
  }) async {
    // 🌍 Required for scheduled notifications
    tz.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
        InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap(response.payload);
      },
    );

    await _createChannels();
  }

  /* -------------------- CHANNEL SETUP -------------------- */

  static Future<void> _createChannels() async {
    const couponChannel = AndroidNotificationChannel(
      _couponChannelId,
      'Coupon Reminders',
      description: 'Coupon expiry reminders',
      importance: Importance.high,
    );

    const contextChannel = AndroidNotificationChannel(
      _contextChannelId,
      'Smart Coupon Alerts',
      description: 'Context-aware coupon notifications',
      importance: Importance.high,
    );

    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(couponChannel);
    await android?.createNotificationChannel(contextChannel);
  }

  /* -------------------- SCHEDULED EXPIRY REMINDERS -------------------- */

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _couponChannelId,
        'Coupon Reminders',
        channelDescription: 'Coupon expiry reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final tzDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /* -------------------- CONTEXT-AWARE ALERT -------------------- */

  /// Fired by ContextCouponEngine
  static Future<void> showContextNotification({
    required String context, // shopping_amazon, food_ordering
    required String title,
    required String code,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _contextChannelId,
        'Smart Coupon Alerts',
        channelDescription: 'Context-aware coupon notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      999, // single active smart alert
      title,
      'Use code $code before checkout 💸',
      details,
      payload: context, // 🔥 consumed by AppLaunchContext
    );
  }

  /* -------------------- CANCEL -------------------- */

  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}