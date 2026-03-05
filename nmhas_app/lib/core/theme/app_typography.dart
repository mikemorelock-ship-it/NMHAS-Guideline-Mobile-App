import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography styles using Montserrat (open-source Gotham alternative).
/// Per brand standards: Gotham Bold → Montserrat Bold (700),
/// Gotham Medium → Montserrat Medium (500), Gotham Book → Montserrat Regular (400),
/// Gotham Light → Montserrat Light (300).
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: textColor,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 20,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: textColor,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: textColor,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: textColor,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w300,
        fontSize: 12,
        color: textColor,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: textColor,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.w300,
        fontSize: 11,
        color: textColor,
      ),
    );
  }
}
