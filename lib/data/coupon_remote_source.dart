import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/coupon.dart';

class CouponRemoteSource {
  /* =========================
     CONFIG
     ========================= */

  // 🔁 Replace with YOUR backend URL
  static const String _baseUrl =
      'https://api.yourdomain.com/coupons';

  static const Duration _timeout =
      Duration(seconds: 8);

  /* =========================
     PUBLIC API
     ========================= */

  /// 🔥 Fetch all coupons from backend
  static Future<List<Coupon>> fetchCoupons() async {
    try {
      final uri = Uri.parse(_baseUrl);

      final response = await http
          .get(
            uri,
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw HttpException(
          'Bad response: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw const FormatException('Invalid API format');
      }

      return _parseCoupons(decoded);
    } catch (e) {
      // ❌ NEVER crash UI due to backend
      return [];
    }
  }

  /// 🔮 Context-aware fetch (optional backend support)
  /// Example:
  /// /coupons?context=shopping_amazon
  static Future<List<Coupon>> fetchCouponsForContext(
    String context,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?context=$context',
      );

      final response = await http
          .get(
            uri,
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);

      if (decoded is! List) return [];

      return _parseCoupons(decoded);
    } catch (_) {
      return [];
    }
  }

  /* =========================
     PARSING + SAFETY
     ========================= */

  static List<Coupon> _parseCoupons(List raw) {
    final seenCodes = <String>{};
    final List<Coupon> result = [];

    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;

      try {
        final coupon = Coupon.fromJson(item);
        final key = coupon.code.toLowerCase().trim();

        if (key.isEmpty) continue;
        if (seenCodes.contains(key)) continue;

        seenCodes.add(key);
        result.add(coupon);
      } catch (_) {
        // skip bad records silently
      }
    }

    return result;
  }

  /* =========================
     HEADERS
     ========================= */

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',

        // 🔐 Optional
        // 'Authorization': 'Bearer YOUR_TOKEN',
      };
}