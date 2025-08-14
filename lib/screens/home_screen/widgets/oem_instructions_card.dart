import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/instruction_step.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildOemInstructionsCard({
  required AppLocalizations t,
  required String? oemBrand,
}) {
  final isXiaomi = (oemBrand ?? '').contains('xiaomi') ||
      (oemBrand ?? '').contains('redmi') ||
      (oemBrand ?? '').contains('mi');
  final isSamsung = (oemBrand ?? '').contains('samsung');

  final showAll = oemBrand == null || (!isXiaomi && !isSamsung);

  final List<Widget> sections = [];

  if (showAll || isXiaomi) {
    sections.addAll([
      Row(
        children: [
          const Icon(Icons.phone_android, color: Color(0xFFE94560), size: 28),
          const SizedBox(width: 8),
          Text(
            t.t('xiaomi_heading'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      buildInstructionStep(
          t.t('1'), t.t('xiaomi_step_1_t'), t.t('xiaomi_step_1_d')),
      buildInstructionStep(
          t.t('2'), t.t('xiaomi_step_2_t'), t.t('xiaomi_step_2_d')),
      buildInstructionStep(
          t.t('3'), t.t('xiaomi_step_3_t'), t.t('xiaomi_step_3_d')),
      const SizedBox(height: 16),
    ]);
  }

  if (showAll || isSamsung) {
    sections.addAll([
      Row(
        children: [
          const Icon(Icons.phone_iphone, color: Color(0xFFE94560), size: 28),
          const SizedBox(width: 8),
          Text(
            t.t('samsung_heading'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      buildInstructionStep(
          t.t('1'), t.t('samsung_step_1_t'), t.t('samsung_step_1_d')),
      buildInstructionStep(
          t.t('2'), t.t('samsung_step_2_t'), t.t('samsung_step_2_d')),
      buildInstructionStep(
          t.t('3'), t.t('samsung_step_3_t'), t.t('samsung_step_3_d')),
    ]);
  }

  if (sections.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF16213E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_outlined,
                color: Color(0xFFE94560), size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.t('oem_card_title'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sections,
        if (showAll) ...[
          const SizedBox(height: 8),
          Text(
            t.t('oem_unknown_hint'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
        ],
      ],
    ),
  );
}
