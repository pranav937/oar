import 'package:flutter/material.dart';

class CustomToast {
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green.shade600, Icons.check_circle_outline_rounded);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red.shade500, Icons.error_outline_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFF1E293B), Icons.info_outline_rounded);
  }

  static void _showToast(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: color,
        elevation: 8,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
