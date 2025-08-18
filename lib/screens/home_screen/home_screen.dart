import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
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
import '../../utils/accessibility_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAccessibilityEnabled = false;
  String? _oemBrand;
  String? _prefixTrigger;
  String? _suffixTrigger;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _loadOemBrand();
    _getTriggers();
  }

  Future<void> _refreshStatus() async {
    final enabled = await AccessibilityUtils.isAccessibilityServiceEnabled();
    if (enabled == true) {
      setState(() => _isAccessibilityEnabled = enabled);
    }
  }

  Future<void> _loadOemBrand() async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final manufacturer = (info.manufacturer).toLowerCase();
        final brand = (info.brand).toLowerCase();
        setState(() {
          _oemBrand = manufacturer.isNotEmpty ? manufacturer : brand;
        });
      }
    } catch (_) {}
  }

  Future<void> _getTriggers() async {
    final cubit = context.read<AppCubit>();
    await cubit.loadPreferences();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final state = cubit.state;
    if (state is AppLoaded) {
      _suffixTrigger = state.preferences.triggerSuffix;
      _prefixTrigger = state.preferences.triggerPrefix;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              await _refreshStatus();
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
                  currentStart: _prefixTrigger ?? "/ai",
                  currentEnd: _suffixTrigger ?? "/",
                  cubit: context.read<AppCubit>(),
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
            buildStatusCard(
              t: t,
              isAccessibilityEnabled: _isAccessibilityEnabled,
            ),
            const SizedBox(height: 24),
            buildAccessibilitySection(
              t: t,
              isAccessibilityEnabled: _isAccessibilityEnabled,
              context: context,
            ),
            const SizedBox(height: 24),
            buildInstructionsCard(t: t),
            const SizedBox(height: 24),
            buildOemInstructionsCard(t: t, oemBrand: _oemBrand),
            const SizedBox(height: 24),
            buildTroubleshootingCard(t: t),
          ],
        ),
      ),
    );
  }
}
