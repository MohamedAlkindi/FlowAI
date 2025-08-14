import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/instruction_step.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildInstructionsCard({required AppLocalizations t}) {
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
            const Icon(Icons.help_outline, color: Color(0xFFE94560), size: 48),
            const SizedBox(width: 12),
            Text(
              t.t('how_to_use'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildInstructionStep(t.t('1'), t.t('step_1_t'), t.t('step_1_d')),
        buildInstructionStep(t.t('2'), t.t('step_2_t'), t.t('step_2_d')),
        buildInstructionStep(t.t('3'), t.t('step_3_t'), t.t('step_3_d')),
      ],
    ),
  );
}
