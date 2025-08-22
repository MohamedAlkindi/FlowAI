import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/cards_title_widget.dart';
import 'package:flow_ai/screens/home_screen/widgets/steps_widget.dart';
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
    sections.addAll(showXiaomiInstructions(t: t));
  }

  if (showAll || isSamsung) {
    sections.addAll(showSamsungInstructions(t: t));
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
        cardTitleRow(
          icon: Icons.warning_amber_outlined,
          cardTitle: t.t('oem_card_title'),
        ),
        const SizedBox(height: 12),
        ...sections,
        if (showAll) ...[
          const SizedBox(height: 8),
          Text(
            t.t('oem_unknown_hint'),
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    ),
  );
}

Widget showInstructionsRow(String oemManufacture) {
  return Row(
    children: [
      const Icon(Icons.phone_android, color: Color(0xFFE94560), size: 24),
      const SizedBox(width: 8),
      Text(
        oemManufacture,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ],
  );
}

Iterable<Widget> showXiaomiInstructions({required AppLocalizations t}) {
  return [
    showInstructionsRow(t.t('xiaomi_heading')),
    const SizedBox(height: 10),
    buildStepsWidget(t.t('1'), t.t('xiaomi_step_1_t'), t.t('xiaomi_step_1_d')),
    buildStepsWidget(t.t('2'), t.t('xiaomi_step_2_t'), t.t('xiaomi_step_2_d')),
    buildStepsWidget(t.t('3'), t.t('xiaomi_step_3_t'), t.t('xiaomi_step_3_d')),
    const SizedBox(height: 16),
  ];
}

Iterable<Widget> showSamsungInstructions({required AppLocalizations t}) {
  return [
    showInstructionsRow(t.t('samsung_heading')),
    const SizedBox(height: 10),
    buildStepsWidget(
        t.t('1'), t.t('samsung_step_1_t'), t.t('samsung_step_1_d')),
    buildStepsWidget(
        t.t('2'), t.t('samsung_step_2_t'), t.t('samsung_step_2_d')),
    buildStepsWidget(
        t.t('3'), t.t('samsung_step_3_t'), t.t('samsung_step_3_d')),
  ];
}
