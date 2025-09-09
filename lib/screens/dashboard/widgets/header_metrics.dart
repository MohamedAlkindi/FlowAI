import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/screens/dashboard/widgets/metric_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderMetrics extends StatelessWidget {
  final DashboardUsage? usage;
  const HeaderMetrics({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).t("usage_restrictions"),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricChip(
              icon: Icons.shield,
              label: AppLocalizations.of(context).t("daily_limit"),
              value: '40000',
              color: Colors.cyanAccent,
              bg: const Color(0x3321D4FD),
            ),
            MetricChip(
              icon: Icons.timer,
              label: AppLocalizations.of(context).t("last_minute"),
              value: '4000',
              color: Colors.amberAccent,
              bg: const Color(0x33FFC107),
            ),
          ],
        ),
      ],
    );
  }
}
