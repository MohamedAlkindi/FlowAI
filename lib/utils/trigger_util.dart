import 'package:flutter/services.dart';

class TriggerUtil {
  static const MethodChannel _channel = MethodChannel('flow_ai/platform');

  static Future<void> setTriggers({
    String? startTrigger,
    String? endTrigger,
  }) async {
    try {
      await _channel.invokeMethod("setTriggers", {
        "startTrigger": startTrigger,
        "endTrigger": endTrigger,
      });
    } on PlatformException catch (_) {}
  }
}
