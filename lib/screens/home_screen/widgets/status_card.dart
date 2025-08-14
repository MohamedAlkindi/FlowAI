import 'package:flow_ai/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildStatusCard({
  required AppLocalizations t,
  required bool isAccessibilityEnabled,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF16213E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isAccessibilityEnabled
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE94560),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Icon(
          isAccessibilityEnabled ? Icons.check_circle : Icons.warning,
          size: 48,
          color: isAccessibilityEnabled
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE94560),
        ),
        const SizedBox(height: 16),
        Text(
          isAccessibilityEnabled
              ? t.t('status_active')
              : t.t('status_inactive'),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAccessibilityEnabled ? t.t('status_ready') : t.t('status_enable'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
