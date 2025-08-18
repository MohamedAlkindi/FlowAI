import 'package:flow_ai/screens/home_screen/cubit/home_screen_cubit.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_state.dart';
import 'package:flow_ai/screens/home_screen/widgets/accessibility_section.dart';
import 'package:flow_ai/screens/home_screen/widgets/instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/oem_instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/status_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/trigger_popup.dart';
import 'package:flow_ai/screens/home_screen/widgets/troubleshooting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeScreenCubit>().initMethods(context);
  }

  @override
  Widget build(BuildContext context) {
    var homeScreenCubit = context.read<HomeScreenCubit>();
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          t.t('app_title'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Refersh button.
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              homeScreenCubit.refreshStatus();
            },
            tooltip: t.t('status_refreshed'),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) => TriggerPopup(
                  currentStart: homeScreenCubit.prefixTrigger ?? "/ai",
                  currentEnd: homeScreenCubit.suffixTrigger ?? "/",
                ),
              );
            },
            tooltip: "Customize Triggers",
            // tooltip: t.t('status_refreshed'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<HomeScreenCubit, GotHomeScreenData>(
              buildWhen: (prev, curr) =>
                  prev.isAccessibilityEnabled != curr.isAccessibilityEnabled,
              builder: (context, state) {
                return buildStatusCard(
                  t: t,
                  isAccessibilityEnabled: state.isAccessibilityEnabled,
                );
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<HomeScreenCubit, GotHomeScreenData>(
              buildWhen: (prev, curr) =>
                  prev.isAccessibilityEnabled != curr.isAccessibilityEnabled,
              builder: (context, state) {
                return buildAccessibilitySection(
                  t: t,
                  isAccessibilityEnabled: state.isAccessibilityEnabled,
                  context: context,
                );
              },
            ),
            const SizedBox(height: 24),
            buildInstructionsCard(t: t),
            const SizedBox(height: 24),
            BlocBuilder<HomeScreenCubit, GotHomeScreenData>(
              builder: (context, state) {
                return buildOemInstructionsCard(
                  t: t,
                  oemBrand: state.oemBrand,
                );
              },
            ),
            const SizedBox(height: 24),
            buildTroubleshootingCard(t: t),
          ],
        ),
      ),
    );
  }
}
