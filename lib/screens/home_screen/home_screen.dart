import 'package:flow_ai/screens/home_screen/cubit/home_screen_cubit.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_state.dart';
import 'package:flow_ai/screens/home_screen/widgets/instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/oem_instructions_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/status_card.dart';
import 'package:flow_ai/screens/home_screen/widgets/trigger_popup.dart';
import 'package:flow_ai/screens/home_screen/widgets/troubleshooting_card.dart';
import 'package:flow_ai/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import '../../l10n/l10n.dart';
import 'package:flow_ai/utils/overlay_dialog.dart';

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
    context.read<HomeScreenCubit>().checkOverlayPermission(context);
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            homeScreenCubit.refreshStatus(context);
            if (context.mounted) {
              showSnackBar(
                t.t("status_refreshed"),
                context: context,
              );
            }
          },
          child: BlocBuilder<HomeScreenCubit, GotHomeScreenData>(
            builder: (context, state) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStatusCard(
                          t: t,
                          isAccessibilityEnabled: state.isAccessibilityEnabled,
                          context: context,
                          hasOverlayPermission: state.hasOverlayPermission,
                          onRequestOverlayPermission: () =>
                              homeScreenCubit.requestOverlayPermission(context),
                        ),
                        const SizedBox(height: 24),
                        buildOemInstructionsCard(
                          t: t,
                          oemBrand: state.oemBrand,
                        ),
                        const SizedBox(height: 24),
                        buildInstructionsCard(t: t),
                        const SizedBox(height: 24),
                        buildTroubleshootingCard(t: t),
                      ],
                    ),
                  ),
                  if (state.showOverlayDialog && !state.isDialogDismissed) ...[
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.black45,
                    ),
                    Center(
                      child: OverlayPermissionDialog(
                        onGrant: () =>
                            homeScreenCubit.requestOverlayPermission(context),
                        onDismiss: () => homeScreenCubit.dismissOverlayDialog(),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
