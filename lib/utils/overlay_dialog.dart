import 'package:flutter/material.dart';

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
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      content: Text(
        t.t("overlayDisplayPermissionText"),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: Text(
            t.t("later"),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
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
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
