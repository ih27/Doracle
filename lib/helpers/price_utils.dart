String? convertPrice(String? originalPrice) {
  if (originalPrice != null) {
    // Extract the currency symbol and the numeric value
    RegExp regExp = RegExp(r'^([^\d]+)?([\d.,]+)');
    Match? match = regExp.firstMatch(originalPrice);

    if (match != null) {
      String currencySymbol = match.group(1) ?? '\$';
      String numericPart = match.group(2) ?? '';

      // Remove thousands separators and replace comma with dot for decimal
      numericPart = numericPart.replaceAll(RegExp(r'[^\d.]'), '');

      double price = double.parse(numericPart);

      // Multiply by 5
      double convertedPrice = price * 5;

      // Round down to the nearest 0.X9
      int wholeUnits = convertedPrice.floor();
      int fractionalUnits = ((convertedPrice - wholeUnits) * 100).round();
      fractionalUnits = (fractionalUnits ~/ 10) * 10 + 9;

      // Format the price to always end in .X9
      String formattedPrice =
          '$wholeUnits.${fractionalUnits.toString().padLeft(2, '0')}';

      // Add the original currency symbol back
      return '$currencySymbol$formattedPrice';
    }
  }
  return null;
}
