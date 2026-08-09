import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Palette
  static const Color royalBlue = Color(0xFF1565C0);    // Sky Blue (primary)
  static const Color royalPurple = Color(0xFF0D47A1);  // Deep Blue (dark shade)
  static const Color goldAccent = Color(0xFF42A5F5);   // Light Blue Accent

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F9FF);   // Soft Blue-tinted White
  static const Color white = Colors.white;
  static const Color surface = Colors.white;

  // Semantic & UI colors
  static const Color primary = royalBlue;       // #1565C0 Sky Blue
  static const Color secondary = royalPurple;   // #0D47A1 Deep Blue
  static const Color accent = goldAccent;        // #42A5F5 Light Blue

  static const Color black = Color(0xFF212121);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color darkGrey = Color(0xFF546E7A);  // Blue-grey for body text

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
}
