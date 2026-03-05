import 'dart:ui';

/// Brand colors from North Memorial Health Identity Standards v9.7.
/// Source: brand/tokens.json
class AppColors {
  AppColors._();

  // Primary palette
  static const teal = Color(0xFF00B0AD);
  static const orangeRed = Color(0xFFE04726);
  static const gray = Color(0xFF4B4F54);
  static const gold = Color(0xFFFCB526);

  // Secondary palette (must pair with corresponding primary)
  static const darkTeal = Color(0xFF00383D);
  static const darkRed = Color(0xFF60151E);
  static const darkBrown = Color(0xFF762D10);
  static const lightGray = Color(0xFFD6D6D6);

  // Functional colors — Light mode
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F5);
  static const lightTextPrimary = gray;
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightDivider = lightGray;

  // Functional colors — Dark mode
  static const darkBackground = darkTeal;
  static const darkSurface = Color(0xFF0A4A4D);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = lightGray;
  static const darkDivider = Color(0xFF1A5A5D);

  // Semantic colors (same in both modes)
  static const success = teal;
  static const warning = gold;
  static const error = orangeRed;
  static const info = teal;

  // Scope accent colors (jurisdiction theming)
  static const scopeMinnesota = teal;
  static const scopeWisconsin = gold;
  static const scopeAirMedical = orangeRed;
}
