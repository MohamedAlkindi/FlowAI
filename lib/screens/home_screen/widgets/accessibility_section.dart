import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/utils/accessibility_utils.dart';
import 'package:flow_ai/utils/friendly_error.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildAccessibilitySection({
  required AppLocalizations t,
  required bool isAccessibilityEnabled,
  required BuildContext context,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF16213E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Column(
          children: [
            const Icon(
              Icons.accessibility,
              color: Color(0xFFE94560),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              t.t('accessibility'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          t.t('accessibility_desc'),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await AccessibilityUtils.openAccessibilitySettings();
                if (context.mounted) {
                  showSnackBar(
                    t.t('open_settings'),
                    context: context,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(
                    friendlyError(e),
                    error: true,
                    context: context,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccessibilityEnabled
                  ? const Color(0xFFE94560)
                  : const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isAccessibilityEnabled
                  ? t.t('manage_in_settings')
                  : t.t('enable_service'),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
