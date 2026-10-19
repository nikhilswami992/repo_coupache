import '../repositories/coupon_repository.dart';
import '../services/notification_service.dart';
import '../context/app_context_resolver.dart';
import '../models/coupon.dart';

class ContextCouponEngine {
  /// 🔥 Called when foreground app changes
  static Future<void> handleForegroundApp(
    String packageName,
  ) async {
    print('🔥 Engine triggered for: $packageName');

    // 1️⃣ Resolve EXACT brand from package
    final brand =
        AppContextResolver.brandFromPackage(packageName);

    print('🏷️ Resolved brand: $brand');

    if (brand == null) return;

    // 2️⃣ Fetch ONLY user-saved coupons
    final List<Coupon> coupons =
        await CouponRepository.getCoupons();

    print('🎟️ Coupons count: ${coupons.length}');

    if (coupons.isEmpty) return;

    // 3️⃣ Find coupons matching this brand
    Coupon? match;
    for (final c in coupons) {
      if (c.brand.toLowerCase().contains(brand)) {
        match = c;
        break;
      }
    }

    if (match == null) {
      print('❌ No coupon found for $brand');
      return;
    }

    // 4️⃣ Fire notification
    await NotificationService.showContextNotification(
      context: brand,
      title: 'You have a $brand coupon 🎉',
      code: match.code,
    );

    print('🔔 Notification fired for $brand');
  }
}
