import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/screens/dashboard/widgets/metric_chip.dart';
import 'package:flutter/material.dart';

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
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricChip(
              icon: Icons.calendar_month_rounded,
              value: '40000 ${AppLocalizations.of(context).t("per_day")}',
              color: Colors.cyanAccent,
              bg: const Color(0x3321D4FD),
            ),
            MetricChip(
              icon: Icons.timer,
              value: '4000 ${AppLocalizations.of(context).t("per_minute")}',
              color: Colors.amberAccent,
              bg: const Color(0x33FFC107),
            ),
          ],
        ),
      ],
    );
  }
}
