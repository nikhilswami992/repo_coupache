import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'context_coupon_engine.dart';

class ForegroundAppService {
  static String? _lastPackage;

  static void start() {
    Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final end = DateTime.now();
        final start = end.subtract(const Duration(seconds: 5));

        final infoList =
            await AppUsage().getAppUsage(start, end);

        if (infoList.isEmpty) return;

        infoList.sort(
          (a, b) => b.usage.compareTo(a.usage),
        );

        final currentPackage = infoList.first.packageName;

        if (_lastPackage == currentPackage) return;

        _lastPackage = currentPackage;

        // 🔥 THIS FINALLY TRIGGERS YOUR LOGIC
        await ContextCouponEngine.handleForegroundApp(
          currentPackage,
        );
      } catch (_) {}
    });
  }
}
