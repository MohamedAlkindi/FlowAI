import 'dart:io';
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_state.dart';
import 'package:flow_ai/services/preferences_service.dart';
import 'package:flow_ai/utils/accessibility_utils.dart';
import 'package:flow_ai/utils/trigger_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenCubit extends Cubit<GotHomeScreenData> {
  HomeScreenCubit()
    : super(
        GotHomeScreenData(
          isAccessibilityEnabled: false,
          oemBrand: '',
          hasOverlayPermission: false,
          showOverlayDialog: false,
        ),
      );
  String? prefixTrigger;
  String? suffixTrigger;

  static const MethodChannel _channel = MethodChannel('flow_ai/platform');
  static const EventChannel _accessibilityEventChannel = EventChannel(
    'flow_ai/accessibility_status',
  );
  static const EventChannel _overlayEventChannel = EventChannel(
    'flow_ai/overlay_status',
  );

  StreamSubscription? _accessibilitySub;
  StreamSubscription? _overlaySub;

  Future<void> checkOverlayPermission(BuildContext context) async {
    try {
      final hasPermission =
          await _channel.invokeMethod('checkOverlayPermission') ?? false;
      emit(
        state.copyWith(
          hasOverlayPermission: hasPermission,
          showOverlayDialog: !hasPermission,
        ),
      );
    } catch (_) {}
  }

  Future<void> requestOverlayPermission(BuildContext context) async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        await checkOverlayPermission(context);
      }
    } catch (_) {}
  }

  void dismissOverlayDialog() {
    PreferencesService.markDialogDismissed();
    emit(state.copyWith(showOverlayDialog: false, isDialogDismissed: true));
  }

  Future<void> refreshStatus(BuildContext context) async {
    final isAccessibilityEnabled =
        await AccessibilityUtils.isAccessibilityServiceEnabled();
    if (context.mounted) {
      checkOverlayPermission(context);
    }
    emit(state.copyWith(isAccessibilityEnabled: isAccessibilityEnabled));
  }

  Future<void> loadOemBrand() async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final manufacturer = (info.manufacturer).toLowerCase();
        final brand = (info.brand).toLowerCase();
        emit(
          state.copyWith(
            oemBrand: manufacturer.isNotEmpty ? manufacturer : brand,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> getTriggers(BuildContext context) async {
    final cubit = context.read<AppCubit>();
    await cubit.loadPreferences();
    final state = cubit.state;
    if (state is AppLoaded) {
      suffixTrigger = state.preferences.triggerSuffix;
      prefixTrigger = state.preferences.triggerPrefix;
    }

    // Tell Kotlin about the triggers when the app, service restarts.
    await TriggerUtil.setTriggers(
      startTrigger: prefixTrigger,
      endTrigger: suffixTrigger,
    );
  }

  Future<void> initMethods(BuildContext context) async {
    await getTriggers(context);
    if (context.mounted) {
      _listenToNativeStatus(context);
      await refreshStatus(context);
    }
    await loadOemBrand();
  }

  void _listenToNativeStatus(BuildContext context) {
    _accessibilitySub?.cancel();
    _overlaySub?.cancel();
    _accessibilitySub = _accessibilityEventChannel
        .receiveBroadcastStream()
        .listen((event) {
          if (event is bool) {
            emit(state.copyWith(isAccessibilityEnabled: event));
          }
        });
    _overlaySub = _overlayEventChannel.receiveBroadcastStream().listen((event) {
      if (event is bool) {
        emit(state.copyWith(hasOverlayPermission: event));
      }
    });
  }

  @override
  Future<void> close() {
    _accessibilitySub?.cancel();
    _overlaySub?.cancel();
    return super.close();
  }
}
