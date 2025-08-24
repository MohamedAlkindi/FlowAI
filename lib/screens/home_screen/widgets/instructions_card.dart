import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/cards_title_widget.dart';
import 'package:flow_ai/screens/home_screen/widgets/steps_widget.dart';
import 'package:flutter/material.dart';

Widget buildInstructionsCard({required AppLocalizations t}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF16213E),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cardTitleRow(
          icon: Icons.help_outline,
          cardTitle: t.t('how_to_use'),
        ),
        const SizedBox(height: 12), // Reduced from 16
        buildStepsWidget(t.t('1'), t.t('step_1_t'), t.t('step_1_d')),
        buildStepsWidget(t.t('2'), t.t('step_2_t'), t.t('step_2_d')),
        buildStepsWidget(t.t('3'), t.t('step_3_t'), t.t('step_3_d')),
        buildStepsWidget('4', 'Grant Overlay Permission',
            'Go to Settings > Apps > FlowAI > Permissions > Display over other apps and enable it. This allows the AI bubble to appear over other apps.'),
        buildStepsWidget('5', 'Use the AI Bubble',
            'Type your trigger (e.g., /ai your prompt /) in any app. The AI bubble will appear, showing your prompt, the AI result, and Apply/Cancel/Redo buttons.'),
      ],
    ),
  );
}
