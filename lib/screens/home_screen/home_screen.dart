import 'package:flow_ai/screens/home_screen/cubit/home_screen_cubit.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_state.dart';
import 'package:flow_ai/screens/home_screen/widgets/instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/oem_instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/status_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/trigger_popup.dart';
import 'package:flow_ai/screens/home_screen/widgets/troubleshooting_card.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasOverlayPermission = false;
  static const MethodChannel _channel = MethodChannel('flow_ai/platform');

  @override
  void initState() {
    super.initState();
    context.read<HomeScreenCubit>().initMethods(context);
    _checkOverlayPermission();
  }

  Future<void> _checkOverlayPermission() async {
    try {
      final hasPermission =
          await _channel.invokeMethod('checkOverlayPermission') ?? false;
      setState(() {
        _hasOverlayPermission = hasPermission;
      });

      // Show permission request dialog if not granted
      if (!hasPermission && mounted) {
        _showOverlayPermissionDialog();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
      // Recheck after user returns from settings
      await Future.delayed(const Duration(milliseconds: 500));
      await _checkOverlayPermission();
    } catch (e) {
      // Handle error
    }
  }

  void _showOverlayPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          AppLocalizations.of(context).t("overlayDisplayPermissionTitle"),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          AppLocalizations.of(context).t("overlayDisplayPermissionText"),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context).t("later"),
              style: GoogleFonts.poppins(
                color: const Color(0xFFE94560),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestOverlayPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).t("grantPermission"),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
              await homeScreenCubit.refreshStatus();
              if (context.mounted) {
                showSnackBar(
                  t.t("status_refreshed"),
                  context: context,
                );
              }
            },
            tooltip: t.t('refresh_status'),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (ctx) => TriggerPopup(
                  currentStart: homeScreenCubit.prefixTrigger!.isEmpty
                      ? "/ai"
                      : homeScreenCubit.prefixTrigger!,
                  currentEnd: homeScreenCubit.suffixTrigger!.isEmpty
                      ? "/"
                      : homeScreenCubit.suffixTrigger!,
                ),
              );
            },
            tooltip: t.t("customize_triggers"),
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
                  context: context,
                  hasOverlayPermission: _hasOverlayPermission,
                  onRequestOverlayPermission: _requestOverlayPermission,
                );
              },
            ),
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
            buildInstructionsCard(t: t),
            const SizedBox(height: 24),
            buildTroubleshootingCard(t: t),
          ],
        ),
      ),
    );
  }
}
