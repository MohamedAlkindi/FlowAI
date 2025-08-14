import 'package:flow_ai/utils/friendly_error.dart';
import 'package:flutter/material.dart';

void showSnackBar(
  String message, {
  bool error = false,
  required BuildContext context,
}) {
  final text = friendlyError(message);
  final bg = error ? const Color(0xFFB00020) : const Color(0xFF0F3460);
  final icon = error ? Icons.error_outline : Icons.check_circle_outline;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
