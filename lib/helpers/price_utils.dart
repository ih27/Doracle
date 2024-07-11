String? convertPrice(String? originalPrice) {
  if (originalPrice != null) {
    // Remove the currency symbol and parse the number
    double price =
        double.parse(originalPrice.replaceAll(RegExp(r'[^\d.]'), ''));

    // Multiply by 5
    double convertedPrice = price * 5;

    // Round down to the nearest 0.X9
    int dollars = convertedPrice.floor();
    int cents = ((convertedPrice - dollars) * 100).round();
    cents = (cents ~/ 10) * 10 + 9;

    // Format the price to always end in .X9
    String formattedPrice = '$dollars.${cents.toString().padLeft(2, '0')}';

    // Add the currency symbol back
    return '\$$formattedPrice';
  }
  return null;
}
