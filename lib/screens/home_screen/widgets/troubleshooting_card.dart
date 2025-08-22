import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/home_screen/widgets/cards_title_widget.dart';
import 'package:flow_ai/screens/home_screen/widgets/steps_widget.dart';
import 'package:flutter/material.dart';

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
        cardTitleRow(
          icon: Icons.build_outlined,
          cardTitle: t.t('troubleshooting_title'),
        ),
        const SizedBox(height: 12),
        buildStepsWidget(t.t('1'), t.t('ts_issue_1_t'), t.t('ts_issue_1_d')),
        buildStepsWidget(t.t('2'), t.t('ts_issue_2_t'), t.t('ts_issue_2_d')),
        buildStepsWidget(t.t('3'), t.t('ts_issue_3_t'), t.t('ts_issue_3_d')),
        buildStepsWidget(t.t('4'), t.t('ts_issue_4_t'), t.t('ts_issue_4_d')),
        buildStepsWidget(t.t('5'), t.t('ts_issue_5_t'), t.t('ts_issue_5_d')),
      ],
    ),
  );
}
