import 'package:flutter/services.dart';
import '../context/context_coupon_engine.dart';

class ForegroundAppListener {
  static const _channel =
      MethodChannel('app_foreground_channel');

  static void start() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAppChanged') {
        final packageName = call.arguments as String?;
        if (packageName != null) {
          ContextCouponEngine.handleForegroundApp(
            packageName,
          );
        }
      }
    });
  }
}
