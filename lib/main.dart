import 'package:flutter/material.dart';

import 'services/notification_service.dart';
import 'services/app_foreground_listener.dart';
import 'context/app_launch_context.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init(
    onNotificationTap: (payload) {
      if (payload != null) {
        AppLaunchContext.set(payload);
      }
    },
  );

  // 🔥 THIS is what actually starts detection
  AppForegroundListener.start();

  runApp(const CouponReminderApp());
}

class CouponReminderApp extends StatelessWidget {
  const CouponReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coupon Reminder',
      theme: CouponAppTheme.lightTheme,
      darkTheme: CouponAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
