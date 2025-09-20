import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/screens/dashboard/widgets/guage_card.dart';
import 'package:flutter/material.dart';


class GaugesRow extends StatelessWidget {
  final DashboardUsage? usage;
  const GaugesRow({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F3460);
    final accent = const Color(0xFFE94560);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 400;
            if (isSmallScreen) {
              return Column(
                children: [
                  Text(
                    AppLocalizations.of(context).t("today_summary"),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 15),
                  AnimatedGaugeCard(
                    title: AppLocalizations.of(context).t("today"),
                    value: (usage?.requestCount ?? 0).toDouble(),
                    max: (usage?.dailyLimit ?? 1).toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    color: accent,
                    bg: bg,
                    caption: '/${usage?.dailyLimit ?? 40000}',
                  ),
                  const SizedBox(height: 16),
                  AnimatedGaugeCard(
                    title: AppLocalizations.of(context).t("minute"),
                    value: (usage?.requestsLastMinute ?? 0).toDouble(),
                    max: (usage?.perMinuteLimit ?? 1).toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    color: Colors.cyanAccent,
                    bg: bg,
                    caption: '/${usage?.perMinuteLimit ?? 4000}',
                  ),
                ],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedGaugeCard(
                    title: AppLocalizations.of(context).t("today"),
                    value: (usage?.requestCount ?? 0).toDouble(),
                    max: (usage?.dailyLimit ?? 1).toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    color: accent,
                    bg: bg,
                    caption: '/${usage?.dailyLimit ?? 0}',
                  ),
                  AnimatedGaugeCard(
                    title: AppLocalizations.of(context).t("minute"),
                    value: (usage?.requestsLastMinute ?? 0).toDouble(),
                    max: (usage?.perMinuteLimit ?? 1).toDouble().clamp(
                      1,
                      double.infinity,
                    ),
                    color: Colors.cyanAccent,
                    bg: bg,
                    caption: '/${usage?.perMinuteLimit ?? 0}',
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
