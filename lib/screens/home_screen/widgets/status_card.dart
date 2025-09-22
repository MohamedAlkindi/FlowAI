import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/utils/accessibility_utils.dart';
import 'package:flow_ai/utils/friendly_error.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flutter/material.dart';

Widget buildStatusCard({
  required AppLocalizations t,
  required bool isAccessibilityEnabled,
  required BuildContext context,
  required bool hasOverlayPermission,
  required VoidCallback onRequestOverlayPermission,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          size: 40, // Reduced from 48
          color: isAccessibilityEnabled
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE94560),
        ),
        const SizedBox(height: 12), // Reduced from 16
        Text(
          isAccessibilityEnabled
              ? t.t('status_active')
              : t.t('status_inactive'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Text(
          isAccessibilityEnabled ? t.t('status_ready') : t.t('status_enable'),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFD6D6D6), // Approximate Colors.grey[300]
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16), // Reduced from 20
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await AccessibilityUtils.openAccessibilitySettings();
                if (context.mounted) {
                  showSnackBar(t.t('open_settings'), context: context);
                }
              } catch (e) {
                if (context.mounted) {
                  showSnackBar(friendlyError(e), error: true, context: context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isAccessibilityEnabled
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ), // Reduced from 16
            ),
            child: Text(
              isAccessibilityEnabled
                  ? t.t('manage_in_settings')
                  : t.t('enable_service'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (isAccessibilityEnabled) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRequestOverlayPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasOverlayPermission
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                hasOverlayPermission
                    ? t.t("permissionGranted")
                    : t.t("grantBubblePermission"),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
