import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';

class OverlayPermissionDialog extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onDismiss;

  const OverlayPermissionDialog({
    super.key,
    required this.onGrant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: Text(
        t.t("overlayDisplayPermissionTitle"),
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Text(
        t.t("overlayDisplayPermissionText"),
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text(
            t.t("later"),
            style: GoogleFonts.poppins(
              color: const Color(0xFFE94560),
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onGrant,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE94560),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            t.t("grantPermission"),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
