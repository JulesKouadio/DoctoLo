import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - DoctoLo Brand Colors #5FCDD9
  static const Color primary = Color(0xFF5FCDD9); // Couleur principale (dark)
  static const Color primaryLight = Color(0xFFA4ECFC); // Couleur light
  static const Color primaryDark = Color(0xFF3DB5E8);

  // Secondary Colors (Vert médical)
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryLight = Color(0xFF80E27E);
  static const Color secondaryDark = Color(0xFF087F23);

  // Accent Colors
  static const Color accent = Color(0xFF65CDF6);
  static const Color accentLight = Color(0xFFA4ECFC);
  static const Color accentDark = Color(0xFF3DB5E8);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Appointment Status Colors
  static const Color appointmentPending = Color(0xFFFF9800);
  static const Color appointmentConfirmed = Color(0xFF4CAF50);
  static const Color appointmentCancelled = Color(0xFFF44336);
  static const Color appointmentCompleted = Color(0xFF9E9E9E);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
}
