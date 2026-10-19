import 'dart:async';
import 'package:flutter/services.dart';

import '../services/context_coupon_engine.dart';

class AppForegroundListener {
  static const MethodChannel _channel =
      MethodChannel('app_foreground_channel');

  static Timer? _timer;
  static String? _lastPackage;

  /// 🔥 Start listening for foreground app
  static void start() {
  _timer ??= Timer.periodic(
    const Duration(seconds: 3),
    (_) async {
      final String? packageName =
          await _channel.invokeMethod('getForegroundApp');

      debugPrint('🧪 Foreground result: $packageName');

      if (packageName == null) return;
      if (packageName == 'NO_USAGE_PERMISSION') {
        debugPrint('❌ Usage permission NOT granted');
        return;
      }

      if (packageName == _lastPackage) return;
      _lastPackage = packageName;

      await ContextCouponEngine.handleForegroundApp(packageName);
    },
  );
}


  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
