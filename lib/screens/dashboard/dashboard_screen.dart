import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/models/dashboard_usage.dart';
import 'package:flow_ai/screens/dashboard/widgets/gradient_card.dart';
import 'package:flow_ai/screens/dashboard/widgets/guage_row.dart';
import 'package:flow_ai/screens/dashboard/widgets/header_metrics.dart';
import 'package:flow_ai/screens/dashboard/widgets/history_chart.dart';
import 'package:flow_ai/screens/dashboard/widgets/recent_section.dart';
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
              GradientCard(
                gradient: LinearGradient(
                  colors: [grad1, grad2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: HeaderMetrics(usage: _usage),
              ),
              const SizedBox(height: 20),
              GradientCard(
                gradient: LinearGradient(
                  colors: [const Color(0xFF16213E), grad1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: GaugesRow(usage: _usage),
              ),
              const SizedBox(height: 20),
              GradientCard(
                gradient: LinearGradient(
                  colors: [const Color(0xFF16213E), grad1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: HistoryBarChart(history: _history),
              ),
              const SizedBox(height: 20),
              GradientCard(
                gradient: LinearGradient(
                  colors: [grad2, const Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: RecentSection(usage: _usage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
