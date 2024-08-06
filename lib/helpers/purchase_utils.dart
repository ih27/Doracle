import 'package:flutter/material.dart';
import 'constants.dart';

String? convertPrice(String? originalPrice) {
  if (originalPrice == null) return null;

  RegExp regExp = RegExp(r'^([^\d]+)?([\d.,]+)');
  Match? match = regExp.firstMatch(originalPrice);

  if (match != null) {
    String currencySymbol = match.group(1) ?? '';
    String numericPart = match.group(2) ?? '';

    // Determine the decimal separator used in the original price
    String decimalSeparator = numericPart.contains(',') ? ',' : '.';

    // Replace the decimal separator with a dot for parsing
    numericPart = numericPart.replaceAll(',', '.');

    double price = double.parse(numericPart);
    double convertedPrice = price * 5;

    int wholeUnits = (convertedPrice ~/ 10) * 10; // Round down to nearest 10
    int fractionalUnits = 99; // Always .99

    // Format the price using the original decimal separator
    String formattedPrice =
        '$wholeUnits$decimalSeparator${fractionalUnits.toString().padLeft(2, '0')}';

    return '$currencySymbol$formattedPrice';
  }
  return null;
}

String? convertAnnualToMonthly(String? annualPrice) {
  if (annualPrice == null) return null;

  RegExp regExp = RegExp(r'^([^\d]+)?([\d.,]+)');
  Match? match = regExp.firstMatch(annualPrice);

  if (match != null) {
    String currencySymbol = match.group(1) ?? '';
    String numericPart = match.group(2) ?? '';

    // Determine the decimal separator used in the original price
    String decimalSeparator = numericPart.contains(',') ? ',' : '.';

    // Replace the decimal separator with a dot for parsing
    numericPart = numericPart.replaceAll(',', '.');

    double price = double.parse(numericPart);
    double monthlyPrice = price / 12;

    // Round down to two decimal places
    int cents = (monthlyPrice * 100).floor();

    // If the last digit is not 9, replace it with 9
    if (cents % 10 != 9) {
      cents = (cents ~/ 10) * 10 + 9;
    }

    double finalPrice = cents / 100;

    // Format the price using the original decimal separator
    String formattedPrice =
        finalPrice.toStringAsFixed(2).replaceAll('.', decimalSeparator);

    return '$currencySymbol$formattedPrice';
  }
  return null;
}

void showCustomOverlay<T>({
  required BuildContext context,
  required Widget Function(BuildContext, VoidCallback) overlayBuilder,
  required double heightFactor,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    pageBuilder: (BuildContext dialogContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.95,
            height: MediaQuery.of(dialogContext).size.height * heightFactor,
            child: overlayBuilder(
              dialogContext,
              () => Navigator.of(dialogContext).pop(),
            ),
          ),
        ),
      );
    },
    transitionDuration: FortuneConstants.iapPopupDelay,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: child,
        ),
      );
    },
  );
}
