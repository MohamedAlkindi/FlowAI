import 'package:flutter/services.dart';

class AccessibilityUtils {
  static const MethodChannel _channel = MethodChannel('flow_ai/platform');

  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      final bool enabled =
          await _channel.invokeMethod('isAccessibilityServiceEnabled');
      return enabled;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  static String getAccessibilityServiceName() {
    return 'FlowAI Accessibility Service';
  }

  static String getAccessibilityServiceDescription() {
    return 'This service monitors text input fields to detect /ai commands and provide AI-powered text generation.';
  }
}
