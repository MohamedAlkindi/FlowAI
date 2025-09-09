import 'package:flow_ai/l10n/l10n.dart';
import 'package:flow_ai/screens/dashboard/cubit/dashboard_cubit.dart';
import 'package:flow_ai/screens/dashboard/widgets/gradient_card.dart';
import 'package:flow_ai/screens/dashboard/widgets/guage_row.dart';
import 'package:flow_ai/screens/dashboard/widgets/header_metrics.dart';
import 'package:flow_ai/screens/dashboard/widgets/history_chart.dart';
import 'package:flow_ai/screens/dashboard/widgets/recent_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadData();
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
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is UsageDataState) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                GradientCard(
                  gradient: LinearGradient(
                    colors: [grad1, grad2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: HeaderMetrics(usage: state.usageData),
                ),
                const SizedBox(height: 20),
                GradientCard(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF16213E), grad1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: GaugesRow(usage: state.usageData),
                ),
                const SizedBox(height: 20),
                GradientCard(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF16213E), grad1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: HistoryBarChart(history: state.usageHistory),
                ),
                const SizedBox(height: 20),
                GradientCard(
                  gradient: LinearGradient(
                    colors: [grad2, const Color(0xFF16213E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: RecentSection(usage: state.usageData),
                ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
