String detectBrand(String title, String code) {
  final text = (title + code).toLowerCase();

  if (text.contains('amazon')) return 'amazon';
  if (text.contains('flipkart')) return 'flipkart';
  if (text.contains('zomato')) return 'zomato';
  if (text.contains('swiggy')) return 'swiggy';
  if (text.contains('myntra')) return 'myntra';

  return 'generic';
}

String detectCategory(String brand) {
  switch (brand) {
    case 'amazon':
    case 'flipkart':
    case 'myntra':
      return 'Shopping';
    case 'zomato':
    case 'swiggy':
      return 'Food';
    default:
      return 'Other';
  }
}