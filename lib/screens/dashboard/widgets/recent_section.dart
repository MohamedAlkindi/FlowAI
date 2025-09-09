import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/screens/dashboard/widgets/recent_section_row.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentSection extends StatelessWidget {
  final DashboardUsage? usage;
  const RecentSection({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0F3460);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).t("recent_activity"),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RowValue(
                icon: Icons.calendar_month,
                label: AppLocalizations.of(context).t("last_request_date"),
                value: usage?.lastRequestDate ?? '-',
              ),
              const SizedBox(height: 8),
              RowValue(
                icon: Icons.schedule,
                label: AppLocalizations.of(context).t("last_request_time"),
                value: formatTimeOnly(usage?.lastRequestMinute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String formatTimeOnly(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final localDt = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(localDt.hour)}:${two(localDt.minute)}';
  } catch (_) {
    return '-';
  }
}
