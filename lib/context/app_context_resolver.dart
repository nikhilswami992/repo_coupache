import 'app_context.dart';

class AppContextResolver {
  /* =========================
     PACKAGE → BRAND MAP
     (ORDER MATTERS: longest first)
     ========================= */

  static const Map<String, String> _packageToBrand = {
    // 🛍️ SHOPPING / FASHION
    'com.amazon.mShop': 'amazon',
    'com.flipkart.android': 'flipkart',
    'com.myntra.android': 'myntra',
    'com.meesho.supply': 'meesho',
    'com.shopsy.app': 'shopsy',
    'com.ajio.android': 'ajio',
    'com.nykaa.app': 'nykaa',
    'com.nykaa.fashion': 'nykaa fashion',
    'com.lenskart.app': 'lenskart',
    'com.purplle.android': 'purplle',
    'com.zivame.consumer': 'zivame',
    'com.inditex.zara': 'zara',
    'com.westside.app': 'westside',
    'com.tira.beauty': 'tira',
    'com.savana.app': 'savana',

    // 🛒 GROCERY / QUICK COMMERCE
    'com.bigbasket.mobileapp': 'bigbasket',
    'com.bigbasket.bbinstant': 'bigbasket',
    'com.zeptoconsumerapp': 'zepto',
    'com.grofers.customerapp': 'blinkit',
    'in.swiggy.android': 'instamart',

    // 🍔 FOOD / TRANSPORT
    'com.application.zomato': 'zomato',
    'com.ubercab': 'uber',
    'com.olacabs.customer': 'ola',
    'com.rapido.passenger': 'rapido',
  };

  /* =========================
     BRAND RESOLUTION (CRITICAL)
     ========================= */

  /// 🔥 EXACT brand user opened (used for notification + filtering)
  static String? brandFromPackage(String packageName) {
    final p = packageName.toLowerCase();

    for (final entry in _packageToBrand.entries) {
      if (p.startsWith(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /* =========================
     CONTEXT (ONLY FOR UI)
     ========================= */

  static AppContext fromPackage(String packageName) {
    final brand = brandFromPackage(packageName);
    if (brand == null) return AppContext.unknown;

    if (_shoppingBrands.contains(brand)) {
      return AppContext.shopping;
    }
    if (_groceryBrands.contains(brand)) {
      return AppContext.grocery;
    }
    if (_foodBrands.contains(brand)) {
      return AppContext.food;
    }

    return AppContext.unknown;
  }

  /* =========================
     BRAND GROUPS
     ========================= */

  static const Set<String> _shoppingBrands = {
    'amazon',
    'flipkart',
    'myntra',
    'meesho',
    'shopsy',
    'ajio',
    'nykaa',
    'nykaa fashion',
    'lenskart',
    'purplle',
    'zivame',
    'zara',
    'westside',
    'tira',
    'savana',
  };

  static const Set<String> _groceryBrands = {
    'bigbasket',
    'zepto',
    'blinkit',
    'instamart',
  };

  static const Set<String> _foodBrands = {
    'zomato',
    'uber',
    'ola',
    'rapido',
  };
}
