class AppContextService {
  static String? detectContext(String packageName) {
    final p = packageName.toLowerCase();

    if (p.contains('amazon')) {
      return 'shopping_amazon';
    }

    if (p.contains('flipkart')) {
      return 'shopping_flipkart';
    }

    if (p.contains('meesho') || p.contains('myntra')) {
      return 'shopping_fashion';
    }

    if (p.contains('zomato') || p.contains('swiggy')) {
      return 'food_ordering';
    }

    return null; // ignore everything else
  }
}