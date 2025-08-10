import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';

class PreferencesService {
  static const String _preferencesKey = 'user_preferences';

  static Future<UserPreferences> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);

    if (preferencesJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(preferencesJson);
        return UserPreferences.fromJson(json);
      } catch (e) {
        return UserPreferences();
      }
    }

    return UserPreferences();
  }

  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = jsonEncode(preferences.toJson());
    await prefs.setString(_preferencesKey, preferencesJson);
  }

  static Future<void> updateAccessibilityStatus(bool isEnabled) async {
    final preferences = await getUserPreferences();
    final updatedPreferences =
        preferences.copyWith(isAccessibilityEnabled: isEnabled);
    await saveUserPreferences(updatedPreferences);
  }

  static Future<void> markFirstLaunchComplete() async {
    final preferences = await getUserPreferences();
    final updatedPreferences = preferences.copyWith(isFirstLaunch: false);
    await saveUserPreferences(updatedPreferences);
  }
}
