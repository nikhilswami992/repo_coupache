import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coupon.dart';

class CouponRepository {
  static const String _storageKey = 'coupons';

  /* =========================
     PUBLIC API (UI USES THIS)
     ========================= */

  /// 🔥 SINGLE SOURCE OF TRUTH
  /// - Load saved coupons
  /// - Remove expired
  /// - Sort by urgency
  static Future<List<Coupon>> getCoupons() async {
    final localCoupons = await _getLocalCoupons();

    final cleaned = _removeExpired(localCoupons);
    final sorted = _sortCoupons(cleaned);

    await _saveCoupons(sorted);
    return sorted;
  }

  /// ➕ Add user-saved coupon
  static Future<List<Coupon>> addCoupon(
    List<Coupon> existing,
    Coupon newCoupon,
  ) async {
    final updated = _mergeCoupons(
      existing: existing,
      newCoupon: newCoupon,
    );

    final sorted = _sortCoupons(updated);
    await _saveCoupons(sorted);
    return sorted;
  }

  /// ❌ Delete coupon
  static Future<List<Coupon>> deleteCoupon(
    List<Coupon> existing,
    Coupon coupon,
  ) async {
    final updated = existing
        .where((c) =>
            c.code.toLowerCase() != coupon.code.toLowerCase())
        .toList();

    await _saveCoupons(updated);
    return updated;
  }

  /* =========================
     LOCAL STORAGE
     ========================= */

  static Future<List<Coupon>> _getLocalCoupons() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) return [];

    try {
      final List decoded = jsonDecode(raw);
      return decoded
          .map((e) => Coupon.fromJson(e))
          .where((c) => c.code.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveCoupons(
    List<Coupon> coupons,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(coupons.map((c) => c.toJson()).toList()),
    );
  }

  /* =========================
     HELPERS
     ========================= */

  /// 🧠 Code = unique ID
  static List<Coupon> _mergeCoupons({
    required List<Coupon> existing,
    required Coupon newCoupon,
  }) {
    final Map<String, Coupon> map = {
      for (final c in existing)
        c.code.toLowerCase().trim(): c,
    };

    final key = newCoupon.code.toLowerCase().trim();
    if (key.isNotEmpty) {
      map[key] = newCoupon;
    }

    return map.values.toList();
  }

  static List<Coupon> _removeExpired(
    List<Coupon> coupons,
  ) {
    return coupons.where((c) => !c.isExpired).toList();
  }

  static List<Coupon> _sortCoupons(
    List<Coupon> coupons,
  ) {
    coupons.sort((a, b) {
      // 1️⃣ Expiry urgency
      final d = a.daysLeft.compareTo(b.daysLeft);
      if (d != 0) return d;

      // 2️⃣ Brand name (stable UI)
      return a.brand.compareTo(b.brand);
    });

    return coupons;
  }
}