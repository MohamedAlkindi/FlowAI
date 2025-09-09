import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flow_ai/services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  DashboardUsage? _usage;
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  List<Map<String, dynamic>> _history = const [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await DashboardService.getSavedUsage();
    final hist = await DashboardService.getUsageHistory();
    if (!mounted) return;
    setState(() {
      _usage = data;
      _history = hist;
    });
  }

  @override
  Widget build(BuildContext context) {
    final grad1 = const Color(0xFF0F3460);
    final grad2 = const Color(0xFF1A1A2E);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).t("usage_dashboard"),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FadeTransition(
          opacity: _fadeIn,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _GradientCard(
                gradient: LinearGradient(
                  colors: [grad1, grad2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: _HeaderMetrics(usage: _usage),
              ),
              const SizedBox(height: 20),
              _GradientCard(
                gradient: LinearGradient(
                  colors: [const Color(0xFF16213E), grad1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: _GaugesRow(usage: _usage),
              ),
              const SizedBox(height: 20),
              _GradientCard(
                gradient: LinearGradient(
                  colors: [const Color(0xFF16213E), grad1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: _HistoryBarChart(history: _history),
              ),
              const SizedBox(height: 20),
              _GradientCard(
                gradient: LinearGradient(
                  colors: [grad2, const Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: _RecentSection(usage: _usage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;

  const _GradientCard({required this.child, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _HeaderMetrics extends StatelessWidget {
  final DashboardUsage? usage;
  const _HeaderMetrics({required this.usage});

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
            _MetricChip(
              icon: Icons.shield,
              label: AppLocalizations.of(context).t("daily_limit"),
              value: '40000',
              color: Colors.cyanAccent,
              bg: const Color(0x3321D4FD),
            ),
            _MetricChip(
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

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugesRow extends StatelessWidget {
  final DashboardUsage? usage;
  const _GaugesRow({required this.usage});

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
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _AnimatedGaugeCard(
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
                  _AnimatedGaugeCard(
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
                  _AnimatedGaugeCard(
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
                  _AnimatedGaugeCard(
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

class _AnimatedGaugeCard extends StatefulWidget {
  final String title;
  final double value;
  final double max;
  final Color color;
  final Color bg;
  final String caption;

  const _AnimatedGaugeCard({
    required this.title,
    required this.value,
    required this.max,
    required this.color,
    required this.bg,
    required this.caption,
  });

  @override
  State<_AnimatedGaugeCard> createState() => _AnimatedGaugeCardState();
}

class _AnimatedGaugeCardState extends State<_AnimatedGaugeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _anim = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.value / (widget.max == 0 ? 1 : widget.max))
        .clamp(0, 1.0)
        .toDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 0
            ? (constraints.maxWidth * 0.6).clamp(120.0, 180.0)
            : 160.0;
        final gaugeSize = (cardWidth * 0.6).clamp(70.0, 100.0);

        return Container(
          width: cardWidth,
          height: 180,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ScaleTransition(
                scale: _anim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: gaugeSize,
                      height: gaugeSize,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Text(
                      '${widget.value.toInt()}${widget.caption}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentSection extends StatelessWidget {
  final DashboardUsage? usage;
  const _RecentSection({required this.usage});

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
              _RowValue(
                icon: Icons.calendar_month,
                label: AppLocalizations.of(context).t("last_request_date"),
                value: usage?.lastRequestDate ?? '-',
              ),
              const SizedBox(height: 8),
              _RowValue(
                icon: Icons.schedule,
                label: AppLocalizations.of(context).t("last_request_time"),
                value: _formatTimeOnly(usage?.lastRequestMinute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RowValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RowValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),

            Text(
              label,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatTimeOnly(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';
    final localDt = dt.toLocal();
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(localDt.hour)}:${two(localDt.minute)}';
  } catch (_) {
    return '-';
  }
}

class _HistoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>>
  history; // each {date: yyyy-MM-dd, request_count: int}
  const _HistoryBarChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final data = history.isEmpty ? _placeholderHistory() : history;

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
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                AppLocalizations.of(context).t("usage_data"),
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                                  _formatDate(item['date'] as String),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              _Bar(
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

  String _formatDate(String dateStr) {
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

  List<Map<String, dynamic>> _placeholderHistory() {
    // Return empty list when no real data - chart will show "No data available"
    return [];
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final double max;
  final bool isLast;
  const _Bar({required this.value, required this.max, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final pct = (value / (max == 0 ? 1 : max)).clamp(0, 1.0);
    return Expanded(
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white12,
        ),
        child: Stack(
          children: [
            // Background bar
            Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white12,
              ),
            ),
            // Progress bar
            FractionallySizedBox(
              widthFactor: pct.toDouble(),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: isLast
                        ? [const Color(0xFFE94560), const Color(0xFFFF6B6B)]
                        : [const Color(0xFF0F3460), const Color(0xFF1A1A2E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isLast
                                  ? const Color(0xFFE94560)
                                  : const Color(0xFF0F3460))
                              .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Value text
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$value',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
