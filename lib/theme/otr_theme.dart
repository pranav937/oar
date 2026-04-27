import 'package:flutter/material.dart';

class OtrTheme {
  // Brand Colors - Government Professional Palette
  static const Color darkNavy = Color(0xFF001A33);    // Midnight Navy
  static const Color primaryBlue = Color(0xFF003366); // Deep National Blue
  static const Color mediumBlue = Color(0xFF0055A4);  // Formal Blue
  static const Color lightBlue = Color(0xFFE6F0FF);   // Very Light Blue Tint
  static const Color background = Color(0xFFF2F5F8);  // Professional Light Gray
  static const Color surface = Color(0xFFFFFFFF);     // Pure White

  // Status Colors
  static const Color success = Color(0xFF1B5E20);     // Deep Green
  static const Color warning = Color(0xFFE65100);     // Deep Orange
  static const Color error = Color(0xFFB71C1C);       // Deep Red
  static const Color info = Color(0xFF01579B);        // Deep Blue Info

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF004080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkNavy, Color(0xFF002244)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color dividerColor = Color(0xFFE2E8F0);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0xFF001A33).withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> intenseShadow = [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
