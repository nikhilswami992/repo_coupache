import '../models/coupon.dart';

class CouponRanker {
  /// 🎯 Returns the SINGLE best coupon for a given context
  /// Used for:
  /// - Smart notifications
  /// - Best Pick highlighting
  static Coupon? pickBest({
    required List<Coupon> coupons,
    String? contextBrand, // e.g. amazon, zomato
  }) {
    if (coupons.isEmpty) return null;

    // 1️⃣ Remove expired or useless coupons
    final validCoupons = coupons.where((c) {
      return !c.isExpired && c.code.isNotEmpty;
    }).toList();

    if (validCoupons.isEmpty) return null;

    // 2️⃣ Score each coupon
    final scored = validCoupons.map((coupon) {
      return _ScoredCoupon(
        coupon: coupon,
        score: _scoreCoupon(
          coupon: coupon,
          contextBrand: contextBrand,
        ),
      );
    }).toList();

    // 3️⃣ Sort by highest score
    scored.sort((a, b) => b.score.compareTo(a.score));

    // 4️⃣ Safety check (don’t fire useless alerts)
    if (scored.first.score < 20) {
      return null; // 👈 prevents bad notifications
    }

    return scored.first.coupon;
  }

  /* -------------------- SCORING LOGIC -------------------- */

  static int _scoreCoupon({
    required Coupon coupon,
    String? contextBrand,
  }) {
    int score = 0;

    final brand = coupon.brand.toLowerCase();
    final category = coupon.category.toLowerCase();

    /* 🎯 CONTEXT MATCH (MOST IMPORTANT) */
    if (contextBrand != null &&
        brand.contains(contextBrand.toLowerCase())) {
      score += 60;
    }

    /* ⏳ EXPIRY URGENCY */
    if (coupon.daysLeft <= 0) {
      return -100; // already expired safeguard
    } else if (coupon.daysLeft <= 1) {
      score += 35;
    } else if (coupon.daysLeft <= 3) {
      score += 20;
    } else if (coupon.daysLeft <= 7) {
      score += 10;
    }

    /* 🏷 CATEGORY PRIORITY */
    if (category == 'shopping') score += 5;
    if (category == 'food') score += 5;

    /* 🧠 BRAND QUALITY BOOST (OPTIONAL, SAFE) */
    if (_trustedBrands.contains(brand)) {
      score += 5;
    }

    return score;
  }
}

/* -------------------- INTERNAL MODELS -------------------- */

class _ScoredCoupon {
  final Coupon coupon;
  final int score;

  _ScoredCoupon({
    required this.coupon,
    required this.score,
  });
}

/* -------------------- TRUSTED BRANDS -------------------- */

const Set<String> _trustedBrands = {
  'amazon',
  'flipkart',
  'zomato',
  'swiggy',
  'myntra',
};