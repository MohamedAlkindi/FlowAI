import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/instruction_step.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTroubleshootingCard({required AppLocalizations t}) {
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
            const Icon(Icons.build_outlined,
                color: Color(0xFFE94560), size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t.t('troubleshooting_title'),
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
        buildInstructionStep(
            t.t('1'), t.t('ts_issue_1_t'), t.t('ts_issue_1_d')),
        buildInstructionStep(
            t.t('2'), t.t('ts_issue_2_t'), t.t('ts_issue_2_d')),
        buildInstructionStep(
            t.t('3'), t.t('ts_issue_3_t'), t.t('ts_issue_3_d')),
        buildInstructionStep(
            t.t('4'), t.t('ts_issue_4_t'), t.t('ts_issue_4_d')),
        buildInstructionStep(
            t.t('5'), t.t('ts_issue_5_t'), t.t('ts_issue_5_d')),
      ],
    ),
  );
}
