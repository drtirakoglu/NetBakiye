import 'package:flutter/material.dart';

class AppColors {
  // Deep Dark Backgrounds
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF21262D);

  // Accents (Teal -> Cyan Gradient)
  static const Color primary = Color(0xFF2EA043); // Success green
  static const Color accentStart = Color(0xFF0DBCB5);
  static const Color accentEnd = Color(0xFF00D2FF);

  // Functional Colors
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFF87171);
  static const Color success = Color(0xFF4ADE80);
  static const Color info = Color(0xFF60A5FA);

  // Text Colors
  static const Color textPrimary = Color(0xFFC9D1D9);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
