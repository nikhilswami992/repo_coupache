class AppLaunchContext {
  /// Holds the last context that opened the app
  /// Example values:
  /// - shopping_amazon
  /// - shopping_flipkart
  /// - food_ordering
  static String? _context;

  /* -------------------- SET -------------------- */

  static void set(String? context) {
    _context = context;
  }

  /* -------------------- GET -------------------- */

  static String? get() {
    return _context;
  }

  /* -------------------- CLEAR -------------------- */

  /// Call this AFTER navigation is done
  static void clear() {
    _context = null;
  }

  /* -------------------- HELPERS -------------------- */

  static bool get hasContext => _context != null;

  static bool isShopping() {
    return _context?.startsWith('shopping') ?? false;
  }

  static bool isFood() {
    return _context == 'food_ordering';
  }
}