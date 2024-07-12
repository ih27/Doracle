import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF507382);
  static const Color secondaryColor = Color(0xFF18aa99);
  static const Color tertiaryColor = Color(0xFF728163);
  static const Color alternateColor = Color(0xFFdede8f);

  // Utility Colors
  static const Color primaryText = Color(0xFF101518);
  static const Color secondaryText = Color(0xFF57636c);
  static const Color primaryBackground = Color(0xFFfbf9f5);
  static const Color secondaryBackground = Color(0xFFffffff);

  // Accent Colors
  static const Color accent1 = Color(0x4f507583);
  static const Color accent2 = Color(0x4d18aa99);
  static const Color accent3 = Color(0x4d928163);
  static const Color accent4 = Color(0xb2ffffff);

  // Semantic Colors
  static const Color success = Color(0xFF16857b);
  static const Color error = Color(0xFFc4454d);
  static const Color warning = Color(0xFFf3c344);
  static const Color info = Color(0xFFffffff);

  // Custom Colors
  static const Color yaleBlue = Color(0xFF0d3b66);
  static const Color lemonChiffon = Color(0xFFfaf0ca);
  static const Color naplesYellow = Color(0xFFf4d35e);
  static const Color sandyBrown = Color(0xFFee964b);
  static const Color tomato = Color(0xFFf95738);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF507583),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0x4F507583),
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
        displayLarge: GoogleFonts.roboto(fontSize: 52.0, fontWeight: FontWeight.w300, color: AppTheme.primaryText),
        displayMedium: GoogleFonts.roboto(fontSize: 44.0, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
        displaySmall: GoogleFonts.roboto(fontSize: 36.0, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
        headlineLarge: GoogleFonts.roboto(fontSize: 32.0, color: AppTheme.primaryText),
        headlineMedium: GoogleFonts.roboto(fontSize: 28.0, color: AppTheme.primaryText),
        headlineSmall: GoogleFonts.roboto(fontSize: 24.0, color: AppTheme.primaryText),
        titleLarge: GoogleFonts.roboto(fontSize: 22.0, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
        titleMedium: GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.w500, color: AppTheme.info),
        titleSmall: GoogleFonts.roboto(fontSize: 16.0, fontWeight: FontWeight.w500, color: AppTheme.info),
        bodyLarge: GoogleFonts.roboto(fontSize: 16.0, color: AppTheme.primaryText),
        bodyMedium: GoogleFonts.roboto(fontSize: 14.0, color: AppTheme.primaryText),
        bodySmall: GoogleFonts.roboto(fontSize: 12.0, color: AppTheme.primaryText),
        labelMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
            letterSpacing: 0),
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
