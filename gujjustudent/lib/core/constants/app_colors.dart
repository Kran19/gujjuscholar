import 'package:flutter/material.dart';

class AppColors {
  // Modern Vibrant Brand Palette
  static const Color primary = Color(0xFF2563EB);        // Vibrant Electric Blue (Tailwind Blue-600)
  static const Color primaryDark = Color(0xFF1D4ED8);    // Deep Cobalt (Blue-700)
  static const Color primaryLight = Color(0xFFEFF6FF);   // Soft Ice Blue Tint (Blue-50)
  static const Color primaryGradientStart = Color(0xFF3B82F6);
  static const Color primaryGradientEnd = Color(0xFF1D4ED8);

  static const Color secondary = Color(0xFF6366F1);      // Indigo Accent
  static const Color accent = Color(0xFFF59E0B);         // Warm Saffron/Amber
  static const Color accentLight = Color(0xFFFEF3C7);    // Light Amber Tint

  // Backward compatibility aliases
  static const Color royalBlue = primary;
  static const Color royalPurple = primaryDark;
  static const Color goldAccent = accent;

  // Backgrounds & Surfaces (Crisp Slate Theme)
  static const Color background = Color(0xFFF8FAFC);     // Slate-50 (Clean, bright, modern)
  static const Color white = Colors.white;
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color cardSubtle = Color(0xFFF1F5F9);     // Slate-100

  // Crisp Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);         // Slate-200 (Clean 1px stroke)
  static const Color borderSubtle = Color(0xFFF1F5F9);   // Slate-100

  // Modern Typography Neutrals
  static const Color textPrimary = Color(0xFF0F172A);    // Slate-900 (High contrast)
  static const Color textSecondary = Color(0xFF475569);  // Slate-600 (Subtitles)
  static const Color textMuted = Color(0xFF94A3B8);      // Slate-400 (Meta & timestamps)
  
  static const Color black = Color(0xFF0F172A);
  static const Color grey = Color(0xFF94A3B8);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color darkGrey = Color(0xFF475569);

  // Status & Gamification Colors
  static const Color success = Color(0xFF10B981);        // Emerald-500
  static const Color successLight = Color(0xFFECFDF5);   // Emerald-50
  static const Color error = Color(0xFFEF4444);          // Rose-500
  static const Color errorLight = Color(0xFFFEF2F2);     // Rose-50
  static const Color warning = Color(0xFFF59E0B);        // Amber-500
  static const Color info = Color(0xFF06B6D4);           // Cyan-500
}
