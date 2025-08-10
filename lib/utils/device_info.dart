import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  static Future<String> getDeviceId() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        // Compose a reasonably stable ID
        final parts = <String>[
          info.id,
          info.hardware,
          info.product,
        ].where((e) => e.isNotEmpty).toList();
        if (parts.isNotEmpty) return parts.join('-');
        return 'unknown_device';
      }

      return 'unknown_device';
    } catch (_) {
      return 'unknown_device';
    }
  }
}
