import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flow_ai/cubits/app_cubit.dart';
import 'package:flow_ai/cubits/app_states.dart';
import 'package:flow_ai/screens/home_screen/cubit/home_screen_state.dart';
import 'package:flow_ai/utils/accessibility_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenCubit extends Cubit<GotHomeScreenData> {
  HomeScreenCubit()
      : super(GotHomeScreenData(
          isAccessibilityEnabled: false,
          oemBrand: '',
        ));
  String? prefixTrigger;
  String? suffixTrigger;

  Future<void> refreshStatus() async {
    final enabled = await AccessibilityUtils.isAccessibilityServiceEnabled();
    emit(
      state.copyWith(isAccessibilityEnabled: enabled),
    );
  }

  Future<void> loadOemBrand() async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final manufacturer = (info.manufacturer).toLowerCase();
        final brand = (info.brand).toLowerCase();
        emit(
          state.copyWith(
              oemBrand: manufacturer.isNotEmpty ? manufacturer : brand),
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
  }

  Future<void> initMethods(BuildContext context) async {
    await refreshStatus();
    await loadOemBrand();
    await getTriggers(context);
  }
}
