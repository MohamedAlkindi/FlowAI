import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flow_ai/screens/home_screen/widgets/accessibility_section.dart';
import 'package:flow_ai/screens/home_screen/widgets/instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/oem_instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/result_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/status_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/troubleshooting_card.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
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
  final _promptController = TextEditingController();
  String? _functionResult;
  String? _oemBrand;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _loadOemBrand();
  }

  Future<void> _refreshStatus() async {
    final enabled = await AccessibilityUtils.isAccessibilityServiceEnabled();
    setState(() => _isAccessibilityEnabled = enabled);
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _refreshStatus();
              showSnackBar(
                t.t('status_refreshed'),
                context: context,
              );
            },
            tooltip: t.t('status_refreshed'),
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
            if (_functionResult != null) ...[
              const SizedBox(height: 16),
              buildResultCard(text: _functionResult!),
            ],
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

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
