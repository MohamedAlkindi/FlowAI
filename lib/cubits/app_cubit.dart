import 'package:flow_ai/cubits/app_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/preferences_service.dart';

// Cubit
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  Future<void> loadPreferences() async {
    emit(AppLoading());
    try {
      final preferences = await PreferencesService.getUserPreferences();
      emit(AppLoaded(preferences));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> updateAccessibilityStatus(bool isEnabled) async {
    try {
      await PreferencesService.updateAccessibilityStatus(isEnabled);
      final currentState = state;
      if (currentState is AppLoaded) {
        final updatedPreferences = currentState.preferences
            .copyWith(isAccessibilityEnabled: isEnabled);
        emit(AppLoaded(updatedPreferences));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> markFirstLaunchComplete() async {
    try {
      await PreferencesService.markFirstLaunchComplete();
      final currentState = state;
      if (currentState is AppLoaded) {
        final updatedPreferences =
            currentState.preferences.copyWith(isFirstLaunch: false);
        emit(AppLoaded(updatedPreferences));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  Future<void> saveUserTriggers(
      String? prefixTrigger, String? suffixTrigger) async {
    try {
      await PreferencesService.saveUserTriggers(prefixTrigger, suffixTrigger);
      final currentState = state;
      if (currentState is AppLoaded) {
        final updatedPreferences = currentState.preferences.copyWith(
          triggerPrefix: prefixTrigger,
          triggerSuffix: suffixTrigger,
        );
        emit(AppLoaded(updatedPreferences));
      }
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  bool get isFirstLaunch {
    final currentState = state;
    if (currentState is AppLoaded) {
      return currentState.preferences.isFirstLaunch;
    }
    return true;
  }

  bool get isAccessibilityEnabled {
    final currentState = state;
    if (currentState is AppLoaded) {
      return currentState.preferences.isAccessibilityEnabled;
    }
    return false;
  }
}
