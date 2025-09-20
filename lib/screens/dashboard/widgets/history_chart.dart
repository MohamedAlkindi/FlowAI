import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/dashboard/widgets/history_bar.dart';
import 'package:flutter/material.dart';


class HistoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>>
  history; // each {date: yyyy-MM-dd, request_count: int}
  const HistoryBarChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final data = history.isEmpty ? placeholderHistory() : history;

    if (data.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).t("trend"),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                AppLocalizations.of(context).t("usage_data"),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final maxCount = data.fold<int>(1, (m, e) {
      final c = (e['request_count'] ?? 0) as int;
      return c > m ? c : m;
    }).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).t("trend"),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Column(
                children: [
                  for (int i = 0; i < data.length; i++)
                    Builder(
                      builder: (context) {
                        final item = data[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: width * 0.25,
                                child: Text(
                                  formatDate(item['date'] as String),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              HistoryBar(
                                value: (item['request_count'] ?? 0) as int,
                                max: maxCount,
                                isLast: i == data.length - 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

String formatDate(String dateStr) {
  if (dateStr == "—") return dateStr;
  try {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}'; // DD/MM format
    }
    return dateStr;
  } catch (_) {
    return dateStr;
  }
}

List<Map<String, dynamic>> placeholderHistory() {
  // Return empty list when no real data - chart will show "No data available"
  return [];
}
