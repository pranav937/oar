import 'package:flutter/material.dart';

class OtrTheme {
  static const Color darkNavy = Color(0xFF0F172A); // Rich navy for deep contrast
  static const Color primaryBlue = Color(0xFF0066FF); // Corporate ERP Blue
  static const Color mediumBlue = Color(0xFF3B82F6); // Vibrant accent blue
  static const Color lightBlue = Color(0xFFEFF6FF); // Very soft blue for card backgrounds
  static const Color background = Color(0xFFF8FAFC); // Clean, modern slate-tinted white
  static const Color surface = Color(0xFFFFFFFF); // Pure white for cards
  
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}
