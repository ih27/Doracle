import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: getColorFromHex("#507583"),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: getColorFromHex("4F507583"),
      ),
      scaffoldBackgroundColor: getColorFromHex("#fbf9f5"),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        buttonColor: getColorFromHex("#507583"),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: getColorFromHex("#507583"),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.robotoMono(fontSize: 72.0, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.roboto(fontSize: 36.0),
        bodyMedium: GoogleFonts.roboto(fontSize: 14.0),
        bodyLarge: GoogleFonts.robotoMono(fontSize: 16.0, letterSpacing: 0),
      ),
    );
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}