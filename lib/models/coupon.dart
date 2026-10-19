class Coupon {
  final String title;
  final String code;
  final String expiryDate; // dd/MM/yyyy
  final String category;
  final String brand;

  const Coupon({
    required this.title,
    required this.code,
    required this.expiryDate,
    required this.category,
    required this.brand,
  });

  /* -------------------- JSON -------------------- */

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      title: (json['title'] ?? '').toString().trim(),
      code: (json['code'] ?? '').toString().trim(),
      expiryDate: (json['expiryDate'] ?? '').toString().trim(),
      category: (json['category'] ?? 'Other').toString().trim(),
      brand: (json['brand'] ?? 'Generic').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
      'expiryDate': expiryDate,
      'category': category,
      'brand': brand,
    };
  }

  /* -------------------- HELPERS -------------------- */

  DateTime? get expiryAsDate {
    try {
      final parts = expiryDate.split('/');
      if (parts.length != 3) return null;

      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }

  bool get isExpired {
    final date = expiryAsDate;
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  int get daysLeft {
    final date = expiryAsDate;
    if (date == null) return 0;
    return date.difference(DateTime.now()).inDays;
  }

  /* -------------------- EQUALITY -------------------- */
  /// Coupons are uniquely identified by `code`
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coupon &&
        other.code.toLowerCase() == code.toLowerCase();
  }

  @override
  int get hashCode => code.toLowerCase().hashCode;

  /* -------------------- DEBUG -------------------- */

  @override
  String toString() {
    return 'Coupon(code: $code, brand: $brand, expiry: $expiryDate)';
  }
}